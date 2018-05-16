org 0
	; test kopiowania

	mov r1, #30h
	mov r4, #5
	mov	dptr,#0030H
	lcall copy

	sjmp $
	
;------------------------
; Copy IRAM -> XRAM
; R0 - src DPTR - dest
;------------------------
copy:
	mov a, @r1
	movx @dptr, a
	inc dptr
	inc r1
	djnz r4, copy
	ret
end
