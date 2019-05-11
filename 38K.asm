;           < Every program submitted in this class must follow the formatted prescribed here. What follows is 
; a minimal program. I suggest you copy this to start every programming project.>
;-----------------------------------------------------------------------------------------------------------------------
;
;            Assignment #:    <put assignment number here>
;            Authors : < State all participants in the following format : last_name, first_name, EID>
;            Filename:   < Source filename>
;            Date:   <submission date>
;
;            Program Description: <what does this program do????? One line descriptions are lazy and will be penalized. 5 page
;                     descriptions are too long and no one will read them. Three to five sentences will do in most cases  >
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

START	
	movlw 	0x98 ;Setting count1 to 7
	movwf 	Counta
	movlw 	0xfa ;Setting count2 to 187
	movwf 	Countb
	call 	FLASH ;Flash each cycle
	decfsz 	Countb
	goto 	$-2
	decfsz 	Counta
	goto 	$-6

	movlw 	0x98 ;Setting count1 to 7
	movwf 	Counta
	movlw 	0xfa ;Setting count2 to 187
	movwf 	Countb
	call 	OFF ;Off for each cycle
	decfsz 	Countb
	goto 	$-2
	decfsz 	Counta
	goto	$-6
	goto 	START
	
FLASH ;Should take 24 microsec to complete, and the CALL of it takes 2, bringing us to our total of 26	
	bsf	 PORTB, 4
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
	nop ;High for 13 microseconds
	bcf	 PORTB, 4
	nop
	nop
	nop
	return
	
	
	
	
	
OFF ;Should take 24 microsec to complete, and the CALL of it takes 2, bringing us to our total of 26	
	
	movlw	0x05
	movwf	Count1	;Brings us to 2nd microsec
	nop
	
	nop				;This and the following should take 4(n-1)+3 microseconds
	decfsz 	Count1
	goto 	$-2
	return
		
	
; don't forget the word 'end'	
	end