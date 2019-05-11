
;           < Every program submitted in this class must follow the formatted
;				 prescribed here. What follows is a minimal program. I suggest
;				you copy this to start every programming project.>
;-----------------------------------------------------------------------------------
;
;            Assignment #:	Assignment 5 (Robot Receiver but with some automation)
;            Authors : 			Bean, Anthony, E01362835
;								Khan, Ismet, E01303340
;								McGrath, Connor, E01449286
;            Filename:		Robot_Receiver.asm
;            Date:			4/3/19
;
;            Program Description: This program constantly reads in from a receiver.
;					 When the receiver switches from a high pulse to a low pulse,
;					 this program will begin to pay attention. It'll skip the start
;					 bit (which acts as the signal that the sender is about to send
;					 a code), read the next 3 bits, returns to idle mode, and 
;					 performs the requested action.
;
;            < Let's agree upon the following conventions:
;                           Labels (for goto statements and functions) - ALL_CAPS
;                           Variable Names - first letter is capitalized,
;								all rest are lower case. For example:  Count, Pint, Inches
;                           Commands - all lower case. For example:   goto , decfsz ,
;                           Defined Constants - ALL_CAPS (examples below)>
;-----------------------------------------------------------------------------------
;
;
;
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)
	
; Filename : Robot_Receiver.asm
; DECLARE VARIABLES!!!!!!

	cblock	0x20			;start of general purpose registers
		Count1			;  count1 is symbolic name for location 0x20
		Counta			;  counta is symbolic name for location 0x21
    Countb      ; countb.
		Clicked			;  stores what was pushed
	endc																							
	

	org		0x00
	goto	SETUP
	org		0x04
	goto	INTERRUPTION
	
;The Main portion of the program																									
; FORGET THESE 2 LINES AND FUNNY STUFF HAPPENS
	movlw	0x07
	movwf	CMCON			;turn comparators off (make it like a 16F84)

;Setting the interrupts for B0 (enabling both interrupts and B0 as an input interruption)
SETUP
	bsf		INTCON,GIE		;enable global interrupts
	bsf		INTCON,4		;enable B0 interrupt
	bcf		INTCON,1
	bsf		STATUS,RP0		;goto bank 1
	movlw	0x01
	movwf	TRISB		; portb pin 0 is input
	bcf		OPTION_REG, INTEDG	; interrupt on low to high
	bcf		STATUS,RP0 ;	;return to bank 0		


;start  main code here
MAIN
	movlw	0x50
	movwf	Countb
	call	FORWARD
	decfsz	Countb
	goto	$-2

	call	RIGHT
	call	STOP
	goto	MAIN
	
	
	
	
	

;FORWARD == On for 2 mili, off for 18
;BACKWARD == On for 1 mili, off for 19
;Wheel1 == Left wheel == PORTB, 3
;Wheel2 == Right wheel == PORTB, 2

;We want both wheels moving backward
LEFT		;001
	bsf		PORTB, 3		;Turning the backward servo on
	bsf		PORTB, 2		;Turning the forward servo on
	call	DELAY_1_MILLI	;Leave both on for 1 millisecond
	bcf		PORTB, 3		;Turning both off
	bcf		PORTB, 2
	
	movlw	0x13			;Moving 19 into Count1
	movwf	Count1

	call	DELAY_1_MILLI	;Calling a 1 mili delay 18 times
	decfsz	Count1
	goto	$-2

	return


;Wheel1 forward, Wheel2 backward
FORWARD		;010
	bsf		PORTB, 3
	bsf		PORTB, 2
	call	DELAY_1_MILLI	;Leave both on for 1 millisecond
	bcf		PORTB, 2		;Turning Wheel2 off
	call	DELAY_1_MILLI	;Leaving Wheel1 servo on for an additional millisecond
	bcf		PORTB, 3

	movlw	0x12			;Moving 18 into Count1
	movwf	Count1

	call	DELAY_1_MILLI	;Calling a 1 mili delay 18 times
	decfsz	Count1
	goto	$-2

	return

;both wheels moving backward
RIGHT		;011
	bsf		PORTB, 3
	bsf		PORTB, 2
	call	DELAY_1_MILLI	;Leave wheels on for 2 millisecond
	call	DELAY_1_MILLI
	bcf		PORTB, 3		;Turn off both wheels
	bcf		PORTB, 2

	movlw	0x12			;Moving 18 into Count1
	movwf	Count1

	call	DELAY_1_MILLI	;Calling a 1 mili delay 18 times
	decfsz	Count1
	goto	$-2

	return


;Wheel1 moving backward, Wheel2 moving forward
BACKWARD	;101
	bsf		PORTB, 3
	bsf		PORTB, 2
	call	DELAY_1_MILLI	;Leave both on
	bcf		PORTB, 3
	call	DELAY_1_MILLI
	bcf		PORTB, 2

	movlw	0x12			;Moving 18 into Count1
	movwf	Count1

	call	DELAY_1_MILLI	;Calling a 1 mili delay 18 times
	decfsz	Count1
	goto	$-2

	return


;AINT NO WHEELS BE MOVING!
STOP		;100 OR 110
	bcf		PORTB, 3
	bcf		PORTB, 2
	movlw	0x14			;Moving 20 into Count1
	movwf	Count1

	call	DELAY_1_MILLI	;Calling a 1 mili delay 18 times
	decfsz	Count1
	goto	$-2

	return


INTERRUPTION		;Interruption has occurred
	
	movlw	0x50
	movwf	Countb
	call	STOP
	decfsz	Countb	
	goto	$-2
	

	movlw	0xae
	movwf	Countb
	call	BACKWARD
	decfsz	Countb
	goto	$-2

	movlw	0x0f
	movwf	Countb
	call	STOP
	decfsz	Countb
	goto	$-2

	btfsc	PORTB, 1
	goto	LEFT_DO
	goto	RIGHT_DO	
	
;	btfsc	PORTB, 4		;if 0, then the first flag isn't set.
;	goto	BIT_1
;	goto	BIT_0


;BIT_0
;	btfsc	PORTB, 5		;if 0, then the second flag isn't set.
;	goto	BIT_01
;	goto	BIT_00

;BIT_00
;	bcf		PORTB, 4
;	bsf		PORTB, 5
;	call	LEFTDO
;BIT_01
;	bsf		PORTB, 4
;	bcf		PORTB, 5
;	call	
	
;BIT_1
;	btfsc	PORTB, 5		;if 0, then the second flag isn't set.
;	goto	BIT_11
;	goto	BIT_10

;BIT_10

;BIT_11

LEFT_DO
	movlw	0x07
	movwf	Countb
	call	LEFT
	decfsz	Countb	
	goto	$-2
	
	bcf		PORTB,1
	goto	END_INTER
	
RIGHT_DO
	movlw	0x09
	movwf	Countb
	call	RIGHT
	decfsz	Countb	
	goto	$-2
	
	goto	END_INTER

;SETL
	

END_INTER
	movlw	0x50
	movwf	Countb
	call	STOP
	decfsz	Countb	
	goto	$-2
	
	bcf	INTCON, INTF
	retfie


DELAY_500_MICROS		;503 micros
	movlw	0x7c		;1, setting it to 125
	movwf	Counta		;1
	nop					;4(n)+1
	decfsz	Counta
	goto	$-2
	return				;2

DELAY_1_MILLI			;999 micros
	movlw	0xf9		;1
	movwf	Counta		;1
	nop					;4n+1
	decfsz	Counta
	goto	$-2
	return

; don't forget the word 'end'
	end
