# hp-z4-front-fan-mount

## Introduction

This is a 3D-Printable [OpenSCAD](https://openscad.org/) model of front fan
mount for an HP Z4 G4 workstation. This is in no way endorsed by HP; we are in
no way responsible for any damage resulting from its use.

## Models and Variations

TBD

[![View Fan Mount Model](../media/media/hp-z4-front-fan-mount.icon.png)](../media/media/hp-z4-front-fan-mount.stl "View Model of Fan Mount")

[![View Hardware Model](../media/media/hp-z4-front-fan-hardware.icon.png)](../media/media/hp-z4-front-fan-hardware.stl "View Model of Hardware")

## What You'll Need

### One 92mm x 25mm HP-Compatible Fan

Generally, you'll want to buy or scavenge an HP-compatible PWM 12VDC fan that
has the HP-specific 4-pin connector and a cable length of around 6 inches.

The HP fan connector is somewhat proprietary. Older fans tend to have 4
color-coded wires and a dark red-brown connector. Newer ones seem to have black
wires with a white connector. Both connectors are keyed on either end of
the 4-pin connector. If you use an after-market fan, you'll have the change the
connector to accommodate the HP-style.

I picked up a Foxconn PVA092G12H (0.40A) from ebay that was originally used on a
Compaq/Z2x0 computer and it works great. A few other choices are Nidec
T92T12MS3A7-57A03 (0.35A) fans from the Z8x0 series (HP part
numbers: 647113-001, 749598-001, and 782506-001). Also common is the Delta
AUB0912HH (0.40A). Beware: some of HP's newer case fans have ultra-short cables.
I have not tested these other fans.

### One 92 mm Fan Guard

This is essential - i.e., it's not just for your protection\! The fan guard
bolts the baffle to the fan and keeps the structure square and strong. Setting
aside color choice, you want a metal one (not plastic). Some are flat, some
bulge a little. Silver wire with a bulge matches the CPU fan.

### Four Case Fan Screws

These seem more or less standard - silver or black, 10 mm in length, very coarse
thread. Oh, skip the plastic push-pins or rubber connectors.

### M6 x ~16 mm Bolt, M6 Nut, and Washer

You'll want to secure the fan mount to the bottom of the drive cage with an M6
bolt of about 16mm length. Too much longer and you'll run into other parts of
the mount. You can get by with M5 or a \#12 size (1/4" hardware won't fit thru
the hole). The head style does not matter too much.

You can print out the hardware pack provided. The washers are great, the nut is
okay, but you'll eventually want a metal bolt.

## Printing

I use a Creality Ender 3 Pro to build from PLA with a **layer height of 0.2 mm**
and **infill density of 20%** with **support generation**. In Cura, I use
"Support Placement" set to "Touching Buildplate" with "Support Overhang Angle"
set to 45 degrees (the default).

After printing, remove the generated supports (6 pieces - under the 2 bottom
tangs, the 2 top tangs, the screw arm, and at small horizontal top-front piece
at the start of the top arms). Clean-up the print with utility knife.

## Installation

1.  Set your computer it on its side and open up the side.

2.  Check your fan electrically to ensure that it works by connecting it and
    turning on/off the computer briefly.

3.  Remove the bottom drive from the drive cage.

4.  While you're in there do a visual inspection of the lower front of the
    computer where the mount will be installed:
    
    - two slots and the tab on the far side (now bottom) of the case
    - a screw hole about an inch and a half from the bottom/side (now
      bottom/top) of the drive cage
    - two slots at the side (now top) of front of the case (just below the
      outside).

5.  Do a visual inspection of the corresponding parts of the mount:
    
    - two short tangs on the bottom of the mount and a narrow slot between them
      that fits the case's tab
    - the hole on the cage-side arm on the top of the mount
    - two large sway-back tabs on the top of mount

6.  Now's a good time to verify that your bolt fits thru the hole in the cage
    arm on the mount and in the hole in drive cage bottom.

7.  Move/rearrange any cable flow in the case now to get some access. Consider
    anything from the bottom slots/tab to the front of the case off-limits. The
    fan does not obstruct drive cables, but it's going to be a pain to change
    these after the fan is installed.

8.  Join the fan to the baffle. Orient the fan so that the air blows thru the
    baffle (bottom of print) - generally that's fan label toward the front of
    the baffle - and so that the fan cable is near the bottom corner (farthest
    from the cage arm). Then its fan guard in front of baffle, and screw the
    four case screws thru the guard and baffle into the case. You can make that
    quite tight.

9.  Install the mount in the computer. The easiest sequence seems to be tilt the
    mount slightly forward, line up the bottom tab/tangs, push the top tabs down
    a little and let the whole thing slide down. Release the tabs into the top
    slots. Verify a reasonably tight fit.

10. Push the bolt with a washer thru the drive side and thru the cage arm, and
    then apply the nut - finger tight. It's a little bit of a dexterity
    challenge.

11. Plug in the fan, reattach any hardware, power on and enjoy the cool breeze
    of a front case fan on your HP Z4\!

## Source

The fan mount is built using OpenSCAD. *hp-z4-front-fan-mount.scad* is the main
file for the adapter. *hp-z4-front-fan-hardware.scad* builds the hardware
package.

### Libraries

You'll need the following openscad libraries (four for threading - as described
by [threadlib](https://github.com/adrianschlatter/threadlib) - as well as the
semi-standard MCAD library):

- [MCAD](https://github.com/openscad/MCAD)
- [scad-utils](https://github.com/openscad/scad-utils)
- [list-comprehension](https://github.com/openscad/list-comprehension-demos)
- [threadprofile.scad](https://github.com/MisterHW/IoP-satellite/blob/master/OpenSCAD%20bottle%20threads/thread_profile.scad)
- [threadlib](https://github.com/adrianschlatter/threadlib)

Save all of these into your OpenSCAD [library
folder](https://wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries) and then the
folder should now include the following files and directories:

```
    libraries
    ├── list-comprehension-demos/
    ├── MCAD/
    ├── scad-utils/
    ├── threadlib/
    └── thread_profile.scad
```

### Fan Models

Models are used to visualize and verify the relative positions of holes and
mounts during debugging and not necessary for building.

This projects uses a 92mm fan model that was created from [Delta](https://www.delta-fan.com) fan
models by conversion from the STEP files they provide and converted to stl by 
[IMAGEtoSTL](https://imagetostl.com/convert/file/stp/to/stl). The models are:

- 92mm x 25mm Fan: _Delta-AFB0912HH.STL_ - Delta model [AFB0912HH](https://www.delta-fan.com/AFB0912HH.html)
- 80mm x 25mm Fan: _Delta-AFB0812HH.STL_ - Delta model [AFB0812HH](https://www.delta-fan.com/AFB0812HH.html)
- 120mm x 25mm Fan: _Delta-AFB1212HH.STL_ - Delta model [AFB1212HH](https://www.delta-fan.com/AFB1212HH.html)

## Also Available on Thingiverse

STLs are available on [Thingiverse](https://www.thingiverse.com/thing:).
