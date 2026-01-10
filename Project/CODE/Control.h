/*
 * Control.h
 *
 *  Created on: 2025年9月29日
 *      Author: CYM
 */

#ifndef CODE_CONTROL_H_
#define CODE_CONTROL_H_
#include "headfile.h"
/* 任务类型枚举 */
typedef enum
{
    task1_xunji = 0,             // 巡线任务（主线任务）
    task_loop_gyro = 1,        // 陀螺仪环路（姿态稳定）
    task_loop_speed = 2,       // 速度环任务（速度闭环）
    task_loop_direction = 3,   // 方向环任务（方向闭环）
    task_hardware_test = 4,    // 硬件测试模式
	  task_Encoder_test,
	  task_Motor_test,
	  task_ADC_test,
    task_clear ,            // 清除/重置任务

} Task_t;

typedef enum
{
    Init_xunji = 0, 
    Init_Encoder ,  
    Init_Motor ,    
    Init_ADC , 
		Init_imu,
} Init_t;

typedef struct
{
    uint8 in_angle_flag;
    uint8 in_angle_cnt;
    uint16 in_angle_encoder;

    uint8 out_angle_flag;
    uint8 out_angle_cnt;
    uint16 out_angle_encoder;

    uint8 in_island_flag;
    uint8 in_island_cnt;
    uint16 in_island_encoder;
    uint8 island_dir;           /* 圆环方向: 0=左环, 1=右环 */
    uint8 island_stage;         /* 入环阶段: 0=未开始, 1=打角中, 2=完成 */
    uint32 island_start_encoder; /* 入环起始编码器值 */

    uint8 out_island_flag;
    uint8 out_island_cnt;
    uint16 out_island_encoder;
    uint8 out_island_stage;     /* 出环阶段 */
    uint32 out_island_start_encoder;

} Flag_t;
extern Flag_t element_Flag;
//====================================================配置区（按需调整）====================================================
//默认模式
#define CURRENTINIT Init_xunji
#define CURRENTMODEL task1_xunji

#define STEER_SEGMENTS 3  //分段数目
/* 默认控制周期（ms） */
#define G_DT_MS 10

/* 舵机角度限制（根据你的舵机物理极限设定） */
#define G_Servo_Min_Angle 500
#define G_Servo_Max_Angle 1100

/* 默认速度（正为前进） */
#define G_Base_Speed 1900

/* motor 输出限幅（与 Motor_SetSpeedAndDir 协议一致） */
#define G_Motor_Speed_max 4000
#define G_Motor_Speed_min 50 /* 可为负表示反转 */

/*赛道总长*/
#define TOTAL_Distance 200000.0

/*元素判断的全局变量*/
extern float meas_L;
extern float meas_R;
extern float steer_u;
#define IN_ISLAND_ENCODER_MAX 10000
#define OUT_ISLAND_ENCODER_MAX 10000
#define IN_ANGLE_ENCODER_MAX 10000
#define OUT_ANGLE_ENCODER_MAX 10000
//====================================================可调用区====================================================
//====================================================控制 基础函数====================================================
void Control_Init(void);       //初始化控制模块（传入控制周期 ms）
void Control_SetBaseSpeed(int base_speed);    //设置基准巡航速度（unit：与你 Motor_SetSpeedAndDir 接口一致的速度单位）
void Control_Update(void);                    //在固定周期 (ctrl_dt_ms) 调用，读取全局 ADC 和编码器数据进行控制
void Control_Reset(void);                     //可选：重置控制器状态
//====================================================控制 基础函数====================================================
void apply_servo_angle(float angle);
//void apply_motor_output(int8 dir,int32 uL, int32 uR);
//====================================================已有任务函数====================================================
void Excute_xunji(void);
void Excute_Init_xunji(uint32 ctrl_dt_ms);

void Excute_Init_Encoder(void);
void Excute_Encoder_test(void);

void Excute_Init_Motor(void);
void Excute_Motor_test(void);

void Excute_Init_ADC(void);
void Excute_ADC_test(void);

void imu_init(void);
void Excute_imu_test(float target_w);

void Control_InitModel(Task_t task);
void Control_model(Init_t init_task);
void Excute_in_island(void);
void Excute_out_island(void);
#endif /* CODE_CONTROL_H_ */
