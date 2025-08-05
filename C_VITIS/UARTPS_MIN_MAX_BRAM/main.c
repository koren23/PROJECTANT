#include "xparameters.h"
#include "xuartps.h"
#include "xscugic.h"
#include "xil_exception.h"
#include <stdio.h>
#include <string.h>
#include "sleep.h"

XUartPs Uart_Ps;// for Uart
XScuGic Intc; // for interrupt

volatile int interruptflag = 0; // indicates interrupt occured
volatile int max = 0;
volatile int min = 255;
volatile int maxaddr = 0;
volatile int minaddr = 0;
volatile int zerofound = 0; // data is 0x00 meaning it isnt a part of the default values
volatile int nodata = 0; // tells main if theres data
volatile int has_data = 0; // indicated if theres at least one valid data in BRAM 

void format_value(char *dest, u8 val) { // converts dec value back to asci
    if (val >= 32 && val <= 126) { // 32 to 126 is printable ascii values
        sprintf(dest, "%c", val); //formats them as ascii values
    } else {
        sprintf(dest, "0x%02X", val); // formats them as 0x values hex
    }
}

void UartIntrHandler(void *CallBackRef) { // called when Uart receives data
    static int state = 0; //static means it keeps the values between calls
    static u8 address = 0;
    static u8 data = 0;
    XUartPs *UartInstancePtr = (XUartPs *)CallBackRef; // converts the callbackref pointer to XUartPs type pointer
    while (XUartPs_IsReceiveData(UartInstancePtr->Config.BaseAddress)) { // while received data
        u8 received = XUartPs_RecvByte(UartInstancePtr->Config.BaseAddress); // saves data into u8
        interruptflag = 1; // interrupts main code
        if (received == '*' && state == 0) state = 1; // start byte detected
        else if (state == 1) { // save address
            address = received;
            state = 2;
        }
        else if (state == 2) { // save data
            data = received;
            if (data == 0) // if data is zero its the same value as default so need to flag it
                zerofound = 1;
            state = 3;
        }
        else if (state == 3 && received == '#') { // end byte detected
            Xil_Out8(address + XPAR_AXI_BRAM_CTRL_0_BASEADDR, data); // rewrites the data in that location
            nodata = 1; // tells main theres data
            has_data = 1; // indicator that theres at least 1 data saved
            state = 0; // restart FSM
        } 
        else {
            state = 0; // if anything goes wrong it goes back to 0
        }
        interruptflag = 0; // goes back to main code
    }
}

int main(void) // code to send max min values every second
{
    int Status; // var to store the status of the functions
    XUartPs_Config *Config; // pointer of UART configuration struct
    char message[100];
    char minStr[10];
    char maxStr[10];
    char minaddrStr[10];
    char maxaddrStr[10];

    Config = XUartPs_LookupConfig(0); // looks up uart config for id 0
    if (!Config) return XST_FAILURE; // if theres an error breaks
    Status = XUartPs_CfgInitialize(&Uart_Ps, Config, Config->BaseAddress); // initializing uart driver
    if (Status != XST_SUCCESS) return XST_FAILURE; // if theres an error breaks
    Status = SetupInterruptSystem(); // setup interrupt system (next function)
    if (Status != XST_SUCCESS) return XST_FAILURE; // if theres an error breaks
    XUartPs_SetHandler(&Uart_Ps, (XUartPs_Handler)UartIntrHandler, &Uart_Ps); // register the UART interrupt handler function and pass UART instance as callback reference
    XUartPs_SetInterruptMask(&Uart_Ps, XUARTPS_IXR_RXFULL | XUARTPS_IXR_RXOVR | XUARTPS_IXR_RXEMPTY); // enable UART interrupts for those 3 events

    while (1) {
        if (nodata) { // if theres data
            max = 0; // resets the value to calculate them again (just in case)
            min = 255;

            for (int tempaddr = XPAR_AXI_BRAM_CTRL_0_BASEADDR; tempaddr < XPAR_AXI_BRAM_CTRL_0_BASEADDR + 256; tempaddr++) { // loops for each address
                u8 val = Xil_In8(tempaddr); // saves address value
                if (val > max) {
                    max = val; // if its bigger than max its max
                    maxaddr = tempaddr;
                }
                if (val < min && val != 0){
                    min = val; // if its smaller than min and isnt 0 its min (if it is zero theres a flag)
                    minaddr = tempaddr;
                }
            }
            nodata = 0; // data taken care of no new data to check
        }
        if (!has_data) { // if it doesnt have data
            sprintf(message, "Min: - At -    Max: - At -\n"); // print no data message
        }
        else {
            format_value(minStr, min); // converts to string
            format_value(maxStr, max);
            format_value(maxaddrStr, maxaddr);
            format_value(minaddrStr, minaddr);
            sprintf(message, "Min: %s At - %s    Max: %s At %s\n", minStr,minaddrStr, maxStr, maxaddrStr); // mesage
        }
        XUartPs_Send(&Uart_Ps, (u8 *)message, strlen(message)); // send message
        usleep(1000000); // 1 second delay
    }
}

int SetupInterruptSystem(){
    int Status; // variable to store status codes from each call
    XScuGic_Config *IntcConfig; // pointer to the interrupt controller
    IntcConfig = XScuGic_LookupConfig(0); // lookup configuration from interrupt ID 0 
    if (!IntcConfig) return XST_FAILURE; // if it doesnt work break
    Status = XScuGic_CfgInitialize(&Intc, IntcConfig, IntcConfig->CpuBaseAddress); // initialize the interrupt controller
    if (Status != XST_SUCCESS) return XST_FAILURE; // if it doesnt work break
    Xil_ExceptionInit(); // initialize the exception handling system
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &Intc); // register the GIC (generic interrupt controller) as the main interrupt handler
    Xil_ExceptionEnable(); // enable processor-level interrupts
    Status = XScuGic_Connect(&Intc, XPAR_XUARTPS_0_INTR, (Xil_ExceptionHandler)UartIntrHandler, (void *)&Uart_Ps); // connect the UART interrupt to the UART interrupt handler
    if (Status != XST_SUCCESS) return XST_FAILURE; // if it doesnt work break
    XScuGic_Enable(&Intc, XPAR_XUARTPS_0_INTR);// enable the UART interrupt in the interrupt controller
    return XST_SUCCESS; // break
}

