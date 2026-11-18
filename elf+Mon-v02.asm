                        ; elf+ Monitor  
                        ; Version 0.2 
                        ; Adaptation du programme de Joseph Weisbecker
                        ; paru dans le Popular electronics de mars 1977
                        ; 
                        ; R0 registre de travail 
                        ; R1 PC du moniteur 
                        ; R2 pointeur de donnée 
                        ; R3 adresse aaaa  
                        ; R4 GETBYTE 
                        ; R5 GETKEY
                        ; R6 DELAY
                        ; R7 BEEP
                        ; 
                        ; elf+ Monitor reconnaît 5 commandes 
                        ; la commande est sélectionnée par les toggles switches
                        ; 0 aaaa, Exécute le programme à l'adresse $aaaa
                        ; 1 aaaa, Modifie la mémoire débutant à l'adresse $aaaa
                        ; 2 aaaa, Examine la mémoire débutant à l'adresse $aaaa 
                        ; 3 aaaa nn , sauvegarde programme sur cassette 
                        ; 4 aaaa , charge programme à partir d'une cassette 
                        ; Un programme peut retourner au moniteur 
                        ; en faisant un saut long à l'adresse 0000
                        ; NOTES:
                        ;     1)puisque elf+ a plus que 256 octets de mémoire 
                        ;       le programme est modifié pour accepter des 
                        ;       adresses de 16 bits (4 chiffres hexadécimals)
                        ;     2) La switch IN est utiliséE pour la commande 01 
                        ;        afin d'afficher le conten M(R3) et passé à l'adresse suivante.
                        ;
.ORG 0000
INIT:
00  71          DIS           ; désactive les interruptions 
01  00          .BYTE 00      ; l'instruction DIS utilise cet octet X=0,P=0
02  90          GHI R0        ; Installation des sous-routines dans la page 01
03  B1          PHI R1        ; à l'adresse 0010 
04  B4          PHI R4        ; R4, PC de GETBYTE
05  B5          PHI R5        ; R5, PC de GETKEY 
06  B6          PHI R6        ; R6, PC de DELAY 
07  B7          PHI R7        ; R7, PC de BEEP 
08  F8 10       LDI 10        ; adresse ou R1 devient le PC du moniteur 
0A  A1          PLO R1        ; 
0B  D1          SEP R1        ; P=1 
0C  F8 FF       LDI FF        ; initialise R2 comme pointeur de donnée
0E  A2          PLO R2        ; à la fin de la mémoire RAM
0F  B2          PHI R2        ; R2 = $FFFF
10  E2          SEX R2        ; X=2
11  F8 5D       LDI GETBYTE.0 ; octet faible de l'adresse de GETBYTE      
13  A4          PLO R4        ; PC de GETBYTE
14  F8 71       LDI GETKEY.0  ; octet faible de l'adresse de GETKEY 
16  A5          PLO R5        ; PC de GETKEY
17  F8 7C       LDI DELAY.0   ; octet faible de l'adresse de DELAY
19  A6			PLO R6        ; PC de DELAY
1A  F8 86       LDI BEEP.0    ; octet faible de l'adrese de BEEP
1C  A7          PLO R7        ; PC de BEEP 

ELFMON:                       ; 
1D  79          MARK 
1E  D4          SEP GETBYTE 
1F  22          DEC R2        ; appel GETBYTE, obtient adresse high
20  B3          PHI R3        ; R3.1=aaaa>>8 
21  79			MARK 
22  D4          SEP GETBYTE   ; appel GETBYTE, obtient adresse low 
23  22          DEC R2 
24  A3          PLO R3        ; R3.0=aaaa & FF  
25  79          MARK 
26  D5          SEP GETKEY    ; code d'opération, retourné dans D 
27  22          DEC R2 
28  3A 2B       BNZ NOT_RUN  ; si D <> 0 commande 1,2,3 OU 4

;------------------------------
; exécution d'un programme 
; utilisant R3 comme PC 
;------------------------------
2A  D3          SEP R3        ; code d'opération 00, execute le programme 
                              ; dont l'adresse est dans R3 

;------------------------------
; sélecteur de commande 
;------------------------------
NOT_RUN:                      ; code 1,2,3 ou 4 
2B  FB 01       XRI 01        ; commande 1 ? 
2D  32 46       BZ MODIFY     ; commande MODIFY 
2F  FB 01       XRI 01        ; rétablie D 
31  FB 02       XRI 02        ; commande 2 ? 
33  32 4F       BZ EXAMINE    ; commande EXAMINE 
35  FB 02       XRI 02        ; rétablie D 
37  FB 03       XRI 03        ; commande 3 ? 
39  32 41       BZ  SAVE      ; commande SAVE 
3B  FB 03       XRI 03
3D  FB 04       XRI 04        ; commande 4 ? 
3F  32 41       BZ LOAD       ; commande LOAD 
BAD_CODE:
41  79          MARK 
42  D7          SEP BEEP      ; erreur BEEP 
43  22			DEC R2 
44  30 1D       BR ELFMON     ; recommande au début 

;------------------------------
; modification de la mémoire 
;------------------------------
MODIFY:                       ; code d'opération 01 
46  E2          SEX R2 
47  79          MARK 
48  D4          SEP GETBYTE   ; appel GETBYTE.
49  22          DEC R2 
4A  E1          SEX R1        ; R3 devient le pointeur de donnée.
4B  51          STR M(R1)     ; dépose D à l'adresse M(R1)
4C  64          OUT M(R1)     ; affiche M(R1) et R1=R1+1 
4D  30 46       BR MODIFY     ; boucle à MODIFY 

;-------------------------------
; examin de la mémoire 
;-------------------------------
EXAMINE:                      ; code d'opération 02
4F  E3          SEX R3        ; R3 devient le pointeur de donnée.         
WAIT_IN_DN:
50  3F 50       BN4 WAIT_IN_DN  ; attend que le bouton IN soit enfoncé
52  64          OUT DISPLAY   ; affiche l'octet en mémoire, R1=R1+1
WAIT_IN_UP:                              
53  37 53       B4 WAIT_IN_UP ; attend que le bouton IN soit relaché 
55  30 50       BR WAIT_IN_DN ; boucle à EXAMINE 
57  00 00
59  00 00 
5B  00   
;-------------------------------------
; GETBYTE 
; PC=R4
; lecture d'un octet au clavier 
; hexadécimal
; valeur retournée dans D 
;-------------------------------------
GB_EXIT: 
5C  71          DIS  		  ; X,P=M(R2) R2=R2+1, IE=0	
GETBYTE:                      ; lecture de 2 touches du clavier
5D  E2          SEX R2		  ; remet X=2 
5E  79          MARK          ; X,P -> T  X,P -> M(RX) RX=RX-1
5F	D5			SEP GETKEY    ; appel  GETKEY, 1ière touche  
60  22			DEC R2        ; parce que DIS incrémente R2  
61  FE FE       SHL SHL       ; décale D 2 fois à gauche 
63  FE FE       SHL SHL       ; décale D 2 fois à gauche
65  A0          PLO R0        ; dépose 16*D -> R0.0     
66  79          MARK 
67  D5          SEP GETKEY    ; appel GETKEY, 2ième touche
68  22			DEC R2        ; parce que DIS incrémente R2
69  22          DEC R2
6A  52          STD M(R2)     ; M(RX)=D 
6B  80          GLO R0        ; D=R0.0D
6C  F1          OR            ; D=D OR M(RX) 
6D  52          52 
6E  64          OUT DISPLAY   ; 
6F  30 5C       BR GB_EXIT    ;                                          

;------------------------------------
; GETKEY 
; PC=R5
; lecture d'une touche au clavier 
; hexadécimal.
; retourne la valeur dans D 
;------------------------------------                
GK_EXIT:        
71  12          INC R2        ; ajustement nécessaire pour M(R2)=X,P 
72  71          DIS           ; retourne à l'appellant, incrémente R2
GETKEY:                       ; lecture du clavier hexadécimal
73  E2			SEX R2         
WAIT_KD: 
74  3C 74       BN1 WAIT_KD   ; attend qu'un touche soit enfoncée.
76  69          INP 1         ; lecture de la valeur, D et M(RX)=KEY
WAIT_KR:
77  34 75       B1  WAIT_KR   ; attend que la touche soit relachée       
79  30 6F       BR  GK_EXIT   ; saut vers GK_EXIT                       
 

;------------------------------
; DELAY 
; PC=R6 
; insertion d'un délais 
; dans l'exécution.
; RF.0 durée du délais. 
; T=6*NN+12
;----------------------------- 
DELAY_EXIT:                   ; T = 6*NN+12
7B  E2          SEX R2 
7C	12			INC R2        ; pointe vers dernier MARK 
7D  71          DIS           ; exit to caller 
DELAY:                        ; délais pointé par M(RP) 
7E  72			LDXA		  ; compte délais 
7F  AF          PLO  RF       ; RF.0= délais                            
DLY_LOOP:
80  2F          DEC  RF                                                  
81  8F          GLO  RF 
82  3A 7E       BNZ DLY_LOOP  ; boucle tant que pas zéro 
84  30 79       BR DELAY_EXIT 
 

;-------------------------
; BEEP 
; PC=R7
; émet 1Khz pendant 100msec  
;    RF.1  durée du BEEP 
;    appel DELAY 
;----------------------------- 
BEEP_EXIT:
86  12 			INC R2    ; ajustement nécessaire
87  71 			DIS       ; TOP -> X,P  
BEEP:
88  E2          SEX R2    ; X=2
89  F8 C8   	LDI C8    ;200=100 cycles audio, 100 msec    
8B  BF  		PHI RF    ; RF.1 durée
B00:
8C  39 91		BNQ  B01  ; si Q==0  va à B01
8E  7A			REQ       ; met Q à 0 
8F  30 94		BR   B02  ; va à B02
B01:
91  7B			SEQ       ; met Q à 1                                   
92  30 94		BR  B02   ; va à B02, nécessaire pour timing
B02: 
94  79			MARK      ; T=X,P, M(R2)=X,P, DEC(X)                    
95  D6			SEP R6    ; PC=R6 
96  25  		.BYTE 25  ; délais  
97  22			DEC R2    ; réajuste R2
98  9F			GHI RF    ; D=RF.1
99	FF 01		SMI 01    ; D=D-1
9B  BF			PHI RF    ; RF.1=D                                      
9C  3A 8A		BNZ B00   ; si D <> 0 boucle 
9E  30 84		BR BEEP_EXIT ; terminé.
			

;------------------------------------
; SAVE 
; sauvegarde d'un programme sur
; cassette audio.
;--------------------------------------
SAVE:
A0  

;--------------------------------------
; LOAD 
; chargement d'un programme à partir 
; d'une cassette audio.
;---------------------------------------
LOAD: 

;--------------------------------------
; sous-routines d'usage général 
; ces routines peuvent être appellées 
; par une autre sous-routines
; discipline d'appel:
;   MARK 
;   SEP PC 
;   PARAM 
;   DEC R2 
;
;   X=2 à l'appel et au retour
;   PC est le registre qui sert de 
;   comme compteur ordinal pour la 
;   routine. 
;   PARAM est la liste des paramètres 
;   transmis à la sous-routine
;--------------------------------------

