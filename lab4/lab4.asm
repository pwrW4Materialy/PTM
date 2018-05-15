TIME EQU 50
CYKLE EQU (TIME*1000)
LOAD EQU (65536 - CYKLE)
	
LICZNIK EQU 030H
SECONDS EQU 031H
MINUTES EQU 032H
HOURS	EQU 033H

ALARM_SECONDS	EQU	034H
ALARM_MINUTES 	EQU 035H
ALARM_HOURS 	EQU 036H

WRITE_TIME_FLAG EQU 0
	
WR_CMD EQU 0FF2CH
WR_DATA EQU 0FF2DH
RD_STATUS EQU 0FF2EH
RD_DATA EQU 0FF2FH
LCD_INIT_CMD EQU 038H
LCD_CLEAR EQU 001H
LCD_MODE EQU 00CH

ORG 0
	ljmp begin
ORG 0BH
	push ACC
	push PSW
	mov tl0, #LOW(LOAD)
	mov th0, #HIGH(LOAD)

	djnz LICZNIK, skip
	mov LICZNIK, #20
	
add_sec:		 
	setb WRITE_TIME_FLAG
	inc SECONDS
	mov A, SECONDS
	cjne A, #60, skip
add_min:
	mov SECONDS, #0
	inc MINUTES
	mov A, MINUTES
	cjne A, #60, skip
add_hr:
	mov MINUTES, #0
	inc HOURS
	mov A, HOURS
	cjne A, #24, skip
day:
	mov HOURS, #0
skip:
	pop PSW
	pop ACC
	reti

begin:
	mov SECONDS, #55
	mov MINUTES, #4
	mov HOURS, #14
	mov ALARM_SECONDS, #5
	mov ALARM_MINUTES, #5
	mov ALARM_HOURS, #14
	lcall timer_init
	lcall lcd_init
	setb WRITE_TIME_FLAG
check_time:
	jnb WRITE_TIME_FLAG, check_time	 
	clr WRITE_TIME_FLAG
	lcall update_time
	lcall alarm
	jmp check_time

update_time:
	mov A, #4
	lcall lcd_gotoxy
	mov A, HOURS
	lcall lcd_writeint
	mov A, #':'
	lcall lcd_writec
	mov A, MINUTES
	lcall lcd_writeint
	mov A, #':'
	lcall lcd_writec
	mov A, SECONDS
	lcall lcd_writeint
	ret

alarm:
	mov A, HOURS
	cjne A, ALARM_HOURS, alarm_ret
	mov A, MINUTES
	cjne A, ALARM_MINUTES, alarm_ret
	mov A, SECONDS
	cjne A, ALARM_SECONDS, alarm_ret

	mov A, #21
	lcall lcd_gotoxy
	MOV DPTR, #text
	lcall lcd_writestr

alarm_ret:
	ret

timer_init:	
	clr tr0

	mov	LICZNIK, #20

	clr tf0
	anl tmod, #11110000B
	orl tmod, #00000001B
	mov tl0, #LOW(LOAD)
	mov th0, #HIGH(LOAD)
	setb ea				  
	setb et0
	setb tr0
	ret

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

lcd_writec:	
//char in ACC
	push ACC
	call wait_busy
	MOV DPTR, #WR_DATA
	pop ACC
	MOVX @DPTR, A
ret

lcd_writestr: 
//str pointer in DPTR
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
//allow numbers only on 6 youngest bits
	anl A, #00111111B
	mov B, #10
	div AB	   
	add A, #'0'
	lcall lcd_writec
	mov A, B
	add A, #'0'
	lcall lcd_writec
ret

lcd_gotoxy:
// x in 4 lowes bits, y in bit 5	
	anl	A, #00011111B
	jnb ACC.4, first_line
	clr ACC.4
	add A, #40H
first_line:
//set addr command
	orl A, #10000000B
	lcall lcd_cmd
ret

wait_busy:
	mov DPTR, #RD_STATUS
	wait:
	movx A, @DPTR
	jb ACC.7, wait
ret

text: DB 'ALARM!', 0

END
