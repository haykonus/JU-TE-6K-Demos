;------------------------------------------------------------------------------
; Title:                Z80 Macros für Z8
;
; Erstellt:             20.11.2024
; Letzte Änderung:      11.01.2025
;------------------------------------------------------------------------------

Z80_INC                 ; Flag für include-Anweisungen

;------------------------------------------------------------------------------

        ifndef  ES40_INC                
                include ../ES4.0/es40_inc.asm
        endif

;------------------------------------------------------------------------------
        
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

; rudimentäre Parser-Funktionen

isZ80r          function op, (op=="A")||(op=="B") ||(op=="C") ||(op=="D") ||(op=="E")|| \
                             (op=="H")|| (op=="L")||(op=="IXL")||(op=="IXH")|| \
                             (op=="IYL")||(op=="IYH")||(op=="I")||(op=="R")
                             
isZ80rr         function op, (op=="AF")||(op=="BC")||(op=="DE")||(op=="HL")|| \
                             (op=="IX")||(op=="IY")||(op=="IR")

getFromBrackets function op, substr(substr(op,0,strstr(op,")")),1,0)

isInBrackets    function op, (substr(op,0,1) == "(") && (substr(op, strstr(op,")"), 1)  == ")")

getOffset       function op, substr(getFromBrackets(op), strstr(getFromBrackets(op),"+")+1, 0)

;------------------------------------------------------------------------------

ldir    MACRO   {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

ldir1:  lde     tempL, @hl
        lde     @de, tempL
        incw    hl
        incw    de
        decw    bc
        jr      nz, ldir1
        
        ENDM
        
;------------------------------------------------------------------------------

inc     MACRO   OP1, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        if isZ80rr("OP1")
                !incw   OP1
        else
                !inc    OP1
        endif
        
        ENDM
        
;------------------------------------------------------------------------------

dec     MACRO   OP1, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        if isZ80rr("OP1")
                !decw   OP1
        else
                !dec    OP1
        endif
        
        ENDM

;------------------------------------------------------------------------------

srl     MACRO   OP1, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        rcf     
        rrc     OP1
        
        ENDM
        
;------------------------------------------------------------------------------

sla     MACRO   OP1, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        rcf     
        rlc     OP1
        
        ENDM
        
;------------------------------------------------------------------------------

add     MACRO   OP1, OP2, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        ; add HL, rr
        if "OP1" == "HL"
                if "OP2" == "BC"
                        !add    l, c
                        !adc    h, b    
                elseif "OP2" == "DE"
                        !add    l, e
                        !adc    h, d    
                elseif "OP2" == "HL"
                        !add    l, l
                        !adc    h, h
                elseif "OP2" == "SP"
                        !add    l, SPL
                        !adc    h, SPH  
                endif   
        ; add DE, rr            
        elseif "OP1" == "DE"
                if "OP2" == "BC"
                        !add    e, c
                        !adc    d, b    
                elseif "OP2" == "DE"
                        !add    e, e
                        !adc    d, d    
                elseif "OP2" == "HL"
                        !add    e, l
                        !adc    d, h
                elseif "OP2" == "SP"
                        !add    e, SPL
                        !adc    d, SPH  
                endif   
        else    
                !add    OP1, OP2
        endif
        
        ENDM

;------------------------------------------------------------------------------

ex      MACRO   OP1, OP2, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}
        
        if "OP1" == "DE" 
                ; EX  DE,HL
                if "OP2" == "HL"  
                        !ld     tempH, D
                        !ld     tempL, E
                        !ld     D, H
                        !ld     E, L
                        !ld     H, tempH
                        !ld     L, tempL
                endif
                                
        elseif "OP1" == "(SP)"
                ; EX  (SP),HL   
                if "OP2" == "HL"                        
                        !pop    tempL
                        !pop    tempH
                        !push   h
                        !push   l
                        !ld     h, tempH
                        !ld     l, tempL
                endif
        endif
        
        ENDM    

;------------------------------------------------------------------------------

exx30   MACRO   {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        srp     #30h
        !ld     30h, 20h        ; Akku holen
        
        ENDM

;------------------------------------------------------------------------------

exx20   MACRO   {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        srp     #20h
        !ld     20h, 30h        ; Akku holen
        
        ENDM
        
;------------------------------------------------------------------------------

push    MACRO   OP1, {NOEXPIF};, {NOEXPAND}, {NOEXPMACRO}

        if isZ80rr("OP1")               
                if "OP1" == "AF"
                        !push   a
                        !push   FLAGS
                elseif "OP1" == "BC"
                        !push   b
                        !push   c
                elseif "OP1" == "DE"
                        !push   d
                        !push   e                       
                elseif "OP1" == "HL"
                        !push   h
                        !push   l
                endif                   
        else
                !push   OP1
        endif

        ENDM

;------------------------------------------------------------------------------
        
pop     MACRO   OP1, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        if isZ80rr("OP1")               
                if "OP1" == "AF"
                        !pop    FLAGS
                        !pop    a
                elseif "OP1" == "BC"
                        !pop    c
                        !pop    b                       
                elseif "OP1" == "DE"
                        !pop    e
                        !pop    d       
                elseif "OP1" == "HL"
                        !pop    l
                        !pop    h
                endif
        else
                !pop    OP1
        endif

        ENDM    
        
;------------------------------------------------------------------------------

ld      MACRO   OP1, OP2, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        ;A B C D E H L I R IXH IXL IYH IYL
        if isZ80r("OP1")

                ;A B C D E H L I R IXH IXL IYH IYL
                if isZ80r("OP2")
                        ;message "Z80 -> LD OP1,OP2 | Register <- Register"
                        !ld     OP1, OP2

                ;(BC) (DE) (HL) (IX+N) (IY+N) (NN)
                elseif isInBrackets("OP2")
                        ;(BC)
                        if getFromBrackets("OP2") == "BC"
                                ;message "Z80 -> LD OP1,OP2 | OP2"
                                lde     OP1, @bc
                        ;(DE)
                        elseif getFromBrackets("OP2") == "DE"
                                ;message "Z80 -> LD OP1,OP2 | OP2"
                                lde     OP1, @de
                        ;(HL)
                        elseif getFromBrackets("OP2") == "HL"
                                ;message "Z80 -> LD OP1,OP2 | OP2"
                                lde     OP1, @hl
                        ;(IX[+])
                        elseif strstr (getFromBrackets("OP2"), "IX") >= 0
                                ;(IX+N)
                                if strstr(getFromBrackets("OP2"),"+") >= 0
                                        ;message "Z80 -> LD OP1,OP2 | IX+\{getOffset("OP2")}"

                                        add     ixl, #lo(val(getOffset("OP2")))
                                        adc     ixh, #hi(val(getOffset("OP2")))
                                        lde     OP1, @ix
                                ;(IX)
                                else
                                        ;message "Z80 -> LD OP1,OP2 | OP2"
                                        lde     OP1, @ix

                                endif
                        ;(IY[+])
                        elseif strstr (getFromBrackets("OP2"), "IY") >= 0
                                ;(IY+N)
                                if strstr(getFromBrackets("OP2"),"+") >= 0
                                        ;message "Z80 -> LD OP1,OP2 | IY+\{getOffset("OP2")}"
                                        add     iyl, #lo(val(getOffset("OP2")))
                                        adc     iyh, #hi(val(getOffset("OP2")))
                                        lde     OP1, @iy
                                ;(IY)
                                else
                                        ;message "Z80 -> LD OP1,OP2 | OP2"
                                        lde     OP1, @iy

                                endif
                        ;(NN)
                        else
                                ;message "Z80 -> LD OP1,OP2 | \{getFromBrackets("OP2")}"
                                !ld     tempH, #hi(val(getFromBrackets("OP2")))
                                !ld     tempL, #lo(val(getFromBrackets("OP2")))
                                lde     OP1, @temp
                        endif
                ;N
                elseif EXPRTYPE(OP2) == 0       ; integer ?
                        ;message "Z80 -> LD OP1,OP2 | Register <- OP2"
                        !ld     OP1, #OP2
                endif

        ;BC DE HL SP IX IY
        elseif isZ80rr("OP1")
                ;(NN)
                if isInBrackets("OP2")
                        ;message "Z80 -> LD OP1,OP2 | Doppelregister <- (\{getFromBrackets("OP2")})"

                        !ld     tempH, #hi(val(getFromBrackets("OP2")))
                        !ld     tempL, #lo(val(getFromBrackets("OP2")))

                        if "OP1" == "BC"
                                lde     b, @temp
                                incw    temp
                                lde     c, @temp
                        elseif "OP1" == "DE"
                                lde     d, @temp
                                incw    temp
                                lde     e, @temp
                        elseif "OP1" == "HL"
                                lde     h, @temp
                                incw    temp
                                lde     l, @temp
                        elseif "OP1" == "IX"
                                lde     ixh, @temp
                                incw    temp
                                lde     ixl, @temp
                        elseif "OP1" == "IY"
                                lde     iyh, @temp
                                incw    temp
                                lde     iyl, @temp
                        endif
                ;NN
                elseif EXPRTYPE(OP2) == 0       ; integer ?
                        ;message "Z80 -> LD OP1,OP2 | Doppelregister <- OP2"

                        if "OP1" == "BC"
                                !ld     b, #hi(OP2)
                                !ld     c, #lo(OP2)
                        elseif "OP1" == "DE"
                                !ld     d, #hi(OP2)
                                !ld     e, #lo(OP2)
                        elseif "OP1" == "HL"
                                !ld     h, #hi(OP2)
                                !ld     l, #lo(OP2)
                        elseif "OP1" == "IX"
                                !ld     ixh, #hi(OP2)
                                !ld     ixl, #lo(OP2)
                        elseif "OP1" == "IY"
                                !ld     iyh, #hi(OP2)
                                !ld     iyl, #lo(OP2)
                        endif
                endif



        ;(BC) (DE) (HL) (IX+N) (IY+N) (NN)
        elseif isInBrackets("OP1")

                ;A B C D E H L I R IXH IXL IYH IYL
                if isZ80r("OP2")

                        ;(BC)
                        if getFromBrackets("OP1") == "BC"
                                ;message "Z80 -> LD OP1,OP2 | OP1"
                                lde     @bc, OP2
                        ;(DE)
                        elseif getFromBrackets("OP1") == "DE"
                                ;message "Z80 -> LD OP1,OP2 | OP1"
                                lde     @de, OP2
                        ;(HL)
                        elseif getFromBrackets("OP1") == "HL"
                                ;message "Z80 -> LD OP1,OP2 | OP1"
                                lde     @hl, OP2
                        ;(IX[+])
                        elseif strstr (getFromBrackets("OP1"), "IX") >= 0
                                ;(IX+N)
                                if strstr(getFromBrackets("OP1"),"+") >= 0
                                        ;message "Z80 -> LD OP1,OP2 | IX+\{getOffset("OP1")}"

                                        add     ixl, #lo(val(getOffset("OP1")))
                                        adc     ixh, #hi(val(getOffset("OP1")))
                                        lde     @ix, OP2
                                ;(IX)
                                else
                                        ;message "Z80 -> LD OP1,OP2 | OP1"
                                        lde     @ix, OP2

                                endif
                        ;(IY[+])
                        elseif strstr (getFromBrackets("OP1"), "IY") >= 0
                                ;(IY+N)
                                if strstr(getFromBrackets("OP1"),"+") >= 0
                                        ;message "Z80 -> LD OP1,OP2 | IY+\{getOffset("OP1")}"
                                        add     iyl, #lo(val(getOffset("OP1")))
                                        adc     iyh, #hi(val(getOffset("OP1")))
                                        lde     @iy, OP2
                                ;(IY)
                                else
                                        ;message "Z80 -> LD OP1,OP2 | OP1"
                                        lde     @iy, OP2

                                endif

                        ;(NN)
                        elseif EXPRTYPE(val(getFromBrackets("OP1"))) == 0       ; integer ?

                                ;message "Z80 -> LD OP1,OP2 | \{getFromBrackets("OP1")}"
                                !ld     tempH, #hi(val(getFromBrackets("OP1")))
                                !ld     tempL, #lo(val(getFromBrackets("OP1")))
                                lde     @temp, OP2

                        endif


                ;N
                elseif EXPRTYPE(OP2) == 0       ; integer ?

                        ;(HL)   
                        if getFromBrackets("OP1") == "HL"
                                message "Z80 -> LD OP1,OP2 | OP1"
                                !ld     tempL, #OP2
                                lde     @hl, tempL
                                
                        ;(IX[+])
                        elseif strstr (getFromBrackets("OP1"), "IX") >= 0
                                ;(IX+N)
                                if strstr(getFromBrackets("OP1"),"+") >= 0
                                        ;message "Z80 -> LD OP1,OP2 | IX+\{getOffset("OP1")}"

                                        add     ixl, #lo(val(getOffset("OP1")))
                                        adc     ixh, #hi(val(getOffset("OP1")))
                                        !ld     tempL, #OP2
                                        lde     @ix, tempL
                                ;(IX)
                                else
                                        ;message "Z80 -> LD OP1,OP2 | OP1"
                                        !ld     tempL, #OP2                                     
                                        lde     @ix, tempL

                                endif
                                
                        ;(IY[+])
                        elseif strstr (getFromBrackets("OP1"), "IY") >= 0
                                ;(IY+N)
                                if strstr(getFromBrackets("OP1"),"+") >= 0
                                        ;message "Z80 -> LD OP1,OP2 | IY+\{getOffset("OP1")}"
                                        add     iyl, #lo(val(getOffset("OP1")))
                                        adc     iyh, #hi(val(getOffset("OP1")))
                                        !ld     tempL, #OP2
                                        lde     @iy, tempL
                                ;(IY)
                                else
                                        ;message "Z80 -> LD OP1,OP2 | OP1"
                                        !ld     tempL, #OP2
                                        lde     @iy, tempL

                                endif
                        endif   
                endif   
                                        
        else
                ;message "Z8 -> OP1:OP2"
                !ld     OP1, OP2
        endif

        ENDM

