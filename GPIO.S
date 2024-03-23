
# Created by Dr.Murray / Artsem Labanau

.set GPIO_BASEADDR, 0xE000A000

# More addresses needed
.set BUTTONS, 0x41200000
.set LEDS, 0x41210000

.text

# set up LED12 as an output
# enable LED12 as an output
# clear LED12 to off initally
# setup BTN4 and BTN5 as inputs
# setup buttons
initialize_GPIO:

LDR r0, =GPIO_BASEADDR
LDR r1, =#0x70000
STR r1, [r0, #0x204] @ set up LD12 as an output
STR r1, [r0, #0x208] @ to enable LD12 as an output

LDR r1, =#0xFFF80000 @ mask off everything a 1 except what we need
STR r1, [r0, #0x04]

MOV r1, #0
STR r1, [r0, #0x244] @ setup BTN4 and BTN5 as input

MOV pc, lr


# first disable GPIO interrupts to avoid purious interrupts to trigger
# setup the sensitivity of BTN 4 and BTN 5 interrupts
# enable BTN 4 and BTN 5 interrupts
intialize_GPIO_interrupts:
LDR r0, =GPIO_BASEADDR
LDR r1, =#0xFFFFFFFF @ Disable all GPIO interrupts
STR r1, [r0, #0x214]
STR r1, [r0, #0x254]

# sensitivity setup
LDR r1, =#0xC0000
STR r1, [r0, #0x25C] @ edge-sensitive
STR r1, [r0, #0x260] @ rising edge

MOV r1, #0
STR r1, [r0, #0x264] @ only rising edge

# enable section
LDR r1, =#0xFFFFFFFF
STR r1, [r0, #0x258]

LDR r1, =#0xC0000
STR r1, [r0, #0x250]

MOV pc, lr

# a get buttons state function that stores button state in r0
get_buttons:

PUSH {r1}

	LDR r1, =BUTTONS
	LDR r0, [r1]

	AND r0, r0, #0xF

POP {r1}
BX LR

LEDs:

	PUSH {r1, r2}

	LDR r1, =LEDS
	LDR r2, [r1]
	MOV r2, #0b1000
	STR r2, [r1]

	POP {r1, r2}
BX LR
