                        ; elf+ Monitor  
                        ; Version 0.1 
                        ; Adaptation du programme de Joseph Weisbecker
                        ; paru dans le Popular electronics de mars 1977
                        ; 
                        ; R0 registre de travail 
                        ; R1 registre contenant l'adresse
                        ; R2 pointeur de donnée pour GETKEY 
                        ; R3 programme principal 
                        ; R5 GETBYTE 
                        ; R6 GETKEY
                        ; elf+ Monitor reconnaît 3 commandes 
                        ; la commande est sélectionnée par les toggles switches
                        ; 0 aaaa, Exécute le programme à l'adresse $aaaa
                        ; 1 aaaa, Modifie la mémoire débutant à l'adresse $aaaa
                        ; 2 aaaa, Examine la mémoire débutant à l'adresse $aaaa 
                        ; Un programme peut retourner au moniteur 
                        ; en faisant un saut long à l'adresse $0000
                        ; NOTES:
                        ;     1)puisque elf+ a plus que 256 octets de mémoire 
                        ;       le programme est modifié pour accepter des 
                        ;       adresses de 16 bits (4 chiffres hexadécimals)
                        ;     2) La switch IN est utilisé pour la commande 01 
                        ;        pour passé à l'adresse suivante.
                        ;
.ORG 0000
INIT:
00  F8 FF       LDI FF        ; initialise R2 comme pointeur de donnée
02  A2          PLO R2        ; à la fin de la mémoire RAM
03  B2          PHI R2        ; R2 = $FFFF
04  F8 00       LDI  00       ; La partie haute des registres R3,R5,R6 
06  B3          PHI  R3       ; doit-être initialisée à 0. 
07  B5          PHI  R5       ;
08  B6          PHI  R6       ;
09  F8 13       LDI MAIN.0    ; partie basse de la procédure MAIN 
0B  A3          PLO R3        ; R3=MAIN 
0C  F8 2D       LDI GETBYTE.0 ; partie basse de la procédure GETBYTE      
0E  A5          PLO R5        ; R5=GETBYTE
0F  F8 3C       LDI GETKEY.0  ; partie basse de GETKEY 
11  A6          PLO R6        ; R6=GETKEY 
12  D3          SEP R3        ; exécute la routine MAIN 

MAIN:                         ; routine principale
13  D5          SEP GETBYTE   ; appel GETBYTE, obtient adresse high
14  B1          PHI R1        ; R1.1=aa_hi 
15  D5          SEP GETBYTE   ; appel GETBYTE, obtient adresse low 
16  A1          PLO R1        ; R1.0=aa_lo 
17  6C          INP TOGGLES   ; lecture des toggles switches D=op_code 
18  3A 1B       BNZ MOD_EXAM  ; si D <> 0 commande 1 ou 2 
1A  D1          SEP R1        ; code d'opération 00, execute le programme 
                              ; dont l'adresse est dans R1 
MOD_EXAM:                     ; code 01 or 02 ?
1B  F6          SHR D         ; D = D/2 
1C  3B 24       BNF EXAMINE   ; si DF = 0 alors code 02, examine mémoire 
MODIFY:                       ; code d'opération 01 
1E  D5          SEP GETBYTE   ; appel GETBYTE.
1F  E1          SEX R1        ; R1 devient le pointeur de donnée.
20  51          STR M(R1)     ; dépose D à l'adresse M(R1)
21  64          OUT M(R1)     ; affiche M(R1) et R1=R1+1 
22  30 1E       BR MODIFY     ; boucle à MODIFY 
EXAMINE:                      ; code d'opération 02
24  E1          SEX R1        ; R1 devient le pointeur de donnée.         
WAIT_IN_DN:
25  3F 25       BN4 WAIT_IN_DN  ; attend que le bouton IN soit enfoncé
27  64          OUT DISPLAY   ; affiche l'octet en mémoire, R1=R1+1
                              ; Délais anti rebond sur switch IN 
28  37 28       B4 WAIT_IN_UP ; attend que le bouton IN soit relaché 
2A  30 25       BR WAIT_IN_DN ; boucle à EXAMINE 

GB_EXIT:        
2C  D3          SEP MAIN      ; sortie de GETBYTE
GETBYTE:                      ; lecture de 2 touches du clavier
2D  D6          SEP GETKEY    ; appel  GETKEY, 1ière touche  
2E  FE FE       SHL SHL       ; décale D 2 fois à gauche 
30  FE FE       SHL SHL       ; décale D 2 fois à gauche
32  A0          PLO R0.0      ; dépose D dans R0.0   
33  D6          SEP GETKEY    ; appel GETKEY, 2ième touche
34  80          PLO R0.0      ; D=R0.0
35  F1          OR            ; D=D OR M(R2) 
36  52          STR M(RX)     ; M(RX)=D 
37  64          OUT DISPLAY   ; affiche l'octet saisie R2=R2+1
38  22          DEC R2 
39  30 2C       BR GB_EXIT    ; 
                
GK_EXIT:        
3B  D5          SEP GETBYTE   ; retourne à GETBYTE
GETKEY:                       ; lecture du clavier hexadécimal
3C  E2          SEX R2        ; R2 devient le pointeur de donnée.       
WAIT_KD:
3D  3C 3D       BN1 WAIT_KD   ; attend qu'un touche soit enfoncée.
3F  69          INP 1         ; lecture de la valeur
WAIT_KR:
40  34 40       B1  WAIT_KR   ; attend que la touche soit relachée
42  30 3B       BR  GK_EXIT   ; saut vers GK_EXIT 
44
