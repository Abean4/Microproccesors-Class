;           < Every program submitted in this class must follow the formatted prescribed here. What follows is 
; a minimal program. I suggest you copy this to start every programming project.>
;-----------------------------------------------------------------------------------------------------------------------
;;
;            Assignment #:    	Program 2
;            Authors : 			Bean, Anthony, E01362835
;					Khan, Ismet, E01
;					McGrath, Connor, E01
;            Filename:  		Servo.asm
;            Date:   			February 11th, 2019
;
;            Program Description: This program sends electrical pulses to a (or the if applicable) servo motor(s).
;					A servo motor can be wired to pin 3 to move forward, or to pin 2 to move backward. 
;					The main idea behind both servo motors is that a servo receives a high pulse for 
;					about 1 millisecond to move forward and a high pulse for 2 milliseconds to move backward.
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

; Filename : Servo.asm

; DECLARE VARIABLES!!!!!!

	cblock 	0x20 			;start of general purpose registers
		Count1 			;  count1 is symbolic name for location 0x20
		Count2 			;  count2 is symbolic name for location 0x21
		Count3 			;  count3 is symbolic name for location 0x22
	endc

; FORGET THESE 2 LINES AND FUNNY STUFF HAPPENS

	movlw	0x07
	movwf	CMCON			;turn comparators off (make it like a 16F84)
	
; The following is very typical. We must change memory banks to set the TRIS registers

	bsf	STATUS,RP0
	movlw	0x00
	movwf	TRISB			; portb is output
	movlw	0xff
	movwf	TRISA			;porta is input
	bcf	STATUS,RP0		;return to bank 0

;start  main code here
				;To move the servo forward, the servo will need to be connected to pin 3.
				;To move the servo backward, the servo will need to be connected to pin 2
	TOP
		bsf		PORTB, 2		;Turning the backward servo on
		bsf		PORTB, 3		;Turning the forward servo on
		call	DELAY_1_MILLI	;Leave both on for 1 millisecond
		bcf		PORTB, 3		;Turning forward servo off
		call	DELAY_1_MILLI	;Leaving backward servo on for an additional milisecond
		bcf		PORTB, 2		;Turning forward servo off
	
		movlw	0x12			;Moving 18 into Count1
		movwf	Count1
		
		call	DELAY_1_MILLI	;Calling a 1 mili delay 18 times
		decfsz	Count1
		goto	$-2
		goto	TOP
	
	DELAY_1_MILLI
		
		movlw	0xF9			;249, 1 micro
		movwf	Count2			;Setting Count2 to 249, 1 micro
		nop						;1 micro
	
		nop						;Total of the following is 4(n-1)+5 micro
		decfsz	Count2
		goto	$-2
		return	
		
	
; don't forget the word 'end'	
	end
