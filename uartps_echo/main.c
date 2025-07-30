#include <stdio.h>
#include "xparameters.h"
#include "xuartps.h"
#include "xuartps_hw.h"
#include "xgpio.h"


int main()
{
	XGpio ledgpio;
	XGpio_Initialize(&ledgpio,0);
	XGpio_SetDataDirection(&ledgpio, 1, 0x0);

	XUartPs uartps;
	XUartPs_Config *config;
	config = XUartPs_LookupConfig(0); // lookups the config using the id and the lookupconfig function
	XUartPs_CfgInitialize(&uartps, config, config -> BaseAddress);

	while(1){
		XGpio_DiscreteWrite(&ledgpio, 1, 1);
		u32 status = XUartPs_ReadReg(config -> BaseAddress, XUARTPS_SR_OFFSET); // saves the status of the register in a u32
		u8 uartpsbuffer; // temp buffer from uartps
		if((XUARTPS_SR_RXEMPTY & status) == 0){ //if fifo isnt empty and if theres data
			uartpsbuffer = XUartPs_RecvByte(uartps.Config.BaseAddress);
			XUartPs_SendByte(uartps.Config.BaseAddress,uartpsbuffer);
		}

	}
	return 0;
}
