//ECE 385 USB Host Shield code
//based on Circuits-at-home USB Host code 1.x
//to be used for ECE 385 course materials
//Revised October 2020 - Zuofu Cheng

#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"
#include "main.h"
#include "music.h"

extern HID_DEVICE hid_device;

static BYTE addr = 1; 				//hard-wired USB address
const char LEDS_PIO_BASE = 0x60;
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };

BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;

	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}

void setLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) | (0x001 << LED)));
}

void clearLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) & ~(0x001 << LED)));

}

void printSignedHex0(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	WORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(11);
		value = -value;
	} else {
		clearLED(11);
	}
	//handled hundreds
	if (value / 100)
		setLED(13);
	else
		clearLED(13);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0x00FF;
	pio_val |= (tens << 12);
	pio_val |= (ones << 8);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void printSignedHex1(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	DWORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(10);
		value = -value;
	} else {
		clearLED(10);
	}
	//handled hundreds
	if (value / 100)
		setLED(12);
	else
		clearLED(12);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0xFF00;
	pio_val |= (tens << 4);
	pio_val |= (ones << 0);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void setKeycode(WORD keycode)
{
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, keycode);
}

int keyNote(int key, int* octave, int* musicKey){
    //return key's frequency

    int ret = 0;
    switch(key){

        //part 1: white keys
        case 4: //A
            ret = 36;
            break;
        case 22: //S
            ret = 38;
            break;
        case 7: //D
            ret = 40;
            break;
        case 9: //F
            ret = 41;
            break;
        case 10: //G
            ret = 43;
            break; 
        case 11: //H
            ret = 45;
            break;
        case 13: //J
            ret = 47;
            break;
        case 14: //K
            ret = 48;
            break;
        case 15: //L
            ret = 50;
            break;
        case 51: //;
            ret = 52;
            break;

        //part 2: black keys
        case 26: //W
            ret = 37;
            break;
        case 8: //E
            ret = 39;
            break;
        case 23: //T
            ret = 42;
            break;
        case 28: //Y
            ret = 44;
            break;
        case 24: //U
            ret = 46;
            break;
        case 18: //O
            ret = 49;
            break;
        case 19: //P
            ret = 51;
            break;

        //part 3: shift keys
        case 29: //Z
            *octave -= 1;
            break;
        case 27: //X
            *octave += 1;
            break;
        case 6: //C
            *musicKey -= 1;
            break;
        case 25: //V
            *musicKey += 1;
            break;
        default:
            ret = 0;
    }
    return ret;
}

int main() {

	int freq = 0;

	const int offset = 2;

	int ph0 = 0;
	int ph1 = 0;
	int ph2 = 0;

	unsigned* si0 = 0x4000;
	unsigned* si1 = 0x0120;
	unsigned* si2 = 0x00b0;
	unsigned* sikb = 0x0090;

	unsigned* lights = 0x000c0000;
	unsigned* instant_drum = 0x30;

	int freq2, freq3;
	char counter0 = 0;
	char counter1 = 0;
	char counter2 = 0;

	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	WORD keycode;
	int * mainOctave;
	int * mainKey;
	*mainOctave = 0;
	*mainKey = 0;

	printf("initializing MAX3421E...\n");
	MAX3421E_init();
	printf("initializing USB...\n");
	USB_init();


	// Turn off all the lights
	*lights = 0x00;

	// Wait for start key
	while(kbdbuf.keycode[0] != 0x2B) {
		MAX3421E_Task();
		USB_Task();

		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				device = GetDriverandReport();
			} else if (device == 1) {
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
				if (rcode == hrNAK) {
					continue; //NAK means no new data
				} else if (rcode) {

					continue;
				}

                int myNote;
				int myFreq;
                if (kbdbuf.keycode[0] != 0) {
                    myNote = keyNote(kbdbuf.keycode[0], mainOctave, mainKey);
					myFreq = freq_lut[myNote+(12*(*mainOctave))+(*mainKey)];
                }
                else {
                    myFreq = 0;
                }
                // write that frequency
                *sikb = myFreq;


                // Do instant drum
				char do_drum = 0;

				for (char i = 0; i < 6; i ++) {
					if (kbdbuf.keycode[i] == 0x2c) {
						do_drum = 1;
					}
				}

				*instant_drum = do_drum;

				}
		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
				errorflag = 1;
				clearLED(9);
			}
		} else //not in USB running state
		{
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}

	}
	printf("Start to play music!\n");

	while (1) {
		if (*(si0)) {
			counter0 ++;
			if(chan0[ph0*3+1]!=0){
				freq = freq_lut[chan0[ph0*3]];
			}
			else{
				freq = 0;
			}
			*(si0) = (chan0[(ph0+1)*3+2]*offset << 16) | freq;
			if (counter0 % 4 == 0) {
				*lights = (*lights & 0xFE) | ~(*lights & 0x01);
			}
			ph0 ++;
		}
		if (*(si1)) {
			counter1 ++;
			if(chan1[ph1*3+1]!=0){
				freq2 = freq_lut[chan1[ph1*3]];
			}
			else{
				freq2 = 0;
			}
			*(si1) = (chan1[(ph1+1)*3+2]*offset << 16) | freq2;
			if (counter1 % 8 == 0) {
				*lights = (*lights & 0xFD) | ~(*lights & 0x02);
			}
			ph1 ++;
		}
		if (*(si2)) {
			counter2 ++;
			if(chan2[ph2*3+1]!=0){
				freq3 = freq_lut[chan2[ph2*3]];
			}
			else{
				freq3 = 0;
			}
			*(si2) = (chan2[(ph2+1)*3+2]*offset << 16) | freq3;
			if (counter2 % 16 == 0) {
				*lights = (*lights & 0xFB) | ~(*lights & 0x04);
			}
			ph2 ++;
		}

		MAX3421E_Task();
		USB_Task();

		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				device = GetDriverandReport();
			} else if (device == 1) {
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
				if (rcode == hrNAK) { continue; //NAK means no new data
				} else if (rcode) {

					continue;
				}

                int myNote;
				int myFreq;
                if (kbdbuf.keycode[0] != 0) {
                    myNote = keyNote(kbdbuf.keycode[0], mainOctave, mainKey);
					myFreq = freq_lut[myNote+(12*(*mainOctave))+(*mainKey)];
                }
                else {
                    myFreq = 0;
                }
                // write that frequency
                *sikb = myFreq;

                // Do instant drum
                char do_drum = 0;

                for (char i = 0; i < 6; i ++) {
                	if (kbdbuf.keycode[i] == 0x2c) {
                		do_drum = 1;
                	}
                }

                *instant_drum = do_drum;

				}
		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
				errorflag = 1;
				clearLED(9);
//				printf("USB Error State\n");
				//print out string descriptor here
			}
		} else //not in USB running state
		{

//			printf("USB task state: ");
//			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}

	}
	return 0;
}

int main3(){
	while(1){

		unsigned * si = 0x4000;
		int freq = 0;
		int j=0;
		while(1){
			for(int i=0; i<100000; i++){

			}
			printf("f = %d", freq);
			freq = freq_lut[(j++)%sizeof(freq_lut)];
			*si = freq;
		}
	}
}

void delay(int ms){
	for(int i=0; i<ms*40; i++){

	}
}
int main4(){

	int freq = 0;

	const int offset = 2;

	int ph0 = 0;
	int ph1 = 0;
	int ph2 = 0;

	unsigned* si0 = 0x4000;
	unsigned* si1 = 0x0120;
	unsigned* si2 = 0x00b0;

	int freq2, freq3;

//	unsigned* drum = 0x80000;
//	*drum = 436;

	while(1) {
		if (*(si0)) {
			if(chan0[ph0*3+1]!=0){
				freq = freq_lut[chan0[ph0*3]];
			}
			else{
				freq = 0;
			}
			*(si0) = (chan0[(ph0+1)*3+2]*offset << 16) | freq;
			ph0 ++;
		}
		if (*(si1)) {
			if(chan1[ph1*3+1]!=0){
				freq2 = freq_lut[chan1[ph1*3]];
			}
			else{
				freq2 = 0;
			}
			*(si1) = (chan1[(ph1+1)*3+2]*offset << 16) | freq2;
			ph1 ++;
		}
		if (*(si2)) {
			if(chan2[ph2*3+1]!=0){
				freq3 = freq_lut[chan2[ph2*3]];
			}
			else{
				freq3 = 0;
			}
			*(si2) = (chan2[(ph2+1)*3+2]*offset << 16) | freq3;
			ph2 ++;
		}
	}

//	int freq = 0;
//		for(int i=0; i<sizeof(chan0)/12; i++){
//			if(chan0[i*3+1]!=0){
//				freq = freq_lut[chan0[i*3]];
//			}
//			else{
//				freq = 0;
//			}
//			*si = (chan0[(i+1)*3+2] << 16) | freq;
//			 while (!*si) {}
//		}
}


//int main() {
//	unsigned* drum = 0x80000;
//	*drum = 1000;
//	while(1) {
////		printf("%d\n", *drum);
//	}
//}

int main6() {
	unsigned* lights = 0x000c0000;
	*lights = 0xff;
}
