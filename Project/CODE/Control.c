/*
 * Control.c
 *
 *  Created on: 2025年9月29日
 *      Author:
 */


#include "headfile.h"
/*全局变量*/
extern ADC_inductance ADC;
extern float measured_w;
float meas_L;
float meas_R;
Flag_t element_Flag ={0};
float tgt_L;
float tgt_R;
float steer_u;

float w_error;
float  steer_angle;
float err_servo;

float temp_angle;
int16 dat = 0;
//默认模式
Task_t CurrentModel = CURRENTMODEL;
Init_t CurrentInit  = CURRENTINIT;
//分段数目
/* 默认控制周期（ms） */
uint32 g_dt_ms = G_DT_MS;

int g_servo_min_angle = G_Servo_Min_Angle;
int g_servo_max_angle = G_Servo_Max_Angle;

int g_base_speed = G_Base_Speed;
int g_motor_speed_max = G_Motor_Speed_max;
int g_motor_speed_min = G_Motor_Speed_min;
float Total_Distance = TOTAL_Distance;

/* 舵机分段 PID：将 ADC_Err 映射到舵机角度*/

typedef struct {
    float err_max_abs; /* 该段最大绝对误差阈值 */
    PID_t pid;         /* 位置式 PID（setpoint=0, measurement=err） */
} SteerSeg_t;

//创建三个SteerSeg_t 结构体
SteerSeg_t g_steer_seg[STEER_SEGMENTS];

SteerSeg_t *seg;  // 声明为指针
/* 串级电机控制：
   外环：位置式 PID (输入 ADC_Err -> 输出 delta_speed)
   内环：速度式 PID (输入 target_speed, measurement encoder_speed -> 输出 Δu)
*/
PID_t g_motor_outer_pid; /* 位置式，输出：速度差（signed） */
PID_t g_motor_inner_L;   /* 速度式（增量式）用于左电机 */
PID_t g_motor_inner_R;   /* 速度式（增量式）用于右电机 */
PID_t PID_w;
PID_t PID_servo;
extern  motor Motor_L;
extern  motor Motor_R;
/* 内环累加控制量 */
float g_ctrl_u_L = 0.0f;
float g_ctrl_u_R = 0.0f;

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     根据err_abs选择分段PID
// 参数说明     err_abs  误差值
// 返回参数     SteerSeg_t*
// 使用示例     select_steer_seg(4) 当前ADC计算后返回的误差的绝对值为4
// 备注信息     将PID分成了STEER_SEGMENTS段，每段都有一个err阈值（err_max_abs），未超过该阈值则使用该段PID，超过则使用下一段PID
//-------------------------------------------------------------------------------------------------------------------
static SteerSeg_t* select_steer_seg(float err_abs)
{
    int i;
    /* 判断当前误差属于哪个分段 */
    for (i = 0; i < STEER_SEGMENTS; ++i) {
        if (err_abs <= g_steer_seg[i].err_max_abs) return &g_steer_seg[i];
    }
    /* 索引是长度-1 */
    return &g_steer_seg[STEER_SEGMENTS - 1];
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     设置舵机角度（限幅）
// 参数说明     angle ：需要的舵机角度
// 返回参数     void
// 使用示例     apply_servo_angle(30) 设置电机角度为30度
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void apply_servo_angle(float angle)
{
    if (angle < g_servo_min_angle) angle = g_servo_min_angle;
    if (angle > g_servo_max_angle) angle = g_servo_max_angle;
//    temp_angle = angle;
    Servo_SetAngle(angle);
}

/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     控制初始化
 * 参数说明     ctrl_dt_ms  控制周期
 * 返回参数     void
 * 使用示例     Control_Init(10) 中断10ms控制一次
 * 备注信息     该函数会初始化所有需要的设备，并且定义所有的PID参数
 *-------------------------------------------------------------------------------------------------------------------*/
void Excute_Init_xunji(uint32 ctrl_dt_ms)
{
    g_dt_ms = (ctrl_dt_ms == 0) ? 20u : ctrl_dt_ms;

    Servo_Init();
    Motor_Init();
    Encoder_Init();
    ADCinductance_init();

    /* 舵机分段 PID 参数 */
    /* 输出限幅为相对于中心位置(815)的偏移量: 500-815=-315, 1100-815=285 */
    PID_Init(&g_steer_seg[0].pid, 0.5f, 0.0f, 0.0f, -315.0f, 285.0f, g_dt_ms);
    g_steer_seg[0].err_max_abs = 35.0f;

    PID_Init(&g_steer_seg[1].pid, 0.0f, 0.0f, 0.0f, -315.0f, 285.0f, g_dt_ms);
    g_steer_seg[1].err_max_abs = 60.0f;

    PID_Init(&g_steer_seg[2].pid, 0.0f, 0.0f, 0.0f, -315.0f, 285.0f, g_dt_ms);
    g_steer_seg[2].err_max_abs = 900.0f;

    /* 串级电机 PID 参数 */
    PID_Init(&g_motor_outer_pid, 5.5f, 0.0f, 0.0f, -(float)g_motor_speed_max, (float)g_motor_speed_max, g_dt_ms);
    PID_Init(&g_motor_inner_L, 0.1f, 0.0f, 0.000f, -5000.0f, 5000.0f, g_dt_ms);
    PID_Init(&g_motor_inner_R, 0.1f, 0.0f, 0.000f, -5000.0f, 5000.0f, g_dt_ms);

    g_ctrl_u_L = 0.0f;
    g_ctrl_u_R = 0.0f;

    /* 角速度环 PID */
    PID_Init(&PID_w, 1.0f, 0, 0, 0.0f, 1000.f, g_dt_ms);
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     设置电机初始前进速度
// 参数说明     base_speed 速度（默认200 ，最大9999）
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Control_SetBaseSpeed(int base_speed)
{
    g_base_speed = base_speed;
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     清除所有内部值
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Control_Reset(void)
{
    /* 清除内部状态（积分、累加等） */
    int i;
    
    for (i = 0; i < STEER_SEGMENTS; ++i) {
        g_steer_seg[i].pid.integ = 0.0f;
        g_steer_seg[i].pid.prev_err = 0.0f;
        g_steer_seg[i].pid.prev_deriv = 0.0f;
    }
    g_motor_outer_pid.integ = 0.0f;
    g_motor_outer_pid.prev_err = 0.0f;
    g_motor_outer_pid.prev_deriv = 0.0f;

    g_motor_inner_L.integ = 0.0f;
    g_motor_inner_L.prev_err = 0.0f;
    g_motor_inner_L.prev_deriv = 0.0f;
    g_motor_inner_R.integ = 0.0f;
    g_motor_inner_R.prev_err = 0.0f;
    g_motor_inner_R.prev_deriv = 0.0f;

    g_ctrl_u_L = 0.0f;
    g_ctrl_u_R = 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     执行任务选择
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Control_model(Init_t init_task)
{
    switch(init_task)
    {
			case task1_xunji          :Excute_xunji();break;
			case task_loop_direction  :break;
			case task_hardware_test   :break;
			case task_Encoder_test    :Excute_Encoder_test();break;
			case task_Motor_test      :Excute_Motor_test();break;
			case task_ADC_test        :Excute_ADC_test();break;
			case task_clear           :break;
			default:
					//打印报错
					break;
    }
}


//-------------------------------------------------------------------------------------------------------------------
// 函数简介     初始化任务选择
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Control_InitModel(Task_t task)
{
    switch(task)
    {
        case Init_xunji           :Excute_Init_xunji(5u);break;
				case Init_Encoder         :Excute_Init_Encoder();break;
        case Init_Motor           :Excute_Init_Motor();break;
			  case Init_ADC   				  :Excute_Init_ADC();break;
				default:
            //打印报错
            break;
    }
}
void Control_Init(void)
{
   Control_InitModel(CurrentInit);
}
//-------------------------------------------------------------------------------------------------------------------
// 函数简介     更新控制
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息     在定时器或 RTOS 任务以固定周期调用（与 Control_Init 的 dt 相同）
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Control_Update(void)
{
    Control_model(CurrentModel);
}




/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     循迹任务
 * 参数说明
 * 返回参数
 * 使用示例
 * 备注信息
 *-------------------------------------------------------------------------------------------------------------------*/
void Excute_xunji(void)
{
    float delta_speed;

    /* 获取电磁数据 */
    read_AD();
    err_servo = ADC.ADC_Err;

    /* 读取编码器 */
    Encoder_Date_Get();
    meas_L = 112.12f * Motor_L.Encoder_Raw + 292.05f;
    meas_R = 112.12f * Motor_R.Encoder_Raw + 292.05f;

    /* 判断是否跑完赛道 */
    if ((Motor_L.Total_Encoder + Motor_R.Total_Encoder) >= Total_Distance)
    {
        MotorL_SetSpeedAndDir(1, 0);
        MotorR_SetSpeedAndDir(1, 0);
        return;
    }

    /* 元素判断 */
    isRingDetected();

    if (element_Flag.in_island_flag)
    {
        Excute_in_island();
    }
    if (element_Flag.out_island_flag)
    {
        Excute_out_island();
    }

    /* 舵机控制：分段 PID */
    seg = select_steer_seg(fabs(err_servo));
    steer_u = PID_Update_Position(&seg->pid, 0.0f, err_servo);
    steer_angle = 815 + steer_u;
    apply_servo_angle(steer_angle);

    /* 电机串级控制 */
    delta_speed = PID_Update_Position(&g_motor_outer_pid, 0.0f, err_servo);

    tgt_L = (float)g_base_speed - delta_speed * 3;
    tgt_R = (float)g_base_speed + delta_speed * 3;
    g_ctrl_u_L = tgt_L;
    g_ctrl_u_R = tgt_R;

    if (g_ctrl_u_L > 5000)
    {
        g_ctrl_u_L = 0;
    }
    else if (g_ctrl_u_L < 0)
    {
        g_ctrl_u_L = 500;
    }
    if (g_ctrl_u_R > 5000)
    {
        g_ctrl_u_R = 0;
    }
    else if (g_ctrl_u_R < 0)
    {
        g_ctrl_u_R = 500;
    }

    MotorL_SetSpeedAndDir(1, g_ctrl_u_L);
    MotorR_SetSpeedAndDir(1, g_ctrl_u_R);
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     入环初始化
// 参数说明     pid与陀螺仪的初始化
// 返回参数			无
// 使用示例	
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
	void imu_init(void)
	{
		imu660ra_init();
	}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     环岛任务
// 参数说明			获取环岛任务角速度并计算环岛所需要的pid数值
// 返回参数			w_error
// 使用示例				
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Excute_imu_test(float target_w)
{
    float filter_w;
    static float previous_w = 0.0f;
    filter_w = Lower_filter(previous_w, measured_w, 0.85f);
    previous_w = filter_w;
    w_error = PID_Update_Velocity(&PID_w,target_w,filter_w);
}
//-------------------------------------------------------------------------------------------------------------------
// 函数简介     编码器初始化任务
// 参数说明			
// 返回参数			无
// 使用示例				
// 备注信息     初始化板载串口和编码所使用到的定时器计数口
//-------------------------------------------------------------------------------------------------------------------
void Excute_Init_Encoder(void)
{
	dat =  0;
	ctimer_count_init(CTIM0_P34);
}

/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     编码器测试任务
 * 参数说明
 * 返回参数     无
 * 使用示例
 * 备注信息     读取编码器是否有数据，读取CTIM0_P34的计数值
 *-------------------------------------------------------------------------------------------------------------------*/
void Excute_Encoder_test(void)
{
    dat = ctimer_count_read(CTIM0_P34);
}


//-------------------------------------------------------------------------------------------------------------------
// 函数简介     电机初始化任务
// 参数说明			
// 返回参数			
// 使用示例				
// 备注信息     初始化电机驱动口
//-------------------------------------------------------------------------------------------------------------------
void Excute_Init_Motor(void)
{
	Motor_Init();
}



//-------------------------------------------------------------------------------------------------------------------
// 函数简介     电机测试任务
// 参数说明			
// 返回参数			
// 使用示例				
// 备注信息     电机直接转
//-------------------------------------------------------------------------------------------------------------------


void Excute_Motor_test(void)
{
	    /* 限幅 */
    if (g_base_speed > (int32)g_motor_speed_max) g_base_speed = (int32)g_motor_speed_max;
    if (g_base_speed < (int32)G_Motor_Speed_min) g_base_speed = (int32)g_motor_speed_min;
    MotorL_SetSpeedAndDir(1, g_base_speed);
    MotorR_SetSpeedAndDir(1, g_base_speed);

}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     电磁初始化任务
// 参数说明			
// 返回参数			
// 使用示例				
// 备注信息     初始化电磁口
//-------------------------------------------------------------------------------------------------------------------


void Excute_Init_ADC(void)
{
	
	ADCinductance_init();

}



//-------------------------------------------------------------------------------------------------------------------
// 函数简介     电磁测试任务
// 参数说明			
// 返回参数			
// 使用示例				
// 备注信息     显示电磁在串口上
//-------------------------------------------------------------------------------------------------------------------

void Excute_ADC_test(void)
{
    float err1, err2, err3, err4;

    err1 = ADC.ADC1;
    err2 = ADC.ADC2;
    err3 = ADC.ADC3;
    err4 = ADC.ADC4;
    printf("err1 = %f,err2 = %f,err3 = %f,err4 = %f", err1, err2, err3, err4);
    delay_ms(100);
}

/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     入环执行
 * 参数说明     无
 * 返回参数     无
 * 备注信息     检测到圆环后舵机打角到该侧极限，编码器累计35000后恢复巡线
 *-------------------------------------------------------------------------------------------------------------------*/
#define ISLAND_ENCODER_THRESHOLD  35000  /* 入环编码器阈值，可调参 */
#define ISLAND_SPEED              1000   /* 入环速度 */

void Excute_in_island(void)
{
    uint32 current_encoder;
    uint32 encoder_diff;
    float target_angle;

    current_encoder = (uint32)(Motor_L.Total_Encoder + Motor_R.Total_Encoder);

    /* 阶段0: 刚检测到入环，记录起始编码器值 */
    if (element_Flag.island_stage == 0)
    {
        element_Flag.island_start_encoder = current_encoder;
        element_Flag.island_stage = 1;
    }

    /* 阶段1: 打角行驶 */
    if (element_Flag.island_stage == 1)
    {
        /* 根据圆环方向选择舵机打角方向 */
        if (element_Flag.island_dir == 0)
        {
            /* 左环：舵机打到左极限 */
            target_angle = (float)g_servo_min_angle;
        }
        else
        {
            /* 右环：舵机打到右极限 */
            target_angle = (float)g_servo_max_angle;
        }

        apply_servo_angle(target_angle);
        MotorL_SetSpeedAndDir(1, ISLAND_SPEED);
        MotorR_SetSpeedAndDir(1, ISLAND_SPEED);

        /* 计算编码器差值 */
        encoder_diff = current_encoder - element_Flag.island_start_encoder;

        /* 达到阈值后恢复巡线 */
        if (encoder_diff >= ISLAND_ENCODER_THRESHOLD)
        {
            element_Flag.island_stage = 0;
            element_Flag.in_island_flag = 0;
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     出环执行
// 参数说明     无
// 返回参数     无
// 备注信息     出环时舵机打角，编码器累计后恢复巡线
//-------------------------------------------------------------------------------------------------------------------
#define OUT_ISLAND_ENCODER_TH  35000  /* 出环编码器阈值 */
#define OUT_ISLAND_SPEED       1000   /* 出环速度 */

void Excute_out_island(void)
{
    uint32 current_encoder;
    uint32 encoder_diff;
    float target_angle;

    current_encoder = (uint32)(Motor_L.Total_Encoder + Motor_R.Total_Encoder);

    /* 阶段0: 刚检测到出环，记录起始编码器值 */
    if (element_Flag.out_island_stage == 0)
    {
        element_Flag.out_island_start_encoder = current_encoder;
        element_Flag.out_island_stage = 1;
    }

    /* 阶段1: 打角行驶 */
    if (element_Flag.out_island_stage == 1)
    {
        /* 出环方向与入环相反 */
        if (element_Flag.island_dir == 0)
        {
            /* 左环出环：舵机打到右侧 */
            target_angle = (float)g_servo_max_angle;
        }
        else
        {
            /* 右环出环：舵机打到左侧 */
            target_angle = (float)g_servo_min_angle;
        }

        apply_servo_angle(target_angle);
        MotorL_SetSpeedAndDir(1, OUT_ISLAND_SPEED);
        MotorR_SetSpeedAndDir(1, OUT_ISLAND_SPEED);

        /* 计算编码器差值 */
        encoder_diff = current_encoder - element_Flag.out_island_start_encoder;

        /* 达到阈值后恢复巡线 */
        if (encoder_diff >= OUT_ISLAND_ENCODER_TH)
        {
            element_Flag.out_island_stage = 0;
            element_Flag.out_island_flag = 0;
        }
    }
}