;           < Every program submitted in this class must follow the formatted prescribed here. What follows is																									
; a minimal program. I suggest you copy this to start every programming project.>																									
;-----------------------------------------------------------------------------------------------------------------------																									
;																									
;            Assignment #:    Assignment 3 (Keypad Sender)																								
;            Authors : 		Bean, Anthony, E01362835
;							Khan, Ismet, E01303340
;							McGrath, Connor, E01449286
;            Filename:	      kbsender.asm																									
;            Date:   	      3/25/19																							
;																									
;            Program Description: This program allows the use of a keypad to send sequences to a receiver.
;					It checks for keypad input, and calls the necessary function to send
;					the appropriate bits. After a sequence is sent, the program calls a 
;					3 millisecond delay. If nothing is pressed during the looping, the
;					program continues sending nothing.
;																									
;            < Let's agree upon the following conventions:																									
;                           Labels (for goto statements and functions) - ALL_CAPS																									
;                           Variable Names - first letter is capitalized, all rest are lower case. For example:  Count, Pint, Inches																									
;                           Commands - all lower case. For example:   goto , decfsz ,																									
;                           Defined Constants - ALL_CAPS (examples below)>																									
;------------------------------------------------------------------------------------------------------------------------------																									
;																									
;																									
;					
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; Filename : Sample.asm

; DECLARE VARIABLES!!!!!!
cblock 	0x20 			;start of general purpose registers
		Count1 			;  count1 is symbolic name for location 0x20
		Counta 			;  counta is symbolic name for location 0x21
		Countb 			;  countb is symbolic name for location 0x22
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

READ_KBD
;	movlw 0x00
	; inelegant code, but it does work!
	; code  1- turn left
	;       2- go straight
	;       3- go right
	;       5- go in reverse
	;       anything else, transmit a zero and stop motors
	
	bsf 	PORTB, 4			;	lets scan the first column of keys		
	btfsc 	PORTB, 0			;	has the 1 key been pressed? if yes then send 1
	call	PUSHED_1			;
	btfsc	PORTB, 1			;	has the 4 key been pressed? if yes then
	call	PUSHED_4			;
	btfsc 	PORTB, 2			;	has the 7 key been pressed? if yes then
	call	PUSHED_7	;	copy decimal number 07 into w. but if not then continue on.
	bcf 	PORTB, 4			;	now we have finished scanning the first column of keys
	
	bsf 	PORTB, 5			;	lets scan the middle column of keys
	btfsc 	PORTB, 0			;	has the 2 key been pressed? if yes then
	call	PUSHED_2			;	copy decimal number 02 into w. but if not then continue on.
	btfsc 	PORTB, 1			;	has the 5 key been pressed? if yes then
	call	PUSHED_5			;	copy decimal number 05 into w. but if not then continue on.
	btfsc 	PORTB, 2			;	has the 8 key been pressed? if yes then
	call	PUSHED_7			;copy decimal number 00 into w. but if not then continue on.
	bcf 	PORTB, 5			;	now we have finished scanning the middle column of keys
	
	bsf 	PORTB, 6			;	lets scan the last column of keys
	btfsc 	PORTB, 0			;	has the 3 key been pressed? if yes then
	call	PUSHED_3		;	copy decimal number 03 into w. but if not then continue on.
	btfsc 	PORTB, 1			;	has the 6 key been pressed? if yes then
	call	PUSHED_6		;	copy decimal number 06 into w. but if not then continue on.
	btfsc 	PORTB, 2			;	has the 9 key been pressed? if yes then
	call	PUSHED_7			;	copy decimal number 09 into w. but if not then continue on.
	bcf 	PORTB, 6			;	no

	call	WAIT
	goto	READ_KBD


;Our what-if the number is ever greater than 6 --> Our error alarm
PUSHED_7
	call	SEND_0_BIT		
	call	SEND_1_BIT		
	call	SEND_1_BIT
	call	SEND_1_BIT
	return

PUSHED_1
	call	SEND_0_BIT		
	call	SEND_0_BIT		
	call	SEND_0_BIT
	call	SEND_1_BIT
	return		
		
PUSHED_2
	call	SEND_0_BIT		
	call	SEND_0_BIT		
	call	SEND_1_BIT
	call	SEND_0_BIT
	return		
		
PUSHED_3
	call	SEND_0_BIT		
	call	SEND_0_BIT		
	call	SEND_1_BIT
	call	SEND_1_BIT
	return		
		
PUSHED_4
	call	SEND_0_BIT		
	call	SEND_1_BIT		
	call	SEND_0_BIT
	call	SEND_0_BIT
	return		
		
PUSHED_5
	call	SEND_0_BIT		
	call	SEND_1_BIT		
	call	SEND_0_BIT
	call	SEND_1_BIT
	return		
		
PUSHED_6
	call	SEND_0_BIT		
	call	SEND_1_BIT		
	call	SEND_1_BIT
	call	SEND_0_BIT
	return		
		
WAIT
	movlw	0x03
	movwf	Counta
	call	SEND_1_BIT
	decfsz	Counta
	goto	$-2
	return

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
	bsf		PORTA, 0
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
	bcf		PORTA, 0
	nop	
	nop	
	nop	
	return			;6 micro --> 22micro
		
		
OFF		
	bcf		PORTA, 0
	movlw	0x05
	movwf	Count1
	nop	
		
	nop	
	decfsz	Count1
	goto	$-2
	return		
; don't forget the word 'end'	
	end
