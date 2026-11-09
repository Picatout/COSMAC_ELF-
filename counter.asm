		; Ce programme affiche un compte en continue
		; R0 utilisé comme compteur 
		; R1 compteur ordinal du programme 
		; R2 compteur de délais
		
.ORG 8000
00  F8 FF   LDI FF        ; 
02  A0 B0   PLO R0 PHI R0 ; R0=FFFF
04  F8 00   LDI 00        ; initialise le compteur 
06  50      STR M(R0)     ; M(FFFF)=00
COUNTER:
07  E0      SEX 0         ; X=0
08  64      OUT DISPLAY   ; display M(R0)
09  20      DEC R0        ; remet R0=FFFF
0A  F0		LDX           ; D= M(R0)
0B  FC 01   ADI 01        ; D=D+1
0D  50		STR M(R0)     ; M(R0)=D 
DELAY:
0E  F8 40   LDI 40        ; durée du délais 
10  B2      PHI R2        ; R2 compteur de délais 
LOOP:                     ; boucle du délais 
11  22		DEC R2 
12  92 		GHI R2 
13  3A 11   BNZ LOOP 
15  30 07   BR COUNTER 
