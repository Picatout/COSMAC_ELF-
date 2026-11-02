                            ; Cette version de TONE lit les toggle switches 
                            ; comme paramètre de délais pour la sous-routine 
                            ; DELAY 
                            ; R0  compteur ordinal routine MAIN 
                            ; R3  compteur ordinal sous-routine DELAY  
                            ; RF  compteur de délais  

INIT:
00  F8 FF       LDI FF      ; initialise R2 comme pointeur de pile
02  A2          PLO R2      ; à la fin de la mémoire RAM
03  B2          PHI R2      ; R2 = $FFFF
04  E2          SEX R2      ; R2 devient le pointeur de pile 
05  F8 00       LDI DELAY.1 ; initialisation de R3 
07  B3          PHI R3      ; à l'adresse de DELAY 
08  F8 13       LDI DELAY.0  
0A  A3          PLO R3      ; R3 <- adresse de DELAY $000D

TONE:                       ; génération d'une tonalité sur Q 
0B  7B 7B       SEQ SEQ     ; Q = 1 
0D  D3          SEP R3      ; appel sous-routine DELAY 
0E  7A          REQ         ; Q = 0 
0F  D3          SEP R3      ; appel sous-routine DELAY
10  30 0B       BR  TONE    ;boucle à TONE 

EXIT:                       ; sortie de la sous-routine 
12  D0          SEP R0      ; retourne au programme MAIN  
DELAY:                      ; entrée sous-routine DELAY 
13  6C          IN  TOGGLES ; initialise le compteur de délais D=toggles
14  64          OUT DISPLAY ; par la lectures des toogles switches 
15  22          DEC R2      ; R2=R2-1
16  AF          PLO  RF.0   ; RF.0= D 
17  F8 00       LDI  0      ; D <- 0
19  BF          PHI  RF     ; RF.1 <- 0 
LOOP:                       ; décrémente RF tant que RF.1==0 
1A  2F          DEC RF      ; RF <- RF-1 
1B  9F          GHI RF      ; D <- RF.1 
1C  32 1A       BZ LOOP     ; SI D=0 retourne à LOOP 
1E  30 12       BR EXIT     ; délais terminé
20

