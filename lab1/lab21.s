 org 0
 /*
	; test kopiowania

	mov r1, #30h
	mov r4, #5
	lcall put_in

	mov r1, #30h
	mov	dptr,#0030H
	mov r4, #5
	lcall copy

	sjmp $
	
;-------------------------------------
; Copy IRAM -> XRAM
; R0 - src DPTR -  
;-------------------------------------
copy:
	mov a, @r1
	movx @dptr, a
	inc dptr
	inc r1
	djnz r4, copy
	ret

;-------------------------------------
put_in:
	mov a, r4
	mov @r1, a
	inc r1

	djnz r4, put_in
	ret
*/	
end
