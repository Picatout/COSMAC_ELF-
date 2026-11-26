; wozmon pour COSMAC elf+  
; version 1.1
; Ce programme reprend les fonctionnalités 
; de la première version du moniteur du Apple I 
; Créé par Steve Wozniak 
; Le elf+ communique avec le terminal 
; à 9600 BAUD, 8 bits, 1 STOP bit 
; La sortie Q du CDP1802 sert de sortie sérielle.
; le flag externe ~EF2 sert d'entrée sérielle.
; La routine COUT assure la sérialisation de l'octet à envoyer.
; La routine CIN assure la désérialisation de l'octet reçu.
; La routine PUTS permet d'envoyer une chaîne de caractère. 
; dans ce qui suit:
;  aaaa   représente une adresse en hexadécimal 
;  bb     représente un octet en hexadécimal 
;  <CR>     représente un retour à la ligne code ASCII 0xD 
; fonctionnalités:
;  aaaa<CR>    affiche le contenu de la mémoire à l'adresse aaaa
;  aaaa.aaaa<CR> affiche le contenu de la mémoire dans l'intervalle d'adresse 
;  aaaa: bb ...<CR>  modifie le contenu de la mémoire à partir de l'adresse aaaa
;                avec les octets qui suivent l'adresse.
;  aaaaGCR   exécute le programme à l'adresse aaaa
;
;  utilisation des registres 
;  R1 pointeur de donnée pour tampon texte 
;  R2 pointeur de pile à initialisé à 0xFFFF
;  R3 PC du moniteur 
;  R4 PC de la routine CIN 
;  R5 PC de la routine COUT 
;  R6 PC de la routine PUTS 
;  RA adresse début de la plage mémoire 
;  RB adresse fin de la plage mémoire
;  RE.1  caractère reçu ou envoyé
;  RE.0  compteur de bits pour CIN et COUT 
;  RF.0  compteur délais de bit
;
;------------------------------------------------
; Ce programme doit-être assemblé avec 
; a18 
; ref: https://github.com/carangil/A18
;------------------------------------------------
;
;----------------
; constantes
;----------------

			CPU 1802
			
; caractères ASCII 
BS      	EQU 8H    ; back space 
CR      	EQU 0DH    ; carriage return 
ESC     	EQU 1BH    ; caractère ESCAPE 
SPC     	EQU 20H    ; caractère espace 
SHARP   	EQU 23H   ; '#' 
DOT     	EQU 2EH    ; '.' 
COL     	EQU 3AH    ; ':'
TICK    	EQU 60H    ; ` 

TMP     	EQU 0       ; R0 usage temporaire 
STPTR     	EQU 1       ; pointeur de chaîne
SP      	EQU 2       ; pointeur de pile 
PC_MAIN 	EQU 3       ; PC routine principale 
PC_CIN  	EQU 4       ; PC routine CIN 
PC_COUT 	EQU 5       ; PC routine COUT 
PC_PUTS 	EQU 6       ; PC routine PUTS 
PC_ECHO 	EQU 7       ; PC routine ECHO 
PC_PRHEX 	EQU 8       ; PC routine PRHEX 
PC_EEWAIT   EQU 9       ; PC routine EE_STORE
XAMADR  	EQU 0AH     ; pointeur adresse début intervalle  
ENDADR  	EQU 0BH     ; pointeur adresse fin intervalle  
LAST    	EQU 0CH     ; dernière valeur hexadécimale interprétée
MODE    	EQU 0DH     ; mode dans RD.0 
BCNTR   	EQU 0EH     ; compteur de bits RE.0
DCNTR   	EQU 0FH     ; compteur de délais RF.0
TPTR    	EQU 1       ; pointeur des transactions terminal 
STKTOP      EQU 0FFFFH  ; stack empty address, réserve  16 octets 
TIB     	EQU STKTOP-128-16+1  ; tampon de réception des commandes, réserve 128 octets 
EEWAIT_ADR  EQU TIB-15  ; routine copiée sous le TIB  

			ORG 8000H  

;---------------------------------------------------
; suppose que le moniteur a été lancé à partir 
; de elf+Mon et qu'en conséquence certaines 
; initialisation sont déjà faite, tel que:
;   interruptions déjà désactivé
;   R2 déjà configuré comme pointeur de pile à 0xFFFF
;   R3 est le PC pour ce programme.		
;---------------------------------------------------
INIT
			  SEQ
			  NOP				; il faut garder Q à 1 par défaut.
			  LDI HIGH COUT     ; HIGH PC_MAIN 
			  PHI PC_CIN		; PC de CIN 
			  PHI PC_COUT		; PC de COUT 
			  PHI PC_PUTS		; PC de PUTS 
			  PHI PC_ECHO		; PC de ECHO 
			  PHI PC_PRHEX     	; PC de PRHEX 
			  PHI PC_EESTOR     
			  LDI  LOW CIN      	; initialisation de  la partie basse 
			  PLO  PC_CIN   	; des PC des sous-routines
			  LDI  LOW COUT     	;
			  PLO  PC_COUT  	;
			  LDI  LOW PUTS   	;
			  PLO  PC_PUTS  	;
			  LDI  LOW ECHO 
			  PLO  PC_ECHO 
			  LDI  LOW PRHEX 
			  PLO  PC_PRHEX
			  LDI  HIGH EEWAIT_ADR
			  PHI  PC_EEWAIT
			  LDI  LOW EEWAIT_ADR 
			  PLO  PC_EEWAIT
; copie EEWAIT dans la RAM à EEWAIT_ADR-1 
			  LDI HIGH EEWAIT 
			  PHI XAMADR 
			  LDI LOW EEWAIT-1  
			  PLO XAMADR 
			  LDI HIGH EEWAIT_ADR 	
			  PHI ENDADR 
			  LDI LOW EEWAIT_ADR-1 
			  PLO ENDADR
			  LDI  16           ; copie 16 octets
			  PLO  15
COPY_EEWAIT			  
			  LDN  XAMADR 
			  STR  ENDADR 
			  INC  XAMADR 
			  INC  ENDADR 
			  DEC  15 
			  BNZ  COPY_EEWAIT 
			  LDI  0  
			  PHI  XAMADR       ; initialise ce pointeur 
			  PLO  XAMADR       ; à l'adresse 0x0000
			   
;--------------------------------------
; routine principale 
; PC=R3
;--------------------------------------		
MAIN
			LDI  HIGH SIGN      ; page de ce programme 
			PHI  STPTR          ; initialise le pointeur de chaîne 
			LDI  LOW SIGN       ; avec l'adresse de SIGN 
			PLO  STPTR          ; et appel PUTS   
			MARK                ; pour imprimer le
			SEP  PC_PUTS        ; message 
			DEC  SP             ; décrémente le pointeur de pile 
GETLINE                         ; réception de la commande 
			LDI  CR             ; passe à la ligne suivante 
			SEP  PC_ECHO 
			LDI  SHARP          ; envoie le caratère '#' au terminal 
			SEP  PC_ECHO 
			LDI HIGH TIB        ; initialise le tampon de réception   
			PHI TPTR            ; des commandes *TIB=0xFE00 
			LDI LOW TIB    
			PLO TPTR      
			BR  NEXTCHAR 
BACKSPACE
		    GLO TPTR
		    XRI LOW TIB  
		    BZ  NEXTCHAR 
		    LDI BS 
		    SEP PC_ECHO 
		    DEC TPTR  
NEXTCHAR 
		    MARK 
		    SEP PC_CIN 
		    DEC SP 
		    PLO TMP 
		    XRI BS 
		    BZ  BACKSPACE 
		    GLO TMP  
		    XRI ESC 
		    BZ  GETLINE 
		    GLO TMP 
		    SMI TICK
		    GLO TMP  
		    BNF UPPER  
			ANI 0DFH 		; met lettre en majuscule
UPPER
			STR TPTR 
			SEP PC_ECHO 
			LDA TPTR
			XRI CR 
			BNZ NEXTCHAR  
INTERPRET 					; interprète la commande 
			GLO XAMADR      ; copie XAMADR 
			PLO ENDADR      ; dans LAST 
			GHI XAMADR      ;
			PHI ENDADR      ;
			LDI HIGH TIB    ; remet le pointeur au début du tampon    
			PHI TPTR        ; des commandes *TIB=0xFE00 
			LDI LOW TIB-1    
			PLO TPTR      
			LDI 0
			PLO TMP 
SETMODE 
			GLO TMP 
			PLO MODE        ; mode d'opération 
BLSKP                      ; saute les espaces 
			INC  TPTR 
			LDN  TPTR
			XRI  SPC         ; espace? 
			BZ   BLSKP       ; ignore 
NEXTITEM
			LDN TPTR        ; reprend le caractère dans TMP 
			PLO TMP 
			XRI CR          ; fin de la commande?
			BZ  GETLINE     ; si oui retourne au début 
			GLO TMP   
			SMI  DOT         ; '.'? 
			BNF BLSKP        ; ignore les caractères < '.'
			BZ SETMODE      ; 1=EXAMINE BLOCK  
			GLO TMP 
			XRI COL 
			BZ  SETMODE 
			GLO TMP  
			XRI 'G'         ; 'G' go exétute un programme 
			BZ  RUN 
			GLO TPTR 
			PHI TMP         ; conserve la position de TPTR          
                            ; il faut que ce soit un entier en hexadécimal 
			LDI 0           ; initialise le registre qui reçoit l'entier
			PLO LAST        ; à zéro 
			PHI LAST 
NEXTHEX
			LDN TPTR  
			SMI 30H         ; soustrait '0' 
			BNF NOTHEX      ; caractère invalide retourne au début 
			PLO TMP         ; conserve cette valeur
			SMI 10          ; si < 10 DIGIT  
			BNF  DIGIT 
			GLO TMP 
			SMI 11H 
			BNF NOTHEX 
			GLO TMP 
			SMI 17H
			BDF NOTHEX  
			GLO TMP         
			SMI 7            ; A..F
			PLO TMP   
DIGIT			 
		    GLO TMP 
		    STR SP          ; met sur la pile 
		    LDI 4           ; LAST= 16 * LAST + M(SP)
		    PLO DCNTR        
MULT16                  ;  16*LAST, décale last 4 bits vers la gauche
			GLO LAST 
			SHL 
			PLO LAST  
			GHI LAST  
			SHLC 
			PHI LAST  
			DEC DCNTR 
			GLO DCNTR 
			BNZ MULT16  
			GLO LAST
			ADD 
			PLO LAST
			INC TPTR 
			BR NEXTHEX 
NOTHEX
			GHI TMP       ; position initiale de TPTR 
			STR SP        ; EMPILE 
			GLO TPTR 
			SD            ; M(RX)-D 
			BZ  GETLINE  
GOTNUMBER
			GLO  MODE     ; MODE ?  
			BNZ NOTREAD   ; 
			GLO LAST      ;sI MODE==0 copie LAST  
			PLO XAMADR    ;dans XAMADR 
			PLO ENDADR    ;et ENDADR 
			GHI LAST 
			PHI XAMADR 
			PHI ENDADR
			LDI 0  
			BR  NXTPRNT    
NOTREAD
			XRI DOT   
			BZ  XAM_BLOCK 
STORE
			GLO LAST
			STR ENDADR
			STR SP 
			SEP PC_EEWAIT 
			INC ENDADR 
			BR  NEXTITEM
RUN						 ; copy XAMADR dans R0
			GHI  ENDADR 
			PHI  0 
			GLO  ENDADR 
			PLO  0
			SEP  0        ; exécutre programme à cette adresse.
XAM_BLOCK                 ; examine un block mémoire 
			GHI LAST 
			PHI ENDADR 
			GLO LAST 
			PLO ENDADR  
			BR  PRDATA
NXTPRNT                  
			BNZ  PRDATA   ; si D<>0 imprime la valeur de LAST&0XFF
			LDI  CR       ; si D=0 imprime la valeur de XAMADR 
			SEP PC_ECHO 
			GHI  XAMADR 
			SEP  PC_PRHEX
			GLO XAMADR 
			SEP  PC_PRHEX 
			LDI COL 
			SEP PC_ECHO 
PRDATA
		    LDI SPC 
		    SEP PC_ECHO 
		    LDN XAMADR 
		    SEP PC_PRHEX 
		    INC XAMADR 
		    GLO ENDADR  
		    STR SP 
		    GLO XAMADR 
		    SD   
		    GHI ENDADR  
		    STR SP 
		    GHI XAMADR 
		    SDB 
		    BNF NEXTITEM
MOD16CHK                  ; nouvelle ligne à tous les 16 octets
		    GLO XAMADR 
		    ANI 15 
		    LBNZ PRDATA 
		    LDI 0 
		    LBR NXTPRNT

;------------------------------------
; la routine STORE doit-être 
; copiée en RAM pour pouvoir modifier 
; L'EEPROM 
;-----------------------------------
EEWAIT_EXIT:
		    SEP PC_MAIN  
EE_WAIT			       ; écrire dans l'EEPROM prend minimum 1msec
			LDN ENDADR 
			XOR 
			BNZ EE_WAIT 
			BR  EEWAIT_EXIT
		     
;--------------------------------------
; sous-routines 
;---------------------------------------
			
			ORG 8130H 
			
;---------------------------------------
; PRHEX 
; imprime un octetet en hexadécimal 
; paramètre:
;    D
; sortie:
;    TOP  digit fort 
;    NEXT digit faible 
;--------------------------------------- 
PRHEX_EXIT
			SEP PC_MAIN 
PRHEX 
			PLO TMP 
			SHR         ; D/16
			SHR 
			SHR 
			SHR 
			ADI '0'  
			STR  SP 
			SMI  COL
			BNF   PRH01 
			LDI  7 
			ADD
			STR SP  
PRH01
			LDX 
			MARK 
			SEP PC_COUT 
			DEC SP 
			GLO TMP 
			ANI 0FH 
			ADI '0' 
			STR SP 
			SMI COL
			BNF PRH02 
			LDI 7 
			ADD 
			STR SP 
PRH02		
			LDX 
			MARK 
			SEP  PC_COUT 
			DEC  SP 
			BR   PRHEX_EXIT
			
			
;--------------------------------------
; CIN 
; reçoit un caractère du terminal 
; PC=R4
; paramètre:
;   caractère reçu retourné dans D
;--------------------------------------
CIN_EXIT
              DIS            ; retour au programme principal  
CIN
              SEX SP         ; X = stack pointer
CIN01               
              BN2 CIN01        ; attend le START bit  
              LDI 09         ; initialise le compteur de bits  
              PLO BCNTR      ; RE.0 décompte les bits reçus
              LDI 00         ; initialise caractère reçu.
              STR SP         ; TOP = caractère  
BLOOP                       ; bit loop 
              LDI 5          ; NN=(52-22)/6 
              PLO DCNTR      ; RF compteur de délais 
DLY00                       ; boucle délais de bit
              DEC DCNTR 
              GLO DCNTR
              BNZ DLY00   
              LDX            ; D=C
              SHR            ; décale C à droite 
              B2  DLY02      ; si ~EF2=1 va à DLY02, bit 7 reste à 0  
              ORI 80H       ; met bit 7 à 1  
              BR  DLY02      ; ajustement pour délais
DLY02
              STR SP         ; sauvegarde C dans RF.1
              DEC BCNTR  
              GLO BCNTR      ; si non nul  
              BNZ BLOOP      ;reçoit bit suivant
STOP                        ; attend stop bit 
              LDI 05 
              PLO DCNTR      ; délais STOP bit  
SLOOP      
              DEC DCNTR      ; décrémente RF 
              GLO DCNTR       ; si non nul 
              BNZ SLOOP      ; boucle 
	          LDXA           ; D=caractère,  incrémente SP 
	          BR CIN_EXIT    ; 


;-----------------------------------
; ECHO 
; PC=R7
; paramètre: 
;    D     caractère à envoyer
;------------------------------------
ECHO_EXIT  
			  SEP PC_MAIN 
ECHO
			  MARK
			  SEP  PC_COUT 
			  DEC  SP 
			  BR   ECHO_EXIT 
			 
;-------------------------------
; COUT 
; PC=R5 
; transmet un caractère au 
; terminal. 
; paramètre:
;   caractère à envoyer dans  
;   D 
;--------------------------------
COUT_EXIT		
              INC SP        ; incrémente stack pointer
              DIS           ; sortie de sous-routine  
COUT  					    ; 
                            ; Envoie d'un caractère ASCII sur Q 
							; RE.1 contient le caractère à envoyer.
							; RE.0 compteur de bits 
              SEX SP        ; X= stack pointer
              STR SP        ; TOP = caractère à envoyer
              LDI 9         ; bits count incluant start bit 
              PLO BCNTR     ; dans RE.0
              LDX           ; D=caractère
              SHL           ; shift left 1 bit
              STR SP       
BIT_LOOP
              LDX           ; D=caractère 
              SHRC          ; bit 0 dans DF, DF dans bit 7  
              STR SP        ; RE.1=C>>1
              BNF NUL       ; bit à zéro 
              SEQ           ; bit==1
              BR B_DLY  
NUL                        ; bit==0
              REQ
              BR B_DLY      ; burn 2 more T 
B_DLY 
              LDI 5         ; N=(52-22)/6 
              PLO DCNTR     ; 
BIT_DLY                    ; boucle durée de bit 
              DEC DCNTR        
              GLO DCNTR
              BNZ BIT_DLY 
              DEC BCNTR     ; décrément le compteur de bits 
              GLO BCNTR     ; RE.1=D
              BNZ BIT_LOOP  ; pas terminé l'envoie 
              GLO BCNTR     ; remplissage pour ajouter 
              GLO BCNTR     ; 4T de délais supplémentaire
              LDI 5         ; délais N=(52-22)/6 
              PLO DCNTR     ; sont pour le timing 
              SEQ           ;  STOP bit
STP_DLY                    ; délais du stop BIT 
			  DEC DCNTR
			  GLO DCNTR
			  BNZ STP_DLY  	
              BR COUT_EXIT  ; terminé.  

;-------------------------------------
; PUTS
; PC=R6 
; envoie une chaîne de 
; caractères au terminal
; paramètre:
;    R1 adresse de la chaîne 
;-------------------------------------
PUTS_EXIT  
			  INC SP        ; incrémente stack pointer 
              DIS           ; retouren à l'appellant 
PUTS 
              SEX SP        ; X=stack pointer 
			  LDA  STPTR      ; D=M(R1), R1=R1+1
			  BZ PUTS_EXIT  ; si D nul exit
              MARK          ; T=X,P M(R2)=X,P R2-1 
              SEP PC_COUT   ; PC=R6
			  DEC SP        ; réajuste R2 
              BR  PUTS      ; boucle pour le prochain carractère.

SIGN
			TEXT "COSMAC elf+ monitor, V1.0"
			BYTE CR,0

		
			END 
