# Written by Dr.Murray / Artsem Labanau

.include "../src/interrupts.S"
.include "../src/GPIO.S"
.include "../src/timers.S"
.include "../src/sevenSeg.S"

.global main

# global variables
.global count
.global count_DI

.data

# jump table for different buttons
buttons: .word button0, button1, button2, button3, none

count: .word 0
count_DI: .word 0

.text

main:

	# place all of my setup here
	BL initialize_GPIO
	BL configure_sevenSeg

	# setup interrupts
	BL disable_interrupts
	BL intialize_GPIO_interrupts
	BL configure_GTC
	BL configure_GIC

	# Xil_ExceptionRegisterHandler(input id, IRQ_Handler, Data)
	# input parameters below
	MOV r0, #5
	LDR r1, =IRQ_Handler
	MOV r2, #0
	BL Xil_ExceptionRegisterHandler

	BL enable_interrupts

	# turn on green leds to proper amount intially
	BL LEDs

	whileOne:

	# decodes the button state & makes it easy for jump table reference
	decoder:
	MOV r0, #0
	BL get_buttons
	CMP r0, #0b0001
	MOVEQ r4, #0

	CMP r0, #0b0010
	MOVEQ r4, #1

	CMP r0, #0b0100
	MOVEQ r4, #2

	CMP r0, #0b1000
	MOVEQ r4, #3

	CMP r0, #0b0000
	MOVEQ r4, #4

	# switch statement for all my different buttons
	states:

	# branch to the correct button
	LDR r3, =buttons

	LDR r5, [r3, r4, LSL #2]

	BX r5

		# starts the up counter
		button0:
		BL start_timer
		LDR r0, =count_DI
		MOV r1, #1
		STR r1, [r0]

		# RGB Led 12 Blue
		LDR r0, =GPIO_BASEADDR
		LDR r3, =#0xFFF80001
		STR r3, [r0, #0x04] @ LED is turn on
		B endcase

		# starts the down counter
		button1:
		BL start_timer
		LDR r0, =count_DI
		MOV r1, #-1
		STR r1, [r0]

		# RGB LED 12 Red
		LDR r0, =GPIO_BASEADDR
		LDR r3, =#0xFFF80002
		STR r3, [r0, #0x04] @ LED is turn on
		B endcase

		# stops the counter
		button2:
		BL end_timer

		# RGB LED 12 Green
		LDR r0, =GPIO_BASEADDR
		LDR r3, =#0xFFF80004
		STR r3, [r0, #0x04] @ LED is turn on
		B endcase

		# clears the counter
		button3:
		LDR r0, =count
		MOV r1, #0
		STR r1, [r0]
		B endcase

		# no button pressed case
		none:
		B endcase

		# Just outputting
		endcase:
		LDR r0, =count
		LDR r1, [r0]
		BL write_sevenSeg
		# give up


	B whileOne

.end
