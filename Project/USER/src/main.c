/*********************************************************************************************************************
 * copyright notice
 * copyright (c) 2020,逐飞科技
 * all rights reserved.
 * 技术讨论qq群：一群：179029047(已满)  二群：244861897(已满)  三群：824575535
 *
 * 以下所有内容版权均属逐飞科技所有，未经允许不得用于商业用途，
 * 欢迎各位使用并传播本程序，修改内容时必须保留逐飞科技的版权声明。
 *
 * @file       		main
 * @company	   		成都逐飞科技有限公司
 * @author     		逐飞科技(qq790875685)
 * @version    		查看doc内version文件 版本说明
 * @software 		mdk for c251 v5.60
 * @target core		stc16f40k128
 * @taobao   		https://seekfree.taobao.com/
 * @date       		2020-12-18
 ********************************************************************************************************************/

#include "headfile.h"

extern float tgt_L;
extern float tgt_R;
extern  motor Motor_L;
extern  motor Motor_R;
extern float g_ctrl_u_L;
extern float g_ctrl_u_R;
float measured_w;
extern ADC_inductance ADC;
int16 flag_10ms;
// 上述define为反接
  /*
	*关于内核频率的设定，可以查看board.h文件
 *在board_init中,已经将p54引脚设置为复位
 *如果需要使用p54引脚,可以在board.c文件中的board_init()函数中删除set_p54_resrt即可
 */
void main()
{
	DisableGlobalIRQ();
	sys_clk = 30000000; 
	board_init();
	Control_Init();
	ips114_init_simspi();
	pit_timer_ms(TIM_2, 5);
	EnableGlobalIRQ();
	
	while(1)
	{	
		ips114_showfloat_simspi(0, 0, Motor_L.Total_Encoder, 6, 3);
		ips114_showfloat_simspi(0, 1, Motor_R.Total_Encoder, 6, 3);
		ips114_showfloat_simspi(0, 3, ADC.ADC1, 4, 3);
		ips114_showfloat_simspi(0, 4, ADC.ADC2, 4, 3);
		ips114_showfloat_simspi(0, 5, ADC.ADC3, 4, 3);
		ips114_showfloat_simspi(0, 6, ADC.ADC4, 4, 3);
		ips114_showfloat_simspi(0,7, steer_u, 4, 3);
	}
}