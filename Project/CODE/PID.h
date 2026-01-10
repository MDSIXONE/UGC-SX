/*
 * PID.h
 *
 *  Created on: 2025年9月29日
 *      Author: CYM
 */

#ifndef PID_H
#define PID_H

#include "headfile.h"

typedef struct {
    float kp;
    float ki;
    float kd;
    float out_min;
    float out_max;

    /* internal states */
    float integ;       /* 积分累计 */
    float prev_err;    /* 上次误差 */
    float prev_deriv;  /* 上次导数（用于滤波/增量式） */
    uint32 dt_ms;    /* 采样周期(ms) */
} PID_t;

//====================================================PID 基础函数====================================================
void PID_Init(PID_t *p, float kp, float ki, float kd, float out_min, float out_max, uint32 dt_ms);    //初始化 PID（并清零状态）

float PID_Update_Position(PID_t *p, float setpoint, float measurement);                                 //位置式 PID：返回控制量 u（带积分防饱和）

float PID_Update_Velocity(PID_t *p, float setpoint, float measurement);                                 //速度式（增量式）PID：返回 Δu（增量），调用者需累加并限幅
//====================================================PID 基础函数====================================================
float Lower_filter(float current_value,float previous_filtered,float Alpha);
#endif /* CODE_PID_H_ */
