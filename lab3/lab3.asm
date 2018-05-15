WR_CMD EQU 0FF2CH
WR_DATA EQU 0FF2DH
RD_STATUS EQU 0FF2EH
RD_DATA EQU 0FF2FH
LCD_INIT EQU 038H
LCD_CLEAR EQU 001H
LCD_MODE EQU 00EH

ORG 0

	call init_lcd
	MOV A, #'A'
	lcall lcd_writec

	MOV DPTR, #text
	lcall lcd_writestr

	mov a, #18
	lcall lcd_gotoxy

	MOV DPTR, #text
	lcall lcd_writestr

	SJMP $

init_lcd:
	MOV A, #LCD_INIT
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

lcd_gotoxy: ; x in  	
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

text: DB 'qwerty', 0

END