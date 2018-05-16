org 0
   	
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
delay:
	mov r1, #10		; 10*1ms
d1:
	mov r0, #250	; 250*4us=1ms
d0:
	nop				; 1
	nop				; 1 
	djnz r0, d0		; 2
					; ---
					;   4	
	djnz r1, d1
	djnz r3, delay

	ret
end