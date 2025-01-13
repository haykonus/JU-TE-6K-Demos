[English version](https://github-com.translate.goog/haykonus/JU-TE-6K-Demos?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp)
# INHALT

[GleEst](https://github.com/haykonus/JU-TE-6K-Demos/tree/main?tab=readme-ov-file#gleest)

[KCcompact-Demo](https://github.com/haykonus/JU-TE-6K-Demos/tree/main?tab=readme-ov-file#kccompact-demo-f%C3%BCr-jute-6k)

[Plasma-Effekt](https://github.com/haykonus/JU-TE-6K-Demos/tree/main?tab=readme-ov-file#plasma-effekt)



# GleEst
![GleEst](/GleEst/Bilder/gleest_JuTe-6K.gif)

Dieses Programm für den [JuTe 6K](https://hc-ddr.hucki.net/wiki/doku.php/tiny/es40) basiert auf [GleEst](https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/) für den ZX-Spectrum 128, programmiert von Oleg Senin (bfox, St.Petersburg, Russland). Seine 256 Byte-Demo enthält im Original eine Sound-Ausgabe über den AY-3-8912 und setzt die Farb-Attribute des ZX-Spectrum. Der Algorithmus wurde extrahiert und schon auf weitere DDR-Computer mit Z80-kompatibler CPU portiert ([Z1013](https://github.com/haykonus/Z1013-Demos?tab=readme-ov-file#gleest-f%C3%BCr-z1013-krt), [KC85/1/3/4](https://github.com/haykonus/KC85-Demos?tab=readme-ov-file#gleest-f%C3%BCr-kc85134), [BIC A5105](https://github.com/haykonus/BIC-A5105-Demos?tab=readme-ov-file#gleest-f%C3%BCr-bic-a5105)). Der JuTe-6K hat eine zum Z8 kompatible CPU und eine wesentlich bessere Grafik-Auflösung (320x192 Pixel, 16 Farben/Pixel) als der ZX-Spectrum. 

Die Herausforderung war, den sehr effektiven [Algorithmus](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/GleEst/gleest.asm#L62) auf die Z8 CPU zu portieren. Dafür wurden die Möglichkeiten Macros zu definieren des [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/as_EN.html#sect_3_4_1_) umfangreich genutzt, z.B. für die Abbildung der 16-Bit-Befehle des Z80 auf die Z8-CPU. Sogar das Überladen der Assembler-Syntax ist möglich (z.B. für LD, ADD, POP, PUSH). Die [Z80-Macro-Definitionen](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/GleEst/z80.asm) sind aber nur soweit umgesetzt, wie es für den GleEst-Algorithmus notwendig war. Ausnahme ist der LD-Befehl, der schon vorher im Rahmen eines anderen Projektes umfangreicher portiert wurde.

## Voraussetzungen

- JuTe-6K (JuTe-2K/4K + Grafikerweiterung oder JuTe-6K-kompakt)
- oder [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)
- 32KB RAM
- Optional: [Video-Patch](https://github.com/haykonus/JU-TE-6K-Video-HW-Patch)


## Schnellstart
> [!NOTE]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [gleest_8000H.bin](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/GleEst/gleest_8000H.bin) oder [gleest_8000H.wav](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/GleEst/gleest_8000H.wav) auf Adresse 8000H laden.
- mit ``` J8000 ``` starten
  
Das Programm kann mit Drücken einer beliebigen Taste beendet werden.

## Implementierung

### GleEst-Algorithmus

Der GleEst-Algorithmus zur Berechnung der Bildpunkte wurde 1:1 vom Z80-Code übernommen. Dazu wurden einige [Z80-Assembler-Befehle](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/GleEst/z80.asm) mit Hilfe von Macros nachgebildet. Der entstandene Assembler-Quelltext für den GleEst-Algorithmus ist somit eine Mischung aus Z8/Z80-Assembler. Die Ansteuerung der Grafik und alle anderen Hilfroutinen sind reiner Z8-Code. 

Einige Z8-Befehle sind identisch zum Z80 und konnten ohne Anpassung übernommen werden (z.B.: JR/JP, CP, CALL, RET, AND, OR). Die Register des Z8 sind wie folgt mit Z80-Registern belegt worden:

```
A       equ     r0
F       equ     r1      ; enthält keine echten Flags !
B       equ     r2
C       equ     r3
D       equ     r4
E       equ     r5
H       equ     r6
L       equ     r7

IXH     equ     r8      ; r8-r15 für GleEst nicht 
IXL     equ     r9      ; als Z80 Register   
IYH     equ     r10     ; verwendet !!!
IYL     equ     r11     ;
I       equ     r12     ; 
R       equ     r13     ; 
tempH   equ     r14     ;
tempL   equ     r15     ;

AF      equ     rr0     
BC      equ     rr2
DE      equ     rr4
HL      equ     rr6

IX      equ     rr8     ; rr8-rr14 für GleEst nicht
IY      equ     rr10    ; als Z80 Register
IR      equ     rr12    ; verwendet !!!
temp    equ     rr14    ;
```

Einige Unterschiede gibt es zu beachten, z.B.:

- Der Z8 besitzt kein Parity-Flag:

```
Z80:
----
and     a, #0c0h 
jp      pe, forw  ; Z8 hat kein P-Flag
                                        
Z8:
---
and     a, #0c0h  ; Nachbildung Parity Check
jr      z, forw   
cp      a, #0c0h
jr      z, forw
```

- Die Rotate-Befehle sind in der Bedeutung genau umgekehrt:

```
Instruction                | Z8  | Z80
--------------------------------------
Rotate Right               | rr  | rrc
Rotate Right Through Carry | rrc | rr
Rotate Left                | rl  | rlc
Rotate Left Through Carry  | rlc | rl
```

### Grafik

Der GleEst-Algorithmus liefert die Koordinaten für einen Punkt P(x,y) mit x={0-255} und y={0-191} sowie einen Farbwert C(i) mit i={10H-3FH}, der in 6 Werte zur Darstellung von 6 Farben umgerechnet wird. Diese Werte müssen in eine VRAM-Adresse und eine Kombination aus 4 Farbebenen (R,G,B,H) übersetzt werden. Jede Farbebene besitzt die gleiche VRAM-Adresse, muss aber über einen Speicher-Schreib-Befehl ausgewählt werden.

Die Ermittlung der 16-Bit-VRAM-Adresse erfolgt über eine Lookup-Tabelle, die zu Beginn des Programms mit der Funktion ```initFGL``` erstellt wird. Die Umrechnung kann dann sehr effektiv mit wenigen Befehlen erfolgen:

```
;--------------------------------------
; P(x,y) to VRAM       
;
; in:   X hi = r2
;       X lo = r3
;       Y lo = r9
;       r8   = VRAM_TAB_HI <- global static
;       r10  = VRAM_TAB_LO <- global static
;
; out:  HL = rr6 -> VRAM 
;       A  = r0  -> Bitpos (1 aus 8) 
;--------------------------------------

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
```

Die Funktion ```P(x,y) to VRAM``` liefert zusätzlich noch die Bitposition (1aus8) des Pixels im Byte zur VRAM-Adresse. Die Bitposition dient als Maske für Lese-und Schreiboperation des VRAM-Bytes. Die Umrechnung des Farbwerts C(i) in Anhängikeit vom Wert i in die 4 Farbebenen, mit gleichzeitiger Berücksichtigung der vorhandenen Werte im VRAM, ist aufwendig, aber immer noch schnell genug für den GleEst-Effekt:

```
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
 
 incw    rr12            ; nächste Farbebene
 rr      r15
 
 lde     @rr14, r15      ; G-Bank einschalten
 lde     r9, @rr12       ; Farbe
 and     r9, r0          ; Farbe & Maske
 lde     r11, @rr6       ; VRAM lesen
 or      r11, r9         ; VRAM | Farbe(M)
 lde     @rr6, r11       ; VRAM schreiben
 
 incw    rr12            ; nächste Farbebene
 rr      r15
 
 lde     @rr14, r15      ; B-Bank einschalten
 lde     r9, @rr12       ; Farbe
 and     r9, r0          ; Farbe & Maske
 lde     r11, @rr6       ; VRAM lesen
 or      r11, r9         ; VRAM | Farbe(M)
 lde     @rr6, r11       ; VRAM schreiben

 incw    rr12            ; nächste Farbebene
 rr      r15
 
 lde     @rr14, r15      ; H-Bank einschalten
 lde     r9, @rr12       ; Farbe
 and     r9, r0          ; Farbe & Maske
 lde     r11, @rr6       ; VRAM lesen
 or      r11, r9         ; VRAM | Farbe(M)
 lde     @rr6, r11       ; VRAM schreiben
```

Die Bytes, die in die 4 Farbebenen zur Darstellung der 6 unterschiedlichen Punkt-Farben geladen werden müssen (nach dem Maskieren mit der Bitposition), werden mit einer 6 x 4 Byte-Tabelle über einen Index ermittelt:

```
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
```

Auch das Zurücksetzen der Pixel muss für jede Farbebene entsprechend der Bitposition erfolgen. GleEst speichert dazu aber die VRAM-Adresse und die Bitposition. Die Funktion zum Zurücksetzen ist daher etwas einfacher:

```
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
```

### Kritik

Die 1:1 Umsetzung des GleEst-Algorithmus von Z80 zu Z8 ist keine optimal an den Z8 angepasste Variante von GleEst. Der Z8 kann jedes Register als Akkumulator verwenden. Bei den kompatiblen DDR-Typen des Z8 sind 9 Registersätze mit je 16 8-Bit-Registern vorhanden (144 Register). Es gibt 124 Universalregister, 4 I/O- sowie 16 Status- und Steuerregister. Die meisten 8-Bit-Register können paarweise auch als 16-Bit-Register genutzt werden, jedoch im wesentlichen nur für Speicherzugriffe. 16-Bit-Arithmetik z.B. muss aus 8-Bit-Befehlen zusammengesetzt werden. In der vorliegenden Implementierung wurde der sehr häufig verwendete Z80-Befehl EXX durch SRP und Umladen des A(r0)-Registers nachgebildet.

```
exx30   MACRO   {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}
        srp     #30h
        !ld     30h, 20h        ; Akku holen       
        ENDM

exx20   MACRO   {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}
        srp     #20h
        !ld     20h, 30h        ; Akku holen   
        ENDM
```
Die Verwendung aller 16 Z8-Register in einem Registersatz würde das Programm beschleunigen. Das könnte man noch umbauen, jedoch müsste der universelle Ansatz der Z80-Macros dann verlassen werden. 

Die Verwendung und Umsetzung von EX DE,HL auf dem Z8 ist sehr ungünstig und wird in GleEst so verwendet:

```
ex      de,hl          
add     hl,bc  
ex      de,hl   
```

Die Umsetzung mit Z80-Macros ergab folgenden Z8-Code:

```
!ld     tempH, D
!ld     tempL, E
!ld     D, H
!ld     E, L
!ld     H, tempH
!ld     L, tempL

!add    l, c
!adc    h, b 

!ld     tempH, D
!ld     tempL, E
!ld     D, H
!ld     E, L
!ld     H, tempH
!ld     L, tempL
```

Hier geht auf dem Z8 einfach:

```
!add    e, c
!adc    d, b 
```
Weitere Optimierungen sind sicher noch möglich.


## Quellen

Dieses Projekt nutzt Infos und Software aus folgenden Quellen:

https://hc-ddr.hucki.net/wiki/doku.php/tiny/es40

https://github.com/boert/JU-TE-Computer/tree/main

https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/

<br>
<br>
<br>

# KCcompact-Demo für JuTe-6K

![Testbild](/KCCdemo/Bilder/kccdemo_360x232.gif)     
[Vollständiges Video ansehen](https://nextcloud-ext.peppermint.de/s/jTaJbMyDS46GqiY)

Dieses Programm ist der Versuch einer Portierung der Einleitung (Intro) einer [Grafik-Demonstration für den KCcompact](https://www.youtube.com/watch?v=M-UYCD3MkBg) auf den JuTe-6K. Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 und Kubuntu 24 verwendet. 

## Voraussetzungen

- JuTe-6K (JuTe-2K/4K + Grafikerweiterung oder JuTe-6K-kompakt)
- oder [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)
- 32KB RAM
- Optional: [Video-Patch](https://github.com/haykonus/JU-TE-6K-Video-HW-Patch)

## Schnellstart
> [!NOTE]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [kccdemo_8000H.bin](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/KCCdemo/kccdemo_8000H.bin) oder [kccdemo_8000H.wav](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/KCCdemo/kccdemo_8000H.wav) auf Adresse 8000H laden.
- mit ``` J8000 ``` starten

## Implementierung

Die animierten Linien bestehen aus 4 Zeilen. Für jede Zeile müssen die 4 Farb-Bänke des JuTe-6K beschrieben werden, um die entsprechende Farbe einer Zeile darzustellen. Dazu wird mit dem PUSH-Befehl das jeweilige Byte in die Farb-Bank geschrieben. Das Schreiben der 40 Bytes pro Zeile erfolgt durch Wiederholung der Befehlsfolge mit dem REPT-Marco des Arnold-Assemblers mit max. Geschwindgkeit. Vor jedem Schreibvorgang wird noch der Hintergrund durch Lesen eines Shaddow-VRAM-Buffers geprüft und brücksichtigt (s. drawLineG/drawLineW in [kccdemo.asm](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/KCCdemo/kccdemo.asm)).

Bsp. für eine Farb-Bank in einer Zeile:

```
 ...
 ld      SPH, r6         ; Video-RAM-Addresse (VRAM)
 ld      SPL, r7

 ld      r4, r6
 add     r4, #80h        ; Shaddow-VRAM-Adresse bilden 40 + 80 = C0
 ld      r5, r7
 dec     r5              ; Korrektur PUSH -> SP=SP-1

 lde     @rr14, r15      ; Farb-Bank einschalten
 lde     r1, @rr12       ; Farb-Byte holen
 

 rept    40
         lde     r0, @rr4        ; 12      Shaddow-VRAM lesen   
         com     r0              ;  6      Hintergrund berücksichtigen
         and     r0, r1          ;  6
         push    r0              ; 12      VRAM rückwärts schreiben  
         dec     r5              ;  6      Shaddow-VRAM-Zeiger auf nächstes Byte setzen   
 endm                            ; --
                                 ; 40
 incw    rr12            ; nächstes Farb-Byte
 rr      r15             ; nächste Farb-Bank
 ...
```
<br>
Der zeitliche Verlauf der Funktion zur Animation der Linien auf der imaginären Z-Achse ist:

<br>
<br>

![Funktion-Def](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/KCCdemo/Bilder/funktion-def-600.png)

![Funktion](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/KCCdemo/Bilder/funktion-600.png)


Da der JuTe-6K keine Trigonometrie beherrscht, wurden die Möglichkeiten des Makro-Assemblers genutzt:
```
;------------------------------------------------------------------------------
XW              equ     64                              ; 64 Y-Werte
cmask           equ     00111111b                       ; Maske für Ring-Puffer
PI              equ     3.141592
;------------------------------------------------------------------------------
Y_POS_RING_BUFFER:

x       set 0
        while x<=XW-1
value       set ( sin (1 * (x*2*PI/XW+1) ) + 0.5 * sin( 2 * (x*2*PI/XW+1) ) ) * 0.71 * (-1)
            if value > 0
value           set     value*1.55                  ; untere "Halbwelle" strecken
            endif
value       set     int ((value * 64) + 86)         ; Position der Wendepunkte
            db      value
            ;message "value: \{value}"
x           set     x+1     
        endm
```


## Quellen

Dieses Projekt nutzt Infos und Software aus folgenden Quellen:

https://hc-ddr.hucki.net/wiki/doku.php/tiny/es40

https://github.com/boert/JU-TE-Computer/tree/main

https://www.youtube.com/watch?v=M-UYCD3MkBg

<br>
<br>
<br>

# Plasma-Effekt

![Testbild](/Plasma/Bilder/plasma_360x232.gif)

Das hier vorgestellte Programm erzeugt einen Plasma-Effekt. Es ist vollständig in Zilog Z8-Assembler realisiert. Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 verwendet.

## Voraussetzungen

- JuTe-6K (JuTe-2K/4K + Grafikerweiterung oder JuTe-6K-kompakt)
- oder [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)
- 32KB RAM
- Optional: [Video-Patch](https://github.com/haykonus/JU-TE-6K-Video-HW-Patch)

## Schnellstart
> [!NOTE]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [plasma_8000H.bin](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/Plasma/plasma_8000H.bin) oder [plasma_8000H.wav](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/Plasma/plasma_8000H.wav) auf Adresse 8000H laden.
- mit ``` J8000 ``` starten

## Implementierung

Der Plasma-Effekt wurde in zwei Varianten umgesetzt:

1. mit direktem Zugriff auf den Video-RAM (s. [FGL](https://github.com/haykonus/JU-TE-6K-Demos/blob/main/FGL/FGL.asm))
2. mit dem integrierten PLOT-Befehl des ES4.0

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
Da der JuTe-6K keine Trigonometrie beherrscht, wurden die Möglichkeiten des Makro-Assemblers genutzt:
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
Die schnellste Variante (mit direktem Zugriff auf den Video-RAM) hat eine Laufzeit von 89,0 ms für eine Iteration (Darstellung einer 64x32 Map). Die Plasma-Werte sind als 4-Bit-Werte abgelegt. Sie werden in Gruppen von je 8 Werten ausgelesen und jeweils in 4 Bytes (R,G,B,H) konvertiert, die dann als ein Byte pro Farbebene in den Video-RAM geschrieben werden. Leider kann der JuTe-6K nicht parallel in die Farbebenen schreiben, so dass noch zusätzlich die Farbbänke pro Farbe umgeschaltet werden müssen:
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

https://hc-ddr.hucki.net/wiki/doku.php/tiny/es40

https://github.com/boert/JU-TE-Computer/tree/main

https://rosettacode.org/wiki/Plasma_effect


