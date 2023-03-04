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
			//ps2_p->checkMovement();
			if (id == 2) {  // mouse
				while (ps2_p->get_mouse_activity(&lbtn, &rbtn, &xmov, &ymov, &zmov)) {
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
				}   // end get_mouse_activitiy()
			}
		} while (now_ms() - last < 5000 || id > 0);
	}
	uart.disp("\n\rExit PS2 test \n\r");
}
Ps2Core ps2(get_slot_addr(BRIDGE_BASE, S2_PS2));

int main() {
    ps2.setUpInterrupt();
	while (1) {
		uart_check();
		ps2_check(&ps2);
	} //while
	return 0;
} //main
