# hp-z4-front-fan-mount

## Introduction

This is a 3D-Printable [OpenSCAD](https://openscad.org/) model of a front fan
mount for an HP Z4 G4 workstation. This is in no way endorsed by HP.
Also, the author is not responsible for any damage resulting from its use.

<p align="center"><img src="../media/media/hp-z4-front-fan-mount.installed.jpg" alt="HP Z4 G4 with Front Fan Mount"  height="350px" /></p>

## Model and Parts

There are two models included:

<div class="model" data-name="HP Z4 G4 Front Fan Mount" data-icon-size="128" data-left-icon="hp-z4-front-fan-mount.icon.png" data-left="hp-z4-front-fan-mount.stl"><!-- expanded by annotate-model --><table align="center" width="100%"><tbody><tr width="100%"><td align="center" width="160" height="160"><a href="../media/media/hp-z4-front-fan-mount.stl" target="_blank" title="View HP Z4 G4 Front Fan Mount Model"><img src="../media/media/hp-z4-front-fan-mount.icon.png" alt="HP Z4 G4 Front Fan Mount Model" width="128" height="128" /></a></td><td>

### HP Z4 G4 Front Fan Mount

The fan mount for an HP 92 mm case fan. It is installed below the drive
cage in the front bottom part of an HP Z4 G4 workstation and is required
by the BIOS when certain devices are present (e.g. power graphics cards,
M.2 drives, etc.).

</td></tr></tbody></table></div>

<div class="model" data-name="Hardware Pack" data-icon-size="128" data-left-icon="hp-z4-front-fan-hardware.icon.png" data-left="hp-z4-front-fan-hardware.stl"><!-- expanded by annotate-model --><table align="center" width="100%"><tbody><tr width="100%"><td align="center" width="160" height="160"><a href="../media/media/hp-z4-front-fan-hardware.stl" target="_blank" title="View Hardware Pack Model"><img src="../media/media/hp-z4-front-fan-hardware.icon.png" alt="Hardware Pack Model" width="128" height="128" /></a></td><td>

### Hardware Pack

An optional set of mounting hardware (see below) that
attaches the fan mount to the bottom of the drive cage.

</td></tr></tbody></table></div>

## What You'll Need

### One 92 mm x 25 mm HP-Compatible Fan

<img src="../media/media/fan.jpg" alt="Fan" align="right" width="250px" height="250px" />

Generally, you'll want to buy (or scavenge) an HP-compatible PWM 12VDC fan that
has the HP-specific 4-pin connector and a cable length of at least 6 inches.

The HP fan connector is somewhat proprietary. Older fans tend to have
four color-coded wires and a reddish-brown connector. Newer ones seem to have black
wires and a white connector. Both connectors are keyed on both ends of
the 4-pin connector. If you use an after-market fan, at a minimum, you'll have
to modify the connector to accommodate the HP-style.

I picked up a Foxconn PV902512PSPF from ebay that was originally used on a
HP/Compaq computer and it works great. Here are some choices I saw:

- Foxconn PV902512PSPF (0.40A) from HP/Compaq DCxx00 (HP: 435452-001, 432768-001, 451144-001)
- Nidec T92T12MS3A7-57A03 (0.35A) from the Zxx0 series (HP: 647113-001 Rev. B, 749598-001, and 782506-001)
- Delta QUR0912VH (0.60A) from the Z4x0 series (HP: 647113-001 Rev. A)
- Foxconn PVA092G12H (0.40A) from the Z2x0 series (HP: 727135-001)
- Delta AUB0912HH (0.40A) (HP: 411456-001)

I have not tested the other fans. Given that both 0.60A and 0.35A fans are used
as front fans in the Z440, I think any of these will do the job. Beware: some
of HP's case fans - especially the newer ones - have ultra-short cables.

### One 92 mm Fan Guard

<img src="../media/media/guard.jpg" alt="Fan Guard" align="right" width="180px" height="180px" />

This is essential - i.e., it's not just for your protection\! The fan guard
bolts the baffle to the fan and keeps the structure square and strong. Setting
aside color choice, you want a metal one (not plastic). Some are flat, some
bulge a little. Silver wire with a bulge matched my CPU fan.

### Four Case Fan Screws

<img src="../media/media/screws.jpg" alt="Case Fan Screws" align="right" width="60px" height="60px" />

These seem more or less standard - silver or black, about 10 mm in length, very
coarse thread. Skip the plastic push-pins or rubber connectors.

### M6 x ~16 mm Bolt, Nut, and Washers

<img src="../media/media/bolt.jpg" alt="Nuts and Bolts" align="right" width="75px" height="75px" />

You'll want to secure the fan mount to the bottom of the drive cage with an M6
bolt of about 16 mm length. Too much longer and you'll run into other parts of
the mount. You can get by with M5 or a \#12 size (1/4" hardware won't fit thru
the hole). The head style does not matter, but, a little Threadlocker once
you have everything set is a good idea. 

You can print out the hardware pack provided. The washers are great, the nut is
okay after a little work, but you'll eventually want a metal bolt.

## Printing

I use a Creality Ender 3 Pro to build from PLA with a **layer height of 0.2 mm**
and **infill density of 20%** with **support generation**. In Cura, I use
"Support Placement" set to "Touching Buildplate" with "Support Overhang Angle"
set to 45 degrees (the default).

After printing, remove the generated supports (6 pieces: two under the bottom
tangs, two under the top tangs, one under the screw arm, and a small horizontal
top-front piece at the start of the top arms). Clean-up the print with utility
knife.

As mentioned above, you can print the hardware pack. Use **infill density
of 100%** if you choose to do this.

## Installation

1.  Set your computer on its side and open up the side.

2.  Check your new fan electrically to ensure that it works by connecting it
    and turning the computer on/off briefly. The connector goes to the
    white 4-pin connector at the very front-bottom of the mainboard.

3.  Remove the bottom drive from the drive cage. You'll need the space.

4.  Now seems like a good time to do a little visual inspection. First, look at the
    lower front of the computer where the mount will go. See:
    
    - two slots in the side (now top) of front of the case (just below the
      outside),
    - a screw hole about an inch and a half from the bottom/side (now
      bottom/top) of the drive cage, and,
    - two slots and the tab on the far side (now bottom) of the case.

    Next look at the corresponding parts of the printed mount:
    
    - a large sway-back arm with two tangs at the top of mount,
    - a hole on the cage arm that's on the top side of the baffle, and,
    - two short tangs on the bottom of the mount and a narrow slot between them
      that fits the case's tab.

    It's also a good time to verify that your bolt fits thru the hole in the cage
    arm on the mount and in the hole in drive cage bottom.

    <p align="center"><img src="../media/media/inspection.jpg" alt="Case and Mount Connections" height="350px" /></p>

5.  Rearrange any cable flow in the case now to improve access. Consider
    anything from the bottom slots/tab to the front of the case off-limits. The
    fan does not obstruct drive cables, but it's going to be a pain to change
    these after the fan is installed.

6.  Join the fan to the baffle. Orient the fan so that the air blows thru the
    baffle (bottom of print) - generally that's fan label toward the front of
    the baffle - and so that the fan cable is near the bottom corner (farthest
    from the cage arm). Then its fan guard in front of baffle, and screw the
    four case screws thru the guard and baffle into the case. You can make that
    quite tight.

    <p align="center"><img src="../media/media/assembled.jpg" alt="Fan with Mount Assembled"  height="300px" /></p>

7.  Install the mount in the computer. The easiest sequence seems to be tilt the
    mount slightly forward, line up the bottom tab/tangs, push the top tabs down
    a little and let the whole thing slide down. Release the tabs into the top
    slots. Verify a reasonably tight fit.

8.  Push the bolt with a washer thru the drive side and thru the cage arm, and
    then apply the nut - finger tight. It's a little bit of a dexterity
    challenge.

9.  Plug in the fan, reattach any hardware, power on and enjoy the cool breeze
    of a front case fan on your HP Z4\! Actually, it really is rather
    tepid, so if you want to test higher speeds, reboot into the BIOS
    Setup → Advanced → Built-In Device Options → Increase Idle Fan
    Speed(%) → 90 to create a small hurricane.

## Source

The fan mount is built using OpenSCAD. *hp-z4-front-fan-mount.scad* is the main
file for the model. *hp-z4-front-fan-hardware.scad* builds the hardware
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

Alternately, if you're building on Linux, `make local-libraries` should fetch all the files
and place them in the local directory "./libraries". Then, you can set the environment variable
[OPENSCADPATH](https://wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Setting_OPENSCADPATH)
to include that directory in OpenSCAD's library search path.

### Fan Models

Models are used to visualize and verify the relative positions of holes and
mounts during debugging and not necessary for building. This project uses a
92 mm fan model that was created from a [Delta](https://www.delta-fan.com)
fan model that was converted from STEP to stl format using
[IMAGEtoSTL](https://imagetostl.com/convert/file/stp/to/stl). The fan models
referenced in the source are:

- 92 mm x 25 mm Fan: file _Delta-AFB0912HH.STL_ from [Delta AFB0912HH](https://www.delta-fan.com/AFB0912HH.html)
- 80 mm x 25 mm Fan: file _Delta-AFB0812HH.STL_ from [Delta AFB0812HH](https://www.delta-fan.com/AFB0812HH.html)
- 120 mm x 25 mm Fan: file _Delta-AFB1212HH.STL_ from [Delta AFB1212HH](https://www.delta-fan.com/AFB1212HH.html)

## Also Available on Thingiverse

STLs are available on [Thingiverse](https://www.thingiverse.com/thing:5600480).
