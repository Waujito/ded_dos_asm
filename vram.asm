.model tiny

W_HEIGHT	equ 25
W_WIDTH		equ 80
FILLER_SYM	equ 0503h ; Pink heart, used for debugging. Replace with 0000 to clear the area

.code
org 100h

Start:
		; ES to vram
		mov ax, 0b800h
		mov es, ax

		mov di, 5
		call ShiftText

		mov bx, ax
		mov ax, 0ce31h
		mov es:[bx], ax

		mov ax, 4c00h
		int 21h

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
