.ORG 8100
00  F8 FF    LDI FF
02  A2       PLO R2 
03  B2       PHI R2     ;  RX=FFFF
04  E2       SEX R2     ; X=2 
05  7B       SEQ      ; Q doit-être à 1
CIN:
06  3D 06    BN2 CIN  ; attend le START bit  
08  F8 09    LDI 09  ; initialise le compteur de bits  
0A  AE       PLO RE  ; RE.0 décompte les bits reçus
0B  F8 00    LDI 00  ; initialise caractère reçu.
0D  BE       PHI RE  ; RE.1= C  
BLOOP: 				 ; bit loop 
0E  F8 05    LDI NN  ; NN=(52-22)/6 
10  AF       PLO RF  ; RF compteur de délais 
DELAY:               ; boucle délais de bit
11  2F       DEC RF 
12  8F       GLO RF
13  3A 11    BNZ DELAY  
15  9E       GHI RE  ; D=C
16  F6       SHR     ; décale C à droite 
17  35 1D    B2  1C  ; si ~EF2=1 va à 1B, bit 7 reste à 0  
19  F9 80    ORI 80  ; met bit 7 à 1  
1B  30 1D    BR  1C  ; ajustement pour délais
1D  BE       PHI RE  ; sauvegarde C dans RF.1
1E  2E       DEC RE  
1F  8E       GLO RE  ; si non nul  
20  3A 0E    BNZ BLOOP ;reçoit bit suivant

STOP:				 ; attend stop bit 
22  F8 05    LDI 05 
24  AF       PLO RF  ; délais STOP bit  
SLOOP:      
25  2F       DEC RF  ; décrémente RF 
26  8F       GLO RF    ; si non nul 
27  3A 25    BNZ SLOOP  ; boucle 
29  9E       GHI RE   ; caractère reçu 
2A  52       STR (R2)  ; M(RX)=C
2B  64       OUT DISPLAY ; affiche le code ASCII 
2C  22       DEC R2      ; remet RX à FFFF
2D  30 06    BR CIN      ; recommence
2F 
