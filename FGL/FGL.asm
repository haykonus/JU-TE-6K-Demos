;------------------------------------------------------------------------------
; Titel:                Ju-Te 6K Fast Graphics Library  (6K-FGL)
;
; Erstellt:             10.11.2023
; Letzte Änderung:      15.11.2024
;------------------------------------------------------------------------------ 

        ifndef  MACROS_INC
                include ./macros.asm
        endif   
                
VRAM            equ     4000h
VRAM_END        equ     5FFFh
VRAM_LEN        equ     VRAM_END - VRAM

VRAM_TAB_HI     equ     FGL_RAM_START       ; muss xx00-Adr. sein
VRAM_TAB_LO     equ     FGL_RAM_START+100h  ; muss xx00-Adr. sein

saveH           equ     6Ah             ; Hilfs-Register
saveL           equ     6Bh             ; Hilfs-Register

;------------------------------------------------------------------------------
; Kopiert Bitmap in den VRAM.
;
; in:           rr12    = Pointer auf Bitmap
;
;               db      ?       ; x-Byte-Pos
;               db      ?       ; y-Pos
;               db      ?       ; xw-Bytes
;               db      ?       ; yw-Zeilen
;               db      ?       ; Farbe VH
;               ds      xw*yw   ; Bitmap
;
; out:          Bitmap im VRAM
;------------------------------------------------------------------------------

FGL_BMP_TO_VRAM:

                lde     r0, @rr12
                ld      var_X_lo, r0    ; x
                incw    rr12

                lde     r0, @rr12
                ld      var_Y_lo, r0    ; y
                incw    rr12

                lde     r0, @rr12
                ld      var_Z_lo, r0    ; xw
                incw    rr12

                lde     r0, @rr12
                ld      var_Z_hi, r0    ; yw
                incw    rr12

                lde     r0, @rr12
                ld      var_W_lo, r0    ; Farbe V8
                incw    rr12

                ; use: r0,r2,r3,r4,r5,r6,r7 in: var_X_lo, var_Y_lo
                call    XBY_to_vram

                ld      r3, var_Z_hi

                citv2:  ld      r2, var_Z_lo

                        citv1:
                                lde     r15, @rr12
                                ;use: r5-15 in: var_W_lo, rr6, r15
                                call    setVRAM
                                incw    rr12
                                inc     r7
                        djnz    r2, citv1

                        sub     r7, var_Z_lo
                        call    vram_inc_y_es40
                djnz    r3, citv2
                ret
        
;------------------------------------------------------------------------------
; Gibt eine Zeichenkette mit FGL_CHAROUT aus.
;
; in:   var_T           = Zeiger auf Zeichensatz        
;       var_U           = Warten nach einer Zeichenzeile (ms)
;       var_V           = Warten nach einem Zeichen (ms)
;       var_W_lo        = Farbe         (VVVVHHHHb  V=Vordergrund, H=Hintergrund)
;       var_X_lo        = x-Byte        (0-39)
;       var_Y_lo        = y-Zeile       (0-191)
;       var_Z_lo        = ASCII
;       var_Z_hi        = N             (Zoom-Faktor)
;
; out:  Zeichenkette auf dem Bildschirm
;------------------------------------------------------------------------------

FGL_PRISTRI:    pop     r12
                pop     r13                     ; SP+2
                push    var_X_lo
prc1:           lde     r2, @rr12

                cp      r2, #0                  ; Ende ?
                jr      z, prcret
                ld      var_Z_lo, r2            ; Zeichen laden

                push    r12
                push    r13
                call    FGL_CHAROUT             ; Zeichen ausgeben
                pop     r13
                pop     r12

                call    FGL_TIMER               ; nach Zeichen warten 

                ld      r0, var_Z_hi            ; inc X
prc2:           inc     var_X_lo
                djnz    r0, prc2

                incw    rr12
                jr      prc1

prcret:         pop     var_X_lo
                incw    rr12
                push    r13
                push    r12
                ret

;------------------------------------------------------------------------------
; Stellt Zeichen auf dem Bildschirm dar.
;
; in:   var_T           = Zeiger auf Zeichensatz        
;       var_U           = Wartezeit nach einer Zeichenzeile
;       var_W_lo        = Farbe         (VVVVHHHHb  V=Vordergrund, H=Hintergrund)
;       var_X_lo        = x-Byte        (0-39)
;       var_Y_lo        = y-Zeile       (0-191)
;       var_Z_lo        = ASCII
;       var_Z_hi        = N             (Zoom-Faktor)
;
; out:  Zeichen auf dem Bildschirm
;
; intern:
;       r0              ASCII->ZG / N
;       r1              ASCII->ZG / save FLAGS
;       r2              ZG hi
;       r3              ZG lo
;       r4              ZG-Zeilen-Zähler
;       r5              ZG-Zeilen-Puffer / setVRAM
;       r6              VRAM hi
;       r7              VRAM lo
;       r8              Puffer-Zeiger / setVRAM
;       r9              setVRAM
;       r10             setVRAM
;       r11             N / setVRAM
;       r12             Puffer-Zeiger
;       r13             N
;       r14             Farb-Register hi / setVRAM
;       r15             Farb-Register lo / setVRAM
;------------------------------------------------------------------------------

FGL_CHAROUT:    call    XBY_to_vram             ; rr6 -> VRAM

                clr     r0
                ld      r1, var_Z_lo            ; rr0 = ASCII
                
                rlc     r1                      ; rr0 x 8 ZG-Zeilen
                rlc     r0
                rlc     r1
                rlc     r0
                rlc     r1
                rlc     r0
                and     r1, #11111000b

                ld      r2, var_T_hi            ; Zeichensatz holen
                ld      r3, var_T_lo
                
                add     r3, r1
                adc     r2, r0                  ; rr2 -> ZG-Byte (ASCII) 1. Zeile

                ;4
                ld      r4, #8;9                ; 8 ZG-Zeilen

                pc1:    ;0,5,2,3
                        ld      r0, #8          ; ZG-Pixel-Zähler
                        lde     r5, @rr2        ; ZG-Zeile
                        
                        pc4:    ;5,13,8,11
                                rrc     r5
                                ld      r1, FLAGS
                                ld      r13, var_Z_hi           ; N x N Bytes 1 x strecken

                                pcc2:   
                                        ldrr    rr8, #zoom_buffer
                                        ld      r11, var_Z_hi   ; N Bytes 1 x strecken
                                        pcc1:   lde     r10, @rr8
                                                rrc     r10
                                                lde     @rr8, r10
                                                incw    rr8
                                        djnz    r11, pcc1

                                        ld      FLAGS, r1
                                djnz    r13, pcc2

                        djnz    r0, pc4                         ; nächstes ZG-Pixel
                                
                        ld      r0, var_Z_hi                    ; N ZG-Zeilen (gestreckt)
                        pcc6:   ;12,13,15,6,7
                                ldrr    rr12, #zoom_buffer
                                ld      r1, var_Z_hi;           ; N Pixel-Bytes (gestreckt)

                                pcc5:
                                        lde     r15, @rr12
                                        
                                        ;5,8,9,10,11,14
                                        call    setVRAM         ; Farb-Bänke setzen
                        
                                        cp      var_U_lo, #0    ; Wartezeit nach Zeile = 0 ?
                                        jr      nz, pcc9
                                        cp      var_V_hi, #0    ; wirklich 0 ?
                                        jr      z, pcc8                 
                                pcc9:   
                                        push    var_V_hi        ; nach Zeile warten     
                                        push    var_V_lo
                                        ld      var_V_hi, var_U_hi
                                        ld      var_V_lo, var_U_lo
                                        call    FGL_TIMER
                                        pop     var_V_lo
                                        pop     var_V_hi
                                pcc8:
                                        incw    rr12
                                        inc     r7

                                djnz    r1, pcc5                ; nächstes Byte

                                sub     r7, var_Z_hi            ; X-Pos korrigieren
                                call    vram_inc_y_es40         ; rr6 -> nächste VRAM-Zeile
                        djnz    r0, pcc6

                        incw    rr2                             ; nächstes ZG-Byte

                djnz    r4, pc1                                 ; nächste ZG-Zeile
                ret

;------------------------------------------------------------------------------
; Erstellt die Lookup-Tabelle für die Konvertierung der X,Y Koordinaten in 
; VRAM-Adressen.
; 
; in:   ---
;
; out:  VRAM_TAB_LO/HI im RAM   

; int:  r0-r4   
;------------------------------------------------------------------------------                 

FGL_INIT:        
                ; Low-Bytes erzeugen

                ld      r0, #hi(VRAM_TAB_LO)
                ld      r1, #0
                
                ld      r3, #64         ; 64 x 3 Zeilen = 192 Zeilen

                ld      r4, #0
                lde     @rr0, r4
                incw    rr0

make_vt1:       add     r4,#40
                lde     @rr0, r4
                incw    rr0

                add     r4,#40
                lde     @rr0, r4
                incw    rr0
                                
                add     r4,#48
                lde     @rr0, r4
                incw    rr0
                
                djnz    r3, make_vt1
                
                ; 3 aus 8 Dekoder erzeugen
                
                decw    rr0
                ld      r3, #8
                ld      r4, #10000000b
make_vt3:       lde     @rr0, r4
                rr      r4
                incw    rr0
                djnz    r3, make_vt3
                
                ; High-Bytes erzeugen

                ld      r0, #hi(VRAM_TAB_HI)
                ld      r1, #0
                
                ld      r2, #6
                ld      r3, #32         ; 32 x 6 Zeilen = 192 Zeilen

                ld      r4, #hi(VRAM)
                
make_vt2:       lde     @rr0, r4
                incw    rr0
                djnz    r2, make_vt2    ; 6 x 40h, 41h, 42h, ...
                ld      r2, #6
                inc     r4
                djnz    r3, make_vt2    ; 32 Blöcke

                ret     
        
;------------------------------------------------------------------------------ 
; Löscht den Bildschirm.
;
; in:   var_Z_lo = Farbe (low-aktiv)    |R|G|B|V|x|x|x|x|
;       var_Z_hi = Pixel (high-aktiv)   |x|x|x|x|x|x|x|x|
;
; int:  r0-r9
;------------------------------------------------------------------------------ 

FGL_CLS:        ld      r6, var_Z_hi
                ld      r3, var_Z_lo

                ld      p01m, #0B2h             ; Ports 0-1 mode, langsames Timing für ext. Speicher

                ld      r0, #hi(VRAM)           ; VRAM
                ld      r1, #lo(VRAM)   
                
                ld      r8, #hi(VRAM_LEN)       ; Zähler
                ld      r9, #lo(VRAM_LEN)

                ld      r2, #60h                ; Farb-Register hi
                ld      r4, r2
                
                ld      r5, #00h                ; Farb-Bänke = 0000xxxx (alle Bänke an)
                                                ; Pixel      = 00000000
                
cls_1:          lde     @rr4, r5                ; Farb-Bänke = 0000xxxx (alle Bänke an)
                lde     @rr0, r5                ; Pixel      = 00000000 -> Bank 1-4
                
                lde     @rr2, r3                ; Farb-Bänke = RGBVxxxx                 
                lde     @rr0, r6                ; Pixel      = xxxxxxxx 
                
                incw    rr0                     ; Nächste RAM-Pos.
                decw    rr8                     ; Zähler -1
                jr      nz, cls_1
                
                ld      p01m, #092h             ; Ports 0-1 mode, schnelles Timing für ext. Speicher    
                ret

;------------------------------------------------------------------------------ 
; Timer
;
; in:   var_V   = N 
;
; out:  wartet N * 1 ms
;------------------------------------------------------------------------------ 
                
FGL_TIMER:      DI
                cp      var_V_lo, #0
                jr      nz, tm0
                cp      var_V_hi, #0
                jr      z, tmend
                
tm0:            push    r12
                push    r13
                push    r0
                
                ld      r12, var_V_hi
                ld      r13, var_V_lo
                                        
tm2:            ld      r0, #0dfh       ; 1 ms
                
tm1:            dec     r0
                jr      nz, tm1
                
                decw    rr12
                jr      nz, tm2

                pop     r0
                pop     r13
                pop     r12

tmend:          EI
                ret
                
;------------------------------------------------------------------------------
; Setzt die Farb-Bytes in den 4 Farb-Bänken (RGBH)
;
; in:
;       var_W_lo        = Farbe         (VVVVHHHHb  V=Vordergrund, H=Hintergrund)
;       r15             = Pixel-Byte
;       rr6             = VRAM
;
;       R G B H  Hex  Farbe
;       ----------------------
;       0 0 0 0   0   schwarz
;       0 0 0 1   1   grau
;       0 0 1 0   2   blau
;       0 0 1 1   3   blauH
;       0 1 0 0   4   grün
;       0 1 0 1   5   grünH
;       0 1 1 0   6   cyan
;       0 1 1 1   7   cyanH
;       1 0 0 0   8   rot
;       1 0 0 1   9   rotH
;       1 0 1 0   A   pink
;       1 0 1 1   B   pinkH
;       1 1 0 0   C   gelb
;       1 1 0 1   D   gelbH
;       1 1 1 0   E   grauH
;       1 1 1 1   F   weiss
;
; out:  4 Bytes im VRAM (RGBH)
;
; intern:
;       r0              -
;       r1              -
;       r2              -
;       r3              -
;       r4              -
;       r5              Pixel-Zähler
;       r6              VRAM hi
;       r7              VRAM lo
;       r8              R
;       r9              G
;       r10             B
;       r11             H
;       r12             -
;       r13             -
;       r14             Farbe /      Farb-Register hi
;       r15             Pixel-Byte / Farb-Register lo
;------------------------------------------------------------------------------

setVRAM:        ld      r5, #8
                plv11:
                        ld      r14, var_W_lo   ; Farbe
                        rlc     r15             ; Pixel-Byte
                        jr      c, plv22
                        swap    r14             ; 4 Bit Farbe (high nibble) für Pixel
                plv22:
                        rlc     r14
                        rlc     r8              ; R

                        rlc     r14
                        rlc     r9              ; G

                        rlc     r14
                        rlc     r10             ; B

                        rlc     r14
                        rlc     r11             ; H

                djnz    r5, plv11

                ld      r14, #60h
                ld      r15, #01111111b         ;Farb-Bänke = RGBHxxxx

                lde     @rr14, r15              ;R-Bank einschalten
                lde     @rr6, r8

                rr      r15
                lde     @rr14, r15              ;G-Bank einschalten
                lde     @rr6, r9

                rr      r15
                lde     @rr14, r15              ;B-Bank einschalten
                lde     @rr6, r10

                rr      r15
                lde     @rr14, r15              ;H-Bank einschalten
                lde     @rr6, r11

                ret

;------------------------------------------------------------------------------                         
XPY_to_vram:
                ; P(x,y) to VRAM        ; IN: var_X, var_Y

                ld      r2, #hi(VRAM_TAB_HI) ;-+
                ld      r4, #hi(VRAM_TAB_LO) ; |
                                        ;      |
                ld      r8, var_X_lo    ;      | 
                                        ;      |
                ;r8 = x / 8 (x = 0-319) ;      |
                                        ;      |
                and     r8, #11111000b  ;      |
                or      r8, var_X_hi    ;      |
                rl      r8              ;      |
                swap    r8              ;      |
                                        ;      |
                ld      r3, var_Y_lo    ;      |
                ld      r5, r3          ;      |
                lde     r6, @rr2        ;      |
                lde     r7, @rr4        ;      |
                                        ;      |
                add     r7, r8          ;      |
                                        ;      |
                ld      r5, var_X_lo    ;      |
		and     r5, #00000111b  ;      |
                or      r5, #11000000b  ;      |  
                lde     r3, @rr4        ; -----+-> 122 Takte   
				
                ret                     ;   rr6 -> VRAM 
					;   r3  -> Bitpos (1aus8) 

;------------------------------------------------------------------------------ 
XPY_to_vram_r013:       
                ; P(x,y) to VRAM        ; IN: var_X, var_Y
                
                ld      r2,  #hi(VRAM_TAB_HI);-+
                ld      r10, #hi(VRAM_TAB_LO); |
                                        ;      |        
                ld      r11, var_X_lo   ;      | 
                                        ;      |
                ;r11 = x / 8 (x = 0-319);      |
                                        ;      |
                and     r11, #11111000b ;      |
                or      r11, var_X_hi   ;      |
                rl      r11             ;      |
                swap    r11             ;      |
                                        ;      |
                ld      r3, var_Y_lo    ;      |        
                ld      r11, r3         ;      |
                lde     r0, @rr2        ;      |
                lde     r1, @rr10       ;      |
                                        ;      |
                add     r1, r11         ;      |
                                        ;      |
                ld      r11, var_X_lo   ;      |
                and     r11, #00000111b ;      |
                or     	r11, #11000000b ;      |         
                lde     r3, @rr10       ; -----+-> 122 Takte  
		
                ret                     ;   rr0 -> VRAM 
					;   r3  -> Bitpos (1aus8) 
                
;------------------------------------------------------------------------------ 
XPY_to_vram_es40:
                ; P(x,y) to VRAM        ; IN: var_X, var_Y

                srp     #60h            ; -----+
                call    0FBBh           ;      |
                ld      76h, 60h        ;      |        
                ld      77h, 61h        ;      |
                ld      73h, 63h        ;      |        
                srp     #70h            ; -----+-> 300 Takte    
                ret                     ;   rr6 -> VRAM, r3 -> Bit-Position
        
;------------------------------------------------------------------------------         
XBY_to_vram:    
                ; P(xByte,y) to VRAM    ; IN: var_X, var_Y
                ; r0,r2,r3,r4,r5,r6,r7
                ld      r2, #hi(VRAM_TAB_HI) ;-+
                ld      r4, #hi(VRAM_TAB_LO) ; |                
                ld      r0, var_X_lo    ; -----+
                ld      r3, var_Y_lo    ;      |
                ld      r5, r3          ;      |
                lde     r6, @rr2        ;      |        
                lde     r7, @rr4        ;      |        
                add     r7, r0          ; -----+-> 48 Takte
                ret                     ;  rr6 -> VRAM
                
;------------------------------------------------------------------------------ 
vram_inc_y_es40:
                ; nächste VRAM-Adr. in Y-Richtung 
                
                add     R7, #28h        ; 10 BWS-lo + 28h (40)
                jr      C,  vram1       ; 10/12
                jr      OV, vram2       ; 10/12
                tcm     R7, #78h        ; 10    
                jr      NZ, vram3       ; 10/12
                db  0Bh                 ; 10/12 0Bh = JR F (also niemals), irgendwo hin
                                        ;       Distanz (opcode inc r6)                 
                                        ; wenn Z = 0, springe nicht (2 Bytes)
                                        ; wenn Z = 1, Distanz wird als "inc r6" gelesen                         
vram1:          inc     R6              ; 6
vram2:          add     R7, #8          ; 10 
                adc     R6, #0          ; 10
vram3:          ret
        


;------------------------------------------------------------------------------

                align 100h                      ; VRAM-Tab muss XX00-Adr. sein
                
FGL_RAM_START   equ     $                       ; 

                ds      200h                    ; Länge der P(x,y) zu VRAM Tabelle 
zoom_buffer     ds      32                      ; Zoom-Buffer für FGL_CHAROUT
	
FGL_RAM_END	equ	$


                        
