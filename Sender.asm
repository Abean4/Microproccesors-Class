;           < Every program submitted in this class must follow the formatted prescribed here. What follows is																									
; a minimal program. I suggest you copy this to start every programming project.>																									
;-----------------------------------------------------------------------------------------------------------------------																									
;																									
;            Assignment #:    Assignment 2 (Sender)																								
;            Authors : 		Bean, Anthony, E01362835
;				Khan, Ismet, E01303340
;				McGrath, Connor, E01449286
;            Filename:	      sender.asm																									
;            Date:   	      3/25/19																							
;																									
;            Program Description: This program constantly sends bits to a receiver. It begins by sending filler bits,
;					so that the receiver reads them in and doesn't act on them. After a period of
;					filler bits, the sender then sends a start bit, followed by the 3 bits. After
;					the 3 bits are sent, the sender then returns to sedning the filler bits until
;					the next iteration of bits are sent, and so foth.
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
		Countc 			;  countb is symbolic name for location 0x23
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
WAIT		
	movlw	0x30	
	movwf	Counta	
	call	SEND_1_BIT	
	decfsz	Counta	
	goto	$-2	
	call	SEND_0_BIT	;Start Transmission	
	call 	SEND_0_BIT 	;first bit	
	decfsz  Countb	
	bsf 	PORTB, 3	
	call  	SEND_1_BIT 	;second bit	
	decfsz  Countb	
	bsf 	PORTB, 2	
	call 	SEND_0_BIT 	;final bit	
	decfsz  Countb	
	bsf 	PORTB, 1	
	goto  	WAIT	
		
		
		
		
		
		
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
; don't forget the word 'end'	
	end
