; copie code de la RAM vers l'EEPROM 
; R2 STKPTR 
; R3 PC 
; R4 SRC 
; R5 DEST 
; RF COMPTE 

; copie les sous-routine de 0x8130 vers 0x1F30
	ORG 8400H 
		
	    LDI 80H 
        PHI 4
        LDI 00H
        PLO 4
        PLO 5
        LDI 1EH
        PHI 5 
        LDI 10H   
        PLO 0Fh
        LDI 1 
        PHI 0FH 
LOOP
		LDA 4
        STR 5
        STR 2
LP02         
        LDN 5 
        XOR 
        BNZ LP02 	         
		INC 5 
		DEC 0FH 
		GLO 0FH
		STR 2 
		GHI 0FH 
		OR  
		BNZ LOOP
		REQ
		SEQ
		IDL 
 
	END 
		
 
 

