;------------------------------------------------------------------------------
; Title:                Z8 Macros 
;
; Erstellt:             17.11.2024
; Letzte Änderung:      09.01.2025
;------------------------------------------------------------------------------

MACROS_INC          	; Flag für include-Anweisungen

;------------------------------------------------------------------------------

        ifndef  ES40_INC                
                include ../ES4.0/es40_inc.asm
        endif

;------------------------------------------------------------------------------
; Macro zum Laden von Doppelregistern in Z8 Assembler
; 
; ldrr <Register>, <Wert>
;
; Register [rr0,2,4,6,8,10,12,14 | var_A-Z]
; Wert	   #[0-65535]
;
; Bsp.:    ldrr	rr0, #5555h
;	   ldrr var_A, #65535
;						
;------------------------------------------------------------------------------


ldrr    MACRO    RRX, VALUE, {NOEXPIF}, {NOEXPAND}

numval	set	val(substr(upstring("VALUE"), 1, 0))

	if substr(upstring("RRX"),0,2) == "RR"

		;message "Zielregister = RRX:  \{substr( upstring("RRX"), 1, 0)}"
		if upstring("rrx") == "RR0"
			ld	r0, #hi(numval)
			ld	r1, #lo(numval)

		elseif upstring("rrx") == "RR2"
			ld	r2, #hi(numval)
			ld	r3, #lo(numval)

		elseif upstring("rrx") == "RR4"
			ld	r4, #hi(numval)
			ld	r5, #lo(numval)

		elseif upstring("rrx") == "RR6"
			ld	r6, #hi(numval)
			ld	r7, #lo(numval)

		elseif upstring("rrx") == "RR8"
			ld	r8, #hi(numval)
			ld	r9, #lo(numval)

		elseif upstring("rrx") == "RR10"
			ld	r10, #hi(numval)
			ld	r11, #lo(numval)

		elseif upstring("rrx") == "RR12"
			ld	r12, #hi(numval)
			ld	r13, #lo(numval)

		elseif upstring("rrx") == "RR14"
			ld	r14, #hi(numval)
			ld	r15, #lo(numval)
		endif

	elseif substr(upstring("RRX"), 0, 4) == "VAR_"

		;message "Zielregister = RRX: RRX_HI"
		ld	RRX_HI,   #hi(numval)
		ld	RRX_HI+1, #lo(numval)

	endif

 	ENDM
