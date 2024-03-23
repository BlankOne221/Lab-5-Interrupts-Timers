/*
* sevenSeg.S
*
* Created on: Mar 9, 2022
* Author: jacob / Artsem
*/

.ifndef SRC_SEVENSEG_S_
.set SRC_SEVENSEG_S_, 1

.set SEVSEG_BASEADDR, 0x43C10000

.text

# Enable the seven segment display and initialize all digits to 0
configure_sevenSeg:
	# Enable the seven segment display
	LDR r0, =SEVSEG_BASEADDR
	MOV r1, #1
	STR r1, [r0]
	# clear values and turn off decimal points
	LDR r1, =#0x80808080
	STR r1, [r0, #0x4]
	BX lr


# Write the 16-bit value passed by r1 into the seven segment display
# This is bascially a decimal seven segment display.
write_sevenSeg:
    PUSH {r4, r5, r6, LR}

	# base address of seven seg
    LDR r5, =SEVSEG_BASEADDR

    #display counter
    MOV r3, #0

    # offset
    MOV r4, #8
    MOV r6, #0x0

    loop:
    # check end of display
    CMP r3, #4
    BGE loop_end

    # divide r1 by r2
    # r0 = quotient
    # r1 = remainder
    MOV r2, #10
    BL divide

    # put in correct location
    MUL r2, r3, r4
    LSL r1, r1, r2
    ORR r6, r6, r1

    # move to the next location
    ADD r3, r3, #1

    MOV r1, r0

    B loop

    loop_end:
    STR r6, [r5, #4]
    POP {r4, r5, r6, LR}
    BX LR


# Divide function
# Divides r1/r2
# quotient is in r0, remainder in r1
divide:
    PUSH {r2}

    MOV r0, #0
    CMP r1, r2
    BLT Endcase

    loop1:
    	SUB r1, r1, r2
		ADD r0, r0, #1
        CMP r1, r2
        BGE loop1

    Endcase:
    POP {r2}
    BX LR


.endif /* SRC_SEVENSEG_S_ */
