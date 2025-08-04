#include "xparameters.h"
#include "xuartps.h"
#include "xuartps_hw.h"
#include "xil_io.h"
#include "sleep.h"

int main(void)
{
    XUartPs uart;
    XUartPs_Config *config;
    // initialize UART
    config = XUartPs_LookupConfig(0);
    XUartPs_CfgInitialize(&uart, config, config->BaseAddress);


    // reset loop sets everything to 128dec
    u32 reset_address; // u32 instead of u8 so it just counts for 256 and wont use the rest
    u8 reset_value = 128; // middle of 256 (max value of UART 8bits)
    for (reset_address = XPAR_AXI_BRAM_CTRL_0_BASEADDR ; reset_address < XPAR_AXI_BRAM_CTRL_0_BASEADDR  + 256; reset_address++) {
        Xil_Out8(reset_address, reset_value); 
    }

    int state = 0;
    u8 address = 0;
    u8 data = 0;
    int maxvalue = 0;
    int maxlocation = 0;
    int minvalue = 0;
    int minlocation = 0;

    while(1){
        // wait for incoming data
        while (!XUartPs_IsReceiveData(config->BaseAddress));

        // read the received byte
        u8 received = XUartPs_RecvByte(config->BaseAddress);

        // writing data
        if(received == '*' && state == 0) state = 1; // start byte
        else if(state == 1) {address = received;   state = 2;} // address byte 
        else if(state == 2) {data = received;   state = 3;} // data byte
        else if(state == 3 && received == '#') state = 4; // end byte
        else if(state == 3 && received != '#') {state = 0;} // throw away data if no end byte
        else if(state == 4){
            Xil_Out8(address, data);
            state = 0;
        }

        for(int tempaddr = XPAR_AXI_BRAM_CTRL_0_BASEADDR; tempaddr < XPAR_AXI_BRAM_CTRL_0_BASEADDR  + 256; tempaddr++){ // loops for every address
            if(Xil_In8(tempaddr) > maxvalue){maxvalue = Xil_In8(tempaddr);maxlocation = tempaddr;}
            else if(Xil_In8(tempaddr) < minvalue){minvalue = Xil_In8(tempaddr);minlocation = tempaddr;}
        }

        // need delay for 1 second minus 14 bits

        /* using the UART TX:
                XUartPs_Send(&uart, &received, 1);      
            send the following:
            [ "Min:" minvalue minlocation 0x09 "Max:" maxvalue maxlocation 0x0A ]
                */
        
}

}
