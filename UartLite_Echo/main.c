#include "xparameters.h"
#include "xuartlite.h"
#include "xuartlite_l.h"

int main(void)
{
    XUartLite uart;
    XUartLite_Config *config;

    config = XUartLite_LookupConfig(0);
    if (config == NULL) {
        return XST_FAILURE;
    }

    if (XUartLite_CfgInitialize(&uart, config, config->RegBaseAddr) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XUartLite_ResetFifos(&uart);

    u8 buffer;
    while (1) {

    while (XUartLite_IsReceiveEmpty(uart.RegBaseAddress));

    XUartLite_Recv(&uart, &buffer, 1);

    XUartLite_Send(&uart, &buffer, 1);

    while (XUartLite_IsSending(&uart));
}


}
