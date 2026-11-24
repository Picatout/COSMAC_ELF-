		org 8400h
		
		ldi 01eh 
		phi 4 
		ldi 0
		plo 4
		plo 5
		plo 0fh 
		ldi 80h 
		phi 5
		ldi 2
		phi 0fh 
loop
		lda 4
		str 5 
		inc 5 
		dec 15 
		glo 15
		str 2 
		ghi 15 
		or 
		bnz loop 
		seq
		idl 
 
		end 
		
