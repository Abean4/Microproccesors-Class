
;           < Every program submitted in this class must follow the formatted prescribed here. What follows is																									
; a minimal program. I suggest you copy this to start every programming project.>																									
;-----------------------------------------------------------------------------------------------------------------------																									
;																									
;            Assignment #:    Assignment 2 (Receiver)																								
;            Authors : 		Bean, Anthony, E01362835
;				Khan, Ismet, E01303340
;				McGrath, Connor, E01449286
;            Filename:	      Receiver.asm																									
;            Date:   	      3/25/19																							
;																									
;            Program Description: This program constantly reads in from a receiver. When the receiver switches from a
;					high pulse to a low pulse, this program will begin to pay attention. It'll skip
;					the start bit (which acts as the signal that the sender is about to send a code),
;					read the next 3 bits, then returns to idle mode until another bit code is sent.
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
																									
	cblock	0x20			;start of general purpose registers																				
		Count1			;  count1 is symbolic name for location 0x20																				
		Counta			;  counta is symbolic name for location 0x21																				
	endc																								
																									
																									
	org	0x00																							
	goto	SETUP																							
	org	0x04																							
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
	movlw		0x01																						
	movwf		TRISB		; portb pin 0 is input																				
	bcf		OPTION_REG, INTEDG	; interrupt on low to high																					
	bcf		STATUS,RP0 ;	;return to bank 0																					
																									
																									
;start  main code here																									
MAIN			
	nop																																															
	goto	MAIN																							
																									
																									
																									
INTERRUPTION		;Interruption has occurred
	call	DELAY_500_MICROS
	call	DELAY_1_MILLI						;999 micro																	
	btfsc	PORTB, 0
	goto	SET_0
	goto	CLEAR_0
	
SET_0
	bsf	PORTB, 3
	goto	CHECK_1
	
CLEAR_0
	bcf	PORTB, 3
	
CHECK_1
	call	DELAY_1_MILLI
	btfsc	PORTB, 0
	goto	SET_1
	goto	CLEAR_1
	
SET_1
	bsf	PORTB, 2
	goto	CHECK_2
	
CLEAR_1
	bcf	PORTB, 2
	
CHECK_2
	call	DELAY_1_MILLI
	btfsc	PORTB, 0
	goto	SET_2
	goto	CLEAR_2
	
SET_2
	bsf	PORTB, 1
	goto	END_INTER
	
CLEAR_2
	bcf	PORTB, 1
	goto	END_INTER
	
END_INTER
	bcf	INTCON, INTF																							
	retfie	
	

																									
DELAY_500_MICROS		;503 micros																							
	movlw	0x7c		;1, setting it to 125																					
	movwf	Count1		;1																					
	nop										;4(n)+1												
	decfsz	Count1																					
	goto	$-2																							
	return				;2																				
																									
DELAY_1_MILLI					;999 micros																				
	movlw	0xf9	;1																					
	movwf	Count1		;1																					
	nop						;4n+1															
	decfsz	Count1																							
	goto	$-2																						
	return																								
																									
																									
; don't forget the word 'end'																									
	end																								
