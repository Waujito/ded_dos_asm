.model tiny

W_HEIGHT	equ 25
W_WIDTH		equ 80
FILLER_SYM	equ 0503h ; Pink heart, used for debugging. Replace with 0000 to clear the area

BORDER_COLOR equ 0bh

.code
org 100h

Start:
		; ES to vram
		mov ax, 0b800h
		mov es, ax

		mov di, 8
		call ShiftText

		mov di, ax
		add di, 10
		mov si, 50
		mov dx, 8
		call FillBorder

		
		; Starting of row-wised width
		add di, 2 * 2 * W_WIDTH + 2 * 2
		mov bx, si
		sub bx, 4
		shl bx, 1
		add bx, di
		mov si, bx

		mov dl, ds:[80h]

		test dl, dl
		jz .pw_loop_end

		dec dl
		
		push di
		push di
		xor cx, cx
.pw_loop_start:
		cmp cx, dx
		jge .pw_loop_end

		mov bx, cx
		mov al, ds:[bx + 82h]
		mov ah, 0ceh

		mov es:[di], ax
		add di, 2

		cmp di, si
		jle .pw_loop_no_act

		pop di
		add di, 2 * W_WIDTH
		push di
		add si, 2 * W_WIDTH
	
.pw_loop_no_act:


		inc cx
		jmp .pw_loop_start
.pw_loop_end:

		pop di
		pop di



		mov ax, 4c00h
		int 21h

FillBorder:
; DI is starting point
; SI is nrows
; DX is ncols

	mov ah, BORDER_COLOR
	mov al, 0cdh

; fill top row
	xor cx, cx
.fill_top_row:
	mov bx, cx
	shl bx, 1
	add bx, di

	mov es:[bx], ax

	inc cx
	cmp cx, si
	jl .fill_top_row
; end fill top row

	push di
	push ax
	push dx

	mov ax, W_WIDTH * 2
	dec dx
	mul dx
	add di, ax

	pop dx
	pop ax

; fill bottom row
	xor cx, cx
.fill_bottom_row:
	mov bx, cx
	shl bx, 1
	add bx, di

	mov es:[bx], ax

	inc cx
	cmp cx, si
	jl .fill_bottom_row
; end fill bottom row

	pop di
	mov al, 0bah
	push si

	mov si, W_WIDTH * 2
; fill left border
	xor cx, cx
	mov bx, di
.fill_left_brd:
	mov es:[bx], ax

	add bx, si
	inc cx
	cmp cx, dx
	jl .fill_left_brd

	pop si
	push di
	push si

	mov bx, si
	shl bx, 1

	add di, bx

	mov si, W_WIDTH * 2
; fill right border
	xor cx, cx
	mov bx, di
.fill_right_brd:
	mov es:[bx], ax

	add bx, si
	inc cx
	cmp cx, dx
	jl .fill_right_brd

	pop si
	pop di

; fill angles
	push di

	xor cx, cx
	mov al, 0c9h
	mov es:[di], ax

	mov bx, si
	shl bx, 1
	add di, bx
	mov al, 0bbh		; top-right
	mov es:[di], ax

	pop di
	push di
	push si
	push dx

	mov si, ax
	mov ax, 2 * W_WIDTH
	dec dx
	mul dx
	add di, ax
	mov ax, si
	
	mov al, 0c8h		; top-right
	mov es:[di], ax

	pop dx
	pop si

	mov bx, si
	shl bx, 1
	add di, bx
	mov al, 0bch		; bottom-right
	mov es:[di], ax

	pop di

	ret
	

ShiftText:
; DI is nrows needed to shift down
; Returns AX - relative pointer to the first symbol of filled area
TEXT_OFFSET	= di

		push es

		; ES to vram
		mov ax, 0b800h
		mov es, ax

		; Initialize BP
		push bp
		mov bp, sp

		; Exchange cursor position
		mov ah, 03h
		xor bh, bh
		int 10h	

		; dh is set to cursor row pos (0-based)
		; Move it to bx
		xor bx, bx
		mov bl, dh
		push bx				; cursor row pos: bp - 2

		mov bx, ss:[bp - 2]
		add bx, TEXT_OFFSET
		cmp bx, W_HEIGHT	

		jge .offset_text
		push 0d				; offset flag: bp - 4	
		jmp .fill_gaps_hearts
		
.offset_text:
		push 1d

		; This points on how much text should slide to
		mov ax, W_WIDTH * 2
		mov dx, TEXT_OFFSET
		mul dx
		push ax				; text_copy_offset: bp - 6

		; This points on how many symbols should replace with copied
		mov ax, ss:[bp - 2] ; cursor pos
		; inc ax
		sub ax, TEXT_OFFSET
		mov bx, W_WIDTH
		imul bx
		push ax				; text_copy_cts:    bp - 8	

		xor cx, cx
.lp_move_text_up:
		mov bx, cx
		shl bx, 1
		mov si, ss:[bp - 6]
		add si, bx
		mov ax, es:[si]
		mov es:[bx], ax
		inc cx
		mov dx, ss:[bp - 8]
		cmp cx, dx
		jl .lp_move_text_up

.fill_gaps_hearts:
		mov dx, ss:[bp - 4]
		test dx, dx
		jnz .fill_gaps_uwu
		mov ax, ss:[bp - 2]
		mov dx, W_WIDTH
		mul dx
		mov cx, ax

.fill_gaps_uwu:
		mov bx, cx
		shl bx, 1
		push bx

		mov ax, W_WIDTH
		mul TEXT_OFFSET
		mov dx, cx
		add dx, ax

.lp_fill_gap_hearts:
		mov bx, cx
		shl bx, 1
		mov ax, FILLER_SYM
		mov es:[bx], ax
		inc cx
		cmp cx, dx
		jl .lp_fill_gap_hearts

.shift_cursor:
		mov dx, ss:[bp - 4]
		test dx, dx
		jnz .exit_func

		mov bx, ss:[bp - 2]

		mov ah, 02h
		mov dh, bl
		mov bx, TEXT_OFFSET
		add dh, bl
		xor bh, bh
		xor dl, dl
		int 10h


.exit_func:	
		pop ax
		mov sp, bp
		pop bp
		pop es
		ret


end Start
