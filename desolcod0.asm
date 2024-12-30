
;----------------------------------------------------------------------------

Start		EQU	200h		; Code start and entry point

	ORG	100h

	di
	ld	sp,100h

; Set color mode and memory mode
	xor a
	ld (0F800h), a			; Управление цветным режимом
	ld (0FA00h), a			; Управление переключением экранов
	ld (0F900h), a			; Включаем страницу памяти "0"

; Move encoded block from Start to B000h
	ld	de,Start		; source addr
	ld	hl,0B000h		; destination addr
	ld	bc,04000h		; length
Init_1:
	ld a,(de)
	inc de
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,Init_1

; Decompress the encoded block from B000h to Start
	ld	de,0B000h
	ld	bc,Start
	call	dzx0

; Clear memory from C000h to EFFFh
	ld	hl,0C000h	; addr
	ld	bc,03000h	; size
Init_2:
	xor a
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz, Init_2

	jp Start

; Short sound on look/shoot action
;SoundLookShoot:
;	MVI  H, 00Ah	; Counter 1
;	XRA  A
;SoundLookShoot_1:
;	MVI  L, 080h	; Counter 2
;SoundLookShoot_2:
;	DCR  L
;	JNZ     SoundLookShoot_2  ; delay
;	XRI     001h	; inverse bit 0
;	OUT     000h
;	DCR  H
;	JNZ     SoundLookShoot_1  ; Loop 30 times
;	ret

;----------------------------------------------------------------------------
; ZX0 decompressor code by Ivan Gorodetsky
; https://github.com/ivagorRetrocomp/DeZX/blob/main/ZX0/8080/OLD_V1/dzx0_CLASSIC.asm
; input:	de=compressed data start
;		bc=uncompressed destination start
; Распаковщик для сжатия ZX0 forward, код для 8080 в мнемонике Z80
dzx0:
		ld hl,0FFFFh
		push hl
		inc hl
		ld a,080h
dzx0_literals:
		call dzx0_elias
		call dzx0_ldir
		jp c,dzx0_new_offset
		call dzx0_elias
dzx0_copy:
		ex de,hl
		ex (sp),hl
		push hl
		add hl,bc
		ex de,hl
		call dzx0_ldir
		ex de,hl
		pop hl
		ex (sp),hl
		ex de,hl
		jp nc,dzx0_literals
dzx0_new_offset:
		call dzx0_elias
		ld h,a
		pop af
		xor a
		sub l
		ret z
		push hl
		rra
		ld h,a
		ld a,(de)
		rra
		ld l,a
		inc de
		ex (sp),hl
		ld a,h
		ld hl,1
		call nc,dzx0_elias_backtrack
		inc hl
		jp dzx0_copy
dzx0_elias:
		inc l
dzx0_elias_loop:
		add a,a
		jp nz,dzx0_elias_skip
		ld a,(de)
		inc de
		rla
dzx0_elias_skip:
		ret c
dzx0_elias_backtrack:
		add hl,hl
		add a,a
		jp nc,dzx0_elias_loop
		jp dzx0_elias
dzx0_ldir:
		push af
dzx0_ldir1:
		ld a,(de)
		ld (bc),a
		inc de
		inc bc
		dec hl
		ld a,h
		or l
		jp nz,dzx0_ldir1
		pop af
		add a,a
		ret

;----------------------------------------------------------------------------
; Filler
	ORG	Start - 1
	DB 0

	END

;----------------------------------------------------------------------------
