/*
 * Motor.h
 *
 *  Created on: 2025年9月27日
 *      Author: CYM
 */

#ifndef CODE_MOTOR_H_
#define CODE_MOTOR_H_

#include "headfile.h"
#define MotorL_PWM          PWMA_CH4N_P33
#define MotorR_PWM          PWMA_CH3N_P65
#define MotorL_TurnGPIO    	P63
#define MotorR_TurnGPIO     P45

#define MotorL_Dir					P32
#define MotorR_Dir    			P13
#define MotorL_Decode				CTIM4_P06
#define MotorR_Decode				CTIM3_P04

typedef struct motor
{
        uint32 Target_Speed;
        int16 Encoder_Raw;
        float Encoder_Speed;
        float Total_Encoder;
}motor;


//====================================================电机驱动 基础函数====================================================
void Motor_Init(void);
void MotorL_SetSpeedAndDir(int8 dir, int32 speed);
void MotorR_SetSpeedAndDir(int8 dir, int32 speed);
void Motor_Stop(void);
//====================================================电机驱动 基础函数====================================================

//====================================================编码器 基础函数====================================================
	void Encoder_Init(void);
	void Encoder_Date_Get(void);
//====================================================编码器 基础函数====================================================
#endif /* CODE_MOTOR_H_ */
