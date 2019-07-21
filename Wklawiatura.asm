format MZ
stack stk:256
entry text:main

macro delay time
{
local ext, iter
	push cx
	mov cx, time
ext:
	push cx
	mov cx, 0FFFFh
iter:
	loop iter
	pop cx
	loop ext
	pop cx
}

segment data_16 use16
_stare08 dw ?
	 dw ?
_stare09 dw ?
	 dw ?

mark_08 dw 0
time_08 db 0

mark_09 dw 320
znakim db 'wertyui'
znakid db 'WERTYUI'
znaki2m db 'hjkl'
znaki2d db 'HJKL'

atryb db 71h
flaga db 0

segment text use16
moje08: push ax
	push bx
	push es
	test [time_08],03
	jnz skip
	mov ax,0B800h
	mov es,ax
	mov al,21h
	mov bx,[mark_08]
	mov [es:bx],ax
	add [mark_08],2
skip:	inc [time_08]
	pop es
	pop bx
	pop ax
	jmp dword [ds:_stare08]

moje09: push ax
	push bx
	push es
	in al,60h

	cmp al,42
	jne dalej3
	mov byte [flaga],1
	jmp dalej

dalej3: cmp al,170
	jne dalej4
	mov byte [flaga],0
	jmp dalej

dalej4: cmp al,80h
	ja dalej

	sub al,3
	cmp al,05h
	ja dalej1
	inc al
	cmp al,0Ah
	jne xx
	sub al,0Ah

xx:	add al,31h
yy:	
	mov ah,[atryb]
	mov bx, [mark_09]
	push ax
	mov ax,0B800h
	mov es,ax
	pop ax
	mov [es:bx],ax
	add [mark_09],2
	jmp dalej

dalej1: sub al,14
	cmp al,6
	ja dalej6
	mov ah,0
	mov bx, znakim
	add bx,ax
	mov al, [flaga]
	test al,0FFh
	jz dalej5
	add bx,7

dalej5: mov al,[bx]
	jmp yy

dalej6: sub al,18; roznica miedzy q a h w scancodach
	cmp al,3; sprawdzenie czy nasz scancode jest w zadanym przedziale
	ja dalej
	mov ah,0
	mov bx, znaki2m ;wskazanie gdzie sa litery
	add bx,ax
	mov al, [flaga]
	test al,0FFh ;sprawdzenie czy mamy shift
	jz dalej5    ;skok do wyswietlenia jesli nie
	add bx,4     ;dodanie ilosci malych liter by wejsc na duze ktore sa zaraz obok w pamieci
	jmp dalej5   ;skok do wyswietlania

dalej:	in al,61h
	or al,80h
	out 61h,al
	and al,7Fh
	out 61h,al
	mov al,20h
	out 20h,al

	pop es
	pop bx
	pop ax

	iret

main:	mov ax,data_16
	mov ds,ax
	mov ax,stk
	mov ss,ax
	mov sp,256

	cli
	xor ax,ax
	mov es,ax
	les bx,[es:(8 shl 2)]
	mov [_stare08+2],es
	mov [_stare08],bx
	mov es,ax
	mov word [es:(8 shl 2)],moje08
	mov word [es:(8 shl 2)+2],text

	mov es,ax
	les bx,[es:(9 shl 2)]
	mov [_stare09+2],es
	mov [_stare09],bx
	mov es,ax
	mov word [es:(9 shl 2)],moje09
	mov word [es:(9 shl 2)+2],text
	sti

	delay 0FFh

	cli
	xor ax,ax
	les cx,dword [ds:_stare08]
	mov ds,ax
	mov [ds:(8 shl 2)],cx
	mov [ds:(8 shl 2)+2],es
	
	mov ax,data_16
	mov ds,ax
	les cx,dword [ds:_stare09]
	xor ax,ax
	mov ds,ax
	mov [ds:(9 shl 2)],cx
	mov [ds:(9 shl 2)+2],es
	
	mov ax,data_16
	mov ds,ax
	sti

	mov ah,1
	int 21h
	mov ax,4C00h
	int 21h

	ret

segment stk use16
	db 256 dup (?)
	
	