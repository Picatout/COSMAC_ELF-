                            ; Cette version de TONE passe la valeur du délais 
                            ; comme paramètre et utilise les instructions 
                            ; MARK et RET pour l'appel de la sous-routine
                            ; R0  compteur ordinal routines INIT et GENTONE 
                            ; R2  pointeur de pile 
                            ; R3  compteur ordinal sous-routine DELAY  
                            ; RF  compteur de délais  
                            ; calcul de DLY_CNT
                            ; DLY_CNT= FRosc/(FRaudio*8*6*2)-1-(N/6)
                            ; FRosc est la fréquence du cristal sur le CDP1802
                            ; FRaudio est la fréquence audio désirée.
                            ; N est le nombre de cycles machine en dehors de 
                            ; la boucle LOOP qui se répètent à chaque demi-cycle
                            ; audio fréquence.
INIT:
00  F8 FF       LDI FF      ; initialise R2 comme pointeur de pile
02  A2          PLO R2      ; à la fin de la mémoire RAM
03  B2          PHI R2      ; R2 = $FFFF
04  E2          SEX R2      ; R2 devient le pointeur de pile 
05  C0 00 08    LBR GENTONE ; saut vers le programme GENTONE 

GENTONE:                    ; générateur de tonalité
08  F8 00       LDI DELAY.1 ; initialisation de R3 
0A  B3          PHI R3      ; à l'adresse de DELAY 
0B  F8 1A       LDI DELAY.0  
0D  A3          PLO R3      ; R3 = $001A adresse de DELAY

TONE:                       ; génération d'une tonalité sur Q 
0E  7B          SEQ         ; Q <- 1 
0F  7B          SEQ         ; juste pour utiliser 2 cycles machines 
10  79          MARK        ; T=X,P  M(R2)=T  P=X 
11  D3          SEP 3       ; appel sous-routine DELAY 
12  25          DLY_CNT     ; paramètre pour la sous-routine DELAY 500 hertz
13  7A          REQ         ; Q <- 0 
14  79          MARK        ; T=X,P  M(R2)=T  X=P
15  D3          SEP 3       ; appel sous-routine DELAY
16  25          DLY_CNT     ; paramètre pour la sous-routine DELAY 500 hertz 
17  30 0E       BR TONE     ;boucle à TONE 

DLY_EXIT:                   ; sortie de la sous-routine 
19  D0         RET          ; retourne au programme MAIN  
DELAY:                      ; entrée sous-routine DELAY 
1A  72         LDXA         ; D=M(RX) INC RX 
1B  AF         PLO  RF.0    ; RF.0 = D  
1C  F8 00      LDI  0       ; D = 0
1E  BF         PHI  RF.1    ; RF.1 = D 
LOOP:                       ; décrémente RF tant que RF.1==0 
1F  2F         DEC RF       ; RF = RF-1 
20  9F         GHI RF       ; D = RF.1 
21  32 1F      BZ LOOP      ; SI D==0 retourne à LOOP 
23  30 19      BR DLY_EXIT  ; délais terminé
25
