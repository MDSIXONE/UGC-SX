/*
 * ADCinductance.c
 *
 *  Created on: 2025年9月27日
 *      Author: CYM
 */


#include "headfile.h"

#define AD_Val_max 4095
#define N 5
#define NUM 5

ADC_inductance ADC;
extern Flag_t element_Flag;
float ADC_Value[NUM][5]={{0},{0},{0},{0},{0}} , ADCTemp , adc_Sum[NUM];
float ADC_Aver[NUM], ADC_last[NUM] = {0};
float RAW[NUM];                             /* ADC处理后的原始值 */
float MAX[NUM] = {100,100,100,100,100};     /* 最大值 */
float Err_last = 0.0;                       /* 差比和算法的偏差值 */
int16 Limit = 100;
float Middle_Adc;

/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     电磁初始化
 * 参数说明
 * 返回参数     void
 * 使用示例
 * 备注信息
 *-------------------------------------------------------------------------------------------------------------------*/
void ADCinductance_init(void)
{
    adc_init(ADC_P05, ADC_12BIT);
    adc_init(ADC_P14, ADC_12BIT);
    adc_init(ADC_P15, ADC_12BIT);
    adc_init(ADC_P17, ADC_12BIT);
}

/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     读取电磁
 * 参数说明
 * 返回参数     void
 * 使用示例
 * 备注信息
 *-------------------------------------------------------------------------------------------------------------------*/
void read_AD(void)
{
    int i, j, k;
    float ADC_Convert[4] = {0};
    float ADC_Sum[4] = {0};

    /* ************* 4 个通道，各采 4 次 ************* */
    for(i = 0; i < 4; i++)
    {
        ADC_Value[0][i] = adc_once(ADC_P05, ADC_12BIT);
        ADC_Value[1][i] = adc_once(ADC_P14, ADC_12BIT);
        ADC_Value[2][i] = adc_once(ADC_P15, ADC_12BIT);
        ADC_Value[3][i] = adc_once(ADC_P17, ADC_12BIT);
    }

    /* ************* 4 通道分别排序（4 个数） ************* */
    for(i = 0; i < 4; i++)
    {
        for(j = 0; j < 3; j++)
        {
            for(k = 0; k < 3 - j; k++)
            {
                if(ADC_Value[i][k] > ADC_Value[i][k+1])
                {
                    ADCTemp = ADC_Value[i][k];
                    ADC_Value[i][k] = ADC_Value[i][k+1];
                    ADC_Value[i][k+1] = ADCTemp;
                }
            }
        }
    }

    /* ************* 取排序后的中间两个值求平均 ************* */
    for(i = 0; i < 4; i++)
    {
        adc_Sum[i] = ADC_Value[i][1] + ADC_Value[i][2];
        ADC_Aver[i] = adc_Sum[i] / 2.0f;
    }

    /* ************* 覆盖到最后一个元素（保持你的逻辑） ************* */
    for(i = 0; i < 4; i++)
    {
        ADC_Value[i][3] = ADC_Aver[i];
    }

    /* ************* 滑动覆盖 ************* */
    for(i = 0; i < 3; i++)
    {
        for(j = 0; j < 4; j++)
        {
            ADC_Value[j][i] = ADC_Value[j][i+1];
        }
    }

    /* ************* 再次求和 ************* */
    for(i = 0; i < 3; i++)
    {
        for(j = 0; j < 4; j++)
        {
            ADC_Sum[j] += ADC_Value[j][i];
        }
    }

    /* ************* 求平均 + 限幅 ************* */
    for(i = 0; i < 4; i++)
    {
        ADC_Aver[i] = ADC_Sum[i] / 3.0f;
        RAW[i] = ADC_Aver[i];

        if(ADC_Aver[i] > MAX[i])
            ADC_Aver[i] = MAX[i];

        ADC_Sum[i] = 0;
    }

    /* ************* 归一化处理 ************* */
    for(i = 0; i < 4; i++)
    {
        ADC_Convert[i] = 100.0f * ADC_Aver[i] / MAX[i];
    }

    ADC.ADC1 = ADC_Convert[0];
    ADC.ADC2 = ADC_Convert[1];
    ADC.ADC3 = ADC_Convert[2];
    ADC.ADC4 = ADC_Convert[3];

    /* ************* 差比和（原来是通道 5 和通道 1，这里改成通道 4 和通道 1） ************* */
    /* 防止除零：当两侧电感和太小时，认为误差为0 */
    if ((ADC.ADC4 + ADC.ADC1) > 5.0f)
    {
        ADC.ADC_Err = Limit * (ADC.ADC4 - ADC.ADC1) / (ADC.ADC4 + ADC.ADC1);
    }
    else
    {
        ADC.ADC_Err = 0.0f;  /* 信号太弱，无法判断方向 */
    }
}


/*-------------------------------------------------------------------------------------------------------------------
 * 函数简介     检测是否进入圆环
 * 参数说明     无
 * 返回参数     uint8_t (1 = 检测到圆环, 0 = 否)
 * 使用示例     if (isRingDetected()) { ... }
 * 备注信息     基于电磁传感器特征判断圆环入口/出口，使用状态机和计数器防抖
 *-------------------------------------------------------------------------------------------------------------------*/

/* 圆环检测阈值（可根据实际调参） */
#define RING_SIDE_HIGH_TH       95.0f   /* 单侧传感器高阈值 */
#define RING_SIDE_LOW_TH        80.0f   /* 另一侧传感器低阈值 */
#define RING_MIDDLE_TH          60.0f   /* 中间传感器阈值 */
#define RING_CONFIRM_CNT        3       /* 连续检测次数确认 */
#define RING_EXIT_CONFIRM_CNT   5       /* 出环确认次数 */

/* 圆环状态枚举 */
typedef enum {
    RING_STATE_NONE = 0,    /* 未检测到圆环 */
    RING_STATE_ENTER_L,     /* 检测到左侧入环特征 */
    RING_STATE_ENTER_R,     /* 检测到右侧入环特征 */
    RING_STATE_IN_RING,     /* 正在环内行驶 */
    RING_STATE_EXIT         /* 检测到出环特征 */
} RingState_t;

static RingState_t ring_state = RING_STATE_NONE;
static uint8 ring_enter_cnt = 0;    /* 入环检测计数器 */
static uint8 ring_exit_cnt = 0;     /* 出环检测计数器 */

uint8 isRingDetected(void)
{
    float middle_sum;
    uint8 left_high, right_high;
    uint8 left_low, right_low;
    uint8 middle_valid;

    /* 计算中间传感器均值 */
    middle_sum = (ADC.ADC2 + ADC.ADC3) / 2.0f;

    /* 判断各传感器状态 */
    left_high   = (ADC.ADC1 >= RING_SIDE_HIGH_TH) ? 1 : 0;
    right_high  = (ADC.ADC4 >= RING_SIDE_HIGH_TH) ? 1 : 0;
    left_low    = (ADC.ADC1 <= RING_SIDE_LOW_TH)  ? 1 : 0;
    right_low   = (ADC.ADC4 <= RING_SIDE_LOW_TH)  ? 1 : 0;
    middle_valid = (middle_sum >= RING_MIDDLE_TH) ? 1 : 0;

    /************ 状态机处理 ***********/
    switch (ring_state)
    {
        case RING_STATE_NONE:
            /* 检测入环特征：一侧很强，另一侧较弱，中间有信号 */
            /* 右侧入环（右侧传感器先检测到强信号） */
            if (right_high && left_low && middle_valid)
            {
                ring_enter_cnt++;
                if (ring_enter_cnt >= RING_CONFIRM_CNT)
                {
                    ring_state = RING_STATE_ENTER_R;
                    element_Flag.in_island_flag = 1;
                    element_Flag.in_island_cnt++;
                    element_Flag.island_dir = 1;    /* 右环 */
                    element_Flag.island_stage = 0;  /* 重置阶段 */
                    ring_enter_cnt = 0;
                }
            }
            /* 左侧入环（左侧传感器先检测到强信号） */
            else if (left_high && right_low && middle_valid)
            {
                ring_enter_cnt++;
                if (ring_enter_cnt >= RING_CONFIRM_CNT)
                {
                    ring_state = RING_STATE_ENTER_L;
                    element_Flag.in_island_flag = 1;
                    element_Flag.in_island_cnt++;
                    element_Flag.island_dir = 0;    /* 左环 */
                    element_Flag.island_stage = 0;  /* 重置阶段 */
                    ring_enter_cnt = 0;
                }
            }
            else
            {
                /* 未检测到特征，计数器衰减 */
                if (ring_enter_cnt > 0)
                {
                    ring_enter_cnt--;
                }
            }
            break;

        case RING_STATE_ENTER_R:
        case RING_STATE_ENTER_L:
            /* 进入环内状态，等待入环动作完成 */
            if (element_Flag.in_island_flag == 0)
            {
                /* 入环动作完成，切换到环内状态 */
                ring_state = RING_STATE_IN_RING;
            }
            break;

        case RING_STATE_IN_RING:
            /* 检测出环特征：与入环相反的一侧出现强信号 */
            /* 左侧出环 */
            if (left_high && right_low && middle_valid)
            {
                ring_exit_cnt++;
                if (ring_exit_cnt >= RING_EXIT_CONFIRM_CNT)
                {
                    ring_state = RING_STATE_EXIT;
                    element_Flag.out_island_flag = 1;
                    element_Flag.out_island_cnt++;
                    element_Flag.out_island_stage = 0;  /* 重置出环阶段 */
                    ring_exit_cnt = 0;
                }
            }
            /* 右侧出环 */
            else if (right_high && left_low && middle_valid)
            {
                ring_exit_cnt++;
                if (ring_exit_cnt >= RING_EXIT_CONFIRM_CNT)
                {
                    ring_state = RING_STATE_EXIT;
                    element_Flag.out_island_flag = 1;
                    element_Flag.out_island_cnt++;
                    element_Flag.out_island_stage = 0;  /* 重置出环阶段 */
                    ring_exit_cnt = 0;
                }
            }
            else
            {
                if (ring_exit_cnt > 0)
                {
                    ring_exit_cnt--;
                }
            }
            break;

        case RING_STATE_EXIT:
            /* 出环动作完成后复位状态 */
            if (element_Flag.out_island_flag == 0)
            {
                ring_state = RING_STATE_NONE;
                ring_enter_cnt = 0;
                ring_exit_cnt = 0;
            }
            break;

        default:
            ring_state = RING_STATE_NONE;
            break;
    }

    return (ring_state != RING_STATE_NONE) ? 1 : 0;
}
