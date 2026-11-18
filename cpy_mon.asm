; copi elf+Mon à l'adresse 8200
.ORG 8200 

00  F8 00	    LDI 00 
02  B4	        PHI R4
03  A4	        PLO R4
04  A5	        PLO R5 
05  F8 80	    LDI 82
07  B5	        PHI R5
08  F8 44	    LDI 44  
0A  AF	        PLO RF
LOOP:
0B  44			LDA M(R4)
0C  55           STD M(R5)	         
0D  15			INC R5 
0E  2F			DEC RF 
0F  8F			GLO RF 
10  3A 0B   	BNZ LOOP
12  7B
13  00 
 

