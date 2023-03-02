/*****************************************************************//**
 * @file main_arty_sampler_test.cpp
 *
 * @brief Basic test of arty mmio cores
 *
 * description:
 *   - based on original nexys test program
 *   - commnent out the unused routines
 *   - replace the xadc core/test with arty_xadc
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/
#define _DEBUG
//#define XGPIO_0_CHANNEL 1 /* GPIO port For Custom Interface */
#include "chu_init.h"
#include "ps2_core.h"

/**
 * uart transmits test line.
 * @note uart instance is declared as global variable in chu_io_basic.h
 */
void uart_check() {
	static int loop = 0;

	uart.disp("uart test #");
	uart.disp(loop);
	uart.disp("\n\r");
	loop++;
}

void ps2_check(Ps2Core *ps2_p) {
	int id = 0;
	int lbtn = 0, rbtn = 0, xmov = 0, ymov = 0, zmov = 0;
	int xpos = 0, ypos = 0, zpos = 0;
	//static int x = 0, y = 0;

	unsigned long last;

	uart.disp("\n\rPS2 device (1-keyboard / 2-mouse): \n\r");
	id = ps2_p->init();
	uart.disp(id);
	uart.disp("\n\r");
	last = now_ms();
	if (id == 1 || id == 2) {
		do {
			ps2_p->checkMovement();
			if (id == 2) {  // mouse
				if (ps2_p->get_mouse_activity(&lbtn, &rbtn, &xmov, &ymov, &zmov)) {
                    if (lbtn || rbtn || xmov || ymov || zmov) {
						xpos += xmov;
						ypos += ymov;
						zpos += zmov;
                    	uart.disp("[");
						uart.disp(lbtn);
						uart.disp(", ");
						uart.disp(rbtn);
						uart.disp(", ");
						uart.disp(xpos);
						uart.disp(", ");
						uart.disp(ypos);
						uart.disp(", ");
						uart.disp(zpos);
						uart.disp("] \r\n");
                    }
					last = now_ms();
				}   // end get_mouse_activitiy()
			}
		} while (now_ms() - last < 5000 || id > 0);
	}
	uart.disp("\n\rExit PS2 test \n\r");
}
Ps2Core ps2(get_slot_addr(BRIDGE_BASE, S2_PS2));

int main() {
	//XIOModule_DiscreteWrite(&ps2.gpo, XGPIO_0_CHANNEL, 0); // disable writes to the gpi register by writing 0 to gpo
	Ps2Core *ps2p = &ps2;
	static uint32_t data = 0;
	while (1) {
		uart_check();
		ps2_check(&ps2);
		//uart.disp("Mouse initialization unsuccessful...\r\n");
		//uart.disp("Please power cycle mouse...\r\n");
		//while((data = ps2p->rx_word_from_byte()) && ps2p->byte(data) != 0xAA);
		//while((data = ps2p->rx_word_from_byte()) && ps2p->byte(data) != 0x00);
		//uart.disp("Performing silent mouse reset...\r\n");
		//ps2p->tx_byte(0xF5);
		//ps2p->tx_byte(0xF6);
		//ps2p->tx_byte(0xF4);
		//uart.disp("Flushing receive FIFO buffer...\r\n");
	} //while
	return 0;
} //main
