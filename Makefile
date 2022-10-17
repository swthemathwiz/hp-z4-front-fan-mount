#
# Copyright (c) Stewart H. Whitman, 2022.
#
# File:    Makefile
# Project: HP Z4 G4 Fan Mount
# License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
# Desc:    Makefile for directory
#

NAME = hp-z4-front-fan-mount

OPENSCAD = openscad
PNGCRUSH = pngcrush -brute

SRCS = \
	hp-z4-front-fan-mount.scad \
	hp-z4-front-fan-hardware.scad \
	hp-z4-catch-bottom.scad \
	hp-z4-catch-top.scad \
	arm.scad \
	fasteners.scad \
	fan.scad \
	hash.scad \
	pair.scad \
	rounded.scad \
	smidge.scad \

BUILDS = \
	hp-z4-front-fan-mount.scad \
	hp-z4-front-fan-hardware.scad \

EXTRAS = \
	Makefile \
	README.md \
	LICENSE.txt \

TARGETS = $(BUILDS:.scad=.stl)
IMAGES = $(BUILDS:.scad=.png)
ICONS = $(BUILDS:.scad=.icon.png)

DEPDIR := .deps
DEPFLAGS = -d $(DEPDIR)/$*.d

COMPILE.scad = $(OPENSCAD) -o $@ $(DEPFLAGS)
RENDER.scad = $(OPENSCAD) -o $@ --render --colorscheme=Tomorrow
RENDERICON.scad = $(RENDER.scad) --imgsize=256,256

.PHONY: all images icons clean distclean

all: $(TARGETS)

images: $(IMAGES)

icons : $(ICONS)

%.stl : %.scad
%.stl : %.scad $(DEPDIR)/%.d | $(DEPDIR)
	$(COMPILE.scad) $<

%.unoptimized.png : %.scad
	$(RENDER.scad) $<

%.icon.unoptimized.png : %.scad
	$(RENDERICON.scad) $<

%.png : %.unoptimized.png
	$(PNGCRUSH) $< $@ || mv $< $@

clean:
	rm -f *.stl *.bak *.png

distclean: clean
	rm -rf $(DEPDIR)

$(DEPDIR): ; @mkdir -p $@

DEPFILES := $(TARGETS:%.stl=$(DEPDIR)/%.d)
$(DEPFILES):

include $(wildcard $(DEPFILES))
