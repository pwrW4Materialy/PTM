 org 0
	mov r0, #00h
	mov r1, #30h
	mov r2, #00h
	mov r3, #38h
	mov r4, #5
	
	mov dph, r0
	mov dpl, r1
	mov r4, #5
	lcall copy
	sjmp $
	
copy:

	mov dph, r0
	mov dpl, r1
	movx a, @dptr
	inc dptr
	mov r0, dph
	mov r1, dpl
	
	mov dph, r2
	mov dpl, r3
	movx @dptr, a
	inc dptr
	mov r2, dph
	mov r3, dpl

	djnz r4, copy
	ret
end
