PROJ = vga_bounceball
PIN_DEF = ice40hx1k-evb.pcf
DEVICE = hx1k
#MODULES = vga640x480.v vga_ball.v vga_screenedge.v edgeUp.v ps2_mouse.v
#MODULES = vga640x480.v vga_ball.v vga_screenedge.v edgeUp.v
MODULES = vga640x480.v vga_screenedge.v edgeUp.v


all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $< $(MODULES)

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	sudo iceprogduino $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprogduino $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin

.PHONY: all prog clean
