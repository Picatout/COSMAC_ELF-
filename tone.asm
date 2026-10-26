						; R0  compteur ordinal routine MAIN 
						; R3  compteur ordinal sous-routine DELAY  
						; RF  compteur de délais  
MAIN:
0	F8 00	LDI DELAY.1	; initialisation de R3 
2	B3		PHI R3      ; à l'adresse de DELAY 
3	F8 0D	LDI DELAY.0  
5	A3		PLO R3      ; R3 <- adresse de DELAY 

TONE:					; génération d'une tonalité sur Q 
6	7B		SEQ			; Q <- 1 
7	D3		SEP 3       ; appel sous-routine DELAY 
8	7A		RES 		; Q <- 0 
9	D3		SEP 3 		; appel sous-routine DELAY
A	30 06  	BR  0  		;boucle à TONE 

EXIT:			        ; sortie de la sous-routine 
C	D0		SEP 0		; retourne au programme MAIN  
DELAY:                  ; entrée sous-routine DELAY 
D	F8 50	LDI  50		; initialise le compteur de délais 
F	AF		PLO  RF		;
10	F8 00	LDI  0 
12	BF		PHI  RF   
LOOP:					; décrémente RF tant que RF.1==0 
13	2F	    DEC RF 
14	9F		GHI RF 		; D <- RF.1 
15	32 13	BZ LOOP     ; SI D=0 retourne à LOOP 
17	30 0C	BR EXIT     ; délais terminé


			
