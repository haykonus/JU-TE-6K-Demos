
all: $(f).bin

$(f).bin: *.asm
        asl -L $(f).asm
        p2bin $(f).p
        plist $(f).p

clean:
        rm -f *.lst
        rm -f *.bin
        rm -f *.p
