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

LIBRARIES = ./libraries

LIBRARY_REPOS = \
	https://github.com/openscad/scad-utils \
	https://github.com/openscad/list-comprehension-demos \
	https://github.com/adrianschlatter/threadlib

LIBRARY_FILES = \
	https://github.com/MisterHW/IoP-satellite/raw/master/OpenSCAD%20bottle%20threads/thread_profile.scad

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

local-libraries:
	@[ -d $(LIBRARIES)  ] || mkdir $(LIBRARIES)
	# Install the repositories
	@cd $(LIBRARIES) || exit 1 ; \
	for repo in $(LIBRARY_REPOS); do \
		dn=`echo "$$repo" | tr / ' ' | awk '{ print $$NF }'` ; \
		echo "Getting github repository $$repo"; \
		[ -d "$$dn" ] || git clone "$$repo" ; \
	done
	# Install the files
	@cd $(LIBRARIES) || exit 1 ; \
	for filename in $(LIBRARY_FILES); do \
		fn=`echo "$$filename" | tr / ' ' | awk '{ print $$NF }'` ; \
		echo "Getting file $$fn"; \
		[ -f "$$fn" ] || curl "$$filename" --output "$$fn" --silent ; \
	done
	# Make each repository directory with a Makefile
	for repo in $(LIBRARY_REPOS); do \
		dn=`echo "$$repo" | tr / ' ' | awk '{ print $$NF }'` ; \
		[ -f "$(LIBRARIES)/$$dn/Makefile" ] && cd "$(LIBRARIES)/$$dn" && make; \
	done

include $(wildcard $(DEPFILES))
