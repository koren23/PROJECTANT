#include "xparameters.h"
#include "xgpio.h"
#include "xuartps.h"
#include "xuartps_hw.h"

int main(void)
{
    XGpio led;
    XUartPs uart;
    XUartPs_Config *config;

    // initialize LED gpio
    XGpio_Initialize(&led, 0    );
    XGpio_SetDataDirection(&led, 1, 0x0); // set as output
    XGpio_DiscreteWrite(&led, 1, 1);      // turn on LED

    // initialize UART
    config = XUartPs_LookupConfig(0);
    XUartPs_CfgInitialize(&uart, config, config->BaseAddress);

    while(1){
        // wait for incoming data
        while (!XUartPs_IsReceiveData(config->BaseAddress));

        // read the received byte
        u8 received = XUartPs_RecvByte(config->BaseAddress);

        // echo it back
        XUartPs_Send(&uart, &received, 1);
}

}
