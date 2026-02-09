.model small

.stack

.code
Start:
	int 00h
	mov di, 1b1ah
	call PrintHexNumberNL

	mov di, ds
	call PrintHexNumberNL

	mov di, @code
	call PrintHexNumberNL

	mov di, @data
	call PrintHexNumberNL

	mov di, ss
	call PrintHexNumberNL

	mov di, es
	call PrintHexNumberNL

	mov di, cs
	call PrintHexNumberNL

	mov ax, @code
    	mov ds, ax

	mov ah, 09h
	mov dx, offset message
	int 21h

	mov ax, 4c00h
	int 21h

PrintHexNumberNL:
;	in DI
	call PrintHexNumber

	mov ah, 02h
	mov dl, 0dh
	int 21h

	mov ah, 02h
	mov dl, 0ah
	int 21h

	ret

PrintHexNumber:
	;in DI
	mov ax, di

	mov cx, 3d
.phn_loop_ror:
	ror ax, 4d
	loop .phn_loop_ror

	mov cx, 4d
.phn_loop_pr_dg:
	mov di, ax
	push ax
	call PrintHexDigit
	pop ax
	rol ax, 4d
	loop .phn_loop_pr_dg

	ret


PrintHexDigit:
;	Digit in DX
	mov dx, di
	and dx, 000fh

	cmp dx, 10d
	jl .phd_write_hex_dg
	add dx, 39d

.phd_write_hex_dg:
	add dx, '0'
	mov ah, 02h
	int 21h

	ret

message:	db 'Uwu$'

end Start
