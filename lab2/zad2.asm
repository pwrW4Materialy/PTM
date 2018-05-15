TIME EQU 50
CYKLE EQU (TIME*1000)
LOAD EQU (65536 - CYKLE)

LICZNIK EQU 030H
	
SECONDS EQU 031H
MINUTES EQU 032H
HOURS EQU 033H


ORG 0
	mov SECONDS, #0
	mov MINUTES, #0
	mov HOURS, #0
	call timer
	sjmp $

ORG 0BH
	mov tl0, #LOW(LOAD)
	mov th0, #HIGH(LOAD)

	djnz LICZNIK, skip
	mov LICZNIK, #20
	
	inc SECONDS
	cmp SECONDS, #60
	je minute
	jmp skip
minute:
	mov SECONDS, #0
	inc MINUTES
	cmp MINUTES, #60
	je hour
	jmp skip
hour:
	mov MINUTES, #0
	inc HOURS
	cmp HOURS, #24
	je day
	jmp skip
day:
	mov HOURS, #0
skip:
	reti
;------------------
; DELAY: LICZNIK * 50 ms (default = 20)
;------------------
timer:	
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
end

