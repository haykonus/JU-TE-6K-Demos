;------------------------------------------------------------------------------
; Title:                GleEst für JuTe 6K
;
; Erstellt:             05.01.2025
; Letzte Änderung:      11.01.2025
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
        
        ifndef  Z80_INC
                include z80.asm
        endif   

;------------------------------------------------------------------------------ 
; RAM für GleEst
;------------------------------------------------------------------------------

VRAM            equ     4000h            ; Video-RAM
VRAM_END        equ     5FFFh
VRAM_LEN        equ     VRAM_END - VRAM

VRAM_TAB_HI     equ     RAM_START        ; muss xx00-Adr. sein
VRAM_TAB_LO     equ     RAM_START + 100h ; muss xx00-Adr. sein

GLE_RAM_START   equ     BASE + 600h      ; muss vor Macro-Nutzung bekannt sein

dummy           equ     GLE_RAM_START-3  ; Dummy-VRAM-Adr + Dummy-Bitpos
buffer1         equ     GLE_RAM_START
buffer2         equ     buffer1 + 100h   ; 256 Bytes
buffer2_end     equ     buffer2 + 900h   ; 12 x 192 Bytes


;------------------------------------------------------------------------------
; main
;------------------------------------------------------------------------------
        
start:  srp     #30h

        call    FGL_INIT                ; FGL initialisieren  
                          ;RGBH----
        ld      var_Z_lo, #00001111b    ; Farbe = sw
        ld      var_Z_hi, #00000000b    ; Pixel = alle aus
        call    FGL_CLS 
        
        call    initGleEst
        
        ;--------------------   
        ; Start GleEst (Z80)
        ;--------------------
        
        ld      hl,0001h        ; (stack) darf nicht 0 sein
        push    hl     
        
        ld      hl,buffer1
             
        exx20   ; buffer2

        loop_ix:
        
                call    KEY             
                cp      6Dh, #0
                jr      z, noKey                ; Taste gedrückt ?      
                jp      exit
                
        noKey:  
                ld      hl,buffer2
        
                loop:   
                        ld      bc,3F03h        ; BH = 3F -> max. 64 Punkte / 192-Byte-Block
                                                ; BL = 03 -> HL auf Anfang von nächstem 
                                                ;            192-Byte-Block setzen
                        d_loop:
                                ;
                                ; Pixel löschen
                                ;
                                
                                ld      e,(hl)          ;BWS lo holen
                                inc     hl

                                ld      d,(hl)          ;BWS hi holen
                                inc     hl
                                                                                      
                                ld      a,(hl)          ;Bitpos
         
                                ;-------------------------------------------------------
                                ; JuTe 6K (320 x 192 | 16 Farben)                           
                                ;-------------------------------------------------------
                                ; in:   DE = VRAM-Adr
                                ;       A  = Bitpos 
                                ;               
                                ; out:  Pixel in VRAM gelöscht  
                                ;-------------------------------------------------------
                                
                                call    vramResPixel
                                
                                exx30           ; buffer1                
                                
                                proc:   ld      a,L
                                
                                        ld      e,(hl)   
                                        inc     l
                                        
                                        ld      d,(hl) 
                                        inc     l
                                        
                                        inc     l
                                        inc     l
                                        
                                        ld      c,(hl)  
                                        inc     l
                                        
                                        ld      b,(hl) 
                                        
                                        ;ex      de,hl          
                                        ;add     hl,bc  
                                        ;ex      de,hl               
                                        add     de,bc           ; Z80: nicht vorhanden ;-)
                                        
                                        srl     d               ; Macro
                                        rrc     e               ; Z80: rr    e
                                        ld      L,a
                                       
                                        ld      (hl),e
                                        inc     l
                                        
                                        ld      (hl),d
                                        inc     l
                                        
                                        push    de
                                        and     a,#2       
                                         
                                jr      z, proc

                                pop     bc
                                ex      (sp),hl
                              
                                exx20   ;buffer2
                                
                                ld      a,b
                                
                                exx30   ;buffer1
                    
                                cp      a,#10h
                                jp      c,dontplot              
                                                         
                                ld      bc,0fd40h
                                add     hl,bc
                                srl     h               ; Macro
                                jp      nz,dontplot
                             
                                rrc     l               ; Z80: rr    l
                                ld      c,L
                                ld      a,d
                                add     a,b
                                srl     a               ; Macro
                                jp      nz,dontplot
                              
                        plot_:
                                ld      a,e
                                rrc     a               ; Z80: rr    a
                                cp      a,#192          ; Y max  
                                                          
                                ;
                                ; Pixel schreiben
                                ;
                                                        
                                ;-----------------------------------------------------------
                                ; JuTe 6K (320 x 192 | 16 Farben)
                                ;-----------------------------------------------------------    
                                ; in:   A = Y [0-191]   
                                ;       C = X [0-255]
                                ;       B'= Farbindex [10h-3Fh]
                                ;
                                ; out:  HL = VRAM-Adr
                                ;       A  = Bitpos
                                ;------------------------------------------------------------

                                jr      nc,x1           ; innerhalb 0-191 ?
                                call    setPixel                                
                                jr      x2
                                
                        x1:     ld      hl,dummy        ; nein -> HL = Dummy-BWS
                                ld      a,00h
                                
                        x2:     push    hl
                                
                                exx20   ; buffer2
                                
                                pop     de              
                   
                                ld      (hl),a          ; Bitpos merken
                                dec     hl
                                  
                                ld      (hl),d          ; BWS hi merken
                                dec     hl
                                
                                ld      (hl),e          ; BWS lo merken
                                inc     hl                      
                                inc     hl             
                                ld      a,b
                                
                                exx30   ; buffer1
        
                        dontplot:                       
                                pop     hl              
                                
                                exx20   ; buffer2
                                
                                inc     hl   
                                
                        dec     b
                        jp      nz,d_loop
                        ;djnz    b, d_loop      ; geht nicht, zu weit :-(
                        
                        add     hl,bc   
                        
                        exx30   ; buffer1                  
                        
                        random:
                                pop     de
                                ld      b,10h
                                
                                backw:  sla     e        ; Macro
                                        rlc     d        ; Z80: rl   d
                                        ld      a,d
                                        and     a,#0c0h 
                                        
                                        ;jp      pe,forw ; Z8 hat kein P-Flag :-(
                                        
                                        jr      z,forw   ; Nachbildung Parity Check
                                        cp      a,#0c0h
                                        jr      z,forw
                                        
                                        inc     e
                                        
                        forw:   djnz    b, backw
                        
                                ld      a,d
                                push    de
                                rrc     a                ; Z80: rr    a
                                rrc     b                ; Z80: rr    b
                                and     a,#07h
                                ld      (hl),b   
                                inc     l
                                ld      (hl),a  
                                inc     l
                        jr      nz,random
                        
                        exx20   ; buffer2                                    
                        
                        ld      a,hi(buffer2_end-1)
                        cp      a,h
                        
                jp      nc,loop
                
        jp      loop_ix
       
        ;-------------------    
        ; Ende GleEst (Z80)
        ;-------------------

;------------------------------------------------------------------------------
; buffer2 wird mit Adresse von "dummy" und 00h initialisiert, damit beim 
; Laufen von GleEst keine undefinierten Schreibvorgänge im VRAM erfolgen können.
;
; in:   ---
;
; out:  buffer2 gefüllt [dummyHI, dummyLO, 0]  
;       r8, r10 gesetzt für 3 zu 8 Decoder-Tabelle 
;------------------------------------------------------------------------------
        
initGleEst:

count   equ     (buffer2_end - buffer2)/3

        ldrr    rr2, #count
        ldrr    rr6, #buffer2
        ldrr    rr4, #dummy
              
fb1:    lde     @rr6, r5                ; Dummy-BWS lo
        incw    rr6
                
        lde     @rr6, r4                ; Dummy-BWS hi
        incw    rr6

        ld      r0, #0                  ; Dummy-Pixel           
        lde     @rr6, r0                        
        incw    rr6
        
        decw    rr2
        jr      nz, fb1 

        ld      r8,  #hi(VRAM_TAB_HI)   ; für P(x,y) to VRAM
        ld      r10, #hi(VRAM_TAB_LO) 
        
        ret 
        
;-----------------------------------------------------------------------------  
; Punkt (X,Y) wird mit der Farbe aus "Farbindex" (B') im VRAM gesetzt.  
; 
; in:   A = Y [0-191] Y-Pos
;       C = X [0-255] X-Pos
;       B'= Farbindex [10h-3Fh]
;       
; out:  HL = VRAM-Adr
;       A  = Bitpos 
;
;-----------------------------------------------------------------------------
; intern:
;       r0              A       in/out: Y lo / Bitpos
;       r1              F       -
;       r2              B       in:     X hi = 0        
;       r3              C       in:     X lo
;       r4              D       -
;       r5              E       -
;       r6              H       out:    VRAM hi
;       r7              L       out:    VRAM lo
;
;       r8              VRAM_TAB_HI <- global static
;       r9              Y lo / work 
;       r10             VRAM_TAB_LO <- global static
;       r11             work
;       r12             work    
;       r13             Farbindex
;       r14             Farb-Register hi
;       r15             Farb-Register lo        
;-----------------------------------------------------------------------------  

setPixel: 

        ld      r9, A           ; Y lo <- in
        
        exx20   
        ld      a, B            ; Farbindex (B') holen                               
        exx30                   
        ld      r13, a          ; Farbindex [10h-3Fh] nach r13          
        
        ld      r2,  #0
        add     C,  #32         ; r3 = X lo = C <- in
        adc     r2, #0          ; r2 = X hi
                
        ;------------------------------------------
        ; P(x,y) to VRAM       
        ;
        ; in:   X hi = r2
        ;       X lo = r3
        ;       Y lo = r9
        ;       r8   = VRAM_TAB_HI <- global static
        ;       r10  = VRAM_TAB_LO <- global static
        ;
        ; out:  HL = rr6 -> VRAM 
        ;       A  = r0  -> Bit-Pos (1 aus 8) 
        ;------------------------------------------
        
        ld      r12, r3         ; <- X lo
                                
        ; r12 = X / 8 (X = 0-319)  
        
        and     r12, #11111000b 
        or      r12, r2         ; <- X hi  
        rl      r12             
        swap    r12             
                                
        ld      r11, r9         ; <- Y lo
        lde     r6, @rr8        ; -> H  
        lde     r7, @rr10                                   
        add     r7, r12         ; -> L   
                                
        ld      r11, r3         ; <- X lo
        and     r11, #00000111b 
        or      r11, #11000000b   
        lde     r0, @rr10       ; -> A
        
        ;-------------------------------------- 
        
        ; Farbindex umrechnen [10h-3Fh] -> [0-20]
        
        rr      r13
        and     r13, #00011100b
        sub     r13, #8         ; pixtab lo

        ;--------------------------------------
        
        ld      r12, #hi(pixtab); pixtab hi     
        
        ld      r14, #60h
        ld      r15, #01111111b ; Farb-Bänke = RGBHxxxx
                
        lde     @rr14, r15      ; R-Bank einschalten
        lde     r9, @rr12       ; Farbe
        and     r9, r0          ; Farbe & Maske
        lde     r11, @rr6       ; VRAM lesen
        or      r11, r9         ; VRAM | Farbe(M)
        lde     @rr6, r11       ; VRAM schreiben
        
        incw    rr12            ; nächste Farb-Ebene
        rr      r15
        
        lde     @rr14, r15      ; G-Bank einschalten
        lde     r9, @rr12       ; Farbe
        and     r9, r0          ; Farbe & Maske
        lde     r11, @rr6       ; VRAM lesen
        or      r11, r9         ; VRAM | Farbe(M)
        lde     @rr6, r11       ; VRAM schreiben
        
        incw    rr12            ; nächste Farb-Ebene
        rr      r15
        
        lde     @rr14, r15      ; B-Bank einschalten
        lde     r9, @rr12       ; Farbe
        and     r9, r0          ; Farbe & Maske
        lde     r11, @rr6       ; VRAM lesen
        or      r11, r9         ; VRAM | Farbe(M)
        lde     @rr6, r11       ; VRAM schreiben

        incw    rr12            ; nächste Farb-Ebene
        rr      r15
        
        lde     @rr14, r15      ; H-Bank einschalten
        lde     r9, @rr12       ; Farbe
        and     r9, r0          ; Farbe & Maske
        lde     r11, @rr6       ; VRAM lesen
        or      r11, r9         ; VRAM | Farbe(M)
        lde     @rr6, r11       ; VRAM schreiben

        ret

;-----------------------------------------------------------------------------

        align   100h
        
pixtab:         

;               Bitpos          Ebene   GleEst-Farben

        db      00000000b       ; R     HGB
        db      11111111b       ; G
        db      11111111b       ; B
        db      11111111b       ; H
                                 
        db      00000000b       ; R     HG
        db      11111111b       ; G
        db      00000000b       ; B
        db      11111111b       ; H
                                 
        db      11111111b       ; R     GR
        db      11111111b       ; G
        db      00000000b       ; B
        db      00000000b       ; H
                                 
        db      11111111b       ; R     R
        db      00000000b       ; G
        db      00000000b       ; B
        db      00000000b       ; H
                                 
        db      11111111b       ; R     RB
        db      00000000b       ; G
        db      11111111b       ; B
        db      00000000b       ; H
                                 
        db      00000000b       ; R     B
        db      00000000b       ; G
        db      11111111b       ; B
        db      00000000b       ; H
        
;-----------------------------------------------------------------------------  
; Pixel (R,G,B,H) im VRAM wird auf 0 gesetzt.
;
; in:   DE = rr4 = VRAM-Adr
;       A  = r0  = Bitpos
;
; out:  Pixel in VRAM gelöscht  
;-----------------------------------------------------------------------------

vramResPixel:

        cp      d, #hi(dummy)
        jr      z, vrp_exit

        com     r0              ; r0 = Reset-Maske
        
        ld      r14, #60h

        ld      r15, #01111111b ; Farb-Bänke = RGBHxxxx
        lde     @rr14, r15      ; R-Bank einschalten
        
        lde     r13, @rr4       ; VRAM lesen
        and     r13, r0         ; VRAM & Reset-Maske
        lde     @rr4, r13       ; VRAM schreiben
        
        rr      r15
        lde     @rr14, r15      ; G-Bank einschalten

        lde     r13, @rr4       ; VRAM lesen
        and     r13, r0         ; VRAM & Reset-Maske
        lde     @rr4, r13       ; VRAM schreiben

        rr      r15
        lde     @rr14, r15      ; B-Bank einschalten

        lde     r13, @rr4       ; VRAM lesen
        and     r13, r0         ; VRAM & Reset-Maske
        lde     @rr4, r13       ; VRAM schreiben

        rr      r15
        lde     @rr14, r15      ; H-Bank einschalten

        lde     r13, @rr4       ; VRAM lesen
        and     r13, r0         ; VRAM & Reset-Maske
        lde     @rr4, r13       ; VRAM schreiben
        
vrp_exit:       
        ret
        
;------------------------------------------------------------------------------
; Erstellt die Lookup-Tabelle für die Konvertierung der X,Y Koordinaten in 
; VRAM-Adressen.
; 
; in:   ---
;
; out:  VRAM_TAB_LO/HI im RAM  
;       3 zu 8 Decoder-Tabelle

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

make_vt1:   
        add     r4,#40
        lde     @rr0, r4
        incw    rr0
        
        add     r4,#40
        lde     @rr0, r4
        incw    rr0
                        
        add     r4,#48
        lde     @rr0, r4
        incw    rr0
        
        djnz    r3, make_vt1
        
        ; 3 zu 8 Decoder-Tabelle erzeugen
        
        decw    rr0
        ld      r3, #8
        ld      r4, #10000000b
        
make_vt3:       
        lde     @rr0, r4
        rr      r4
        incw    rr0
        djnz    r3, make_vt3
        
        ; High-Bytes erzeugen

        ld      r0, #hi(VRAM_TAB_HI)
        ld      r1, #0
        
        ld      r2, #6
        ld      r3, #32         ; 32 x 6 Zeilen = 192 Zeilen

        ld      r4, #hi(VRAM)
                
make_vt2:       
        lde     @rr0, r4
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

FGL_CLS:        

        ld      r6, var_Z_hi
        ld      r3, var_Z_lo

        ld      r0, #hi(VRAM)           ; VRAM
        ld      r1, #lo(VRAM)   
        
        ld      r8, #hi(VRAM_LEN)       ; Zähler
        ld      r9, #lo(VRAM_LEN)

        ld      r2, #60h                ; Farb-Register hi
        ld      r4, r2
        
        ld      r5, #00h                ; Farb-Bänke = 0000xxxx (alle Bänke an)
                                        ; Pixel      = 00000000      
cls_1:          
        lde     @rr4, r5                ; Farb-Bänke = 0000xxxx (alle Bänke an)
        lde     @rr0, r5                ; Pixel      = 00000000 -> Bank 1-4
        
        lde     @rr2, r3                ; Farb-Bänke = RGBVxxxx                 
        lde     @rr0, r6                ; Pixel      = xxxxxxxx 
        
        incw    rr0                     ; Nächste RAM-Pos.
        decw    rr8                     ; Zähler -1
        jr      nz, cls_1
                        
        ret

;------------------------------------------------------------------------------

exit:                     ;RGBH----             
        ld      var_Z_lo, #11011011b    ; Farbe = blau
        ld      var_Z_hi, #11111111b    ; Pixel = alle ein
        call    FGL_CLS                 
        pop     hl              
        ld      15h, #0Ch               ; ASCII-Buffer auch löschen
        call    CHAROUT
        jp      MONITOR
        
;------------------------------------------------------------------------------
                                        
                align 100h                      ; VRAM-Tab muss XX00-Adr. sein
                
RAM_START       equ     $                       ; 
                ds      200h                    ; Länge der P(x,y) zu VRAM Tabelle 

        
        

        
        
