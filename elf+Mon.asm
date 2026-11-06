						; elf+ Monitor  
						; Versio 0.1 
						; R2 pointeur de pile 
						; R3 programme principal 
						; R4 GETBYTE 
                        ; R5 GETKEY
                        ; RF registre temporaire 
						; elf+ OS reconnaît 3 commandes 
						; 01  Modifie la mémoire 
						; 02  Examine la mémoire 
						; 03  Exécute un programme 
						; Un programme peut retourner au moniteur 
						; en faisant un saut à l'adresse $0000
INIT:
00  F8 FF       LDI FF      ; initialise R2 comme pointeur de pile
02  A2          PLO R2      ; à la fin de la mémoire RAM
03  B2          PHI R2      ; R2 = $FFFF
04  E2          SEX R2      ; R2 devient le pointeur de pile 




GB_EXIT:        RET         ; sortie de GETBYTE
GETBYTE:					; lecture de 2 touches du clavier
				MARK        ; sauvegarde X,P sur la pile
				SEP GETKEY	; appel  GETKEY, 1ière touche  
				LDXA        ; dépile la touche 
				SHL SHL     ; décale D 2 fois à gauche 
				SHL SHL     ; décale D 2 vois à gauche 
				PHL RF      ; dépose dans F.0          
				MARK        ; sauvegarde X,P sur la pile 
				SEP GETKEY  ; appel GETKEY, 2ième touche
				GLO RF      ; D=F.0 
				OR          ; D= D OR M(RX) 
				INC RX      ; incrément le pointeur de pile
				BR GB_EXIT  ; saut vers GB_EXIT 
				
GK_EXIT:		RET          ; sortie de GETKY 
GETKEY:						 ; lecture du clavier hexadécimal
				BN1	GETKEY   ; attend qu'un touche soit enfoncée.
				INP 1        ; lecture de la valeur
WAIT_KR:
			    B1  WAIT_KR  ; attend que la touche soit relachée
				BR  GK_EXIT  ; saut vers GK_EXIT 
