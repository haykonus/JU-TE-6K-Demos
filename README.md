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

1. mit direktem Zugriff auf den Video-RAM (s. FGL)
2. mit dem integriertem PLOT-Befehl des ES4.0

Für die Darstellung der Plasma-Effekte wurden vier Farbpaletten integriert. Sowohl Varianten als auch die Farbpaletten können zur Laufzeit mit Tasten ausgewählt werden.

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

## Quellen

Dieses Projekt nutzt Infos und Software aus folgenden Quellen:

https://rosettacode.org/wiki/Plasma_effect


