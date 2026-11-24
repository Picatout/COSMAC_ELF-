
; enregistrement de programme en utilisant 
; une fréquence audio de 2400||4800 
; 2400 correspond à un 0 
; 4800  correspond à un 1 
; PC R3 
; R8 routine SEND_BYTE  
; R9 routine RCV_BYTE
; RA routine TONE 

.ORG 8000
INIT:
00  71          DIS         ; désactive les interruptions
01  00			.BYTE 00    ;
02  F8 FF       LDI FF      ; initialise R2 comme pointeur de pile
04  A2          PLO R2      ; à la fin de la mémoire RAM
05  B2          PHI R2      ; R2 = $FFFF
06  E2          SEX R2      ; R2 devient le pointeur de pile 
07  93          GHI R3      ; initialisation de R8, R9 et RA
08  B8          PHI R8      ; avec l'adresse des routines
09  B9          PHI R9
    BA          PHI RA 
0A  F8 aa       LDI SEND_BYTE & FF 
0C  A8          PLO R8 
0D  F8 aa       LDI RCV_BYTE & FF 
0E  A9          PLO R9  
    F8 aa       LDI TON & FF 
    AA          PLO RA 
				REQ 
				
; sent byte test code 
SEND_KBD:
10  79  		MARK
11  D4          SEP GETBYTE
12  22          DEC R2
13  52          STR R2 
14  64          OUT DISPLAY 
15  22          DEC R2 
16  			SHL         
17  BE          PHI RE  RE.1=C , DF=bit 7 
13  D8          SEP R8 
14  30 10       BR SEND_KBD 

SB_EXIT:        D3 
SENBYTE:                    
				LDI 9
				PLO RE
SLOOP:
				GHI RE 
				SHR 
				BNF  B01 
				LDI  N1  ; high frequency 
				BR   TONE
				
B01:				
				LDI  N2   ; low frequency 
				SEP  TONE 
				GLO  RE 
				DEC  RE 
				BNZ  SLOOP 
				LDI  N2 
				SEP  TONE ; STOP bit 
				BR  SB_EXIT   

TONE_EXIT: 
				SEP R8 
TONE:                       ; génération d'une tonalité sur Q 
				LDI 02 
				PHI RF 
T00:
0E  7B          BQ  T01           ;  
0F  7B          REQ
				LDI  N0 
				BR  T02 
T01:
				SEQ 
				LDI N1 
				BR T02 
T02:            
				PLO RF 
10  79          MARK        ; T=X,P  M(R2)=T  P=X 
11  D3          SEP R6       ; appel sous-routine DELAY 
13  22          DEC R2
				PHI RF 
				SMI 01
				BNZ T00 
				BR TONE 
				BR TONE_EXIT 
				
