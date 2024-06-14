//
// Copyright (c) Stewart H. Whitman, 2022-2024.
//
// File:    hp-z4-front-fan-mount.scad
// Project: HP Z4 G4 Fan Mount
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Printable HP Z4 G4 Front Fan Mount
//

include <smidge.scad>;
include <rounded.scad>;
include <fan.scad>;
include <fastener.scad>;
include <screw-hole.scad>;
include <line.scad>;

use <hp-z4-catch-bottom.scad>;
use <hp-z4-catch-top.scad>;
use <arm.scad>;

/* [General] */

// Show mount or hardware (others for debugging)
show_selection = "mount"; // [ "mount", "mount/fan", "mount/machine", "mount/machine/axis", "hardware", "fan" ]

/* [Fan] */

// Fan model
fan_model = "92x92x25"; // [ "92x92x25", "80x80x25", "120x120x25" ]

// Fan specifications
fan_spec = fan_get_spec( fan_model );

// Fan frame size square (mm)
fan_frame_side = fan_get_attribute( fan_spec, "side" );

// Fan frame width (mm)
fan_frame_width = fan_get_attribute( fan_spec, "width" );
fan_frame_area = [ fan_frame_side, fan_frame_side ];

// Mounting screw diameter (mm)
fan_screw_hole_diameter = fan_get_attribute( fan_spec, "screw_hole_diameter" );

// Side of mounting holes center square (mm)
fan_screw_hole_positions = fan_get_screw_positions( fan_spec );

// Thickness of frame structure (mm)
fan_frame_thickness = fan_get_attribute( fan_spec, "frame_thickness" );

// Side of air-hole cutout (mm)
fan_air_hole_side_to_side = fan_get_attribute( fan_spec, "air_hole_side" );

// Diameter of air-hole cutout (mm)
fan_air_hole_diameter = fan_get_attribute( fan_spec, "air_hole_diameter" );

/* [Baffle] */

// Thickness for the baffle face (mm)
baffle_thickness = 3; // [2:0.1:5]

baffle_area = fan_frame_area;
baffle_size = concat( baffle_area, baffle_thickness );

// Thickness for the baffle sides around fan (mm per side)
baffle_extra_side   = 3; // [2:0.1:5]

// Height of baffle sides sides around fan (mm)
baffle_extra_height = 5; // [1:0.1:5]

// Baffle total area/size represent maximal area/size of the baffle excluding attachments
baffle_total_area   = fan_frame_area + 2*[baffle_extra_side,baffle_extra_side];
baffle_total_size   = concat( baffle_total_area, baffle_thickness+baffle_extra_height );

// Decorative radius around baffle (mm)
baffle_radius = 2; // [0:0.5:5]

// Air hole at fan outlet matching slant (degrees)
baffle_air_hole_slant = 80; // [70:5:90]

// Oversize screw holes assuming fan guard (alternative is tight and countersunk)
baffle_screw_hole_oversize = true;
baffle_screw_hole_diameter = baffle_screw_hole_oversize ? fan_screw_hole_diameter+0.35 : fan_screw_hole_diameter;
baffle_screw_hole_countersink = !baffle_screw_hole_oversize;

// Extra space between fan and baffle (mm per side)
baffle_fan_spacing_side = 0.4; // [0.1:0.1:1]

// Decorative radius in space between fan and baffle (mm)
baffle_fan_spacing_radius = 0.5; // [0:0.1:2]

// Extra space cut out baffle for fan
baffle_overfit_min  = max( 0, min( baffle_fan_spacing_side, baffle_extra_side) );
baffle_overfit_area = [ fan_frame_side+2*baffle_overfit_min, fan_frame_side+2*baffle_overfit_min ];
baffle_overfit_size = concat( baffle_overfit_area, baffle_total_size.z - baffle_thickness );

// Thickness of raised areas (mm per side)
baffle_effective_side_thickness = baffle_extra_side - baffle_overfit_min;

// Side cutout height (mm)
baffle_side_cutout_height = 3; // [0:0.1:5]

// Side cutout width (percentage of side)
baffle_side_cutout_percentage = 60; // [0:5:75]

// Minimum height of side
baffle_side_height_min = max( baffle_extra_height - baffle_side_cutout_height, 0 ) + baffle_thickness;

// Cutout
baffle_side_cutout_area = [ baffle_side_cutout_percentage/100*baffle_total_area.x, baffle_total_area.y/2 ];
baffle_side_cutout_size = concat( baffle_side_cutout_area, min( baffle_extra_height, baffle_side_cutout_height ) );

// Mini brace size (mm)
baffle_mini_brace_size = 2.5; // [0:0.5:4]

/* [Grill] */

// Create a grill
grill_add = false;

// Layout grills of different fan sizes geometrically similar
grill_normalize = false;

// Thickness of grill (mm)
grill_thickness = min( baffle_thickness, 2.0 ); // [1:0.1:5];

// Width of the lines of the grill (mm)
grill_line_width = 2.2; // [1:0.1:5];

// Distance between concentric circles (mm)
grill_step_distance = 11.6; // [5:0.2:20]

// Number of supporting ribs
grill_ribs = 6; // [4:1:8]

// Starting angle of rib pattern - polar standard (degrees)
grill_rib_start_angle = 105; // [0:5:360]

/* [Machine Locations and Sizes] */

// N.B.: These distances relative to the bottom catch are generally
//       measured from the "center" of the bottom catch which
//       is the intersection of the mid-points of the slots with
//       the center of the tab.

// Position of bottom catch (our machine origin)
machine_bottom_catch_center = [ 0, 0, 0 ];

// Space between drive cage and baffle side (mm)
machine_spacing_cage_to_baffle = 1;

// Cage screw hole diameter (mm) (larger than 15/64", smaller than 1/4")
machine_cage_screw_hole_diameter = 6;

// Distance from fan bottom to machine needed to accommodate tab - effectively the height of the bottom catch interface plus a little (mm)
machine_catch_to_fan_frame_bottom = ceil( bottom_catch_get_above_size().z + 0.2 );

// Distance from fan front to bottom catch center - moves fan backward and forward, but very limited (mm)
machine_catch_to_fan_front = fan_frame_width/2;

// Distance from drive cage bottom to middle of slots of catch (mm)
machine_cage_bottom_to_catch_mid = 44.0;

// Distance to cage screw hole center above top of catch (mm)
machine_cage_screw_hole_to_catch_top = 111.5;

// Distance to cage screw hole center from mid-catch slots (mm)
machine_cage_screw_hole_to_catch_front = -7.0;

// Inset size between cage bottom to cage screw (mm)
machine_cage_screw_hole_inset = 1.2; // [0:0.1:2]

// Position of cage relative to machine reference point
machine_cage_screw_hole_center = [ machine_cage_bottom_to_catch_mid, machine_cage_screw_hole_to_catch_top, machine_cage_screw_hole_to_catch_front ];

// Distance to center of top tabs from mid-catch slots (mm)
machine_tabs_to_catch_mid = -5.7;

// Distance to center of top tabs above top of catch (mm)
machine_tabs_to_catch_top = 135.0;

// Distance to center of top tabs from mid-catch slots (mm)
machine_tabs_to_catch_front = 26.0;

// Position of mid-point of the two top insertion tabs from machine origin
machine_tabs_center = [ machine_tabs_to_catch_mid, machine_tabs_to_catch_top, machine_tabs_to_catch_front ];

// Mapping of machine position to build position
function machine_to_model( p ) = [ p.x + (baffle_total_area.x/2 - machine_cage_screw_hole_center.x) + machine_spacing_cage_to_baffle,
                                   p.y - baffle_overfit_size.y/2 - machine_catch_to_fan_frame_bottom,
                                   p.z + baffle_thickness + machine_catch_to_fan_front ];

/* [Side Cage Arm] */

// Size of arm fastener
cage_arm_fastener_size = "M6"; // [ "M6", "UNC-#12", "M5" ]

// Fastener specification
cage_arm_fastener_spec = fastener_get_spec(cage_arm_fastener_size);

// Extra diameter around the arm's mating hole (mm)
cage_arm_extra_diameter = 0;  // [0:0.5:4]

// Extra width (thickness) of arm (mm)
cage_arm_extra_width = 0; // [0:0.5:4]

// Tolerance to add to cage arm hole's diameter (mm)
cage_arm_hole_tolerance = 0.4; // [ 0:.1:1]

// Decorative adjustment of upper arm (to avoid side carve-out) (mm)
cage_arm_upper_arm_adjust = 12; // [ 0:20 ]

// Amount to puff out arm so that it reaches drill hole (mm)
cage_arm_puff = machine_spacing_cage_to_baffle + machine_cage_screw_hole_inset;

// Diameter of puff out arm that presses against the cage hole (mm)
// N.B.: less than 3mm to avoid the fold in the case metal
cage_arm_puff_diameter = machine_cage_screw_hole_diameter + 2*2.25;

// Calculated diameter of the circular part of the arm (mm)
cage_arm_diameter = cage_arm_extra_diameter +
                      max( fastener_nominal_circular_diameter( "M6" ) + 1, cage_arm_puff_diameter );

// Calculated width of the arm (mm)
cage_arm_width = baffle_effective_side_thickness + cage_arm_extra_width;

// Length of space behind arm to carve out to allow for nut (mm)
cage_arm_rear_carveout = fastener_get_attribute( "M6", "nut_thickness" ) * 2;

// Mid-center of the cage arm hole is calculated from cage hole position less spacing and half-width
function cage_arm_screw_mate_center() = machine_to_model( machine_cage_screw_hole_center ) - [ machine_spacing_cage_to_baffle + cage_arm_width/2, 0, 0 ];

/* [Top Tabs] */

// Base width of the tab (mm)
tab_base_width = 28; // [ 15:60 ]

// Left/Right balance of the base (%)
tab_base_balance = 35; // [ 10:50 ]

// Degree of arm exponential curvature
tab_curvature = 10; // [1:200]

// Base width of the stopper (mm)
tab_stopper_width = 20; // [ 10:50 ]

// show_fan_model: show fan model in position on mount or alone
module show_fan_model(transparency=0.25) {
  color( "black", transparency )
    translate( [0, 0, show_selection != "fan" ? +baffle_thickness+.1 : 0 ] )
      fan_model( fan_spec );
} // end show_fan_model

// show_machine: show machine origin, planes, and attachment element positions
module show_machine(axis=false,transparency=0.25) {
  // Show the machine origin planes
  if( axis )
    color( "yellow", transparency/3 )
      translate( machine_to_model( machine_bottom_catch_center ) ) {
	plane_thickness = 0.1;

	cube( [ plane_thickness,  3*fan_frame_side, 2*fan_frame_width ], center=true );
	cube( [ 2*fan_frame_side, 3*fan_frame_side, plane_thickness   ], center=true );
	cube( [ 2*fan_frame_side, plane_thickness,  2*fan_frame_width ], center=true );
      }

  // Show the cage screw position as a sphere
  color( "black", transparency )
    translate( machine_to_model( machine_cage_screw_hole_center ) + [cage_arm_puff-machine_spacing_cage_to_baffle, 0, 0 ] )
      sphere( d=machine_cage_screw_hole_diameter );

  // Show top catch slot positions
  color( "black", transparency )
    translate( machine_to_model( machine_tabs_center ) )
      top_catch_fitting( height=0, tang_style="debug", box_style="debug" );

  // Show bottom catch tab/slots position
  color( "black", transparency )
    translate( machine_to_model( machine_bottom_catch_center ) )
      rotate( [ 90, 180, 0 ] )
        bottom_catch_fitting( height=0, tang_style="debug", tab_style="debug" );
} // end show_machine

// foreach_side: rotate thru 90 degrees 0, 1, 2, 3 in mask
module foreach_side( mask ) {
  for( i = mask )
    rotate( [ 0, 0, 90*i ] )
      children();
} // end foreach_side

// beveled_cube: cube with 45 degree sides
module beveled_cube( size ) {
  base = [ size.x+2*size.z, size.y ];
  linear_extrude( height=size.z, scale=[size.x/base.x, size.y/base.y ] )
    square( base, center=true );
} // end beveled_cube

// mini_brace:
//
// Circular side brace for parts on upper/low structures.
//
module mini_brace( size, top_or_bottom, left_or_right ) {
  assert( top_or_bottom == "top" || top_or_bottom == "bottom" );
  assert( left_or_right == "left" || left_or_right == "right" );

  width = baffle_extra_side;

  translate( [ 0,
               top_or_bottom == "top" ? baffle_total_area.y/2 - width/2 : - baffle_total_area.y/2 + width/2,
               baffle_total_size.z] )
    rotate( [ 90, 0, left_or_right == "left" ? 180 : 0 ] )
      linear_extrude( height = width, center=true )
	difference() {
	  square( size );
	  translate( [size, size ] ) circle( size );
	}
} // end mini_brace

// bottom_catch_attach:
//
// Attach the bottom catch to square part of the baffle.
//
module bottom_catch_attach() {
  // The machine build origin is the tab center/tab bottom/mid slot position of the catch on the build plate
  machine_model_origin = machine_to_model( machine_bottom_catch_center );

  // Map center of catch to machine positioning
  catch_above_size  = bottom_catch_get_above_size();
  catch_below_size  = bottom_catch_get_below_size();
  catch_width       = catch_above_size.y;
  catch_height      = machine_catch_to_fan_frame_bottom;

  // Create the catch
  //
  // All this complex code is to get the shape to exactly match the
  // baffle frame's face. Otherwise, we just move the created
  // catch into position.
  //
  translate( machine_model_origin + [ 0, catch_height, 0 ] )
    rotate( [ 90, 180, 0 ] )
      // N.B.: catch is created upside down and must be rotated
      intersection() {
	// Position the midpoint of the catch (the axis running thru the slots) at the midpoint of the fan width
	slot_to_baffle_face = machine_model_origin.z;

	// Taper_start is the position of the edge of the catch's flat mating surface nearest face of baffle
	taper_start_to_baffle_face    = slot_to_baffle_face - catch_width/2;
	taper_start_above_baffle_edge = catch_height - (baffle_total_size.y - baffle_overfit_size.y)/2;

	// Trig: the width the catch needs to be just to meet the slope
	catch_width_meeting_baffle_edge = catch_width + 2 * catch_height * (taper_start_to_baffle_face / taper_start_above_baffle_edge);

        max_height_depth = max(catch_height,catch_below_size.z);
        translate( [0,0,+max_height_depth] )
	  cube( [catch_above_size.x, 2*slot_to_baffle_face, 2*max_height_depth], center=true );
	bottom_catch_fitting(height=catch_height,width=catch_width_meeting_baffle_edge, base_style="trap-front", tang_style="complex", tab_style="flared-hole" );
      }

  // Add braces
  translate( [ machine_model_origin.x - catch_above_size.x/2, 0,0 ] ) mini_brace( baffle_mini_brace_size, "bottom", "left" );
  translate( [ machine_model_origin.x + catch_above_size.x/2, 0,0 ] ) mini_brace( baffle_mini_brace_size, "bottom", "right" );

} // end bottom_catch_attach

// top_catch_attach:
//
// Attach the bottom catch to square part of the baffle.
//
module top_catch_attach() {
  // The machine's tab center position
  catch_center = machine_to_model( machine_tabs_center );

  // If the tabs are going up...
  if( catch_center.y > baffle_total_size.y/2 ) {
    // Two tab arms with tangs
    {
      slot_size    = top_catch_get_slot_size();
      slot_centers = top_catch_get_slot_centers();
      tab_balance  = [ tab_base_balance, 100-tab_base_balance ];

      for( i = [0:1] ) {
	// where to attach this tab horizontally and vertically on the baffle
	baffle_attach_top = concat( [ catch_center.x, baffle_total_size.y/2 ] + [ slot_centers[i].x, 0 ], 0 );

	// Get the tip & tang to fit thru together, resting toward top
	// of the slot, just past metal, with a little play
	tip_profile  = [ slot_size.x - 1.5, slot_size.y/2 ];
	center_delta = [ +0.3, +slot_size.y/4 - 0.5 ];
	tang_profile = [ 80, 30, 70 ];

	// base width is fully adjustable, and base height uses the minimum side height
	base_profile = [ tab_base_width, baffle_side_height_min ];

	// center_size places the center of the tip of the arm at exactly the mid-point of the entrance to the slot
	center_size  = [ catch_center.z - baffle_attach_top.z, catch_center.y - baffle_attach_top.y + tip_profile.y/2 ];

	translate( baffle_attach_top )
	  rotate( [ -90, 270, 0 ] )
	    arm_tapered( center_size + center_delta, base_profile, tip_profile, tang_profile, curvature=tab_curvature, balance=tab_balance[i] );
      }
    }

    // Middle stopper is between the two arms
    {
      stopper_size   = top_catch_get_box_size();
      stopper_center = top_catch_get_box_center();

      // where to attach the stopper horizontally and vertically on the baffle
      baffle_attach_top = concat( [ catch_center.x, baffle_total_size.y/2 ] + [ stopper_center.x, 0 ], 0 );

      // delta/tip sizing allow a little play between stopper and case
      center_delta = [ stopper_size.z - 0.5, 0 ];
      tip_profile  = [ stopper_size.x, stopper_size.y ] - [ 0.75, 0 ];

      // base width is fully adjustable, and base height uses the minimum side height
      base_profile = [ tab_stopper_width, baffle_side_height_min ];

      // center_size places the center of the tip of the arm at exactly the mid-point of the entrance to the slot
      center_size  = [ catch_center.z - baffle_attach_top.z, catch_center.y - baffle_attach_top.y + tip_profile.y/2 ];

      translate( baffle_attach_top )
	rotate( [ -90, 270, 0 ] )
	  arm_tapered( center_size + center_delta, base_profile, tip_profile, curvature=tab_curvature );
     }
  }
  else
    echo( "Top tabs not possible!!!" );
} // end top_catch_attach

// cage_arm_attach:
//
// Attach the arm at that provides the hole to the cage's screw bottom hole.
//
module cage_arm_attach() {
  // Build so that screw hole in arm is at center
  cage_screw_mate_center = cage_arm_screw_mate_center();

  // Arm and tip
  baffle_tip                      = [ baffle_total_size.x/2, baffle_total_size.y/2, 0 ];
  baffle_tip_to_cage_screw_center = baffle_tip - cage_screw_mate_center;

  // Is the arm hole actually over the fan frame
  is_central = !(cage_screw_mate_center.y + cage_arm_diameter/2 >= baffle_tip.y);

  // Create the arm
  translate( cage_screw_mate_center )
    rotate( [0,+90,0] ) {
      linear_extrude( height = cage_arm_width, center = true ) {
	p1 = [-baffle_tip_to_cage_screw_center.z, baffle_tip_to_cage_screw_center.y ];
	if( !is_central ) {
	  tp   = tangent_point_on_circle( p1, [0,0], cage_arm_diameter/2, "closest-x" );
	  d    = tp-p1;
	  a    = atan2( d.y, d.x );
	  ap   = atan2( -d.x, d.y );
	  o    = tp - cage_arm_diameter*[cos(ap),sin(ap)];
	  mult = (o - p1).x * d.y / d.x;
          dy   = (o - mult * [cos(a),sin(a)]).y;
	  p2   = [ p1.x, abs(dy - p1.y) > baffle_total_size.y/2 ? p1.y - baffle_total_size.y/2 : dy ];

	  arm_to_circle( p1, p2 - [ 0, cage_arm_upper_arm_adjust ], [0,0], cage_arm_diameter/2 );
	}
	else {
	  p2 = p1 - [ 0, 2*(baffle_tip.y - cage_screw_mate_center.y) ];

	  arm_to_circle( p1, p2, [0,0], cage_arm_diameter/2 );
	}
      }

      // Puff out the arm so that it is flush against the cage
      if( cage_arm_puff > 0 )
        translate( [ 0,0, cage_arm_width/2 ] )
          cylinder( h=cage_arm_puff, d=cage_arm_puff_diameter );
    }

  // Add a brace to the side of the arm
  if( !is_central )
    translate( [ baffle_tip.x - cage_arm_width, 0,0 ] ) mini_brace( baffle_mini_brace_size, "top", "left" );
} // end cage_arm_attach

// cage_arm_hole_deletion:
//
// Hole in cage arm.
//
module cage_arm_hole_deletion() {
  // Drill the hole
  translate( cage_arm_screw_mate_center() - [SMIDGE,0,0] )
    rotate( [0,+90,0] )
      cylinder( h = cage_arm_width+2*cage_arm_puff+4*SMIDGE, d=machine_cage_screw_hole_diameter+cage_arm_hole_tolerance, center=true );

  // Delete enough extra space for nut
  translate( cage_arm_screw_mate_center() - [cage_arm_rear_carveout + cage_arm_width/2 + SMIDGE, 0, 0 ] )
    rotate( [0,+90,0] )
      cylinder( d=cage_arm_diameter-0.5, h=cage_arm_rear_carveout );
} // end cage_arm_hole_deletion

// air_hole_deletion:
//
// Air-hole in the baffle - a rounded square (squircle-like) shape.
//
module air_hole_deletion() {
  function fan_air_hole_scaling() = 1/sin(baffle_air_hole_slant);

  $fn = 4*$fn;
  translate( [0,0,-SMIDGE] )
    linear_extrude( height=baffle_thickness+2*SMIDGE, scale=1/fan_air_hole_scaling() )
      scale( [ fan_air_hole_scaling(), fan_air_hole_scaling() ] )
	intersection() {
	  circle( d=fan_air_hole_diameter );
	  square( fan_air_hole_side_to_side, center=true );
	}
} // end air_hole_deletion

// replicate_n: Replicate elements at a <distance> from the origin, rotated <theta> degrees
module replicate_n( n, distance = 0 ) {
  theta = 360/n;
  for( i = [0:n-1] )
    translate( concat( polar_to_cartesian( theta*i, distance ), 0 ) )
      rotate( [ 0, 0, theta*i ] )
        children();
} // end replicate_n

// fan_grill:
//
// Create a grill for a fan
//
module fan_grill( fan_spec, thickness, convexity=10 ) {
  fan_area = fan_get_attribute( fan_spec, "area" );

  // Normalize resemblance to 80-mm fan
  step_distance = grill_normalize ? (grill_step_distance * max( fan_area ) / 80 ) : grill_step_distance;

  // Concentric circle parameters
  circle_count        = ceil( min( fan_area ) / 2 / step_distance );
  circle_start_radius = step_distance/2;

  // Ribs parameters
  rib_max_length = norm( fan_area ) / 2;

  linear_extrude( height=thickness, convexity=convexity ) {
    intersection() {
      // Delete any overflow
      square( fan_area, center=true );

      union() {
        // Concentric circles
        for( i = [1:circle_count] )
          line_circular( circle_start_radius + (i-1) * step_distance, grill_line_width );

        // Ribs
        replicate_n( grill_ribs )
          line_ray( grill_rib_start_angle, circle_start_radius, rib_max_length, grill_line_width );
      }
    }
  }
} // end fan_grill

// baffle:
//
// Creates the squarish baffle with all its attachments.
//
module baffle() {
  difference() {
    union() {
      difference() {
	union() {
	  difference() {
	    // Baffle frame
	    rounded_side_cube_upper( baffle_total_size, baffle_radius );

	    // Mostly decorative beveled cutback on 3-sides of frame
	    if( baffle_side_cutout_percentage > 0 && baffle_side_cutout_size.z > 0 ) {
	      h = fan_frame_width;
	      foreach_side( [0,1,3] )
		translate( [0,baffle_side_cutout_size.y/2,baffle_total_size.z+h+SMIDGE] )
		  rotate( [180,0,0] )
		    beveled_cube( baffle_side_cutout_size + [2*SMIDGE,2*SMIDGE,h+SMIDGE] );
	     }
	  }

	  // Attach the cage arm
	  cage_arm_attach();

	  // Attach the bottom catch interface
	  bottom_catch_attach();

	  // Attach the top catch interface
	  top_catch_attach();
	}

	// Air-hole cutout
	air_hole_deletion();
      }

      // Add the grill after air-hole deletion and before body/hole deletion
      if( grill_add )
	fan_grill( fan_spec, grill_thickness );
    }

    // Slightly-oversized fan mount cutout
    {
      h = fan_frame_width;
      translate( [0,0,baffle_total_size.z] )
	rotate( [180,0,0] )
          translate( [-baffle_overfit_size.x/2, -baffle_overfit_size.y/2, -h-SMIDGE ] )
	    rounded_top_cube( baffle_overfit_size + [ -SMIDGE, -SMIDGE, h+2*SMIDGE ], baffle_fan_spacing_radius );
    }

    // Fan mounting holes (possibly countersunk)
    for( p = fan_screw_hole_positions )
      screw_hole( p, baffle_thickness, baffle_screw_hole_diameter, baffle_screw_hole_countersink, 1.5, false );

    // Arm hole
    cage_arm_hole_deletion();
  }
} // end baffle

// hardware:
//
// Generate mounting hardware (bolt, nut, and a couple washers).
//
module hardware() {
  // Get the metric fastener size
  spec = cage_arm_fastener_spec;

  // Placement spacing
  spacing = fastener_get_attribute( spec, "washer_outer_diameter" ) / sqrt(1.8);

  // distribute: Place an element at a <distance> from the origin, rotated <rotation> degrees
  module distribute( rotation=0, distance = spacing )
  {
    //if( rotation == 90 )
    rotate( rotation ) translate([distance,0,0]) children();
  } // end distribute

  // Bolt
  distribute( 0 ) {
    length = cage_arm_puff + cage_arm_width + fastener_get_attribute( spec, "nut_thickness" ) + fastener_get_attribute( spec, "washer_thickness" ) + 3;
    echo( "Suggested Bolt -> ", fastener_get_attribute( spec, "name" ) ," of Length (mm) > ", ceil(length) );
    shank  = machine_spacing_cage_to_baffle/2;
    fastener_hex_bolt( spec, length, shank );
  }

  // Nut
  distribute( 90 ) fastener_hex_nut( spec );

  // Washer
  distribute( 180 ) fastener_washer( spec );

  // Washer
  distribute( 270 ) fastener_washer( spec );
} // end hardware

// mount:
//
// The baffle with all its attachments.
//
module mount() {
  baffle();
} // end mount

$fn = 60;

if( show_selection == "hardware" )
  hardware();
else if( show_selection == "fan" )
  show_fan_model();
else { // shows mount
  mount();
  if( show_selection == "mount/fan" )
    show_fan_model();
  if( show_selection == "mount/machine" )
    show_machine(axis=false);
  if( show_selection == "mount/machine/axis" )
    show_machine(axis=true);
  //top_catch_attach();
}
