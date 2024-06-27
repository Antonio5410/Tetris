.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Tetris",0
area_width EQU 800
area_height EQU 500
area DD 0

poz_x_start dd 331
poz_y_start dd 51

poz_x dd 331
poz_y dd 51

poz_x_next dd 0
poz_y_next dd 0

random_color dd 0
random_form dd 0
random_color1 dd 0
random_form1 dd 0

generare dd 1
valoare_urmator dd 0

start_joc dd 1

counter DD 0 ; numara evenimentele de tip timer
speed_counter dd 0 ; numarator pt 3 secunde
speed dd 15 ;3 secunde 

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24
arg6 EQU 28

symbol_width EQU 10
symbol_height EQU 20

input_image_height equ 20
input_image_width equ 20

include digits.inc
include letters.inc
include mov.inc
include galben.inc
include portocaliu.inc
include alb.inc
include verde.inc
include gri.inc
include border.inc
include rosu.inc
include albastru.inc

matrix_width equ 12
matrix_height equ 21
start_x equ 5
start_y equ 0
mx dd 5
my dd 0

matrice DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
		DD -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, -1



.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
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


;=================================================================================================================================

; procedura draw_image va desena o imagine selectata prin arg6
; arg1 - pointer la vectorul de pixeli
; arg2 = x
; arg3 = y
; arg4 = input_image_height
; arg5 = input_image_width
; arg6 = nr_culoare

draw_image proc 
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg6]
	
	cmp eax, 0
	je r
	
	cmp eax, 1
	je p
	
	cmp eax, 2
	je g
	
	cmp eax, 3
	je v
	
	cmp eax, 4
	je ab
	
	cmp eax, 5
	je m
	
	cmp eax, 6
	je a
	
	cmp eax, 7
	je brd
	
r:
	lea esi, rosu
	jmp final_selectie
	
p: 
	lea esi, portocaliu
	jmp final_selectie
	
g: 
	lea esi, galben
	jmp final_selectie
	
v: 
	lea esi, verde
	jmp final_selectie
	
ab: 
	lea esi, albastru
	jmp final_selectie
	
a:
	lea esi, alb
	jmp final_selectie
	
brd:
	lea esi, border
	jmp final_selectie
	
m: 
	lea esi, violet
	
final_selectie:
	
	mov ecx, [ebp+arg4]
	
	
	
loop_linii:
	mov edi, [ebp+arg1]  ; edi = pointer la vectorul de pixeli
	mov eax, [ebp+arg3] ; eax = y
	add eax, [ebp+arg4] ; eax = y + input_image_height
	sub eax, ecx  ; eax= y + input_image_height - ecx = randul imaginii
	mov ebx, area_width 
	mul ebx  ; eax = randul_imaginii * area_width 
	add eax, [ebp+arg2] ; eax = randul_imaginii * area_width + x
	shl eax, 2 ; eax = 4*(rabdul_imaginii * area_width + x)
	add edi, eax ; edi = adresa inceputului de rand
															
	push ecx
	mov ecx, [ebp+arg5]
loop_coloane:
	push eax
	mov eax, dword ptr[esi]
	mov dword ptr[edi], eax
	pop eax
	add edi, 4
	add esi, 4
	loop loop_coloane
	
	pop ecx
	loop loop_linii
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw_image endp

random_number macro x, modullo
	pusha
	rdtsc
	and eax, modullo
	mov x, eax
	popa
endm


draw_image_macro macro drawArea, x, y, AreaHeight, AreaWidth, sel
	
	push sel
	push AreaWidth
	push AreaHeight
	push y
	push x
	push drawArea
	call draw_image 
	add esp, 24
endm



;=================================================================================================================================



; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm


pozitie macro x,y
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
endm

line_horizontal macro x, y, len, color
	; area = (area_width*y + x)*4
local bucla_orizontala
	pozitie x,y
	mov ecx, len	
bucla_orizontala:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_orizontala
endm

line_vertical macro x, y, len, color
local bucla_verticala
	pozitie x,y
	mov ecx, len	
bucla_verticala:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop bucla_verticala
endm

square macro x, y, len, color
local loop1, loop2
	pozitie x,y
	
	mov ecx, len
loop1:
	push ecx
	mov ecx, len
loop2:
	mov dword ptr[eax], color
	add eax, 4
	loop loop2
	pop ecx
	add eax, (area_width-len)*4
	loop loop1
endm









formare_forme macro area, poz_x, poz_y, nr_culoare, nr_forma
local S,Z,_,J,L,I,O, final
	push eax
	mov eax, nr_forma
	
	cmp eax, 0
	je O
	
	cmp eax, 1
	je I
	
	cmp eax, 2
	je _
	
	cmp eax, 3
	je L
	
	cmp eax, 4
	je J
	
	cmp eax, 5
	je Z
	
	cmp eax, 6
	je S
	
	jmp final

S:
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 20
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	sub poz_y, 20
	jmp final 
Z:
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_y, 20
	sub poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	add poz_x, 20
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 20
	sub poz_y, 20
	jmp final
_:
	sub poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 40
	jmp final
	
J:
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_y, 40
	jmp final
	
L:
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 20
	sub poz_y, 40
	jmp final
	
I:
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_y, 60
	jmp final
O:
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	add poz_y, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_x, 20
	draw_image_macro area, poz_x, poz_y, input_image_height, input_image_width, nr_culoare
	sub poz_y,20
	jmp final
	
	final:
	pop eax
endm


marcare_matrice macro mx, my
	pusha
	lea esi, matrice
	mov eax, my
	mov ebx, matrix_width
	mul ebx
	add eax, mx
	shl eax, 2
	add esi, eax
	mov dword ptr[esi], 1
	popa
endm

marcare_matrice_forma macro mx, my, nr_forma
	local S,Z,_,J,L,I,O, final
	pusha
	mov eax, nr_forma
	
	cmp eax, 0
	je O
	
	cmp eax, 1
	je I
	
	cmp eax, 2
	je _
	
	cmp eax, 3
	je L
	
	cmp eax, 4
	je J
	
	cmp eax, 5
	je Z
	
	cmp eax, 6
	je S
	
	jmp final
	
L:
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	sub my, 2
	sub mx, 1
	jmp final
	
S:
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	sub mx, 1
	add my, 1
	marcare_matrice mx, my
	sub mx, 1
	marcare_matrice mx, my
	sub my, 1
	add mx, 1
	jmp final
	
Z:
	marcare_matrice mx, my
	sub mx, 1
	marcare_matrice mx, my
	add mx, 1
	add my, 1
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	sub mx, 1
	sub my, 1
	jmp final
	
J:
	add mx, 1
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	sub mx, 1
	marcare_matrice mx, my
	sub my, 2
	jmp final
	
_:
	sub mx, 1
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	sub mx, 2
	jmp final
	
I:
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	sub my, 3
	jmp final
	
O:
	marcare_matrice mx, my
	add mx, 1
	marcare_matrice mx, my
	add my, 1
	marcare_matrice mx, my
	sub mx, 1
	marcare_matrice mx, my
	sub my, 1
	jmp final

final:
	
	popa
endm


verificare_valoare macro mx, my
	pusha
	lea esi, matrice
	mov eax, my
	mov ebx, matrix_width
	mul ebx
	add eax, mx
	shl eax, 2
	add esi, eax
	mov eax, dword ptr[esi]
	mov valoare_urmator, eax
	popa
endm

verificare_dreapta_forme macro mx, my, nr_forma
local S,Z,_,J,L,I,O,zero,minus, final
	pusha
	mov eax, nr_forma
	
	cmp eax, 0
	je O
	
	cmp eax, 1
	je I
	
	cmp eax, 2
	je _
	
	cmp eax, 3
	je L
	
	cmp eax, 4
	je J
	
	cmp eax, 5
	je Z
	
	cmp eax, 6
	je S
	
	jmp final
	
L:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final

S:
	add mx,1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
Z:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
	
J:
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add mx, 1
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add mx, 1
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
_:
	add mx, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
	
I:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 3
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 3
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
O:
	add mx,1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	add mx,1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	sub my, 1
	
	cmp eax, 0
	je zero
	jmp final
	
minus:
	mov valoare_urmator, -1
	jmp final
zero:
	mov valoare_urmator, 0
	
	final:
	popa
endm


verificare_stanga_forme macro mx, my, nr_forma
	local S,Z,_,J,L,I,O,zero,minus, final
	pusha
	mov eax, nr_forma
	
	cmp eax, 0
	je O
	
	cmp eax, 1
	je I
	
	cmp eax, 2
	je _
	
	cmp eax, 3
	je L
	
	cmp eax, 4
	je J
	
	cmp eax, 5
	je Z
	
	cmp eax, 6
	je S
	
	jmp final
	
L:
	
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final

S:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	sub mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	add mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
Z:
	sub mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	add mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
	
J:
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add mx, 1
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	
	cmp eax, 0
	je zero
	jmp final
	
_:
	sub mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	add mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	
	cmp eax, 0
	je zero
	jmp final
	
	
I:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 3
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 3
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
O:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
minus:
	mov valoare_urmator, -1
	jmp final
zero:
	mov valoare_urmator, 0
	
	final:
	popa
endm


verificare_jos_forme macro mx, my, nr_forma
	local S,Z,_,J,L,I,O,zero,minus, final
	pusha
	mov eax, nr_forma
	
	cmp eax, 0
	je O
	
	cmp eax, 1
	je I
	
	cmp eax, 2
	je _
	
	cmp eax, 3
	je L
	
	cmp eax, 4
	je J
	
	cmp eax, 5
	je Z
	
	cmp eax, 6
	je S
	
	jmp final
	
L:
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final

S:
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	sub mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	add mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	
	cmp eax, 0
	je zero
	jmp final
	
Z:
	sub mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	add mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
	
J:
	add my, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 2
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 2
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
_:
	verificare_valoare mx, my
	mov eax, valoare_urmator
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add mx, 2
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub mx, 2
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	sub mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	add mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
	
I:
	add my, 3
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 3
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
O:
	add my, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	add my, 1
	add mx, 1
	verificare_valoare mx, my
	mov eax, valoare_urmator
	sub my, 1
	sub mx, 1
	cmp eax, 1
	je minus
	cmp eax, -1
	je minus
	
	cmp eax, 0
	je zero
	jmp final
	
minus:
	mov valoare_urmator, -1
	jmp final
zero:
	mov valoare_urmator, 0
	
	final:
	popa
endm

stop macro nr_forma
	
	local S,Z,_,J,L,I,O,gata, merge, final
	pusha
	mov eax, nr_forma
	
	cmp eax, 0
	je O
	
	cmp eax, 1
	je I
	
	cmp eax, 2
	je _
	
	cmp eax, 3
	je L
	
	cmp eax, 4
	je J
	
	cmp eax, 5
	je Z
	
	cmp eax, 6
	je S
	
	jmp final
	
L:
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	
	; add start_y, 2
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 2
	; cmp eax, -1
	; je gata
	
	; add start_y, 2
	; add start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 2
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	; jmp merge
S:
	
	; add start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; sub start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; add start_x, 1
	; cmp eax, -1
	; je gata
	; jmp merge
	
Z:
	; sub start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; add start_x, 1
	; cmp eax, -1
	; je gata
	
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; add start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 1
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	; jmp merge
	
J:
	
	; add start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	
	; add start_x, 1
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	
	; add start_x, 1
	; add start_y, 2
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 2
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	
	; add start_y, 2
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 2
	; cmp eax, -1
	; je gata
	; jmp merge
	
_:
	; sub start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; add start_x, 1
	; cmp eax, -1
	; je gata
	
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; cmp eax, -1
	; je gata
	
	; add start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	
	; add start_x, 2
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 2
	; cmp eax, -1
	; je gata
	; jmp merge
	
I:
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	
	; add start_y, 2
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 2
	; cmp eax, -1
	; je gata
	
	; add start_y, 3
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 3
	; cmp eax, -1
	; je gata
	; jmp merge
	
O:
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; cmp eax, -1
	; je gata
	
	; add start_x, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 1
	; cmp eax, -1
	; je gata
	
	; add start_x, 1
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_x, 1
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	
	; add start_y, 1
	; verificare_valoare start_x, start_y
	; mov eax, valoare_urmator
	; sub start_y, 1
	; cmp eax, -1
	; je gata
	; jmp merge
	
gata:
	push 0
	call exit

merge:
	popa

	
	; formare_forme area, poz_x_next, poz_y_next, 6, random_form1
endm


mutare_forme macro area, poz_x, poz_y, mx, my, speed_counter, speed, event, nr_forma, nr_culoare
local time, jos, stanga, dreapta, final, inceput, ok
	pusha
	mov eax, speed_counter
	cmp eax, speed
	je time
	
	mov eax, event
	cmp eax, 25h
	je stanga
	
	cmp eax, 27h
	je dreapta
	
	cmp eax, 28h
	je jos
	
	jmp final
time:
	add my,1
	verificare_jos_forme mx, my, nr_forma
	
	sub my, 1
	mov edx, valoare_urmator
	cmp edx, 0
	jne ok
	add my,1
	formare_forme  area, poz_x, poz_y, 6, nr_forma
	add poz_y, 20
	formare_forme  area, poz_x, poz_y, nr_culoare, nr_forma
	mov speed_counter, 0
	jmp final
	
	ok:
		marcare_matrice_forma mx, my, nr_forma
		mov eax, start_x
		mov mx, eax
		mov eax, start_y
		mov my, eax
		mov generare, 1
		mov ebx, random_color1
		mov random_color, ebx
		mov ebx, random_form1
		mov random_form, ebx
		; stop random_form1
		formare_forme area, poz_x_next, poz_y_next, 6, random_form1
		random1
		mov eax, poz_x_start
		mov poz_x, eax
		mov eax, poz_y_start
		mov poz_y, eax
		formare_forme area, poz_x, poz_y, nr_culoare, nr_forma
	
	jmp time
	
	
stanga:
	sub mx,1
	; verificare_valoare mx, my
	verificare_stanga_forme mx, my, nr_forma
	add mx, 1
	mov edx, valoare_urmator
	cmp edx, 0
	jne final
	sub mx,1
	formare_forme  area, poz_x, poz_y, 6, nr_forma
	sub poz_x, 20
	formare_forme  area, poz_x, poz_y, nr_culoare, nr_forma
	jmp final
	
dreapta:
	add mx,1
	verificare_dreapta_forme mx, my, nr_forma
	sub mx, 1
	mov edx, valoare_urmator
	cmp edx, 0
	jne final
	add mx,1
	formare_forme  area, poz_x, poz_y, 6, nr_forma
	add poz_x, 20
	formare_forme  area, poz_x, poz_y, nr_culoare, nr_forma
	jmp final
	
jos:

	add my,1
	verificare_jos_forme mx, my, nr_forma
	
	sub my, 1
	mov edx, valoare_urmator
	cmp edx, 0
	jne final
	add my,1
	formare_forme  area, poz_x, poz_y, 6, nr_forma
	add poz_y, 20
	formare_forme  area, poz_x, poz_y, nr_culoare, nr_forma
	jmp final
		
	final:
	
	popa
endm

random macro
local peste
	push eax
	mov eax, generare
	cmp eax, 1
	jne peste
	
	random_number random_color, 5
	random_number random_form, 6
	mov generare, 0
	peste:
	pop eax
endm

random1 macro 
local peste
	push eax
	mov eax, generare
	cmp eax, 1
	jne peste
	
	random_number random_color1, 5
	random_number random_form1, 6
	mov generare, 0
	peste:
	pop eax
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
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax, 3
	je evt_tasta
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
	
evt_click:
	mov edi, area
	mov ecx, area_height
	mov ebx, [ebp+arg3]
	and ebx, 7
	inc ebx
	
	
evt_timer:
	inc counter
	inc speed_counter

evt_tasta:
	
	
afisare_litere:
	random
	random1
	formare_forme area, poz_x, poz_y, random_color, random_form
	
	mov edx, 'U'
	make_text_macro edx, area, 500, 30
	mov edx, 'R'
	make_text_macro edx, area, 510, 30
	mov edx, 'M'
	make_text_macro edx, area, 520, 30
	mov edx, 'A'
	make_text_macro edx, area, 530, 30
	mov edx, 'T'
	make_text_macro edx, area, 540, 30
	mov edx, 'O'
	make_text_macro edx, area, 550, 30
	mov edx, 'A'
	make_text_macro edx, area, 560, 30
	mov edx, 'R'
	make_text_macro edx, area, 570, 30
	mov edx, 'E'
	make_text_macro edx, area, 580, 30
	mov edx, 'A'
	make_text_macro edx, area, 590, 30
	mov edx, ' '
	make_text_macro edx, area, 600, 30
	mov edx, 'F'
	make_text_macro edx, area, 610, 30
	mov edx, 'O'
	make_text_macro edx, area, 620, 30
	mov edx, 'R'
	make_text_macro edx, area, 630, 30
	mov edx, 'M'
	make_text_macro edx, area, 640, 30
	mov edx, 'A'
	make_text_macro edx, area, 650, 30
	
	mov poz_x_next, 540
	mov poz_y_next, 60
	formare_forme area, poz_x_next, poz_y_next, random_color1, random_form1
	
	
	
	mutare_forme area, poz_x, poz_y,mx, my, speed_counter, 5, [ebp+arg2], random_form, random_color
	
	
	
	

	
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	
	mov edx, 'A'
	make_text_macro edx, area, 550, 450
	mov edx, 'N'
	make_text_macro edx, area, 560, 450
	mov edx, 'T'
	make_text_macro edx, area, 570, 450
	mov edx, 'O'
	make_text_macro edx, area, 580, 450
	mov edx, 'N'
	make_text_macro edx, area, 590, 450
	mov edx, 'I'
	make_text_macro edx, area, 600, 450
	mov edx, 'O'
	make_text_macro edx, area, 610, 450
	
	mov edx, 'M'
	make_text_macro edx, area, 630, 450
	mov edx, 'E'
	make_text_macro edx, area, 640, 450
	mov edx, 'S'
	make_text_macro edx, area, 650, 450
	mov edx, 'A'
	make_text_macro edx, area, 660, 450
	mov edx, 'R'
	make_text_macro edx, area, 670, 450
	mov edx, 'O'
	make_text_macro edx, area, 680, 450
	mov edx, 'S'
	make_text_macro edx, area, 690, 450
	
	
	
	
	
	
	
	;desenez cadranul
	
	line_horizontal 250,70,200,0CCCCCCh
	line_horizontal 250,90,200,0CCCCCCh
	line_horizontal 250,110,200,0CCCCCCh
	line_horizontal 250,130,200,0CCCCCCh
	line_horizontal 250,150,200,0CCCCCCh
	line_horizontal 250,170,200,0CCCCCCh
	line_horizontal 250,190,200,0CCCCCCh
	line_horizontal 250,210,200,0CCCCCCh
	line_horizontal 250,230,200,0CCCCCCh
	line_horizontal 250,250,200,0CCCCCCh
	line_horizontal 250,270,200,0CCCCCCh
	line_horizontal 250,290,200,0CCCCCCh
	line_horizontal 250,310,200,0CCCCCCh
	line_horizontal 250,330,200,0CCCCCCh
	line_horizontal 250,350,200,0CCCCCCh
	line_horizontal 250,370,200,0CCCCCCh
	line_horizontal 250,390,200,0CCCCCCh
	line_horizontal 250,410,200,0CCCCCCh
	line_horizontal 250,430,200,0CCCCCCh
	
	line_vertical 270, 50, 400, 0CCCCCCh
	line_vertical 290, 50, 400, 0CCCCCCh
	line_vertical 310, 50, 400, 0CCCCCCh
	line_vertical 330, 50, 400, 0CCCCCCh
	line_vertical 350, 50, 400, 0CCCCCCh
	line_vertical 370, 50, 400, 0CCCCCCh
	line_vertical 390, 50, 400, 0CCCCCCh
	line_vertical 410, 50, 400, 0CCCCCCh
	line_vertical 430, 50, 400, 0CCCCCCh
	line_horizontal 251,50,200,0 			; N
	line_horizontal 250,450,200,0 			; S
	line_vertical 250, 50, 400, 0 			; V
	line_vertical 450, 51, 400, 0 			; E
	
	; COORDONATE:
	; STANGA SUS : 	X = 250 , Y = 50 
	; STANGA JOS:   X = 250 , Y = 450
	; DREAPTA JOS:  X = 450 , Y = 450
	; DREAPTA SUS:  X = 450 , Y = 50
	
	; LEFT BORDER:
	draw_image_macro area, 230, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 50, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 70, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 90, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 110, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 130, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 150, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 170, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 190, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 210, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 230, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 250, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 270, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 290, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 310, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 330, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 350, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 370, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 390, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 410, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 430, input_image_height, input_image_width, 7
	draw_image_macro area, 230, 450, input_image_height, input_image_width, 7
	
	; RIGHT BORDER:
	draw_image_macro area, 450, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 50, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 70, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 90, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 110, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 130, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 150, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 170, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 190, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 210, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 230, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 250, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 270, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 290, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 310, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 330, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 350, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 370, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 390, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 410, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 430, input_image_height, input_image_width, 7
	draw_image_macro area, 450, 450, input_image_height, input_image_width, 7
	
	; UP BORDER
	draw_image_macro area, 250, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 270, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 290, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 310, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 330, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 350, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 370, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 390, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 410, 30, input_image_height, input_image_width, 7
	draw_image_macro area, 430, 30, input_image_height, input_image_width, 7
	
	; DOWN BORDER
	draw_image_macro area, 250, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 270, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 290, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 310, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 330, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 350, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 370, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 390, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 410, 450, input_image_height, input_image_width, 7
	draw_image_macro area, 430, 450, input_image_height, input_image_width, 7
	
	
	

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
