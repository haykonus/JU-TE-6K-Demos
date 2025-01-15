;------------------------------------------------------------------------------
; Title:                Z80 Macros für Z8
;
; Erstellt:             20.11.2024
; Letzte Änderung:      15.01.2025
;------------------------------------------------------------------------------

                ;cpu     z8601
                
Z80_INC                 ; Flag für include-Anweisungen

;------------------------------------------------------------------------------

        ifndef  ES40_INC                
                include ../ES4.0/es40_inc.asm
        endif

;------------------------------------------------------------------------------
        
A       equ     r0
tempF   equ     r1      
B       equ     r2
C       equ     r3
D       equ     r4
E       equ     r5
H       equ     r6
L       equ     r7

AF      equ     rr0     
BC      equ     rr2
DE      equ     rr4
HL      equ     rr6


B_      equ     r8      ; 8-Bit-'Register 
C_      equ     r9      ;       
D_      equ     r10     ;
E_      equ     r11     ;
H_      equ     r12     ;
L_      equ     r13     ;
tempH   equ     r14     
tempL   equ     r15             
     
BC_      equ    rr8     ; 16-Bit-'Register
DE_      equ    rr10    ;
HL_      equ    rr12    ;
temp     equ    rr14
        
; rudimentäre Parser-Funktionen

isZ80r          function op, (op=="A") ||(op=="F") || \
                             (op=="B") ||(op=="C") ||(op=="D") ||(op=="E")||  (op=="H")|| (op=="L")|| \
                             (op=="C_")||(op=="B_")||(op=="D_")||(op=="E_")|| (op=="H_")||(op=="L_")
                             
isZ80rr         function op, (op=="BC") ||(op=="DE") ||(op=="HL")|| \
                             (op=="BC_")||(op=="DE_")||(op=="HL_")

getFromBrackets function op, substr(substr(op,0,strstr(op,")")),1,0)

isInBrackets    function op, (substr(op,0,1) == "(") && (substr(op, strstr(op,")"), 1)  == ")")

getOffset       function op, substr(getFromBrackets(op), strstr(getFromBrackets(op),"+")+1, 0)

       
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
        elseif "OP1" == "HL_"
                if "OP2" == "BC_"
                        !add    l_, c_
                        !adc    h_, b_    
                elseif "OP2" == "DE_"
                        !add    l_, e_
                        !adc    h_, d_    
                elseif "OP2" == "HL_"
                        !add    l_, l_
                        !adc    h_, h_
                elseif "OP2" == "SP"
                        !add    l_, SPL
                        !adc    h_, SPH  
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
        elseif "OP1" == "DE_"
                if "OP2" == "BC_"
                        !add    e_, c_
                        !adc    d_, b_    
                elseif "OP2" == "DE_"
                        !add    e_, e_
                        !adc    d_, d_    
                elseif "OP2" == "HL_"
                        !add    e_, l_
                        !adc    d_, h_
                elseif "OP2" == "SP"
                        !add    e_, SPL
                        !adc    d_, SPH  
                endif          
        else    
                !add    OP1, OP2
        endif
        
        ENDM

;------------------------------------------------------------------------------

ex      MACRO   OP1, OP2, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}
                                       
        if "OP1" == "(SP)"
                ; EX  (SP),HL   
                if "OP2" == "HL"                        
                        !pop    tempL
                        !pop    tempH
                        !push   h
                        !push   l
                        !ld     h, tempH
                        !ld     l, tempL

                elseif "OP2" == "HL_"                        
                        !pop    tempL
                        !pop    tempH
                        !push   h_
                        !push   l_
                        !ld     h_, tempH
                        !ld     l_, tempL
                endif       
        endif
        
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
                elseif "OP1" == "BC_"
                        !push   b_
                        !push   c_
                elseif "OP1" == "DE_"
                        !push   d_
                        !push   e_                       
                elseif "OP1" == "HL_"
                        !push   h_
                        !push   l_
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
                elseif "OP1" == "BC_"
                        !pop    c_
                        !pop    b_                       
                elseif "OP1" == "DE_"
                        !pop    e_
                        !pop    d_       
                elseif "OP1" == "HL_"
                        !pop    l_
                        !pop    h_
                endif           
        else
                !pop    OP1
        endif

        ENDM    
        
;------------------------------------------------------------------------------

ld      MACRO   OP1, OP2, {NOEXPIF}, {NOEXPAND}, {NOEXPMACRO}

        ;A  B C D E H L  B_ C_ D_ E_ H_ L_ 
        if isZ80r("OP1")

                ;A  B C D E H L  B_ C_ D_ E_ H_ L_
                if isZ80r("OP2")
                        ;message "Z80 -> LD OP1,OP2 | Register <- Register"
                        !ld     OP1, OP2

                ;(BC) (DE) (HL) (BC_) (DE_) (HL_) (NN)
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
                        ;(BC_)
                        elseif getFromBrackets("OP2") == "BC_"
                                ;message "Z80 -> LD OP1,OP2 | OP2"
                                lde     OP1, @bc_
                        ;(DE_)
                        elseif getFromBrackets("OP2") == "DE_"
                                ;message "Z80 -> LD OP1,OP2 | OP2"
                                lde     OP1, @de_
                        ;(HL_)
                        elseif getFromBrackets("OP2") == "HL_"
                                ;message "Z80 -> LD OP1,OP2 | OP2"
                                lde     OP1, @hl_
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

        ;BC DE HL BC_ DE_ HL_
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
                        elseif "OP1" == "BC_"
                                lde     B_, @temp
                                incw    temp
                                lde     C_, @temp
                        elseif "OP1" == "DE_"
                                lde     D_, @temp
                                incw    temp
                                lde     E_, @temp
                        elseif "OP1" == "HL_"
                                lde     H_, @temp
                                incw    temp
                                lde     L_, @temp
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
                        elseif "OP1" == "BC_"
                                !ld     b_, #hi(OP2)
                                !ld     c_, #lo(OP2)
                        elseif "OP1" == "DE_"
                                !ld     d_, #hi(OP2)
                                !ld     e_, #lo(OP2)
                        elseif "OP1" == "HL_"
                                !ld     h_, #hi(OP2)
                                !ld     l_, #lo(OP2)
                        endif
                endif


        ;(BC) (DE) (HL) (BC_) (DE_) (HL_) (NN)
        elseif isInBrackets("OP1")

                ;A  B C D E H L  B_ C_ D_ E_ H_ L_
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
                        ;(BC_)  
                        elseif getFromBrackets("OP1") == "BC_"
                                ;message "Z80 -> LD OP1,OP2 | OP1"
                                lde     @bc_, OP2
                        ;(DE_)
                        elseif getFromBrackets("OP1") == "DE_"
                                ;message "Z80 -> LD OP1,OP2 | OP1"
                                lde     @de_, OP2
                        ;(HL_)
                        elseif getFromBrackets("OP1") == "HL_"
                                ;message "Z80 -> LD OP1,OP2 | OP1"
                                lde     @hl_, OP2                                                       
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
                        elseif getFromBrackets("OP1") == "HL_"
                                message "Z80 -> LD OP1,OP2 | OP1"
                                !ld     tempL, #OP2
                                lde     @hl_, tempL
                        endif 
                endif   
                                        
        else
                ;message "Z8 -> OP1:OP2"
                !ld     OP1, OP2
        endif

        ENDM

        ;org    8000H
        
        ;ld     hl, 1
