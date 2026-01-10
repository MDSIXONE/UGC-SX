/*
 * PID.c
 *
 *  Created on: 2025年9月29日
 *      Author: CYM
 */

#include "PID.h"

#ifndef EPS_F
#define EPS_F 1e-6f
#endif

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     PID初始化
// 参数说明     PID_t *p 对应闭环系统的结构体
// 返回参数     void
// 使用示例
// 备注信息     将结构体里对应的参数赋值
//-------------------------------------------------------------------------------------------------------------------
void PID_Init(PID_t *p, float kp, float ki, float kd, float out_min, float out_max, uint32 dt_ms)
{
    if (!p) return;
    p->kp = kp;
    p->ki = ki;
    p->kd = kd;
    p->out_min = out_min;
    p->out_max = out_max;
    p->integ = 0.0f;
    p->prev_err = 0.0f;
    p->prev_deriv = 0.0f;
    p->dt_ms = (dt_ms == 0) ? 1 : dt_ms;
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     位置式 PID
// 参数说明     setpoint 目标值
// 参数说明     measurement 测量值
// 返回参数     float
// 使用示例
// 备注信息     直接输出控制量
//-------------------------------------------------------------------------------------------------------------------
float PID_Update_Position(PID_t *p, float setpoint, float measurement)
{
    float dt;
    float err;
    float up;
    float deriv;
    float ud;
    float u;

    if (!p)
        return 0;

    dt = (float)p->dt_ms * 0.001f;
    if (dt <= EPS_F)
        dt = EPS_F;

    err = setpoint - measurement;

    /* P */
    up = p->kp * err;

    /* I */
    p->integ += p->ki * err * dt;

    /* D (差分近似) */
    deriv = (err - p->prev_err) / dt;
    ud = p->kd * deriv;

    /* 合成 */
    u = up + p->integ + ud;

    /* 输出限幅 + 积分反向修正（防积分风up）*/
    if (u > p->out_max)
    {
        if (p->ki * err * dt > 0.0f)
        {
            p->integ -= p->ki * err * dt;
        }
        u = p->out_max;
    }
    else if (u < p->out_min)
    {
        if (p->ki * err * dt < 0.0f)
        {
            p->integ -= p->ki * err * dt;
        }
        u = p->out_min;
    }

    p->prev_err = err;
    p->prev_deriv = deriv;

    return u;
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     速度式（增量式）PID
// 参数说明     setpoint 目标值
// 参数说明     measurement 测量值
// 返回参数     float
// 使用示例
// 备注信息     返回 Δu
//-------------------------------------------------------------------------------------------------------------------
float PID_Update_Velocity(PID_t *p, float setpoint, float measurement)
{
    float dt;
    float err;

    float delta_p;
    float delta_i;
    float delta_d;

    float deriv;
    float delta_u;

    if (!p)
        return 0.0f;

    dt = (float)p->dt_ms * 0.001f;
    if (dt <= EPS_F)
        dt = EPS_F;

    err = setpoint - measurement;

    /* ΔP = Kp*(err - prev_err) */
    delta_p = p->kp * (err - p->prev_err);

    /* ΔI = Ki*err*dt */
    delta_i = p->ki * err * dt;
		if (delta_i > 30.0f) delta_i = 30.0f;
		else if (delta_i < -30.0f) delta_i = -30.0f;
    /* ΔD = Kd*((err-prev_err)/dt - prev_deriv) */
    deriv = (err - p->prev_err) / dt;
    delta_d = p->kd * (deriv - p->prev_deriv);

    delta_u = delta_p + delta_i + delta_d;

    /* 更新内部状态 */
    p->prev_deriv = deriv;
    p->prev_err = err;

    return delta_u;
}

//-------------------------------------------------------------------------------------------------------------------
// 函数简介     一阶低通滤波
// 参数说明      current_value 当前值
// 参数说明      previous_filtered 上一次滤波值
// 参数说明      Alpha 滤波系数
// 返回参数     filtered 滤波后值
// 使用示例
// 备注信息
//-------------------------------------------------------------------------------------------------------------------

float Lower_filter(float current_value,float previous_filtered,float Alpha)
{		
		float filtered;
		
    filtered = Alpha*previous_filtered+(1-Alpha)*current_value;

    return filtered;
}

