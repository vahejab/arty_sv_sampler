/*****************************************************************//**
 * @file ps2_core.h
 *
 * @brief Access MMIO ps2 core
 *
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

#ifndef _PS2_H_INCLUDED
#define _PS2_H_INCLUDED

#define QUEUE_SIZE 256
#define XPAR_INTC_MAX_NUM_INTR_INPUTS 1
#include "xparameters.h"
//#include "xgpio.h"
#include "xiomodule.h"
//#include "xintc.h"
#include "chu_init.h"

/**
 * ps2 core driver
 *  - transmit/receive raw byte stream to/from MMIO timer core.
 *  - initialize ps2 mouse
 *  - get mouse movement/button activities
 *  - get keyboard char
 *
 */


class Ps2Core {
	public:
	    XIOModule intr;

		volatile unsigned int queueCount = 0;
		/**
		  * Register map
		  *
		  */
		  enum reg{
			RD_DATA_REG = 0, /**< read data/status register */
			PS2_WR_DATA_REG = 2, /**< 8-bit write data register */
			RM_RD_DATA_REG = 3  // remove read data
		  };
		  /**
			* Transmit/Receive Direction
			*
			*/
		  enum dir{
			RECV = 0,
			SEND = 1
		  };
	  /**
	   * field masks
	   *
	   */
	   enum field{
		RX_IDLE_FIELD = 0x00000200, /**< bit 9 of rd_data_reg; idle bit  */
		RX_EMPT_FIELD = 0x00000100, /**< bit 10 of rd_data_reg; empty bit */
		RX_DATA_FIELD = 0x000000ff  /**< bits of 7..0 rd_data_reg; read data */
	   };

	  /* methods */
	  /**
	   * constructor.
	   @note set default baud rate to 9600
	   *
	   */
	   Ps2Core(uint32_t core_base_addr);
	   ~Ps2Core();       // not used

	   void enqueue(uint8_t value);
	   uint8_t dequeue(void);
	   void checkMovement();
	   int byte(uint32_t data);
	   int getPacket();
	   static void handleInterrupt(Ps2Core *ps2);
	   void setUpInterrupt();
	   /**
		* check whether the ps2 receiver fifo is empty
		*
		* @return 1: if empty; 0: otherwise
		*
		*/
	   int rx_fifo_empty();

	   /**
		* check whether the ps2 receiver is idle
		*
		* @return 1: if idle; 0: otherwise
		*
		*/
	   int rx_idle(uint32_t rd_word);

	   /**
		* send an 8-bit command to ps2
		*
		* @param cmd 8-bit command
		*
		*/
	   uint8_t tx_byte(uint8_t cmd);

	   /**
		* check ps2 fifo and, if not empty, read data and then remove it
		*
		* @return  -1 if fifo is empty; fifo data otherwise
		*
		*/
	   int rx_word_from_byte();
	   int rx_byte();

	   /**
		* reset and identify the type of ps2 device (mouse or keyboard).
		*
		* @return device id or error code as follows:
		*   1: keyboard;
		*   2: mouse (set to stream mode);
		*  -1: no response;
		*  -2: unknown device;
		*  -3: failure to set mouse to stream mode;
		*
		* @note keyboard does not require initialization; init() checks device id
		*/
	   int init();

	   /**
		* get mouse activity
		*
		* @return 0: no new data; 1: with new data
		* @return lbtn return 1 when left mouse button pressed;
		* @return rbtn return 1 when right mouse button pressed;
		* @return xmov return x-axis movement;
		* @return ymov return y-axis movement;
		*
		*/
	   int get_mouse_activity(int *lbtn, int *rbtn, int *xmov, int *ymov, int *zmov);

	   /**
		* hex
		*
		* @return num after outputting hex equivalent
		*/
	   int hex(dir direction, int num);

	private:
	   /* variable to keep track of current status */
	   uint32_t base_addr;

	   unsigned char queue[QUEUE_SIZE];
	   unsigned int head = 0;
	   unsigned int tail = 0;
};

#endif  // _PS2_H_INCLUDED
