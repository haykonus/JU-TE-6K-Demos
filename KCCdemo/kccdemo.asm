;------------------------------------------------------------------------------
; Title:                KCcompact Demo für JuTe 6K
;
; Erstellt:             10.10.2024
; Letzte Änderung:      15.11.2024
;------------------------------------------------------------------------------ 

                cpu     z8601
                assume RP:0C0h                  ; Keine Register-Optimierung
                
        ifndef  BASE
                BASE:   set     8000H   
        endif   
                org     BASE
                
        ifndef  ES40_INC                
                include ../ES4.0/es40_inc.asm
        endif
        
        ifndef  MACROS_INC
                include ../FGL/macros.asm
        endif                   

;------------------------------------------------------------------------------
; main
;------------------------------------------------------------------------------

start:          srp     #70h
                call    FGL_INIT                 ; FGL initialisieren

                ; Banner vorbereiten

                call    prepareBanner
                ldrr    var_B, #banner_buffer
                ldrr    var_L, #banner_len - nChars

                ; Bildschirm löschen

        sta1:   ld      var_Z_lo, #00000000b    ; alle Farbbänke (RGBHxxxx) an
                ld      var_Z_hi, #000h         ; alle Pixel 0 = schwarz
                call    FGL_CLS

                ; Texte und Logos

                ldrr    var_T, #zg_KCC          ; Zeichensatz (KCcompact) für FGL_PRISTRI 
                
                ldrr    var_U, #0               ; warten Zeile
                ldrr    var_V, #0               ; warten Zeichen
                ld      var_W_lo, #0F0h         ; Farbe ws/sw
                ld      var_X_lo, #0            ; x-Byte-Pos
                ld      var_Y_lo, #0            ; y-Pos
                ld      var_Z_hi, #1            ; Zoom-Faktor
                call    FGL_PRISTRI             ; normal
                db      'KCcompact',0

                ldrr    rr12, #KC_LOGO          ; KC-Logo
                call    FGL_BMP_TO_VRAM
                
                ldrr    rr12, #MH_LOGO          ; Mühlhausen-Logo
                call    FGL_BMP_TO_VRAM
                
                ldrr    var_U, #5               ; warten Zeile
                ldrr    var_V, #0               ; warten Zeichen
                ld      var_W_lo, #080h         ; Farbe rot/sw
                ld      var_X_lo, #40/2-9*4/2   ; x-Byte-Pos
                ld      var_Y_lo, #54 + 4       ; y-Pos
                ld      var_Z_hi, #4            ; Zoom-Faktor
                call    FGL_PRISTRI             ; 4-fach vergrössert
                db      'KCcompact',0
                
                ldrr    var_V, #2000            ; 2s
                call    FGL_TIMER
                
                ldrr    var_U, #0               ; warten Zeile
                ldrr    var_V, #0               ; warten Zeichen
                ld      var_W_lo, #080h         ; Farbe rot/sw
                ld      var_X_lo, #40/2-9*4/2   ; x-Byte-Pos
                ld      var_Y_lo, #54 + 4       ; y-Pos
                ld      var_Z_hi, #4            ; Zoom-Faktor
                call    FGL_PRISTRI             ; 4-fach vergrössert
                db      '   ???   ',0

                ldrr    var_V, #2000            ; 2s
                call    FGL_TIMER

                ldrr    var_U, #0               ; warten Zeile
                ldrr    var_V, #0               ; warten Zeichen
                ld      var_W_lo, #0F0h         ; Farbe ws/sw
                ld      var_X_lo, #0            ; x-Byte-Pos
                ld      var_Y_lo, #0            ; y-Pos
                ld      var_Z_hi, #1            ; Zoom-Faktor
                call    FGL_PRISTRI             ; normal
                db      'JTkompakt',0           

                ldrr    var_V, #1000             ; 1s
                call    FGL_TIMER               
                
                ldrr    rr12, #TINY_LOGO        ; TINY-Logo
                call    FGL_BMP_TO_VRAM

                ldrr    var_V, #1000             ; 1s
                call    FGL_TIMER

                ldrr    rr12, #JU_TE_LOGO       ; JuTe-Logo
                call    FGL_BMP_TO_VRAM         

                ldrr    var_V, #1000             ; 1s
                call    FGL_TIMER
                
                ldrr    var_U, #0               ; warten Zeile
                ldrr    var_V, #0               ; warten Zeichen
                ld      var_W_lo, #080h         ; Farbe rot/sw
                ld      var_X_lo, #40/2-9*4/2   ; x-Byte-Pos
                ld      var_Y_lo, #54 + 4       ; y-Pos
                ld      var_Z_hi, #4            ; Zoom-Faktor
                call    FGL_PRISTRI             ; 4-fach vergrössert
                db      'JTkompakt',0

                ldrr    var_V, #500             ; 0,5s
                call    FGL_TIMER
                
                ld      var_X_lo, #40/2-18-1;-1
                ld      var_X_hi, #3*10+6+2;+2
                ld      var_Y_lo, #96-5+1-2      
                ld      var_Y_hi, #4*8+4+1
                call    invertRect              ; rote, 4-fach-vergrösserte Schrift invertieren 
                                                ; (füllen von unten)
                                                
                ldrr    var_V, #1000            ; 1s
                call    FGL_TIMER
                
        ma4:    call    moveScreen              ; 9 Zeilen nach oben schieben

        ma3:    ldrr    var_V, #500             ; 0,5s
                call    FGL_TIMER

                call    switchColors            ; Farben umschalten
        ma2:    call    makeMaskMap             ; VRAM-Maske erstellen

;------------------------------------------------------------------------------

                ; Start Animation

                ldrr    rr0, #Y_POS_RING_BUFFER

        ma1:    call    drawLines               ; Linien in VRAM schreiben
                inc     r1                      ; next Y pos
                and     r1, #cmask              ; 
                jr      ma1                     ; für immer ...


;------------------------------------------------------------------------------
; Auf ESC-Taste prüfen.
;------------------------------------------------------------------------------
checkKey:       call    KEY
                cp      6Dh, #0Eh               ; ESC ?
                jr      z, chexit
                ret
                
chexit:         ld      15h, #12                ; CLS
                call    CHAROUT
                JP      KOMMAND                 ; Bye ...

;------------------------------------------------------------------------------
; Rechteckigen Bereich (sw/rot) invertieren (füllen von unten).
;
; in:           var_X_lo        = X-Byte-Pos    (0-39)
;               var_X_hi        = X-Länge
;               var_Y_lo        = Y-Zeilen-Pos  (0-191)
;               var_Y_hi        = Y-Länge
;
; out:          Fläche invertiert (rot/sw)
;------------------------------------------------------------------------------

invertRect:     push    var_Y_lo
                ld      r1, var_Y_hi                    ; Y-Zähler

                fi1:    ld      r12, var_X_hi           ; X-Zähler
                
                        ; r0,r2,r3,r4,r5,r6,r7
                        call    XBY_to_vram             ; rr6 -> VRAM

                        fi2:    ld      r15, #0FFh
                        
                                ; r5,r8,r9,r10,r11

                                ld      r14, #60h
                                ld      r15, #01111111b         ;Farb-Bänke = RGBHxxxx

                                lde     @rr14, r15              ;R-Bank einschalten
                                lde     r5, @rr6
                                com     r5
                                lde     @rr6, r5

                                inc     r7
                        djnz    r12, fi2
                        dec     var_Y_lo

                        ldrr    var_V, #20                      ; 20 ms warten
                        call    FGL_TIMER

                djnz    r1, fi1

                pop     var_Y_lo
                ret

;------------------------------------------------------------------------------
; Schiebt Banner um 1 Zeichen nach links auf dem Bildschirm.
;
; in:           var_L   -> Banner-Länge
;               var_B   -> Zeiger auf Banner-Puffer
;
;------------------------------------------------------------------------------

moveOneChar:    decw    var_L_hi
		decw    var_L_hi
                jr      nz, oc1

                ldrr    var_B, #banner_buffer
                ldrr    var_L, #banner_len-nChars
        oc1:
                ld      r8, var_B_hi
                ld      r9, var_B_lo
                call    bannerToVRAM

                incw    var_B_hi
		incw    var_B_hi
		
                ret

;------------------------------------------------------------------------------
; Stellt eine komplette Banner-Zeile auf dem Bildschirm dar.
;
; in:           rr8     -> Zeiger auf Banner-Puffer-Position
;
; out:          Banner auf Bildschirm
;------------------------------------------------------------------------------

bannerToVRAM:
                ld      r14, #60h
                ld      r15, #00100000b
                lde     @rr14, r15

                ldrr    rr6, #5EA8h                     ; VRAM-Pos
                ld      r1, #8                          ; 8 ASCII-Zeilen

                ctv2:
                        ld      r0, #nChars             ; Banner = 40 ASCII-Zeichen

                        ctv1:   lde     r3, @rr8        ; banner_buffer
                                lde     @rr6, r3        ; VRAM
                                incw    rr8
                                inc     r7
                        djnz    r0, ctv1

                        sub     r7, #lo(nChars)
                        sbc     r6, #hi(nChars)

                        add     r9, #lo(banner_len-nChars)
                        adc     r8, #hi(banner_len-nChars)

                        call    vram_inc_y_es40

                djnz    r1, ctv2        ; 8 Zeilen

                ret

;------------------------------------------------------------------------------
; Erzeugt aus einem String mit dem Bannertext eine Datenstruktur, aus der sehr
; schnell, zeilenweise der gesamte Text in den VRAM kopiert werden kann.
;
; in:           banner_start    -> Zeiger auf ASCII_Banner-Text
;               banner_len      -> Banner-Länge (ASCII)
;
; out:          banner_buffer   -> Zeiger auf Banner-Puffer zur Ausgabe in VRAM
;
;------------------------------------------------------------------------------

nChars          equ     40

banner_start            equ     $

                        REPT    nChars
                        db      ' '
                        ENDM

                        db      '******    JUGEND + TECHNIK Computer 6K System ES 4.0,    '
                        db      'Dr. Helmut Hoyer, Harun Scheutzow,    '
                        db      'Verlag Junge Welt, PF 43 Berlin 1026   ******'
                        
                        ;db     '******    VEB   Mikroelektronik   M',01Ch,'hlhausen    ******'

                        REPT    nChars
                        db      ' '
                        ENDM

banner_end              equ     $

banner_len              equ     (banner_end - banner_start)

;------------------------------------------------------------------------------

prepareBanner:  ldrr    rr6,  #banner_start
                ldrr    rr10, #banner_buffer
                ld      r12,  #banner_len

                ctb2:   ld      r8, r10
                        ld      r9, r11

                        lde     r1, @rr6                ; Zeichen holen
                        clr     r0

                        rlc     r1                      ; rr0 x 8 ZG-Zeilen
                        rlc     r0
                        rlc     r1
                        rlc     r0
                        rlc     r1
                        rlc     r0

                        and     r1, #11111000b

                        ldrr    rr2, #zg_Z9001          ; rr2 -> ZG Start
                        add     r3, r1
                        adc     r2, r0                  ; rr2 -> ZG-Byte (ASCII) 1. Zeile

                        ld      r4, #8

                        ctb1:
                                lde     r5, @rr2        ; ZG-Byte
                                cp      r4, #5          ; kursiv ?
                                jr      c, ctb3
                                rcf                     ; Zeichen kursiv machen
                                rrc     r5
                        ctb3:
                                lde     @rr8, r5        ;
                                add     r9, #lo(banner_len)
                                adc     r8, #hi(banner_len)
                                incw    rr2             ; nächste ZG-Zeile
                        djnz    r4, ctb1

                        incw    rr6
                        incw    rr10

                djnz    r12, ctb2

                ret
                
;------------------------------------------------------------------------------
; Verschieben des Bildschirms nach oben um 9 Zeilen.
;
;------------------------------------------------------------------------------

moveScreen:     ldrr    rr0, #VRAM + 180h
                ldrr    rr2, #VRAM
                ldrr    rr4, #VRAM_LEN - 180h

                ms1:    ld      r14, #60h
                        ld      r15, #01111111b

                        lde     @rr14, r15
                        lde     r6, @rr0
                        lde     @rr2, r6

                        rr      r15
                        lde     @rr14, r15
                        lde     r6, @rr0
                        lde     @rr2, r6

                        rr      r15
                        lde     @rr14, r15
                        lde     r6, @rr0
                        lde     @rr2, r6

                        rr      r15
                        lde     @rr14, r15
                        lde     r6, @rr0
                        lde     @rr2, r6

                        incw    rr0
                        incw    rr2
                        decw    rr4
                jr      nz, ms1

                ret

;------------------------------------------------------------------------------
; Umschalten der Farben vor der Animation.
;
;               Hintergrund     -> blau
;               grünH           -> ws
;               rot             -> grünH
;------------------------------------------------------------------------------

switchColors:   ldrr    rr6, #VRAM
                ld      r14, #60h

                sws1:   ld      r15, #10110000b         ; Farbbank grün
                        lde     @rr14, r15

                        lde     r0, @rr6
                        cp      r0, #0                  ; grün ?
                        jr      z, sws2                 ; nein

                        ; grün/sw -> ws/blau

                        ld      r15, #00000000b         ; Farbbank ws
                        lde     @rr14, r15
                        lde     @rr6, r0                ; grün => ws

                        jr      sws3

                sws2:   ld      r15, #01110000b         ; Farbbank rot
                        lde     @rr14, r15

                        lde     r0, @rr6
                        cp      r0, #0                  ; rot ?
                        jr      z, sws3                 ; nein

                        ; rot/sw -> grünH/blau

                        clr     r1
                        lde     @rr6, r1                ; rot => 0

                        ld      r15, #10100000b         ; Farbbank grünH
                        lde     @rr14, r15
                        lde     @rr6, r0                ; rot => grünH

                        ld      r15, #11010000b         ; Farbbank blau
                        lde     @rr14, r15
                        com     r0
                        lde     @rr6, r0                ; sw => blau

                        jr      sws4

                        ; sw -> blau

                sws3:   ld      r15, #11010000b         ; Farbbank blau
                        lde     @rr14, r15
                        ld      r15, #0FFh              ; blau => 1
                        lde     @rr6, r15

                sws4:   incw    rr6
                        cp      r6, #60h
                jr      nz, sws1

                ret

;------------------------------------------------------------------------------
; Stellt Linien auf dem Bildschirm dar.
;
; in:           rr0              = Zeiger auf Y-Koordinaten (Ring-Puffer)
;
;               LINES            = Anzahl animierter Linien
;               COLORS_PER_LINE  = Anzahl Zeilen pro Linie
;
;               mcLines          = Zeiger auf Farbdefinition der Linien
;                                  (mc = mehrfarbig)
;
;------------------------------------------------------------------------------

LINES           EQU     10                      ; Anzahl animierter Linien

drawLines:      push    r0
                push    r1

                inc     r1
                and     r1, #cmask
                lde     r8, @rr0
                ld      var_Y_hi, r8            ; Nachfolger holen

                dec     r1
                and     r1, #cmask
                lde     r8, @rr0
                ld      var_Y_lo, r8

                cp      r8, #192/2
                jr      c, dls2
                call    clrlineW
                jr      dls3
        dls2:   call    clrLineG
        dls3:
                inc     r1
                and     r1, #cmask

                ld      r12, #hi(mcLines)       ; Zeiger auf mehrfarbige Linien
                ld      r13, #lo(mcLines)

                ld      var_A_lo, #LINES

        dls1:   lde     r8, @rr0
                ld      var_Y_lo, r8
                inc     r1
                and     r1, #cmask

                lde     r8, @rr0
                ld      var_Y_hi, r8            ; Nachfolger holen
                dec     r1
                and     r1, #cmask

                cp      var_A_lo, #1            ; letzte Linie ? -> alle Zeilen schreiben
                jr      nz, dls4
                ld      var_Y_hi, #128          ; 128 = Code für "alle Zeilen"
        dls4:
                push    r12
                push    r13

                cp      r8, #192/2
                jr      c, dls22
                call    drawLineW
                jr      dls33
        dls22:  call    drawLineG
        dls33:
                pop     r13
                pop     r12

                add     r13, #4*COLORS_PER_LINE ; nächste Farbe, 4 Bytes * Zeilen

                inc     r1
                and     r1, #cmask

                dec     var_A_lo
                jr      nz, dls1

                call    moveOneChar             ; Banner schieben
                call    checkKey                ; ESC ?
                
                pop     r1
                pop     r0

                ret

;------------------------------------------------------------------------------
; clearLineR/W  Löscht eine Linie.
;
;               G = grüne  Objekte werden nicht überschrieben
;               W = weisse Objekte werden nicht überschrieben
;
; in:           var_Y_lo        = Y
;               rr12            = Zeiger auf Farbdefinition der Linien
;                                 Z1(R,G,B,H) ... ZN(R,G,B,H)
;
; out:          Linie auf Bildschirm gelöscht
;------------------------------------------------------------------------------

clrLineG:       ld      r12, #hi(bg)
                ld      r13, #lo(bg)

                push    r12
                push    r13
                call    drawLineG
                pop     r13
                pop     r12
                
                ret

clrLineW:       ld      r12, #hi(bg)
                ld      r13, #lo(bg)

                push    r12
                push    r13
                call    drawLineW
                pop     r13
                pop     r12
                
                ret

;------------------------------------------------------------------------------
; Wartet N-mal 1,6 ms (eine Zeile).
;
; in:           var_T_hi = N
;------------------------------------------------------------------------------

tLine:          add     var_T_hi, #1            ; etwas verlangsamen an Wendepunkten    
tl2:            ld      var_T_lo, #0e2h         ; 6788 Takte = 1,6 ms
tl1:            dec     var_T_lo
                nop
                nop
                jr      nz, tl1
                dec     var_T_hi
                jr      nz, tl2
                ret

;------------------------------------------------------------------------------
; drawLineR/W   Schreibt eine Linie.
;
;               G = grüne  Objekte werden nicht überschrieben
;               W = weisse Objekte werden nicht überschrieben
;
; in:           var_Y_lo        = Y-Pos
;               rr12            = Zeiger auf Farbdefinition der Linien
;                                 Z1(R,G,B,H) ... ZN(R,G,B,H)
;
; out:          Linie auf Bildschirm
;
; intern:
;       r0      -
;       r1      Farbe
;       r2      -
;       r3      -
;       r4      Mask hi
;       r5      Mask lo
;       r6      VRAM hi
;       r7      VRAM lo
;       r8      -
;       r9      Farb-Bank-Zähler
;       r10     Zeilen-Zähler
;       r11     Byte-Zähler
;       r12     Farbe HI
;       r13     Farbe LO
;       r14     Farb-Register hi
;       r15     Farb-Register lo
;
;------------------------------------------------------------------------------

COLORS_PER_LINE EQU     4                               ; Anzahl Farben pro Linie

drawLineG:      DI
                push    r0
                push    r1
                ld      saveH, SPH
                ld      saveL, SPL
                
                ld      r10, #COLORS_PER_LINE           ; Zeilen-Zähler
                ld      r4, #60h
                ld      var_X_lo, #39   

                cp      var_Y_hi, #128                  ; alle Zeilen schreiben ?
                jr      z, dln1

                sub     var_Y_hi, var_Y_lo              ; Anzahl Zeilen sichtbar berechnen
                jp      z, dlrret
                jr      mi, neg                         ; neg/pos ?
        pos:
                cp      var_Y_hi, #COLORS_PER_LINE      ; Anzahl Zeilen begrenzen ?
                jr      nc, dln1

                ld      r10, var_Y_hi                   ; Anzahl Zeilen neu
                jr      dln2
        neg:
                com     var_Y_hi                        ; Zweierkomplement
                add     var_Y_hi, #1

                cp      var_Y_hi, #COLORS_PER_LINE      ; Anzahl Zeilen begrenzen ?
                jr      nc, dln1

                add     var_Y_lo, #COLORS_PER_LINE
                sub     var_Y_lo, var_Y_hi
                ld      r10, var_Y_hi                   ; Anzahl Zeilen neu

        dln2:   ld      var_T_hi, r10                   ; Ausgleich Zeit für fehlende Zeilen
                call    tLine

        dln1:
                ; r0,r2,r3,r4,r5,r6,r7
                call    XBY_to_vram

                dl2:    ld      r9,  #5                 ; Farb-Bank-Zähler
                        ld      r15, #01111111b         ; rot: Farb-Bänke = RGBHxxxx

                        incw    rr6                     ; wegen PUSH -> SP=SP-1
                                                
                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen
                                
                                                                
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        com     r0              ;  6
                                        and     r0, r1          ;  6
                                        ;or     r0, r1          ;  
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 40
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank


                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen
                                                                
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        ;com    r0              ; 
                                        or      r0, r1          ;  6
                                        ;and    r0, r1                                  
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 36
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank

                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen

                                                               
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        com     r0              ;  6
                                        and     r0, r1          ;  6
                                        ;or     r0, r1          ;  
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 40
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank


                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen
                                                               
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        ;com    r0              ;   
                                        or      r0, r1          ;  6
                                        ;and    r0, r1
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 36
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank
                                
                                
                        decw    rr6
                        ;-----------------------
                        add     R7, #28h        ; 10 BWS-lo + 28h (40)
                        jr      C,  vram10      ; 10/12
                        jr      OV, vram20      ; 10/12
                        tcm     R7, #78h        ; 10
                        jr      NZ, vram30      ; 10/12
                        db      0Bh             ; 10/12 0Bh = JR F (also niemals), irgendwo hin
                                                ;       Distanz (opcode inc r6)
                                                ; wenn Z = 0, springe nicht (2 Bytes)
                                                ; wenn Z = 1, Distanz wird als "inc r6" gelesen
                vram10: inc     R6              ; 6
                vram20: add     R7, #8          ; 10
                        adc     R6, #0          ; 10
                vram30: ;-----------------------

                dec     r10
                jp      nz, dl2

        dlr1:   ld      SPH, saveH
                ld      SPL, saveL

                pop     r1
                pop     r0

                EI
                ret

dlrret:         ld      var_T_hi, #4
                call    tLine
                jr      dlr1

;------------------------------------------------------------------------------

drawLineW:      DI
                push    r0
                push    r1
                ld      saveH, SPH
                ld      saveL, SPL

                ld      r10, #COLORS_PER_LINE           ; Zeilen-Zähler
                ld      r4, #60h
                ld      var_X_lo, #39

                cp      var_Y_hi, #128                  ; alle Zeilen schreiben ?
                jr      z, dln11

                sub     var_Y_hi, var_Y_lo              ; Anzahl Zeilen sichtbar berechnen
                jp      z, dlrret2
                jr      mi, neg2                                ; neg/pos ?
        pos2:
                cp      var_Y_hi, #COLORS_PER_LINE      ; Anzahl Zeilen begrenzen ?
                jr      nc, dln11

                ld      r10, var_Y_hi                   ; Anzahl Zeilen neu
                jr      dln22
        neg2:
                com     var_Y_hi                        ; Zweierkomplement
                add     var_Y_hi, #1

                cp      var_Y_hi, #COLORS_PER_LINE      ; Anzahl Zeilen begrenzen ?
                jr      nc, dln11

                add     var_Y_lo, #COLORS_PER_LINE
                sub     var_Y_lo, var_Y_hi
                ld      r10, var_Y_hi                   ; Anzahl Zeilen neu

        dln22:  ld      var_T_hi, r10                   ; Ausgleich Zeit für fehlende Zeilen
                call    tLine

        dln11:
                ; r0,r2,r3,r4,r5,r6,r7
                call    XBY_to_vram

                dl22:   ld      r9,  #4                 ; Farb-Bank-Zähler
                        ld      r15, #01111111b         ; rot: Farb-Bänke = RGBHxxxx

                        incw    rr6                     ; wegen PUSH -> SP=SP-1
                                                
                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen

                                rept    40
                                        lde     r0, @rr4        ; 12
                                        ;com    r0
                                        ;and    r0, r1          ;  
                                        or      r0, r1          ;  6
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 36
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank

                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen
                                                                
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        ;com    r0              ; 
                                        or      r0, r1          ;  6
                                        ;and    r0, r1                                  
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 36
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank

                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen
                                                        ;
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        ;com    r0
                                        ;and    r0, r1          
                                        or      r0, r1          ;  6
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 36
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank

                                ld      SPH, r6
                                ld      SPL, r7
                                ld      r4, r6
                                add     r4, #80h        ; 40 + 80 = C0
                                ld      r5, r7
                                dec     r5              ; Korrektur PUSH -> SP=SP-1

                                lde     @rr14, r15      ; Farb-Bank einschalten
                                lde     r1, @rr12       ; Farb-Byte holen
                                                                ;       wenig   oft
                                rept    40
                                        lde     r0, @rr4        ; 12
                                        ;com    r0              ;    
                                        or      r0, r1          ;  6
                                        ;and    r0, r1
                                        push    r0              ; 12
                                        dec     r5              ;  6
                                endm                            ; --
                                                                ; 36
                                incw    rr12            ; next Farb-Byte
                                rr      r15             ; next Farb-Bank

                        decw    rr6
                        ;-----------------------
                        add     R7, #28h        ; 10 BWS-lo + 28h (40)
                        jr      C,  vram100     ; 10/12
                        jr      OV, vram200     ; 10/12
                        tcm     R7, #78h        ; 10
                        jr      NZ, vram300     ; 10/12
                        db      0Bh             ; 10/12 0Bh = JR F (also niemals), irgendwo hin
                                                ;       Distanz (opcode inc r6)
                                                ; wenn Z = 0, springe nicht (2 Bytes)
                                                ; wenn Z = 1, Distanz wird als "inc r6" gelesen
               vram100: inc     R6              ; 6
               vram200: add     R7, #8          ; 10
                        adc     R6, #0          ; 10
               vram300: ;-----------------------

                dec     r10
                jp      nz, dl22

        dlr11:  ld      SPH, saveH
                ld      SPL, saveL

                pop     r1
                pop     r0

                EI
                ret

dlrret2:        ld      var_T_hi, #4
                call    tLine
                jr      dlr11

;------------------------------------------------------------------------------
; Erzeugt eine Kopie der HELL-Bank des VRAM ab 0C000H im RAM für die Erkennung
; von hell-grün- und weiss-Bitmaps im VRAM, um bei der Animation diese Stellen
; nicht zu überschreiben.
;------------------------------------------------------------------------------

makeMaskMap:
                ld      r14, #60h
                ld      r15, #11101111b         ; hell: Farb-Bänke = RGBHxxxx
                lde     @rr14, r15              ; Farb-Bank einschalten

                ld      r6, #hi(04000h)
                ld      r7, #lo(04000h)
                ld      r4, #hi(0C000h)         ; VRAM-Maske
                ld      r5, #lo(0C000h)

        mmm1:   lde     r0, @rr6
                lde     @rr4, r0
                incw    rr4
                incw    rr6
                cp      r6, #60h
                jr      nz, mmm1

                ret

;------------------------------------------------------------------------------         
                align   100h
cLines:
                ;       R     G     B     H             einfarbige Linien
;10             
                db      0FFh, 000h, 000h, 0FFh
                db      0FFh, 000h, 000h, 0FFh
                db      0FFh, 000h, 000h, 0FFh
                db      0FFh, 000h, 000h, 0FFh
;9
                db      000h, 0FFh, 000h, 0FFh
                db      000h, 0FFh, 000h, 0FFh
                db      000h, 0FFh, 000h, 0FFh
                db      000h, 0FFh, 000h, 0FFh
;8
                db      0FFh, 0FFh, 000h, 0FFh
                db      0FFh, 0FFh, 000h, 0FFh
                db      0FFh, 0FFh, 000h, 0FFh
                db      0FFh, 0FFh, 000h, 0FFh
;7
                db      000h, 0FFh, 0FFh, 0FFh
                db      000h, 0FFh, 0FFh, 0FFh
                db      000h, 0FFh, 0FFh, 0FFh
                db      000h, 0FFh, 0FFh, 0FFh          
;6
                db      0FFh, 000h, 0FFh, 000h
                db      0FFh, 000h, 0FFh, 000h
                db      0FFh, 000h, 0FFh, 000h
                db      0FFh, 000h, 0FFh, 000h
;5
                db      0FFh, 0FFh, 0FFh, 000h
                db      0FFh, 0FFh, 0FFh, 000h
                db      0FFh, 0FFh, 0FFh, 000h
                db      0FFh, 0FFh, 0FFh, 000h
;4
                db      0FFh, 000h, 000h, 000h
                db      0FFh, 000h, 000h, 000h
                db      0FFh, 000h, 000h, 000h
                db      0FFh, 000h, 000h, 000h
;3
                db      000h, 0FFh, 000h, 000h
                db      000h, 0FFh, 000h, 000h
                db      000h, 0FFh, 000h, 000h
                db      000h, 0FFh, 000h, 000h
;2
                db      0FFh, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 000h
;1
                db      000h, 0FFh, 0FFh, 000h
                db      000h, 0FFh, 0FFh, 000h
                db      000h, 0FFh, 0FFh, 000h
                db      000h, 0FFh, 0FFh, 000h

;------------------------------------------------------------------------------
                align   100h
mcLines:
                ;       R     G     B     H             mehrfarbige Linien
;10             
                db      0FFh, 000h, 000h, 000h
                db      0FFh, 000h, 000h, 0FFh
                db      0FFh, 0FFh, 0FFh, 0FFh
                db      0FFh, 000h, 000h, 000h
;9
                db      0FFh, 000h, 000h, 000h
                db      0FFh, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 0FFh
                db      0FFh, 000h, 000h, 000h
;8
                db      000h, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 0FFh
                db      0FFh, 0FFh, 000h, 000h
;7
                db      000h, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 0FFh
                db      000h, 0FFh, 000h, 000h
;6
                db      000h, 0FFh, 000h, 000h
                db      0FFh, 0FFh, 000h, 0FFh
                db      000h, 0FFh, 000h, 0FFh
                db      000h, 0FFh, 000h, 000h
;5
                db      000h, 0FFh, 000h, 000h
                db      000h, 0FFh, 000h, 0FFh
                db      0FFh, 0FFh, 0FFh, 0FFh
                db      000h, 0FFh, 000h, 0FFh
;4
                db      000h, 0FFh, 0FFh, 000h
                db      000h, 0FFh, 0FFh, 0FFh
                db      0FFh, 0FFh, 0FFh, 0FFh
                db      000h, 0FFh, 0FFh, 000h
;3
                db      000h, 000h, 0FFh, 0FFh
                db      000h, 0FFh, 0FFh, 0FFh
                db      0FFh, 0FFh, 0FFh, 0FFh
                db      000h, 000h, 0FFh, 0FFh
;2
                db      0FFh, 000h, 0FFh, 000h
                db      0FFh, 000h, 0FFh, 0FFh
                db      0FFh, 0FFh, 0FFh, 0FFh
                db      0FFh, 000h, 0FFh, 000h
;1
                db      0FFh, 000h, 0FFh, 000h  
                db      0FFh, 000h, 0FFh, 0FFh
                db      0FFh, 0FFh, 0FFh, 0FFh
                db      0FFh, 000h, 0FFh, 0FFh

;------------------------------------------------------------------------------

                ;       R     G     B     H             Hintergrund
bg:             db      000h, 000h, 0FFh, 000h
                db      000h, 000h, 0FFh, 000h
                db      000h, 000h, 0FFh, 000h
                db      000h, 000h, 0FFh, 000h

;------------------------------------------------------------------------------

XW              equ     64                              ; 64 Y-Werte
cmask           equ     00111111b                       ; Maske für Ring-Puffer
PI              equ     3.141592

;------------------------------------------------------------------------------
                align 100h

Y_POS_RING_BUFFER:

x       set     0
        while x<=XW-1

value           set     ( sin (1 * (x*2*PI/XW+1) ) + 0.5 * sin( 2 * (x*2*PI/XW+1) ) ) * 0.71 * (-1)

                if value > 0
value           set     value*1.55                      ; untere "Halbwelle" strecken
                endif

value           set     int ((value * 64) + 86)         ; Position der Wendepunkte
                db      value
                ;message "value: \{value}"
x               set     x+1     
        endm

;;------------------------------------------------------------------------------
; Einfache Simulation der genutzten Funktion zur Bewegung der Linien auf der Z-Achse
;
; https://www.geogebra.org/graphing?lang=de
;
; Copy/Paste: 
;
; Wenn((sin(x)+0.5 sin(2x))*0.71>0, (sin(x)+0.5 sin(2x))*0.71, (sin(x)+0.5 sin(2x))*0.71*1.55)
;
;------------------------------------------------------------------------------
                align 100h
                
zg_KCC:         binclude ./zg_KCC.rom
zg_Z9001:       binclude ./zg_Z9001.rom

                include ./bitmaps.asm
                include ../FGL/FGL.asm

;------------------------------------------------------------------------------

                align 100h

banner_buffer:  ds      (banner_end - banner_start) * 8

