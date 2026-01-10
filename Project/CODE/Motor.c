/*
 * Motor.c
 *
 *  Created on: 2025年9月27日
 *      Author: CYM
 */
#include "Motor.h"

motor Motor_L;
motor Motor_R;
//-------------------------------------------------------------------------------------------------------------------
// 函数简介     电机初始化
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Motor_Init(void)
{		
		gpio_mode(MotorL_TurnGPIO,GPO_PP);
		gpio_mode(MotorR_TurnGPIO,GPO_PP);
    pwm_init(MotorL_PWM, 10000, 0);
    pwm_init(MotorR_PWM, 10000, 0);
		Motor_L.Total_Encoder = 0;
		Motor_R.Total_Encoder = 0;
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     设置左电机速度
// 参数说明     dir         方向 1为正，0为负
// 参数说明     speed         速度(最高为9999)
// 返回参数     void
// 使用示例     MotorL_SetSpeedAndDir(1, 780);// 设置左电机正向，速度为780
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void MotorL_SetSpeedAndDir(int8 dir, int32 speed)
{
    if(speed > 9999 || dir > 1)  //速度限幅
    {
        speed = 3000;
        Motor_L.Target_Speed = speed;
        return;
    }
    if( dir == 1 )  //判断正反转
    {
        
        pwm_duty(MotorL_PWM, speed);//正转
				Motor_L.Target_Speed = speed;
		}
		if(dir == 0)
		{
				 pwm_duty(MotorL_PWM, 0);//停车
		}
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     设置右电机速度
// 参数说明     dir         方向 1为正，0为负
// 参数说明     speed         速度
// 返回参数     void
// 使用示例     MotorR_SetSpeedAndDir(1, 780);// 设置右电机正向，速度为780
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void MotorR_SetSpeedAndDir(int8 dir, int32 speed)
{
    if(speed > 9999 || dir > 1)  //速度限幅
    {
        speed = 3000;
        Motor_R.Target_Speed = speed;
        return;
    }
    if( dir == 1 )  //判断正反转
    {
        pwm_duty(MotorR_PWM, speed);    //正转
    }
    else
    {
        pwm_duty(MotorR_PWM, speed * -1);
    }
    Motor_R.Target_Speed = speed;

}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     失能电机
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Motor_Stop(void)
{
    pwm_duty(MotorL_PWM, 0);
    pwm_duty(MotorR_PWM, 0);
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     编码器初始化
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Encoder_Init(void)
{
    //左编码器
		ctimer_count_init(MotorL_Decode);
    //右编码器
    ctimer_count_init(MotorR_Decode);
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     更新编码器数值
// 参数说明
// 返回参数     void
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------
void Encoder_Date_Get(void)
{
    
	if(MotorL_Dir == 1)
		{
		Motor_L.Encoder_Raw = ctimer_count_read(MotorL_Decode) * -1;
		}
		else
		{
		Motor_L.Encoder_Raw = ctimer_count_read(MotorL_Decode);
		}
		ctimer_count_clean(MotorL_Decode);
    Motor_L.Encoder_Speed=Motor_L.Encoder_Raw*0.8 + Motor_L.Encoder_Speed*0.2;
		Motor_L.Total_Encoder+=Motor_L.Encoder_Raw;

	if(MotorR_Dir == 1)
		{
		Motor_R.Encoder_Raw = ctimer_count_read(MotorR_Decode);
		}
		else
		{
		Motor_R.Encoder_Raw = ctimer_count_read(MotorR_Decode) * -1;
		}
		ctimer_count_clean(MotorR_Decode);
    Motor_R.Encoder_Speed=Motor_R.Encoder_Raw*0.8 + Motor_R.Encoder_Speed*0.2;
		Motor_R.Total_Encoder+=Motor_R.Encoder_Raw;
}