                            ; COUT 
                            ; sérialisation d'un octet sur la sortie Q 
                            ; 1 start bit, 8 bits data, 1 stop bit, 9600 BAUD  
                            ; comme paramètre et utilise les instructions 
                            ; MARK et RET pour l'appel de la sous-routine
                            ; R1  compteur ordinal routines INIT, défini par elf+mon  
                            ; R2  pointeur de pile 
                            ; R3  compteur ordinal routine COUT 
                            ; R4  compteur ordinal sous-routine DELAY
                            ; RE.1  caractère à envoyer
                            ; RE.0  compteur de bit   
                            ; RF  compteur de délais  
                            ; calcul du délais par bit 
							; durée d'un bit à 9600 BAUD = 104µSec 
							; T=2µsEC donc 104/2=52T 
							; valeur de NN pour la routine délais: NN=(52-4-OVERHEAD)/6
.ORG 8000
INIT:                       ; test code 
00  F8 FF       LDI FF      ; initialise R2 comme pointeur de pile
02  A2          PLO R2      ; à la fin de la mémoire RAM
03  B2          PHI R2      ; R2 = $FFFF
04  E2          SEX R2      ; R2 devient le pointeur de pile 
05  91		    GHI R1      ; programme lancé à partir de elf+mon 
06  B3			PHI R3.1    ; le PC est dans R1
07  B4          PHI R4.1    ; on copie le #page de R1 vers R3 et R4 
08  F8 17       LDI COUT & FF  ; 
0A  A3          PLO R3      ; R3=adresse de la routine COUT 
0B  F8 39       LDI DELAY & FF 
0D  A4			PLO R4      ; R4=adresse de la routine DELAY 
0E  7B          SEQ         ; Q doit-être gardé à 1 lorsque OUT n'est pas utilisé

TEST:
0F  F8 55		LDI 55      ; caractère à envoyer 
11  FE          SHL         ; MSB dans DF et 0 dans bit 0 
12	BE          PHI RE.1    ; dans RE.1
13  D3          SEP R3      ; appel COUT 
14  30 0F       BR TEST     ; recommence à TEST

COUT_EXIT:		
16  D1          SEP  R1     ; retour au programme principal  
COUT:  					    ; 
                            ; Envoie d'un caractère ASCII sur Q 
							; RE.1 contient le caractère à envoyer.
							; RE.0 compteur de bits 
17	F8 09		LDI 9       ; bits count incluant start bit 
19  AE			PLO RE      ; dans RE.0
BIT_LOOP:
1A  9E          GHI RE      
1B  76          SHRC         ; bit 0 dans DF, DF dans bit 7  
1C	BE			PHI RE 
1D  3B 22       BNF NUL     ; bit à zéro 
1F  7B          SEQ 
20  30 25       BR B_DLY  
NUL:
22  7A          REQ
23  30 25       BR B_DLY    ; burn 2 more T 
B_DLY: 
25	F8 04       LDI NN      ; délais 
27	AF          PLO RF      ; T=4*6+4=28T
28  D4  		SEP R4      ; appel delay 
29  2E			DEC RE      ; RE=RE-1
2A  8E			GLO RE      ; RE.1=D
2B  3A 1A   	BNZ BIT_LOOP 
2D  30 2F       BR 2F       ; +2T
2F	30 31       BR 31       ; +2T  
31  F8 04       LDI NN      ; délais 4*6+4=28T  
33  AF          PLO RF       ; sont pour le timing 
34  7B          SEQ         ;  STOP bit
35  D4          SEP R4      ; délais du stop BIT 
36  30 16       BR COUT_EXIT ; terminé.  
				

DLY_EXIT:                   ; sortie de la sous-routine 
38	D3          SEP R3      ; retourne à COUT 
							; délais T=6*N+4+OVERHEAD
DELAY:                      ; entrée sous-routine DELAY 
39  2F			DEC RF      ; décrémente N, RF.0=N  
3A  8F			PLO RF      ; D=RF.0
3B  3A 39		BNZ DELAY   ; boucle tant que N>0
3D  30 38   	BR DLY_EXIT  ; terminé
3F

