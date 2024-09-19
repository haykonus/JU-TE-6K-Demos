;------------------------------------------------------------------------------
; Titel:                Ju-Te 6K Fast Graphics Library  (6K-FGL)
;
; Erstellt:             10.11.2023
; Letzte Änderung:      19.09.2024
;------------------------------------------------------------------------------ 

VRAM            equ     4000h
VRAM_END        equ     5FFFh
VRAM_LEN        equ     VRAM_END - VRAM

VRAM_TAB_HI     equ     RAM_START       ; muss xx00-Adr. sein
VRAM_TAB_LO     equ     RAM_START+100h  ; muss xx00-Adr. sein

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
                ;or     r5, #11000000b  ;      |   kann entfallen bei align 100h
                lde     r3, @rr4        ; -----+-> 122 Takte            
                ret                     ;   rr6 -> VRAM, r3 -> Bit-Position 

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
                ;or     r11, #11000000b ;      |   kann entfallen bei align 100h        
                lde     r3, @rr10       ; -----+-> 122 Takte            
                ret                     ;   rr0 -> VRAM, r3 -> Bit-Position 
                
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
; Erstellt die Lookup-Tabelle für die Konvertierung der X,Y Koordinaten in 
; VRAM-Adressen.
; 
; in:   ---
;
; out:  VRAM_TAB_LO/HI im RAM   

; int:  r0-r4   
;------------------------------------------------------------------------------                 

initFGL:        
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
                ld      r4, 10000000b
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
cls:            ld      r6, var_Z_hi
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

                align 100h                      ; VRAM-Tab muss XX00-Adr. sein
RAM_START       equ     $


                        
