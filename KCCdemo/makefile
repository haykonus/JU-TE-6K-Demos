
all: $(f).bin
	touch $(f).asm
$(f).bin: *.asm
	asl -L $(f).asm
	p2bin $(f).p
	plist $(f).p

clean:
	rm -f $(f).lst
	rm -f $(f).bin
	rm -f $(f).p
