; programme test 
; vérification de la communication sérielle
; Renvoie au terminal les caractères reçus de celui-ci.
; routine de base
;    COUT pour transmettre un caractère 
;    CIN  pour recevoir un caractère.
;
;  R3 PC 
;  R8 PC CIN 
;  R9 PC COUT 

; suppose que elf+Mon a initialisé R2 à FFFF 

.ORG 0x8000

DISPLAY EQU 4
PC_MAIN    EQU 3
PC_CIN     EQU 8
PC_COUT    EQU 9 
PC_PUTS    EQU 8 

INIT:
			 SEQ            ; Q doit-être à 1
			 GHI 3 
			 PHI 8          ; adresse CIN>>8
			 PHI 9          ; adresse COUT>>8
			 LDI PUTS&0xFF   ; adresse CIN&FF 
			 PLO 8 
			 LDI COUT&0xFF  ; adresse COUT&FF 	
			 PLO 9

MAIN: 
			 SEP PC_CIN     ; appel CIN 
			 GHI 0xE        ; dépose le caractère dans RE.1
			 STR 2          ; M(RX)=D 
			 OUT DISPLAY    ; affiche le code ASCII
			 DEC 2          ; réajuste R2  
			 SEP PC_COUT    ; echo C 
			 BR MAIN        ; boucle 
			

CIN_EXIT:
			 SEP PC_MAIN     ; retour au programme principal  
CIN:
             BN2 CIN        ; attend le START bit  
             LDI 09         ; initialise le compteur de bits  
             PLO 0xE        ; RE.0 décompte les bits reçus
             LDI 00         ; initialise caractère reçu.
             PHI 0xE        ; RE.1= C  
BLOOP:                      ; bit loop 
             LDI 5          ; NN=(52-22)/6 
             PLO 0xF        ; RF compteur de délais 
DLY00:                      ; boucle délais de bit
             DEC 0XF 
             GLO 0xF
             BNZ DLY00   
             GHI 0xE        ; D=C
             SHR            ; décale C à droite 
             B2  DLY02      ; si ~EF2=1 va à DLY02, bit 7 reste à 0  
             ORI 0x80       ; met bit 7 à 1  
             BR  DLY02      ; ajustement pour délais
DLY02:
             PHI 0xE        ; sauvegarde C dans RF.1
             DEC 0xE  
             GLO 0xE        ; si non nul  
             BNZ BLOOP      ;reçoit bit suivant
STOP:                       ; attend stop bit 
             LDI 05 
             PLO 0xF        ; délais STOP bit  
SLOOP:      
             DEC 0xF        ; décrémente RF 
             GLO 0xF        ; si non nul 
             BNZ SLOOP      ; boucle 
			 BR CIN_EXIT    ; 
			 
;-------------------------------
; COUT 
; PC=R5 
; transmet un caractère au 
; terminal. 
; paramètre:
;   caractère à envoyé dans RE.1 
;--------------------------------
COUT_EXIT:		
              SEP  PC_MAIN  ; retour au programme principal  
COUT:  					    ; 
                            ; Envoie d'un caractère ASCII sur Q 
							; RE.1 contient le caractère à envoyer.
							; RE.0 compteur de bits 
              LDI 9         ; bits count incluant start bit 
              PLO 0xE       ; dans RE.0
              GHI 0xE 
              SHL 
              PHI 0xE
BIT_LOOP:
              GHI 0xE       ; D=caractère 
              SHRC          ; bit 0 dans DF, DF dans bit 7  
              PHI 0xE       ; RE.1=C>>1
              BNF NUL       ; bit à zéro 
              SEQ           ; bit==1
              BR B_DLY  
NUL:                        ; bit==0
              REQ
              BR B_DLY      ; burn 2 more T 
B_DLY: 
              LDI 5         ; N=(52-22)/6 
              PLO 0xF       ; 
BIT_DLY:                    ; boucle durée de bit 
              DEC 0xF        
              GLO 0xF 
              BNZ BIT_DLY 
              DEC 0xE       ; décrément le compteur de bits 
              GLO 0xE       ; RE.1=D
              BNZ BIT_LOOP  ; pas terminé l'envoie 
              GLO 0xE       ; délais supplémentaire 
              GLO 0xE       ; pour le dernier bit 4T
              LDI 5         ; délais N=(52-22)/6 
              PLO 0xF       ; sont pour le timing 
              SEQ           ;  STOP bit
STP_DLY:                      ; délais du stop BIT 
			  DEC 0xF
			  GLO 0xF
			  BNZ STP_DLY  	
              BR COUT_EXIT  ; terminé.  

