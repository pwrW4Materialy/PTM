P5 EQU 0F8H
P7 EQU 0DBH

WR_CMD EQU 0FF2CH
WR_DATA EQU 0FF2DH
RD_STATUS EQU 0FF2EH
RD_DATA EQU 0FF2FH
LCD_INIT_CMD EQU 038H
LCD_CLEAR EQU 001H
LCD_MODE EQU 00CH

ORG 0
loop:
	lcall read_keyboard
	jc is_key
	mov p1, #0ffh
	sjmp loop

read_keyboard:
	mov r1, #07fh
	mov r0, #0
read_kb:
	clr c
	mov a, r1
	lcall read_row
	jc found_key
	mov a, r1
	rr a
	mov r1, a
	inc r0
	cjne r0, #4, read_kb
found_key:	
ret

read_row:
	mov P5, a
	mov a, P7
	xrl a, #0ffh
	anl a, #0fh
	mov r2, #0
	jnz columns
ret

columns:
	rrc a
	jc column_found
	inc r2
	jmp columns 	
column_found:
	mov a, r2
ret

is_key:
	push acc 
	mov b, #4
	mov a, r0
	mul ab
	mov r2, a
	pop acc
	add a, r2
	cpl a
	clr acc.7
	mov p1, a
	jmp loop

lcd_init:
	MOV A, #LCD_INIT_CMD
	call lcd_cmd 
	MOV A, #LCD_CLEAR
	call lcd_cmd
	MOV A, #LCD_MODE
	call lcd_cmd
ret

lcd_cmd: ;cmd in ACC
	push ACC
	call wait_busy
	MOV DPTR, #WR_CMD
	pop ACC
	MOVX @DPTR, A
ret

lcd_writec:	;char in ACC
	push ACC
	call wait_busy
	MOV DPTR, #WR_DATA
	pop ACC
	MOVX @DPTR, A
ret

lcd_writestr: ;str pointer in DPTR
	clr A
	movc A, @A+DPTR	
	jz lcd_writestr_ret
	push dph
	push dpl  
	call lcd_writec
	pop dpl
	pop dph
	inc dptr
	jmp lcd_writestr

	lcd_writestr_ret:
ret	

lcd_writeint:
	anl A, #00111111B	//allow numbers only on 6 youngest bits
	mov B, #10
	div AB	   
	add A, #'0'
	lcall lcd_writec
	mov A, B
	add A, #'0'
	lcall lcd_writec
ret

lcd_gotoxy:	
	anl	A, #00011111B 	// x in 4 lowes bits, y in bit 5
	jnb ACC.4, first_line
	clr ACC.4
	add A, #40H
first_line:
	orl A, #10000000B		//set addr command
	lcall lcd_cmd
ret

wait_busy:
	mov DPTR, #RD_STATUS
	wait:
	movx A, @DPTR
	jb ACC.7, wait
ret

END