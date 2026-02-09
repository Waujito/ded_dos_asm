.model tiny
.code
org 100h

CRLF		equ 0dh, 0ah

Start:
		mov ah, 09h
		mov dx, offset String
		int 21h

; 		mov [offset Hook + 0d], b409h 
; 		mov [offset Hook + 2d], ba0ch
; 		mov [offset Hook + 4d], 01cdh
; 		mov [offset Hook + 5d], 21h
; 
; Hook:
		mov ax, 4c00h
		int 21h

String		db 'MEOW', CRLF, 'MEOW$'

end Start
