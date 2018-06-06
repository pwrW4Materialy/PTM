CYKLE EQU 31
LOAD EQU (65536 - CYKLE)

LICZNIK EQU 030H
BRIGHT EQU 031H
INCREASE EQU 0
	
ORG 0
	mov BRIGHT, #20
	mov R1, #0		; 1/32 ms
	mov R2, #20		; 1 ms
	clr INCREASE
	call timer

	sjmp $

ORG 0BH
	mov tl0, #LOW(LOAD)
	mov th0, #HIGH(LOAD) 

	mov A, R1
	cjne A, BRIGHT, switch_led

switch_led:
	push PSW
	cjne R1, #32, continue
	pop PSW
	mov R1, #0

	djnz R2, no_change ; if 0, 20ms passed	
	mov R2, #20

	jnb INCREASE, decrease
	inc BRIGHT
	mov A, BRIGHT
	cjne A, #31, no_change
	clr INCREASE
	sjmp no_change
decrease:
	djnz BRIGHT, no_change
	setb INCREASE
no_change:
	reti
	
continue:	
	pop PSW
	inc R1
	jc led_on  	  
	setb P1.0  
	reti
	
led_on:		
	clr P1.0
	reti
;------------------
; DELAY: 1/32 ms
;------------------
timer:	
	clr tr0
	clr tf0
	anl tmod, #11110000B
	orl tmod, #00000001B
	mov tl0, #LOW(LOAD)
	mov th0, #HIGH(LOAD)
	setb ea				  
	setb et0
	setb tr0
	ret
end

