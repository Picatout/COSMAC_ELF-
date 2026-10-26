0   F8 7F           LDI 7F   ; D <- 7F
2   B2              PHI R2.1 ; R2.1 <- D
3   F8 FF           LDI FF   ; D <- FF
5   A2              PLO R2   ; R2.0 <- D   R2 pointeur vers $7FFF
6   E2              SEX R2   ; R2 est le pointeur de données 
LOOP:
7   6C              IN  4    ; D <- DATA, M(RX) <- DATA , lecture des switch data  
8   64              OUT 4    ; DISPLAY <- M(RX) , affichage de la valeur
9   22              DEC R2   ; R <- R2-1
A   30 07           BR  LOOP ; boucle

