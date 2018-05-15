TIME EQU 10
CYKLE EQU (TIME*1000)
LOAD EQU (65536 - CYKLE)

ORG 0
call timer_init
mov a, #254
mov r4, #7 
blinkL:
	mov r3, #50
	call delay	 
	mov p1, a
	rl a
	djnz r4, blinkL

mov r4, #7
blinkR:
	mov r3, #50
	call delay	 
	mov p1, a
	rr a
	djnz r4, blinkR

mov r4, #7
jmp blinkL
;------------------
; DELAY: r3 * 10ms
;------------------
timer_init:	
	clr tr0
	anl tmod, #11110000B
	orl tmod, #00000001B
	ret
delay:
	clr tf0	   
	mov tl0, #LOW(LOAD)
	mov th0, #HIGH(LOAD)
	setb tr0
	jnb tf0, $
	clr tr0
	djnz r3, delay
	ret
end

