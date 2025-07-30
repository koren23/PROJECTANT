#include "xparameters.h"
#include "xgpio.h"
#include "xuartlite.h"
#include "xuartlite_l.h"
#include <stdio.h>
#include <string.h>

int main()
{
	XGpio ledgpio;
	XUartLite uartlite;

	XGpio_Initialize(&ledgpio,XPAR_GPIO_0_DEVICE_ID); // initialize from xparameters.h
	XGpio_SetDataDirection(&ledgpio, 1, 0x0); // (0 = output)
	XUartLite_Initialize(&uartlite,XPAR_UARTLITE_0_DEVICE_ID);

	int ledstate = 0; //  0 for off 1 for on
	char messages[][50] = {
		"LED is already ON ",
		"LED turned ON ",
		"LED turned OFF ",
		"LED is already OFF ",
		"Invalid Command ",
	};

	while(1){
		int i;
		if(!XUartLite_IsReceiveEmpty(XPAR_UARTLITE_0_BASEADDR)){ // XUartLite_IsReceiveEmpt returns false when data is in FIFO . . . XPAR_UARTLITE_0_BASEADDR is the u32 BaseAddress
			u8 byte = XUartLite_RecvByte(uartlite.RegBaseAddress); // saves data in 8 bits
			switch(byte){

				case 0xA5:
					XGpio_DiscreteWrite(&ledgpio, 1, 1); // turn led on
					if(ledstate)
						for(i = 0; i < strlen(messages[0]); i++){ // 17 chars in message
							XUartLite_SendByte(uartlite.RegBaseAddress, messages[0][i]);
						}
					else
						for(i = 0; i < strlen(messages[1]); i++){
							XUartLite_SendByte(uartlite.RegBaseAddress, messages[1][i]);
						}
					ledstate = 1; // led is on
					break;

				case 0x33:
					XGpio_DiscreteWrite(&ledgpio, 1, 0); // turn led off
					if(ledstate)
						for(i = 0; i < strlen(messages[2]); i++){
							XUartLite_SendByte(uartlite.RegBaseAddress, messages[2][i]);
						}
					else
						for(i = 0; i < strlen(messages[3]); i++){
							XUartLite_SendByte(uartlite.RegBaseAddress, messages[3][i]);
						}
					ledstate = 0;
					break;

				default:
					for(i = 0; i < strlen(messages[4]); i++){
							XUartLite_SendByte(uartlite.RegBaseAddress, messages[4][i]);
						}
			}

		}

	}
	return 0;
}






