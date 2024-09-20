;------------------------------------------------------------------------------
; Title:                Plasma-Demo für JuTe 6K 
;
; Erstellt:             15.09.2024
; Letzte Änderung:      19.09.2024
;------------------------------------------------------------------------------ 

                cpu     z8601
                assume RP:0C0h                  ; Keine Register-Optimierung
                
        ifndef  BASE
                BASE:   set     8000H   
        endif   
                org     BASE
                include ../ES4.0/es40_inc.asm


;------------------------------------------------------------------------------
; main
;------------------------------------------------------------------------------

                srp     #70h
                call    initFGL                 ; FGL initialisieren    
                
                ; clear screen
                
                ld      var_Z_lo, #11010000b    ; Schwarz -> Farbe RGBH0000
                ld      var_Z_hi, #0FFh         ; pixel
                call    cls             
                call    testbild
 
                ld      r2, #0F0H               ; sw auf ws
                call    setTextColor    
                                
                call    menu1
                call    menu2

                ld      var_Y_lo, #13           ; Y
                ld      var_Z_lo, #1            ; Textkursor Pos.       
                call    SCRFUN
                call    PRISTRI
                db      "<-> Palette( )",0


                ld      var_Y_lo, #14           ; Y
                ld      var_Z_lo, #1            ; Textkursor Pos.       
                call    SCRFUN
                call    PRISTRI
                db      "ESC Exit",0
                
                jr      main1

;------------------------------------------------------------------------------

menu1:          ld      var_X_lo, #13           ; X
                ld      var_Y_lo, #11           ; Y
                ld      var_Z_lo, #1            ; Textkursor Pos.       
                call    SCRFUN
                call    PRISTRI
                db      " 1  VRAM,FGL  ",0
                ret

;------------------------------------------------------------------------------
                
menu2:          ld      var_X_lo, #13           ; X
                ld      var_Y_lo, #12           ; Y
                ld      var_Z_lo, #1            ; Textkursor Pos.       
                call    SCRFUN
                call    PRISTRI
                db      " 2  PLOT,ES4.0",0
                ret 
                
;------------------------------------------------------------------------------

main1:          ld      var_P_lo, #3            ; Palette 3
                ld      var_K_lo, #0            ; keine Taste
                
                call    setPalette
                call    showPalette
                
m1:             call    KEY0
m2:             cp      6Dh, #31h               ; 1
                jr      z, pl_vram
                
                cp      6Dh, #32h               ; 2
                jr      z, pl_plot
                
                cp      6Dh, #01h               ; <-
                jr      z, dec_pal
                
                cp      6Dh, #02h               ; ->
                jr      z, inc_pal
                
                cp      6Dh, #0Eh               ; ESC
                jr      z, exit
                jr      m1
        
pl_vram:        ld      var_K_lo, 6Dh           ; Taste merken
                call    drawColors      
                ld      r3, #00Fh               
                call    drawMenu                
                call    drawPlasma2             ; VRAM, FGL
                jr      m2
                
pl_plot:        ld      var_K_lo, 6Dh           ; Taste merken
                call    drawColors              
                ld      r3, #0F0h               
                call    drawMenu        
                call    drawPlasma1             ; PLOT, ES4.0
                jr      m2

dec_pal:        dec     var_P_lo
                call    setPalette              
                ld      6Dh, var_K_lo
                jr      m2

inc_pal:        inc     var_P_lo
                call    setPalette
                ld      6Dh, var_K_lo
                jr      m2
                
exit:           jp      KOMMAND

;------------------------------------------------------------------------------

drawMenu:       ld      r2, r3
                call    setTextColor
                push    r2
                call    menu1
                pop     r2
                swap    r2
                call    setTextColor
                call    menu2
                ret

;------------------------------------------------------------------------------

setTextColor:   ld      r0, #hi(0F7A0H)         ; %F7A0 Bitmaske für Textzeichen
                ld      r1, #lo(0F7A0H)
                lde     @rr0, r2        
                ret
;------------------------------------------------------------------------------
                
setPalette:     ld      var_X_lo, #13+12        ; X
                ld      var_Y_lo, #13           ; Y
                ld      var_Z_lo, #1            ; Textkursor Pos.       
                call    SCRFUN
                and     var_P_lo, #00000011b    ; 0-3
                
                ld      15h, #30h               
                add     15h, var_P_lo
                
                ld      r2, #00FH
                call    setTextColor    
                call    CHAROUT                 ; Paletten-Nr. anzeigen
                ld      r2, #0F0H
                call    setTextColor    
                call    showPalette             ; Palette ausgeben
                ret
;------------------------------------------------------------------------------

showPalette:    ld      r0, #16

                ld      var_X_lo, #12           ; X
                ld      var_Y_lo, #16           ; Y
                ld      var_Z_lo, #1            ; Textkursor Pos.
                call    SCRFUN
                
                ld      r2, #hi(0F7A0H)         ; %F7A0 Bitmaske für Textzeichen
                ld      r3, #lo(0F7A0H)         

                ld      r4, #hi(colpal)         ; Farb-Palette für Plasma-Werte
                ld      r5, #lo(colpal) 
                
                ld      r6, var_P_lo
                swap    r6
                add     r5, r6                  ; Palette auswählen
                adc     r4, #0
                
                ld      var_C_hi, r4            ; merken für drawPlasma
                ld      var_C_lo, r5
                
                shpal1:         
                        lde     r7, @rr4        ; holen
                        
                        com     r7              ; 0 -> sw ... 15 -> ws
                        and     r7, #0Fh
                        lde     @rr2, r7        ; Bitmaske setzen       
                        
                        ld      15h, #20h       ; Space auf farbigem HG
                        call    CHAROUT
                        incw    rr4             ; nächste Paletten-Farbe        
                
                djnz    r0, shpal1
                
                ld      r0, #0F0H
                lde     @rr2, r0                ; zurück zu sw auf ws
                
                ret

;------------------------------------------------------------------------------

checkKey:       call    KEY0
                cp      6Dh, #0Eh
                jr      z, chexit
                cp      6Dh, #31h               
                jr      z, chexit
                cp      6Dh, #32h
                jr      z, chexit
                cp      6Dh, #01h
                jr      z, chexit
                cp      6Dh, #02h
                jr      z, chexit       
chexit:         ret

;------------------------------------------------------------------------------

KEY0:           call    KEY
                cp      6Dh, #0
                jr      z, keyex        ; gedrückt ?
                ld      var_M_lo, 6Dh
key01:          call    KEY             
                cp      6Dh, #0         
                jr      nz, key01       ; warten auf loslassen  
                ld      6Dh, var_M_lo
keyex:          ret
                

;------------------------------------------------------------------------------
; Schnell aus "Testbild" extrahiert ...
;------------------------------------------------------------------------------
                radix   16
                
drawColors:     PUSH    RP
                SRP     #10             
                LD      R3, #0
                CLR     4E      
                LD      4F, #0C
                LD      R2, #8
loc20BB1:       CALL    loc2186
                CLR     50      
                LD      51, #5
                CALL    loc217F
                CALL    loc218D
                CLR     50      
                LD      51, #6
                CALL    loc217F
                CALL    loc218D
                ADD     R3, #0F
                ADD     4F, #2
                DJNZ    R2, loc20BB1
        
                CLR     4E
                LD      4F, #0C
                LD      R2, #8
loc20E31:       CALL    loc2186
                CLR     50
                LD      51, #7
                CALL    loc217F
                CALL    loc218D
                CLR     50
                LD      51, #8
                CALL    loc217F
                CALL    loc218D
                ADD     R3, #0F
                ADD     4F, #2
                DJNZ    R2, loc20E31
                POP     rp
                
                radix   10

                ld      r2, #0F0H
                call    setTextColor
                                                
                RET
                
;------------------------------------------------------------------------------
;-------------  Beginn der Plasma-Algorithmen ---------------------------------
;------------------------------------------------------------------------------

XS              equ     6*16            ; x-Start
YS              equ     2*16+8          ; y-Start

XW              equ     4*16            ; x-Breite
YW              equ     2*16            ; y-Breite

IT              equ     16              ; Iterationen

;------------------------------------------------------------------------------
; Stellt Plasma auf dem Bildschirm dar. (PLOT, ES4.0) 
;
; Laufzeit:     1 Iteration = 433,5 ms (64x32 Pixel)
;------------------------------------------------------------------------------
drawPlasma1:    
                ld      r5, #IT
        
                dpl11:  
                        ld      var_X_lo, #XS+4*16
                        ld      var_X_hi, #0
                        ld      var_Y_lo, #YS
                        ld      var_Y_hi, #0
                        
                        ld      r2, #hi(plasma)
                        ld      r3, #lo(plasma)
                
                        ld      r0, #XW         ; X
                        ld      r1, #YW         ; Y
                
                        dpl12:
                                dpl13:  lde     r4, @rr2
                                        add     r4, r5
                                        and     r4, #0FH
                
                                        ld      r6, var_C_hi
                                        ld      r7, var_C_lo                            
                                        add     r7, r4
                                        adc     r6, #0
                                        lde     r4, @rr6
                
                                        ld      var_Z_lo, r4
                                        call    PLOT
                                        inc     var_X_lo
                                        incw    rr2
                                djnz    r0, dpl13
                
                                ld      var_X_lo, #XS+4*16
                                ld      r0, #XW
                                inc     var_Y_lo
                
                                call    checkKey
                                jr      z, dpl1_exit
                                
                        djnz    r1, dpl12
                                        
                djnz    r5, dpl11
                jr      drawPlasma1
        
dpl1_exit:      ret

;------------------------------------------------------------------------------
; Stellt Plasma auf dem Bildschirm dar. (VRAM, FGL -> direkter Zugriff) 
;
; Laufzeit:     1 Iteration = 89,9 ms (64x32 Pixel)
;------------------------------------------------------------------------------
drawPlasma2:            
                ld      var_Z_lo, #IT
                        
                dpl21:          
                        ld      var_X_lo, #XS
                        ld      var_X_hi, #0
                        ld      var_Y_lo, #YS
                        ld      var_Y_hi, #0
                        
                        call    XPY_to_vram                     ; rr6=VRAM, r3=Bitpos
                                                                ; used: rr2, rr4, r8
                        ld      r12, #hi(plasma)
                        ld      r13, #lo(plasma)                                
                                                        
                        ld      r1, #YW                         ; Y             
                        dpl22:  
                                ld      r0, #XW/8               ; X
                                dpl23:
                                        call    plv_to_rgb      ;
                                        incw    rr6             ; VRAM                  
                                djnz    r0, dpl23
                                
                                sub     r7, #XW/8
                                sbc     r6, #0
                                call    vram_inc_y_es40
        
                        djnz    r1, dpl22
                        
                        call    checkKey
                        jr      z, dpl2_exit            
                        
                dec     var_Z_lo
                jr      dpl21
        
dpl2_exit:      ret

;------------------------------------------------------------------------------
; Konvertiert Plasma-Wert (INT 4Bit) in 4 RGBH-Bytes und schreibt sie in VRAM.
;
; in:   rr6             = VRAM
;       rr12            = Plasma
;       
; out:  4 Bytes in VRAM (RGBH)
;
; intern:       
;       r0              x  
;       r1              y               
;       r2              colpal hi      
;       r3              colpal lo
;       r4              work       
;       r5*             Zähler (8 Plasma-Werte) = 4 Farb-Bytes (RGBH) 
;       r6*             VRAM hi
;       r7*             VRAM lo
;       r8*             R
;       r9*             G       
;       r10*            B
;       r11*            H
;       r12*            Plasma hi
;       r13*            Plasma lo
;       r14*            Farb-Register hi 
;       r15*            Farb-Register lo
;
;------------------------------------------------------------------------------
plv_to_rgb:     
                
                ld      r5, #8
                plv1:   lde     r4, @rr12
                
                        add     r4, var_Z_lo
                        and     r4, #0FH
                
                        ld      r2, var_C_hi
                        ld      r3, var_C_lo
                        
                        add     r3, r4
                        adc     r2, #0
                        
                        lde     r4, @rr2
                        swap    r4              
                
                        rlc     r4
                        rlc     r8      ; R
                        
                        rlc     r4
                        rlc     r9      ; G
                        
                        rlc     r4
                        rlc     r10     ; B
                        
                        rlc     r4
                        rlc     r11     ; H
                        
                        incw    rr12
                        
                djnz    r5, plv1        
                
                ld      r14, #60h
                ld      r15, #01111111b ;Farb-Bänke = RGBHxxxx
                
                lde     @rr14, r15      ;R-Bank einschalten
                lde     @rr6, r8

                rr      r15
                lde     @rr14, r15      ;G-Bank einschalten
                lde     @rr6, r9

                rr      r15
                lde     @rr14, r15      ;B-Bank einschalten
                lde     @rr6, r10               

                rr      r15
                lde     @rr14, r15      ;H-Bank einschalten
                lde     @rr6, r11
                
                ret
                
;--------------------------------------------------------------------------------------
; Farb-Paletten für die Plasma-Wert-Darstellung
;--------------------------------------------------------------------------------------

                enum    sw, gr, bl, blh,gn, gnh,cy, cyh,rt, rth,li, lih,ge, geh,grh,ws
                
colpal:         db      0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15
                db      gnh,gnh,gnh,geh,geh,rt, rt, rt, rt, lih,blh,blh,blh,blh,gn, gn          
                db      rt, rt, rt, rth,rth,rth,li, li, lih,lih,ge, ge, ge, geh,geh,geh
                db      rt, rt, rt, rt, rth,rth,rth,li, li, li, lih,lih,lih,geh,geh,geh 
        
;--------------------------------------------------------------------------------------
; Array mit normierten Plasma-Werten wird erstellt
;--------------------------------------------------------------------------------------

plasma:

y       set     0
        while y<=YW-1
x       set     0
                while   x<=XW-1
value           set     sin(x/6.0)
value           set     value + sin(y/3.0)
value           set     value + sin(sqrt(x*x+y*y)/3)
value           set     value + 4
value           set     value / 8
value           set     int(value*16)
                db      value
                ;message "value: \{value}"
x               set     x+1
                endm
y         set     y+1
        endm

; Quelle: https://rosettacode.org/wiki/Plasma_effect
        
; value = Math.sin(x / 16.0);
; value += Math.sin(y / 8.0);
; value += Math.sin((x + y) / 16.0);
; value += Math.sin(Math.sqrt(x * x + y * y) / 8.0);
; value += 4; // shift range from -4 .. 4 to 0 .. 8
; value /= 8; // bring range down to 0 .. 1

;------------------------------------------------------------------------------ 
        
                include testbild.asm     
                include ../FGL/FGL.asm  
