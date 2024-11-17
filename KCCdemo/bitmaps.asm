;------------------------------------------------------------------------------

KC_LOGO:        db      10      ; x
                db      12      ; y
                db      4       ; xw
                db      21      ; yw
                db      050h    ; Farbe VH (grünH/sw)

                ;       4 x 21
                ;       12345678  12345678  12345678  12345678
                db      00000000b,00100111b,11111110b,01111111b
                db      00000000b,00100111b,11111110b,01111111b
                db      00000000b,01100111b,11111100b,11111111b
                db      00000000b,01100111b,11111100b,11111111b
                db      00000000b,11100111b,11111001b,11111111b
                db      00000000b,11100111b,11111001b,11111111b
                db      00000001b,11100111b,11110011b,11111111b
                db      00000001b,11100111b,11110011b,11111111b
                db      00000011b,11100111b,11100111b,11111111b
                db      00000011b,11100111b,11100111b,11111111b
                db      00000111b,11100111b,11001111b,11111111b
                db      00000111b,11100111b,11001111b,11111111b
                db      00001111b,11100111b,10011111b,11111111b
                db      00001111b,11100111b,10011111b,11111111b
                db      00011111b,11100111b,00111111b,11111111b
                db      00011111b,11100111b,00111111b,11111111b
                db      00111111b,11100110b,01111111b,11111111b
                db      00111111b,11100110b,01111111b,11111111b
                db      01111111b,11100100b,11111111b,11111111b
                db      01111111b,11100100b,11111111b,11111111b
                db      11111111b,11100100b,11111111b,11111111b

;------------------------------------------------------------------------------

TINY_LOGO:      db      10      ; x
                db      12      ; y
                db      10      ; xw
                db      24      ; yw
                db      050h    ; Farbe VH (grünH/sw)

                ;       10 x 24
                ;       12345678  12345678  12345678  12345678  12345678  12345678  12345678  12345678  12345678  12345678      
                db      00111111b,11111111b,11000000b,10000000b,01111111b,11111111b,11000000b,01000000b,00000000b,10000000b     
                db      01111111b,11111111b,11100001b,11000000b,11111111b,11111111b,11100000b,11100000b,00000001b,11000000b     
                db      00111111b,11111111b,11000001b,11000000b,11111111b,11111111b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,11100000b,00000001b,11000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,01111111b,11111111b,10000000b     
                db      00000000b,11100000b,00000001b,11000000b,11100000b,00000000b,11100000b,00111111b,11111111b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,11110000b,00000001b,11100000b,11110000b,00000000b,11100000b,00000001b,11100000b,00000000b     
                db      00000000b,01100000b,00000000b,11000000b,01100000b,00000000b,01000000b,00000000b,11000000b,00000000b        

;------------------------------------------------------------------------------

MH_LOGO:        db      26      ; x
                db      141     ; y
                db      5       ; xw
                db      44      ; yw
                db      050h    ; Farbe VH (grünH/sw)

                ;       5 x 1 = 5 x 44
                ;       12345678  12345678  12345678  12345678  12345678
                db      00000000b,00000111b,10111110b,00000000b,00000000b                                       
                db      00000000b,00011000b,00000001b,10000000b,00000000b                                     
                db      00000000b,10100000b,00000000b,01010000b,00000000b                                     
                db      00000001b,00000000b,00000000b,00010000b,00000000b                                     
                db      00000011b,00000001b,11111000b,00001000b,00000000b                                     
                db      00000100b,00000110b,00000111b,00000100b,00000000b                                     
                db      00001000b,00011000b,00000000b,11000010b,00000000b                                     
                db      00010000b,00100000b,00000000b,00100001b,10000000b                                     
                db      00010000b,11000000b,00000000b,00010000b,00000000b                                     
                db      00100000b,10000011b,11111100b,00001000b,10000000b                                     
                db      00100001b,00000110b,00000011b,00000100b,01000000b                                     
                db      01000011b,00001000b,00000001b,10000100b,01000000b                                     
                db      01000010b,00010000b,00000000b,01000010b,00100000b                                     
                db      00000100b,00100000b,00000000b,01100010b,00100000b                                     
                db      01000100b,01100000b,00000000b,00100010b,00100000b                                     
                db      10000100b,01000000b,00000000b,00100001b,00100000b                                     
                db      10000100b,01000000b,00000000b,00010001b,00100000b                                     
                db      10000100b,01000000b,00000000b,00010001b,00000000b                                     
                db      10000100b,01000000b,00000000b,00010001b,00100000b                                     
                db      10000100b,01000000b,00000000b,00010001b,00100000b                                     
                db      00000100b,01000001b,11111000b,00100001b,00100000b                                     
                db      01000100b,01000111b,11111110b,00100010b,00100000b                                     
                db      01000010b,00111111b,11111111b,11100010b,01000000b                                     
                db      01000010b,00111111b,11111111b,11000100b,01000000b                                     
                db      00100011b,00011100b,11110011b,11000100b,10000000b                                     
                db      00100001b,00011100b,11110011b,11001000b,00000000b                                     
                db      00010000b,11011111b,11111111b,11010000b,10000000b                                     
                db      00001000b,01011100b,11110011b,11110011b,00000000b                                     
                db      00001000b,00111100b,11110011b,11000010b,00000000b                                     
                db      00000100b,00011100b,11110011b,11000100b,00000000b                                     
                db      00000011b,00011111b,11111111b,11001000b,00000000b                                     
                db      00000000b,10011100b,11110011b,11110000b,00000000b                                     
                db      00000000b,01111100b,11110011b,11000000b,00000000b                                     
                db      00000000b,00011100b,11111011b,11000000b,00000000b                                     
                db      00000000b,00011101b,11110011b,11000000b,00000000b                                     
                db      00000000b,00000000b,00000000b,00000000b,00000000b                                     
                db      00000000b,00000000b,00000000b,00000000b,00000000b                                     
                db      00000000b,00000000b,11110000b,00000000b,00000000b                                     
                db      00000000b,00000011b,11111100b,00000000b,00000000b                                     
                db      00000000b,00011111b,11111111b,10000000b,00000000b                                     
                db      00000000b,00011111b,11111111b,10000000b,00000000b                                     
                db      00000000b,00011001b,10011001b,10000000b,00000000b                                     
                db      00000000b,00011001b,10011001b,10000000b,00000000b                                     
                db      00000000b,00011001b,10011001b,10000000b,00000000b   

;------------------------------------------------------------------------------

JU_TE_LOGO:     db      26      ; x
                db      141     ; y
                db      5       ; xw
                db      44      ; yw
                db      050h    ; Farbe VH (grünH/sw)

                ;       5 x 44
                ;       12345678  12345678  12345678  12345678  12345678
                db      00111100b,00000111b,10000000b,11110000b,00000000b
                db      01111110b,00001111b,11000001b,11111000b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      01111111b,00001111b,11000011b,11111000b,00000000b
                db      00111111b,10000111b,10000111b,11110000b,00000000b
                db      00000001b,11000011b,00001110b,00000000b,00000000b
                db      00000000b,11100011b,00011100b,00000000b,00000000b
                db      00000000b,01110011b,00111000b,00000000b,00000000b
                db      00111100b,00111111b,11110000b,11110000b,00000000b
                db      01111110b,00011111b,11100001b,11111000b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,11111100b,11111111b,11111100b,00000000b
                db      11111111b,11111100b,11111111b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      01111110b,00011111b,11100001b,11111000b,00000000b
                db      00111100b,00111111b,11110000b,11110000b,00000000b
                db      00000000b,01110011b,00111000b,00000000b,00000000b
                db      00000000b,11100011b,00011100b,00000000b,00000000b
                db      00000001b,11000011b,00001110b,00000000b,00000000b
                db      00111111b,10000111b,10000111b,11110000b,00000000b
                db      01111111b,00001111b,11000011b,11111000b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      11111111b,00011111b,11100011b,11111100b,00000000b
                db      01111110b,00001111b,11000001b,11111000b,00000000b
                db      00111100b,00000111b,10000000b,11110000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b                       
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                
;------------------------------------------------------------------------------

                                                                  




                
                        