; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
	LIST	p=16F628a		;tell assembler what chip we are using
	include "P16F628a.inc"		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

;-----------------------------------------------------------------------------------------------------------------------																									
;																									
;            Assignment #:    Assignment 5 (Keypad)																								
;            Authors : 		Bean, Anthony, E01362835
;				Khan, Ismet, E01303340
;				McGrath, Connor, E01449286
;            Filename:	      keypad.asm																									
;            Date:   	      3/25/19																							
;																									
;            Program Description: This program constantly reads in from a keypad. When the receiver detects a button being pressed
;					, this program will begin to pay attention. It'll skip
;					the start bit (which acts as the signal that the sender is about to send a code),
;					read the next 3 bits, then returns to idle mode until another bit code is sent.
;																									
;            < Let's agree upon the following conventions:																									
;                           Labels (for goto statements and functions) - ALL_CAPS																									
;                           Variable Names - first letter is capitalized, all rest are lower case. For example:  Count, Pint, Inches																									
;                           Commands - all lower case. For example:   goto , decfsz ,																									
;                           Defined Constants - ALL_CAPS (examples below)>																									
;------------------------------------------------------------------------------------------------------------------------------		


; Make life easy. Send bits in 1 msec intervals!!


; DECLARE VARIABLES!!!!!!
; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20. Please refer to technical documents to see if this is OK!!

cblock 	0x20 			;start of general purpose registers
		count1 			;  count1 is symbolic name for location 0x20
		counta 			;  counta is symbolic name for location 0x21
		countb 			;  countb is symbolic name for location 0x22
		NUMBER
	endc



;un-comment the following two lines if using 16f627 or 16f628
; FORGET THESE 2 LINES AND FUNNY STUFF HAPPENS

	movlw	0x07
	movwf	CMCON			;turn comparators off (make it like a 16F84)
	
; The following is very typical. We must change memory banks to set the TRIS registers

	bsf		STATUS,RP0
	movlw	0x0f
	movwf	TRISB			; portb is input. Remember pushdown (to ground) resisitors on input lines
					; this was erronoeously report as pull-ups. Corrected 2/13/2019
							; membrane keypad
							;  R1  R2  R3  R4  Col1  Col2  Col3  Col4
							;  B0  B1  B2  B3   B4    B5    B6    B7
							;   1   1   1   1    0     0     0     0
	movlw	0x00
	movwf	TRISA			;porta is output. Connect to resistor and IR LED
	bcf     STATUS,RP0		;return to bank 0

;start  main code here
main_loop

read_kbd

	movlw 0x00

	; inelegant code, but it does work!
	; code  1- turn left
	;       2- go straight
	;       3- go right
	;       5- go in reverse
	;       anything else, transmit a zero and stop motors
	
	bsf PORTB, 4			;	lets scan the first column of keys		
	btfsc PORTB, 0			;	has the 1 key been pressed? if yes then send 1
	movlw 0x01			;
	btfsc PORTB, 1			;	has the 4 key been pressed? if yes then
	movlw 0x00			;
	btfsc PORTB, 2			;	has the 7 key been pressed? if yes then
	movlw 0x00			;	copy decimal number 07 into w. but if not then continue on.
	bcf PORTB, 4			;	now we have finished scanning the first column of keys
	
	bsf PORTB, 5			;	lets scan the middle column of keys
	btfsc PORTB, 0			;	has the 2 key been pressed? if yes then
	movlw 0x02			;	copy decimal number 02 into w. but if not then continue on.
	btfsc PORTB, 1			;	has the 5 key been pressed? if yes then
	movlw 0x05			;	copy decimal number 05 into w. but if not then continue on.
	btfsc PORTB, 2			;	has the 8 key been pressed? if yes then
	movlw 0x00			;copy decimal number 00 into w. but if not then continue on.
	bcf PORTB, 5			;	now we have finished scanning the middle column of keys
	
	bsf PORTB, 6			;	lets scan the last column of keys
	btfsc PORTB, 0			;	has the 3 key been pressed? if yes then
	movlw 0x03			;	copy decimal number 03 into w. but if not then continue on.
	btfsc PORTB, 1			;	has the 6 key been pressed? if yes then
	movlw 0x00			;	copy decimal number 06 into w. but if not then continue on.
	btfsc PORTB, 2			;	has the 9 key been pressed? if yes then
	movlw  0x00			;	copy decimal number 09 into w. but if not then continue on.
	bcf PORTB, 6			;	no


;	lazy programmer! didn't even check other keys!!!


	movwf 	NUMBER	
	movf	NUMBER,1
	btfsc	STATUS,Z	; was a number other than 0 entered ? If yes, skip next statement

	goto read_kbd
	
;   Time to transmit. There is a start bit plus three more bits.
;   You might want to read up on the rlf and rrf commands, since you need to
;   shift bits to get to the three low order bits



	; send all 4 bits in here


	call	DELAY_1_MILLI	; let it resettle!!!!! Don't send stuff so fast!!
	call	DELAY_1_MILLI
	call	DELAY_1_MILLI
	goto	read_kbd	
	
	
	SEND_0_BIT	
	movlw	0x25 		;Setting count2 to 250
	movwf	Countb	
	call	FLASH 		;Flash each cycle, 22 micro
	decfsz	Countb
	goto	$-2
	return	
		
SEND_1_BIT	
	movlw	0x21 		;Setting count2 to 250
	movwf	Countb
	call	OFF 		;Off for each cycle
	decfsz	Countb
	goto	$-2
	return

FLASH		;Should take 22 microsec to complete, and the CALL of it takes 2, bringing us to our total of 26		
	bsf	PORTB, 4
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop 			;High for 16 microseconds	
	bcf	PORTB, 4
	nop	
	nop	
	nop	
	return			;6 micro --> 22micro
		
		
OFF		
	bcf	PORTB, 4
	movlw	0x05
	movwf	Count1
	nop	
		
	nop	
	decfsz	Count1
	goto	$-2
	return		
	
	DELAY_500_MICROS
	movlw	0x7c
	movwf	Count1
	nop
	decfsz	Count1
	goto	$-2
	return
																									
DELAY_1_MILLI
	movlw	0xf9
	movwf	Count1
	nop
	decfsz	Count1
	goto	$-2
	return

	
	end
