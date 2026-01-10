/*
 * ADCinductance.h
 *
 *  Created on: 2025年9月27日
 *      Author: CYM
 */

#ifndef CODE_ADCINDUCTANCE_H_
#define CODE_ADCINDUCTANCE_H_

#include "headfile.h"


typedef struct ADC_inductance
{
        float ADC1, ADC2, ADC3, ADC4, ADC5;//归一化后的数值
        float ADC_Err; //ADC 计算出的偏差
}ADC_inductance;

//====================================================电磁 基础函数====================================================
void ADCinductance_init(void);
void read_AD(void);
uint8 isRingDetected(void);
//====================================================电磁 基础函数====================================================


#endif /* CODE_ADCINDUCTANCE_H_ */
