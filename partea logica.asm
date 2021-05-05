.386
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
window_title DB "Proiect PLA-Logica",0
area_width EQU 800
area_height EQU 600
area DD 0

counter DD 0 ; numara evenimentele de tip timer

numar_linii DD 6
numar_coloane DD 6


x0 EQU 200
y0 EQU 200 

x_matrice dd 0
y_matrice dd 0 
pozitii_corecte dd 0 

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

dim_patrat EQU 49 

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include matrice_patrate.inc
include matrice_stari_initiale.inc
include matrice_stari_finale.inc


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
	mov dword ptr [edi], 884DA7h
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

make_text1 proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit1
	cmp eax, 'Z'
	jg make_digit1
	sub eax, 'A'
	lea esi, letters
	jmp draw_text1
make_digit1:
	cmp eax, '0'
	jl make_space1
	cmp eax, '9'
	jg make_space1
	sub eax, '0'
	lea esi, digits
	jmp draw_text1
make_space1:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text1:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii1:
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
bucla_simbol_coloane1:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb1
	mov dword ptr [edi], 0
	jmp simbol_pixel_next1
simbol_pixel_alb1:
	mov dword ptr [edi], 0F7FF3Ch
simbol_pixel_next1:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane1
	pop ecx
	loop bucla_simbol_linii1
	popa
	mov esp, ebp
	pop ebp
	ret
make_text1 endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_text1_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text1
	add esp, 16
endm

make_patrat proc
	push ebp
	mov ebp, esp
	pusha
	mov eax,[ebp+arg1]
	lea esi, matrice_patrate
	
	bucla_simb_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, dim_patrat
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, dim_patrat
bucla_simb_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	cmp byte ptr [esi], 1
	je simbol_pixel_verde
	cmp byte ptr[esi], 2
	je simbol_pixel_albastru
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_albastru:
	mov dword ptr [edi], 00000CDh
	jmp simbol_pixel_next
simbol_pixel_verde:
	mov dword ptr [edi], 04CAF50h	
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simb_coloane
	pop ecx
	loop bucla_simb_linii
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_patrat endp 

make_patrat_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_patrat
	add esp, 16
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
     jmp afisare_patratele
	
evt_click:
	mov ebx, [ebp+arg2] ; aici x
	mov edx, [ebp+ arg3]; aici y 
	mov esi , edx
	mov eax, 0
	add eax, ebx 
	sub eax, x0
	push edx
	mov edx, 0
	mov ecx, symbol_width
	div ecx ; am in eax j ul 
	mov ecx, eax
	
	
	pop edx
	push ecx
	mov eax, 0
	add eax, edx 
	sub eax, y0
	mov edx, 0
	mov ecx, symbol_height
	div ecx ; aici am i ul 
	
	pop ecx
	mul numar_coloane ; i*nr_coloane+j 
	add eax, ecx
	mov ecx, 0

	mov cl, matrice_stari_initiale[eax]
	push eax
	mov edx, 0
	mov eax,ecx 
	mov esi, 4
	div esi ; vom avea in edx restul impartirii(starea) si in eax catul (nr figurii)
	mov esi, eax ; vom avea in esi catul 
	cmp edx, 3
	je next 
	inc ecx  
	pop eax 
	mov matrice_stari_initiale[eax], cl
	jmp evt_timer
next:	
	mov esi, 4
	mul esi
	mov ecx,eax ; vom inmulti catul cu 4 , pentru a obtine pozitia initiala a fiecarui patrat  
	pop eax 
	mov matrice_stari_initiale[eax], cl

evt_timer:
	inc counter
	
afisare_patratele:
	;pentru indecsi
;incepem parcurgerea pentru afisarea matricei
  mov pozitii_corecte, 0
	mov ebx,0 ;ebx e 0= i 
bucla_i:
		;instructiuni
		mov edx,0 ; edx e 0= j 
bucla_j:
			;instructiuni
			
			;calculam x=x0+j*dimensiunea patratelei
			mov eax,edx; punem j in eax
			push edx
			mov esi, symbol_width
			mul esi
			add eax,x0
			mov esi, eax ; avem x_matrice in registrul esi 
			
			;calculam y=y0+i*dimensiune patratica
			mov eax,ebx; punem i in eax
			mov edi, symbol_height
			mul edi
			add eax,y0
			mov edi, eax; avem y_matrice in registrul edi
			
			;calculam i*c+j
			mov eax, ebx
			mov edx,numar_coloane
			mul edx ;se calculeaza i*c si rezultatul se afla in eax
			pop edx
			add eax, edx ;Rezultatul i*c+j
			mov ecx,0
			mov cl ,matrice_stari_initiale[eax]
			add ecx, '0'
			make_text_macro ecx ,area,esi,edi;afisare element din matrice
			inc edx
			
			push ebx 
			mov ebx, 0
			mov bl, matrice_stari_finale[eax]
			add ebx, '0'
			cmp ebx,ecx 
			je incrementare
			jmp continuam 
		incrementare: inc pozitii_corecte
           continuam: pop ebx
		   cmp edx, numar_coloane   
			jl bucla_j
		inc ebx
		cmp ebx, numar_linii
		jl bucla_i
	
 
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
	make_text_macro 'N', area, 350, 100
	make_text_macro 'E', area, 360, 100
	make_text_macro 'T', area, 370, 100
	make_text_macro 'W', area, 380, 100
	make_text_macro 'O', area, 390, 100
	make_text_macro 'R', area, 400, 100
	make_text_macro 'K', area, 410, 100
	
    cmp pozitii_corecte, 36
	je ai_castigat 
jmp final_draw

ai_castigat:

	make_text1_macro 'A', area, 600, 400
	make_text1_macro 'I', area, 610, 400
	
	make_text1_macro 'C', area, 630, 400
	make_text1_macro 'A', area, 640, 400
	make_text1_macro 'S', area, 650, 400
	make_text1_macro 'T', area, 660, 400
	make_text1_macro 'I', area, 670, 400
	make_text1_macro 'G', area, 680, 400
	make_text1_macro 'A', area, 690, 400
	make_text1_macro 'T', area, 700, 400

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
