00  F8 FF       LDI FF      ; initialise R2 comme pointeur de pile
02  A2          PLO R2      ; à la fin de la mémoire RAM
03  B2          PHI R2      ; R2 = $FFFF
04  E2          SEX R2      ; R2 devient le pointeur de pile 
05  3C 05       BN1 05      ; attend pour une touche
07  69          INP KEY 
08  64          OUT DISPLAY
09  22          DEC R2 
0A  34 0A       B1  0A      ; attend le relachement de la touche
0C  30 05       BR  05
