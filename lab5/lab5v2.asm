P5 EQU 0F8H
P7 EQU 0DBH

ORG 0
loop:
	lcall read_keyboard
	jc is_key
	mov p1, #0ffh
	sjmp loop

;---------------------------------------------------
read_keyboard:
	mov r1, #070h
	mov r0, #0
read_kb:
	mov a, r1
	lcall read_row
	jc found_key
	mov a, r1
	rr a
	mov r1, a
	inc r0
	cjne r0, #4, read_kb
	jmp read_kb_end
found_key:
	push psw
	push acc 
	mov b, #4
	mov a, r0
	mul ab
	mov r2, a
	pop acc
	add a, r2
	pop psw
read_kb_end:	
ret

;---------------------------------------------------
; IN: A - select row (0111 | ----)
; OUT: CY = 0 - no key
;	   CY = 1 - key code (0 ..3) 0 -left
;---------------------------------------------------
read_row:
;	push acc
;	mov a, P5
;	anl a, #0fh
;	mov r3, a
;	pop acc
;	orl a, r3
;	mov P5, a
	anl P5, #0fh
	anl a, #0f0h
	orl P5, a

	mov a, P7
	cpl	a
	anl a, #0fh
	clr c
	jz no_key
	mov r2, #0
columns:
	rrc a
	jc column_found
	inc r2
	jmp columns 	

column_found:
	mov a, r2
no_key:
ret

;---------------------------------------------------
is_key:
	cpl a
	clr acc.7
	mov p1, a
	jmp loop

END