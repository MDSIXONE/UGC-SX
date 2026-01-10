/*
 * Servo.c
 *
 *  Created on: 2025年9月29日
 *      Author: Administrator
 */


#include "Servo.h"   // 头文件根据你用的编译器和库改

#define PWM_FREQUENCY    50  // PWM频率50Hz (舵机标准)
#define MIN_PULSE_WIDTH  500 // 0度对应的脉冲宽度(us)
#define MAX_PULSE_WIDTH 2500 // 180度对应的脉冲宽度(us)
#define SERVO_PWM_PIN PWMB_CH2_P01

void Servo_Init()
{
    pwm_init(SERVO_PWM_PIN, PWM_FREQUENCY,815);
}

// 设置舵机角度（占空比值，范围400-1200）
void Servo_SetAngle(float angle)
{
    uint32 duty;
    
    // 限幅保护，防止float转uint32时出现异常值
    if (angle < 500.0f) angle = 500.0f;
    if (angle > 1100.0f) angle = 1100.0f;
    
    duty = (uint32)angle;
    pwm_duty(SERVO_PWM_PIN, duty);
}
