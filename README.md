# JU-TE-6K-Demos

## Plasma
![Testbild](/Bilder/Plasma-A2.png)

Das hier vorgestellte Programm erzeugt einen Plasma-Effekt. Es ist vollständig in Zilog Z8-Assembler realisiert. Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 verwendet.

## Vorausetzungen

- JuTe 6K (JuTe-2K/4K + Grafikerweiterung oder JuTe-6K-Compact)
- [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)
- 32KB RAM

## Schnellstart

- [plasma_8000H.bin](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/Plasma/plasma_8000H.bin) oder [plasma_8000H.wav](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/Plasma/plasma_8000H.wav) auf Adresse 8000H laden.
- mit J8000 starten

## Implementierung

Der Plasma-Effekt wurde in zwei Varianten umgesetzt:

1. mit direktem Zugriff auf den Video-RAM (s. [FGL](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/FGL/FGL.asm))
2. mit dem integriertem PLOT-Befehl des ES4.0

Für die Darstellung der Plasma-Effekte wurden vier Farbpaletten integriert. Sowohl die Varianten als auch die Farbpaletten können zur Laufzeit mit Tasten ausgewählt werden.

## Grundlagen

Die Idee der Plasma-Generierung stammt von [hier](https://rosettacode.org/wiki/Plasma_effect). 
```
for (var y = 0; y < h; y++) {
    buffer[y] = new Array(w);

    for (var x = 0; x < w; x++) {

        var value = Math.sin(x / 16.0);
        value += Math.sin(y / 8.0);
        value += Math.sin((x + y) / 16.0);
        value += Math.sin(Math.sqrt(x * x + y * y) / 8.0);
        value += 4; // shift range from -4 .. 4 to 0 .. 8
        value /= 8; // bring range down to 0 .. 1

        buffer[y][x] = value;
    }
}
```
Da der JU-TE-6K keine Trigonometrie beherrscht, wurden die Möglichkeiten des Makro-Assemblers genutzt:
```
plasma:
y   set 0
    while y<=YW-1
x       set     0
        while   x<=XW-1
value       set sin(x/6.0)
value       set value + sin(y/3.0)
value       set value + sin(sqrt(x*x+y*y)/3)
value       set value + 4
value       set value / 8
value       set int(value*16)
            db  value
            message "value: \{value}"
x           set     x+1
        endm
y       set     y+1
    endm
```
Die schnellste Variante hat eine Laufzeit von 89,0 ms für eine Iteration (Darstellung einer 64x32 Map). Die Plasma-Werte sind als 4-Bit-Werte abgelegt. Sie werden in Gruppen von je 8 Werten ausgelesen und jeweils in 4 Bytes (R,G,B,H) konvertiert, die dann als ein Byte pro Farbebene in den Video-RAM geschrieben werden. Leider kann der JU-TE-6K nicht parallel in die Farbebenen schreiben, so dass noch zusätzlich die Farbbänke pro Farbe umgeschaltet werden müssen. 
```
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
                
```


## Quellen

Dieses Projekt nutzt Infos und Software aus folgenden Quellen:

https://rosettacode.org/wiki/Plasma_effect

https://hc-ddr.hucki.net/wiki/doku.php/tiny/es40



