/*******************************************************************
 * @file ps2_core.cpp
 *
 * @brief implementation of Ps2Core class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/
#define XPAR_XINTC_NUM_INSTANCES 1
#include "xparameters.h"
//#include "microblaze_exception_handler.c"
#include "xil_exception.h"
#include "mb_interface.h"
#include "xil_assert.c"
#include "xiomodule.h"
#include "ps2_core.h"

#define INTC_DEVICE_ID 0
#define INTERRUPT_ID 0
#define INTERRUPT_CONTROL_REG XPAR_IOMODULE_SINGLE_BASEADDR + XIN_ISR_OFFSET


// Define interrupt priority level
#define INTR_PRIORITY           0

Ps2Core::Ps2Core(uint32_t core_base_addr) {
   base_addr = core_base_addr;
}

Ps2Core::~Ps2Core() {
}

void Ps2Core::enqueue(uint8_t value) {
	if ((tail + 1) % QUEUE_SIZE == head) {
	// queue is full, do nothing
	return;
	}
	queue[tail] = value;
	queueCount++;
	tail = (tail + 1) % QUEUE_SIZE;
}

uint8_t Ps2Core::dequeue(void) {
	if (head == tail) {
	// queue is empty, do nothing
	return 0;
	}
	uint8_t value = queue[head];
	queueCount--;
	head = (head + 1) % QUEUE_SIZE;
	return value;
}

int Ps2Core::byte(uint32_t data) {
	return ((int) (data & RX_DATA_FIELD));
}

void Ps2Core::getPackets() {
    static int data = 0;
    static uint8_t byteArray[4] = {0x00, 0x00, 0x00, 0x00};
    int bytesProcessed = 0;
    int error = 0;
    while (bytesProcessed < 4) {
    	while(!rx_ready(data = rx_word_from_byte()))
    		;
        byteArray[bytesProcessed++] = byte(data);
    	continue;
        if ((bytesProcessed == 0) && (byte(data) & 0x08) != 0x08) {
         	bytesProcessed++;
            error = 1;
        }
        else if (error == 1 && bytesProcessed < 3)
        	bytesProcessed++;
        else if (error == 1 && bytesProcessed == 3){
        	bytesProcessed = 0;
        	error = 0;
			for (int idx = 0; idx < 4; idx++) {
				byteArray[idx] = 0x00;
			}
        }
        else
        	byteArray[bytesProcessed++] = byte(data);


        /*else if (bytesProcessed >= 1) {
        	if ((bytesProcessed == 1 && ((byteArray[0] & 0x08) == 0x00)) ||
        	    (bytesProcessed == 1 && (byte(data) & 0x80) >> 7 != (byteArray[0] & 0x10) >> 4) ||
        	    (bytesProcessed == 2 && (byte(data) & 0x80) >> 7 != (byteArray[0] & 0x20) >> 5) ||
				((bytesProcessed == 3) && ((byteArray[1] == 0x00) && (byteArray[2] == 0x00) && ((byte(data) & 0x07) == 0x00))) ||
				((bytesProcessed == 3) && (((byte(data) & 0x80) != 0x00) || ((byte(data) & 0x40) != 0x00)))
				//((bytesProcessed == 1) && (((byte(data) < 0x80) || (byte(data) > 0x7F)))) ||
				//((bytesProcessed == 2) && (((byte(data) < 0x80) || (byte(data) > 0x7F)))) ||
				//((bytesProcessed == 3) && (((byte(data) & 0x0F) < 0x08) || ((byte(data) & 0x0F) > 0x07)))
				)
			    {//mismatch in sign, no data in x,y, or error (0xF0)

				if (bytesProcessed == 3) {
					bytesProcessed = 0;
					error = 0;
					for (int idx = 0; idx < 4; idx++) {
						byteArray[idx] = 0x00;
					}
				} else {
					bytesProcessed++;
	                error = 1;
				}
        	}
        	else {
           		byteArray[bytesProcessed++] = byte(data);
        	}
        }*/
    }
    for (int idx = 0; idx < 4; idx++) {
    	enqueue(byteArray[idx]);
 		hex(dir::RECV, byteArray[idx]);
    }
}

int Ps2Core::rx_word_from_byte() {
	uint32_t data;
	//if (rx_fifo_empty())
	//	return 0;
	data = io_read(base_addr, RD_DATA_REG);
    //io_write(base_addr, RM_RD_DATA_REG, 0); //dummy write to remove data from rx FIFO
	return ((int) data);
}


int Ps2Core::rx_byte() {
   uint32_t data;
   data = io_read(base_addr, RD_DATA_REG) & RX_DATA_FIELD;
   //io_write(base_addr, RM_RD_DATA_REG, 0); //dummy write to remove data from rx FIFO
   return ((int) data);
}


int Ps2Core::rx_ready(uint32_t rd_word) {
   return rx_idle(rd_word) && !rx_fifo_empty(rd_word);
}

int Ps2Core::rx_idle(uint32_t rd_word) {
   int idle;

   //rd_word = io_read(base_addr, RD_DATA_REG);
   idle = (int) (rd_word & RX_READY_FIELD) >> 9;
   return (idle);
}

uint8_t Ps2Core::tx_byte(uint8_t cmd) {
   io_write(base_addr, PS2_WR_DATA_REG, (uint32_t ) cmd);
   return cmd;
}

int Ps2Core::rx_fifo_empty(uint32_t rd_word) {
   int empty;
   //uint32_t rd_word = io_read(base_addr, RD_DATA_REG);
   empty = (int) (rd_word & RX_EMPT_FIELD) >> 8;
   return (empty);
}


int Ps2Core::hex(dir direction = dir::SEND, int num = 0)
{
	//uart.disp("(");
	//uart.disp(num);
	//uart.disp(") ");
	if (direction == dir::RECV){
		uart.disp("    ");
	}
	uart.disp((direction == dir::RECV)? "Recv:": "Send:");
	uart.disp(" 0x");
    uart.disp("0123456789ABCDEF"[(int)(0x0F & (num >> 4))]);
    uart.disp("0123456789ABCDEF"[(int)(0x0F & num)]);
    uart.disp("\r\n");
    return num;
}

/* procedure:
 *    1. flush ps2 receiver fifo
 *    2. host sends reset command 0xff
 *    3. ps2 device acknowledges (0xfa) and performs self-test
 *    4. ps2 device responds 0xaa if test passes
 *    5a. keyboard sends no additional data
 *    5b. mouse sends an extra id 0x00
 *    6. host sends 0xf4 to start stream mode
 *    7. mouse acknowledges (0xfa)
 */

int Ps2Core::init() {
   static uint32_t data = 0x00000200;
   int last = 0;
   //while(!rx_fifo_empty(data = rx_word_from_byte()))
   //   ;
   hex(dir::SEND, tx_byte(0xFF));  //Reset Mouse
   last = now_ms();
   //sleep_ms(3000);
   //data = rx_word_from_byte();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -1;//Check response (0xFA)
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xAA) return -2;//Check response (0xAA)
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0x00) return -3;//Check response (0x00)
   hex(dir::SEND, tx_byte(0xF3)); //Set Sample Rate
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -4;
   hex(dir::SEND, tx_byte(0xC8)); //Send 200
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -5;
   hex(dir::SEND, tx_byte(0xF3)); //Set Sample Rate
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -6;
   hex(dir::SEND, tx_byte(0x64)); //Send 100
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -7;
   hex(dir::SEND, tx_byte(0xF3)); //Set Sample Rate
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -8;
   hex(dir::SEND, tx_byte(0x50)); //Send 80
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -9;
   hex(dir::SEND, tx_byte(0xF2)); //Read Device Type
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -10;
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0x03) return -11;
   hex(dir::SEND, tx_byte(0xEA)); //Set Enable State
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   last = now_ms();
   if (hex(dir::RECV, byte(data)) != 0xFA) return -12;
   hex(dir::SEND, tx_byte(0xF4));  //Enable Data Reporting
   last = now_ms();
   while(!rx_ready(data = rx_word_from_byte()))
	  ;
   if (hex(dir::RECV, byte(data)) != 0xFA) return -13;
   //hex(dir::SEND, tx_byte(0xF5));  //Disable Data Reporting
   //hex(dir::SEND, tx_byte(0xF4));  //Re-Enable Data Reporting
   return (2);  //Mouse Detected and Initialized Successfully
}
int Ps2Core::get_mouse_activity(int *lbtn, int *rbtn, int *xmov,
      int *ymov, int *zmov) {
   uint8_t b1, b2, b3, b4;
   //uart.disp((char)(queueCount+'0'));
   /* retrieve bytes only if 4 or a multiple of 4 exist in queue */
   if (queueCount >= 4) {
	   b1 = dequeue();
	   b2 = dequeue();
	   b3 = dequeue();
	   b4 = dequeue();
   }
   else {
	   *lbtn = 0;
	   *rbtn = 0;
	   *xmov = 0;
	   *ymov = 0;
	   *zmov = 0;
	   return (1);
   }

   /* extract button info */
   *lbtn = (int) (b1 & 0x01);      // extract bit 0
   *rbtn = (int) (b1 & 0x02) >> 1; // extract bit 1
   /* extract x movement; manually convert 9-bit 2's comp to int */
   if ((b1 & 0x10) >> 4)                // check MSB (sign bit) of x movement
      *xmov = -int(((b2 & 0x7f) ^ 0x7f) + 1);
   else
	  *xmov = int(b2 & 0x7f); // data conversion
   /* extract y movement; manually convert 9-bit 2's comp to int */

   if ((b1 & 0x20) >> 5)                // check MSB (sign bit) of y movement
      *ymov = -int(((b3 & 0x7f) ^ 0x7f) + 1);
   else
	  *ymov = int(b3 & 0x7f);// data conversion

   if ((b4 & 0x08) >> 3)               // check MSB (sign bit) of z movement
      *zmov = -int(((b4 & 0x07) ^ 0x07) + 1);
   else
	  *zmov = int(b4 & 0x07); // data conversion
   /* success */
   return (1);
}
