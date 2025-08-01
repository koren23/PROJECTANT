#include "xparameters.h"
#include "xuartlite.h"
#include "xuartlite_l.h"
#include "xuartps.h"
#include "xuartps_hw.h"

int main(void)
{
    XUartPs uartps;
    XUartPs_Config *configps;

    XUartLite uartlite;
    XUartLite_Config *configlite;

    // Initialize PS UART (XUartPs)
    configps = XUartPs_LookupConfig(0);

    if (configps == NULL) {
        return XST_FAILURE;
    }
// xilinix status type = XST
    if (XUartPs_CfgInitialize(&uartps, configps, configps->BaseAddress) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    configlite = XUartLite_LookupConfig(0);
    if (configlite == NULL) {
        return XST_FAILURE;
    }

    if (XUartLite_CfgInitialize(&uartlite, configlite, configlite->RegBaseAddr) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XUartLite_ResetFifos(&uartlite);

    while (1) {
        while (!XUartPs_IsReceiveData(configps->BaseAddress));

        u8 buffer = XUartPs_RecvByte(configps->BaseAddress);

        XUartLite_Send(&uartlite, &buffer, 1);

        while (XUartLite_IsSending(&uartlite));
    }

}
