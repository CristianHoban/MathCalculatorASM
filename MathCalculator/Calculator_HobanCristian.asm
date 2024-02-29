.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern atoi: proc
extern scanf: proc
extern printf: proc


includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Calculator",0
area_width EQU 320
area_height EQU 440
area DD 0

counter DD 0 ; numara evenimentele de tip timer
counter1 DD 15

ef_operatie dd 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

string db 7 dup(?)
stringnum db 7 dup(0)

stringgol db "0000000"

symbol db 'n'
rez1 dd 0
rez2 dd 0
rezz dd 0
i dd 0
index DD 0
char_op db ?
first_op dd 0
verificare dd 0
opcounter dd 0

format db "%d", 13, 10, 0
symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code

;adunare macro n1, n2
;finit
;fld n1
;fld n2
;fadd
;fst n1
;endm

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
aldoileamumar macro string, rez2
	push offset string
	call atoi
	add esp, 4
	mov rez2, eax
	;adunare rezf, rez1
	push rez2
	push offset format
	call printf
	add esp, 8
	mov string[0], 0
	mov string[1], 0
	mov string[2], 0
	mov string[3], 0
	mov string[4], 0
	mov string[5], 0
	mov string[6], 0
	mov index, 0
	endm
	

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x, y, len, color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_line
endm

line_vertical macro x, y, len, color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop bucla_line
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click_1
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click_1:
	mov eax, [ebp+arg2]; buton pt 1
	cmp eax, 4
	jl evt_click_2
	cmp eax, 64
	jg evt_click_2
	mov eax, [ebp+arg3]	
	cmp eax, 75
	jl evt_click_2
	cmp eax, 142
	jg evt_click_2
	;s-a dat click pe 1 
	make_text_macro '1', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '1'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
	
evt_click_2:
	mov eax, [ebp+arg2]; buton pt 2
	cmp eax, 65
	jl evt_click_3
	cmp eax, 124
	jg evt_click_3
	mov eax, [ebp+arg3]	
	cmp eax, 75
	
	jl evt_click_3
	cmp eax, 142
	jg evt_click_3
	;s-a dat click pe 2
	make_text_macro '2', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '2'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
evt_click_3:
	mov eax, [ebp+arg2]; buton pt 3
	cmp eax, 125
	jl evt_click_plus
	cmp eax, 191
	jg evt_click_plus
	mov eax, [ebp+arg3]	
	cmp eax, 75
	jl evt_click_plus
	cmp eax, 142
	jg evt_click_plus
	;s-a dat click pe 3
	make_text_macro '3', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '3'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
evt_click_plus:
	mov eax, [ebp+arg2]; buton pt +
	cmp eax, 191
	jl evt_click_4
	cmp eax, 320
	jg evt_click_4
	mov eax, [ebp+arg3]	
	cmp eax, 75
	jl evt_click_4
	cmp eax, 142
	jg evt_click_4
	;s-a dat click pe +
	mov char_op, '+'
	make_text_macro 'T', area, counter1, 5
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	cmp opcounter, 0
	jg aldoilea_nr
	cmp opcounter, 0
	je prim_nr
	;adunare rezf, rez1
	;push rezf
	;push offset format
	;call printf
	;add esp, 8
	jmp afisare_litere
evt_click_4:
	mov eax, [ebp+arg2]; buton pt 4
	cmp eax, 4
	jl evt_click_5
	cmp eax, 64
	jg evt_click_5
	mov eax, [ebp+arg3]	
	cmp eax, 142
	jl evt_click_5
	cmp eax, 213
	jg evt_click_5
	;s-a dat click pe 5
	make_text_macro '4', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '4'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
	
evt_click_5:
	mov eax, [ebp+arg2]; buton pt 5
	cmp eax, 65
	jl evt_click_6
	cmp eax, 124
	jg evt_click_6
	mov eax, [ebp+arg3]	
	cmp eax, 142
	jl evt_click_6
	cmp eax, 213
	jg evt_click_6
	;s-a dat click pe 5
	make_text_macro '5', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '5'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
evt_click_6:
	mov eax, [ebp+arg2]; buton pt 6
	cmp eax, 125
	jl evt_click_minus
	cmp eax, 191
	jg evt_click_minus
	mov eax, [ebp+arg3]	
	cmp eax, 142
	jl evt_click_minus
	cmp eax, 213
	jg evt_click_minus
	;s-a dat click pe 6
	make_text_macro '6', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '6'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
evt_click_minus:
	mov eax, [ebp+arg2]; buton pt -
	cmp eax, 191
	jl evt_click_7
	cmp eax, 320
	jg evt_click_7
	mov eax, [ebp+arg3]	
	cmp eax, 142
	jl evt_click_7
	cmp eax, 213
	jg evt_click_7
	;s-a dat click pe -
	make_text_macro 'W', area, counter1, 5
	mov char_op, '-'
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	cmp opcounter, 0
	je prim_nr
	jmp afisare_litere

	
	evt_click_7:
	mov eax, [ebp+arg2]; buton pt 7
	cmp eax, 4
	jl evt_click_8
	cmp eax, 64
	jg evt_click_8
	mov eax, [ebp+arg3]	
	cmp eax, 213
	jl evt_click_8
	cmp eax, 284
	jg evt_click_8
	;s-a dat click pe 7
	make_text_macro '7', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '7'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
	
evt_click_8:
	mov eax, [ebp+arg2]; buton pt 8
	cmp eax, 65
	jl evt_click_9
	cmp eax, 124
	jg evt_click_9
	mov eax, [ebp+arg3]	
	cmp eax, 213
	jl evt_click_9
	cmp eax, 284
	jg evt_click_9
	;s-a dat click pe 8
	make_text_macro '8', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '8'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
evt_click_9:
	mov eax, [ebp+arg2]; buton pt 9
	cmp eax, 125
	jl evt_click_ori
	cmp eax, 191
	jg evt_click_ori
	mov eax, [ebp+arg3]	
	cmp eax, 213
	jl evt_click_ori
	cmp eax, 284
	jg evt_click_ori
	;s-a dat click pe 9
	make_text_macro '9', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '9'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
evt_click_ori:
	mov eax, [ebp+arg2]; buton pt *
	cmp eax, 191
	jl evt_click_0
	cmp eax, 320
	jg evt_click_0
	mov eax, [ebp+arg3]	
	cmp eax, 213
	jl evt_click_0
	cmp eax, 284
	jg evt_click_0
	;s-a dat click pe *
	mov char_op, '*'
	make_text_macro 'X', area, counter1, 5
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	cmp opcounter, 0
	je prim_nr
	jmp afisare_litere
	
	evt_click_0:
	mov eax, [ebp+arg2]; buton pt 0
	cmp eax, 4
	jl evt_click_egal
	cmp eax, 124
	jg evt_click_egal
	mov eax, [ebp+arg3]	
	cmp eax, 284
	jl evt_click_egal
	cmp eax, 355
	jg evt_click_egal
	;s-a dat click pe 0
	make_text_macro '0', area, counter1, 5
	lea ebx, string
	add ebx, index
	mov cl, '0'
	mov [ebx], cl
	;pusha
	;push offset string
	;call printf
	;add esp, 4
	;popa
	inc index
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	jmp afisare_litere
	
evt_click_egal:
	mov eax, [ebp+arg2]; buton pt =
	cmp eax, 125
	jl evt_click_imp
	cmp eax, 191
	jg evt_click_imp
	mov eax, [ebp+arg3]	
	cmp eax, 284
	jl evt_click_imp
	cmp eax, 355
	jg evt_click_imp
	;s-a dat click pe =
	make_text_macro 'Z', area, counter1, 5
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	;aldoileanumar string, rez2
	mov ef_operatie, 1
	jmp aldoilea_nr
Inapoi:	
	cmp char_op, '+'
	je adunare
	cmp char_op, '-'
	je scadere
	cmp char_op, '*'
	je inmultire
	cmp char_op, '/'
	je impartire
Inapoi2:
	jmp number_to_string
back2:
	jmp afisare_litere
evt_click_imp:
	mov eax, [ebp+arg2]; buton pt /
	cmp eax, 191
	jl evt_click_c
	cmp eax, 320
	jg evt_click_c
	mov eax, [ebp+arg3]	
	cmp eax, 284
	jl evt_click_c
	cmp eax, 355
	jg evt_click_c
	;s-a dat click pe /
	mov char_op, '/'
	make_text_macro 'Y', area, counter1, 5
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	cmp opcounter, 0
	je prim_nr
	jmp afisare_litere
evt_click_c:
	mov eax, [ebp+arg2]; buton pt /
	cmp eax, 4
	jl evt_click_null
	cmp eax, 320
	jg evt_click_null
	mov eax, [ebp+arg3]	
	cmp eax, 361
	jl evt_click_null
	cmp eax, 429
	jg evt_click_null
	make_text_macro ' ', area, 5, 5
	make_text_macro ' ', area, 15, 5
	make_text_macro ' ', area, 25, 5
	make_text_macro ' ', area, 35, 5
	make_text_macro ' ', area, 45, 5
	make_text_macro ' ', area, 55, 5
	make_text_macro ' ', area, 65, 5
	make_text_macro ' ', area, 75, 5
	make_text_macro ' ', area, 85, 5
	make_text_macro ' ', area, 95, 5
	make_text_macro ' ', area, 105, 5
	make_text_macro ' ', area, 115, 5
	make_text_macro ' ', area, 125, 5
	make_text_macro ' ', area, 135, 5
	make_text_macro ' ', area, 145, 5
	make_text_macro ' ', area, 155, 5
	make_text_macro ' ', area, 165, 5
	make_text_macro ' ', area, 175, 5
	make_text_macro ' ', area, 185, 5
	make_text_macro ' ', area, 195, 5
	mov rez1, 0
	mov rez2, 0
	mov counter1, 15
	mov opcounter, 0
	jmp afisare_litere
evt_click_null:
	make_text_macro ' ', area, counter1, 5
	jmp afisare_litere

	
prim_nr:
	push offset string
	call atoi
	add esp, 4
	mov rez1, eax
	inc opcounter
	push rez1
	push offset format
	call printf
	add esp, 8
	mov string[0], 0
	mov string[1], 0
	mov string[2], 0
	mov string[3], 0
	mov string[4], 0
	mov string[5], 0
	mov string[6], 0
	mov index, 0
aldoilea_nr:
	push offset string
	call atoi
	add esp, 4
	mov rez2, eax
	;adunare rezf, rez1
	push rez2
	push offset format
	call printf
	add esp, 8
	mov string[0], 0
	mov string[1], 0
	mov string[2], 0
	mov string[3], 0
	mov string[4], 0
	mov string[5], 0
	mov string[6], 0
	mov index, 0
	jmp Inapoi
	
adunare:
	cmp ef_operatie, 1
	jl afisare_litere
	mov eax, rez1
	add eax, rez2
	mov rez1, eax
	push rez1
	push offset format
	call printf
	add esp, 8
	mov ef_operatie, 0
	jmp Inapoi2
scadere:
	cmp ef_operatie, 1
	jl afisare_litere
	mov eax, rez1
	sub eax, rez2
	mov rez1, eax
	push rez1
	push offset format
	call printf
	add esp, 8
	mov ef_operatie, 0
	jmp Inapoi2
inmultire:
	cmp ef_operatie, 1
	jl afisare_litere
	mov eax, rez1
	mov ebx, rez2
	imul ebx
	mov rez1, eax
	push rez1
	push offset format
	call printf
	add esp, 8
	mov ef_operatie, 0
	jmp Inapoi2
impartire:	
	cmp ef_operatie, 1
	jl afisare_litere
	cmp rez1, 0
	jl negare
sss:
	mov eax, rez1
	cmp rez1, 0
	mov edx ,0	
	mov ebx,rez2
	idiv ebx
	mov rez1, eax
	cmp verificare, 0
	je ok
	neg rez1
ok:
	push rez1
	push offset format
	call printf
	add esp, 8
	mov ef_operatie, 0
	mov verificare, 0
	jmp Inapoi2
	
number_to_string:
	make_text_macro ' ', area, 5, 5
	make_text_macro ' ', area, 15, 5
	make_text_macro ' ', area, 25, 5
	make_text_macro ' ', area, 35, 5
	make_text_macro ' ', area, 45, 5
	make_text_macro ' ', area, 55, 5
	make_text_macro ' ', area, 65, 5
	make_text_macro ' ', area, 75, 5
	make_text_macro ' ', area, 85, 5
	make_text_macro ' ', area, 95, 5
	make_text_macro ' ', area, 105, 5
	make_text_macro ' ', area, 115, 5
	make_text_macro ' ', area, 125, 5
	make_text_macro ' ', area, 135, 5
	make_text_macro ' ', area, 145, 5
	make_text_macro ' ', area, 155, 5
	make_text_macro ' ', area, 165, 5
	make_text_macro ' ', area, 175, 5
	make_text_macro ' ', area, 185, 5
	make_text_macro ' ', area, 195, 5
	mov eax, rez1
	mov rezz, eax
	cmp rez1, 0
	jl scrie_minus
	back:
	 mov ebx, 10
	 mov eax, rezz
	 mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 75, 5
	;cifra unitatilor
	 mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 65, 5
	;cifra zecilor
	 mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 55, 5
	;cifra sutelor
	 mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 45, 5
	;cif 4
	mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 35, 5
	 ;cif 5
	mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 25, 5
	 ;cif 6
	mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 15, 5
	 mov counter1, 88
	 jmp back2
	
scrie_minus:
	make_text_macro 'W', area, 5, 5
	mov eax, rez1
	neg eax
	mov rezz, eax
	jmp back
	jmp afisare_litere
negare:
	neg rez1
	mov verificare, 1
	jmp sss
	
evt_timer:
	inc counter

	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	; mov ebx, 10
	; mov eax, counter
	;cifra unitatilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 30, 10
	;cifra zecilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 20, 10
	;cifra sutelor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	 ; make_text_macro '1', area, 110, 100
	; make_text_macro 'R', area, 120, 100
	; make_text_macro 'O', area, 130, 100
	; make_text_macro 'I', area, 140, 100
	; make_text_macro 'E', area, 150, 100
	; make_text_macro 'C', area, 160, 100
	; make_text_macro 'T', area, 170, 100
	
	; make_text_macro 'L', area, 130, 120
	; make_text_macro 'A', area, 140, 120
	
	; make_text_macro 'A', area, 100, 140
	; make_text_macro 'S', area, 110, 140
	; make_text_macro 'A', area, 120, 140
	; make_text_macro 'M', area, 130, 140
	; make_text_macro 'B', area, 140, 140
	; make_text_macro 'L', area, 150, 140
	; make_text_macro 'A', area, 160, 140
	; make_text_macro 'R', area, 170, 140
	; make_text_macro 'E', area, 180, 140
	
	line_horizontal 0, 0, area_width, 0h
	line_horizontal 0, 1, area_width, 0h
	line_horizontal 0, 2, area_width, 0h
	line_horizontal 0, 3, area_width, 0h
	
	line_horizontal 0, 439, area_width, 0h
	line_horizontal 0, 436, area_width, 0h
	line_horizontal 0, 437, area_width, 0h
	line_horizontal 0, 438, area_width, 0h
	
	line_vertical 0, 0, area_height, 0h
	line_vertical 1, 0, area_height, 0h
	line_vertical 2, 0, area_height, 0h
	line_vertical 3, 0, area_height, 0h
	
	line_vertical 319, 0, area_height, 0h
	line_vertical 318, 0, area_height, 0h
	line_vertical 317, 0, area_height, 0h
	line_vertical 316, 0, area_height, 0h
	
	line_horizontal 0, 71, area_width, 0h
	line_horizontal 0, 72, area_width, 0h
	line_horizontal 0, 73, area_width, 0h
	line_horizontal 0, 74, area_width, 0h
	
	line_horizontal 0, 142, area_width, 0h
	line_horizontal 0, 143, area_width, 0h
	line_horizontal 0, 144, area_width, 0h
	line_horizontal 0, 145, area_width, 0h
	
	line_horizontal 0, 213, area_width, 0h
	line_horizontal 0, 214, area_width, 0h
	line_horizontal 0, 215, area_width, 0h
	line_horizontal 0, 216, area_width, 0h
	
	line_horizontal 0, 284, area_width, 0h
	line_horizontal 0, 285, area_width, 0h
	line_horizontal 0, 286, area_width, 0h
	line_horizontal 0, 287, area_width, 0h
	
	line_horizontal 0, 355, area_width, 0h
	line_horizontal 0, 356, area_width, 0h
	line_horizontal 0, 357, area_width, 0h
	line_horizontal 0, 358, area_width, 0h
	
	line_vertical 60*1+4*0, 71, 215, 0h
	line_vertical 60*1+1+4*0, 71, 215, 0h
	line_vertical 60*1+2+4*0, 71, 215, 0h
	line_vertical 60*1+3+4*0, 71, 215, 0h
	
	line_vertical 60*2+4*1, 71, 285, 0h
	line_vertical 60*2+1+4*1, 71, 285, 0h
	line_vertical 60*2+2+4*1, 71, 285, 0h
	line_vertical 60*2+3+4*1, 71, 285, 0h
	
	line_vertical 60*3+4*2, 71, 285, 0h
	line_vertical 60*3+1+4*2, 71, 285, 0h
	line_vertical 60*3+2+4*2, 71, 285, 0h
	line_vertical 60*3+3+4*2, 71, 285, 0h
	
	make_text_macro '1', area, 28, 100
	make_text_macro '2', area, 88, 100
	make_text_macro '3', area, 152, 100
	
	make_text_macro '4', area, 28, 171
	make_text_macro '5', area, 88, 171
	make_text_macro '6', area, 152, 171
	
	make_text_macro '7', area, 28, 242
	make_text_macro '8', area, 88, 242
	make_text_macro '9', area, 152, 242
	
	make_text_macro '0', area, (88+28)/2, 314
	make_text_macro 'Z', area, 152, 314
	
	make_text_macro 'C', area, area_width/2-5, 385
	
	make_text_macro 'T', area, 250, 100
	make_text_macro 'W', area, 250, 171
	make_text_macro 'X', area, 250, 242
	make_text_macro 'Y', area, 250, 314
	
	
	
	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start

; Calculator realizat doar cu ajutorul limbajului de asamblare, inclusiv interfata grafica.
; Programul este realizat, presupunand ca utilizatorul foloseste calculatorul corect(nu am rezolvat cazuri speciale,
; cum ar fi impartirea la 0, sau punerea mai multor operatori, unul dupa altul);
; Calculatorul face operatiile pe rand, dupa fiecare trebuie apasat butonul "=".
