;           < Every program submitted in this class must follow the formatted prescribed here. What follows is 
; a minimal program. I suggest you copy this to start every programming project.>
;-----------------------------------------------------------------------------------------------------------------------
;
;            Assignment #:    Program 1
;            Authors : Bean, Anthony, E01362835
;					   Khan, Ismet, E01
;					   McGrath, Connor, E01
;            Filename:   38KHZ.asm
;            Date:   February 11th, 2019
;
;            Program Description: This program sends electrical pulses to an IR LED Bulb. The pulse will cycle between high 
;									and low in 13 microsecond intervals, then only a low pulse for the same amount of time.
;									This process repeats continuously as long as there is a power supply and no deprecation of equipment. 
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

; Filename : 38KHZ.asm

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
    movlw	0x06		    ;Setting count1 to 6
    movwf	Counta
    movlw	0xf4		    ;Setting count2 to 244
    movwf	Countb
	call	FLASH	    	;Flash each cycle
	decfsz	Countb		
	goto	$-2
    decfsz	Counta		
    goto	$-6
    
    movlw	0x06		    ;Setting count1 to 6
    movwf	Counta
    movlw	0xf4		    ;Setting count2 to 244
    movwf	Countb
	call	OFF	    	;Off for each cycle	
	decfsz	Countb		
	goto	$-2
    decfsz	Counta		
    goto	$-6
    goto	START		    ;Restart the Flash and Off periods continuously
	
	
    
FLASH	
    movlw	0xff
    movwf	PORTB
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
    nop					;High for 13 microseconds
    movlw	0x00
    movwf	PORTB
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
    nop					;Low for 13 microseconds
    return

OFF						;Should take 26 microsec to complete
  						;Last instructions ran should are from FLASH where PORTB is last set to 0, which is what we want here for OFF
  	movlw	0x06
    movwf	Count1		;Brings us to 2nd microsec
    nop					;Brings us to a 3rd microsec
    
    nop					;This and the following should take 4(n-1)+3 microseconds
    decfsz	Count1		
    goto	$-2
    return			
   
    
    

		
	
; don't forget the word 'end'	
    end









