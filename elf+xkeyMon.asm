                        ; elf+ xkey Monitor  (hexadecimal keyboard)  
                        ; Version 0.3 
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

;constantes
TMP          EQU 0      ; registre de travail 
PC_MAIN      EQU 1      ; PC programme principal 
SP           EQU 2      ; pointeur de pile 
ADR          EQU 3      ; adresse lue au clavier  
PC_GETBYTE   EQU 4      ; PC sous-routine GETBYTE 
PC_GETKEY    EQU 5      ; PC sous-routine GETKEY 
PC_DELAY     EQU 6      ; PC sous-routine DELAY 
PC_BEEP      EQU 7      ; PC sous-routine BEEP 
DLY_CNTR     EQU 15     ; registre compteur délais 

;codes des opérations
OP_RUN		EQU 0       ; exécute une application 
OP_MOD      EQU 1       ; modification de la mémoire 
OP_VIEW     EQU 2       ; examine la mémoire 
OP_SAVE     EQU 3       ; sauvegarde mémoire sur un média externe
OP_LOAD     EQU 4       ; charge la mémoire à partir d'un média externe

; codes des E/S 
TOGGLES     EQU 4       ; N code de l'entrée toggle switches 
DISPLAY     EQU 4       ; N code de la sortie affichage 
KEYPAD      EQU 1       ; N code entrée keypad 
 
 
	ORG 0000
INIT
          DIS                 ; désactive les interruptions 
          BYTE 0              ; l'instruction DIS utilise cet octet X=0,P=0
          LDI 0FFH            ; initialise R2 comme pointeur de donnée
          PLO SP              ; à la fin de la mémoire RAM
          PHI SP              ; R2 = 0xFFFF
          SEX SP              ; X=2
          INP TOGGLES         ; lecture des toggles switches  
          OUT DISPLAY 
          DEC SP 
          BNZ INIT01           ; si == 0, exécute le moniteur TERMITE 
		  LDI 1EH 
		  PHI 3 
		  LDI 00 
		  PLO 3 
		  SEP 3
INIT01
          GHI TMP             ; initialisation des registres
          PHI PC_MAIN         ; R1, PC de ELFMON
          PHI PC_GETBYTE      ; R4, PC de GETBYTE
          PHI PC_GETKEY       ; R5, PC de GETKEY 
          PHI PC_DELAY        ; R6, PC de DELAY 
          PHI PC_BEEP         ; R7, PC de BEEP 
          LDI LOW ELFMON      ; adresse ou R1 devient le PC du moniteur 
          PLO PC_MAIN         ; 
          SEP PC_MAIN         ; P=1 
ELFMON                        ; programme principal  
          LDI LOW GETBYTE     ; octet faible de l'adresse de GETBYTE      
          PLO PC_GETBYTE      ; PC de GETBYTE
          LDI LOW GETKEY      ; octet faible de l'adresse de GETKEY 
          PLO PC_GETKEY       ; PC de GETKEY
          LDI LOW DELAY       ; octet faible de l'adresse de DELAY
		  PLO PC_DELAY        ; PC de DELAY
          LDI LOW BEEP        ; octet faible de l'adrese de BEEP
          PLO PC_BEEP         ; PC de BEEP 
          MARK                ; appel GETBYTE
          SEP PC_GETBYTE      ; pour obtenir une adresse 
          DEC SP              ;
          PHI ADR             ; cette adresse est conservée 
		  MARK                ; R3 
          SEP PC_GETBYTE      ; appel GETBYTE, obtient adresse low 
          DEC SP  
          PLO ADR             ;   
          MARK                ; appel GETKEY pour obtenir le 
          SEP PC_GETKEY       ; code d'opération, retourné dans D 
          DEC SP 
          PLO TMP             ; sauvegarde le code dans TMP 
          BNZ NOT_RUN         ; si D <> 0 commande 1,2,3 OU 4


;------------------------------
; OPCDE==OP_RUN 
; exécution d'un programme 
; utilisant R3 comme PC 
;------------------------------
RUN
          SEP ADR              ; code d'opération 00, execute le programme 

;------------------------------
; sélecteur de commande 
;------------------------------
NOT_RUN                       ; code 1,2,3 ou 4 
       XRI OP_MOD             ; commande 1 ? 
       BZ MODIFY              ; commande MODIFY 
       GLO TMP                ; rétablie D 
       XRI OP_VIEW            ; commande 2 ? 
       BZ EXAMINE             ; commande EXAMINE 
       GLO TMP                ; commande 3 ? 
	   XRI OP_SAVE            ; sauvegarde 
       BZ  SAVE               ; commande SAVE 
       GLO TMP
       XRI OP_LOAD            ; commande 4 ? 
       BZ LOAD                ; commande LOAD 
BAD_CODE                      ; opcode invalide 
       MARK 
       SEP PC_BEEP            ; erreur BEEP 
   	   DEC SP 
       BR ELFMON              ; recommande au début 

;------------------------------
; OP_CODE==OP_MOD
; modification de la mémoire 
;------------------------------
MODIFY                        ; code d'opération 01 
	   SEX SP 
       MARK 
       SEP PC_GETBYTE         ; appel GETBYTE.
       DEC SP 
       SEX ADR                ; ADR devient le pointeur de donnée.
       STR ADR                ; dépose D à l'adresse M(ADR)
       OUT ADR                ; affiche M(ADR) et ADR=ADR+1 
       BR MODIFY              ; boucle à MODIFY 

;-------------------------------
; OPCODE==OP_VIEW
; examin de la mémoire 
;-------------------------------
EXAMINE                       
      SEX ADR                 ; ADR devient le pointeur de donnée.         
WAIT_IN_DN
      BN4 WAIT_IN_DN          ; attend que le bouton IN soit enfoncé
      OUT DISPLAY             ; affiche l'octet en mémoire, R1=R1+1
WAIT_IN_UP                              
      B4 WAIT_IN_UP           ; attend que le bouton IN soit relaché 
      BR WAIT_IN_DN           ; boucle à EXAMINE 

;-------------------------------------
; GETBYTE 
; lecture d'un octet au clavier 
; hexadécimal
; valeur retournée dans D 
;-------------------------------------
GB_EXIT 
      DIS  		              ; X,P=M(R2) R2=R2+1, IE=0	
GETBYTE                       ; lecture de 2 touches du clavier
      SEX SP		          ; remet X=2 
      MARK                    ; X,P -> T  X,P -> M(RX) RX=RX-1
	  SEP PC_GETKEY           ; appel  GETKEY, 1ière touche  
	  DEC SP                  ; parce que DIS incrémente R2  
      SHL                     ; 16*D
      SHL                 
      SHL 
      SHL                 
      PLO TMP                 ; dépose 16*D -> R0.0     
      MARK 
      SEP PC_GETKEY           ; appel GETKEY, 2ième touche
	  DEC SP                  ; parce que DIS incrémente R2
      STR SP                  ; M(RX)=D 
      GLO TMP                 ; D=R0.0D
      OR                      ; D=D OR M(RX) 
      STR SP 
      OUT DISPLAY             ; 
      BR GB_EXIT              ;                                          

;------------------------------------
; GETKEY 
; lecture d'une touche au clavier 
; hexadécimal.
; retourne la valeur dans D 
;------------------------------------                
GK_EXIT        
      INC SP                  ; ajustement nécessaire pour M(R2)=X,P 
      DIS                     ; retourne à l'appellant, incrémente R2
GETKEY                        ; lecture du clavier hexadécimal
      SEX SP         
WAIT_KD 
      BN1 WAIT_KD             ; attend qu'un touche soit enfoncée.
      INP KEYPAD              ; lecture de la valeur, D et M(RX)=KEY
WAIT_KR
      B1  WAIT_KR             ; attend que la touche soit relachée       
      BR  GK_EXIT             ; saut vers GK_EXIT                       
 

;------------------------------
; DELAY 
; insertion d'un délais 
; dans l'exécution.
; RF.0 durée du délais. 
; T=6*NN+12
;----------------------------- 
DELAY_EXIT                    ; T = 6*NN+12
      SEX SP 
  	  INC SP                  ; pointe vers dernier MARK 
      DIS                     ; exit
DELAY                         ; délais pointé par M(RP) 
   	  LDXA		              ; compte délais 
      PLO  DLY_CNTR           ; délais                            
DLY_LOOP
      DEC  DLY_CNTR                                                  
      GLO  DLY_CNTR 
      BNZ DLY_LOOP            ; boucle tant que > zéro 
      BR DELAY_EXIT 
 

;-------------------------
; BEEP 
; émet 1Khz pendant 100msec  
; HIGH DLY_CNTR -> durée du BEEP 
; appel DELAY 
;----------------------------- 
BEEP_EXIT
	  INC SP                  ; ajustement nécessaire
 	  DIS                     ; TOP -> X,P  
BEEP
      SEX SP                  ; X=2
   	  LDI 200                 ;200=100 cycles audio, 100 msec    
 	  PHI DLY_CNTR            ; RF.1 durée
B00
	  BNQ  B01                ; si Q==0  va à B01
	  REQ                     ; met Q à 0 
	  BR   B02                ; va à B02
B01
	  SEQ                     ; met Q à 1                                   
	  BR  B02                 ;  va à B02, nécessaire pour timing
B02 
	  MARK                    ; T=X,P, M(R2)=X,P, DEC(X)                    
	  SEP PC_DELAY            ; PC=R6 
  	  BYTE 25                 ; délais  
	  DEC SP                  ; réajuste R2
	  GHI DLY_CNTR            ; D=RF.1
	  SMI 01                  ; D=D-1
	  PHI DLY_CNTR            ; RF.1=D                                      
	  BNZ B00                 ; si D <> 0 boucle 
	  BR BEEP_EXIT            ; terminé.
			

;------------------------------------
; SAVE 
; sauvegarde d'un programme sur
; cassette audio.
;--------------------------------------
SAVE	
	BR BAD_CODE 

;--------------------------------------
; LOAD 
; chargement d'un programme à partir 
; d'une cassette audio.
;---------------------------------------
LOAD 
	BR BAD_CODE 
	
		END

