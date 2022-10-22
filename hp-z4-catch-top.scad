//
// Copyright (c) Stewart H. Whitman, 2022.
//
// File:    hp-z4-catch-top.scad
// Project: HP Z4 G4 Fan Mount
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    HP Z4 G4 Top Front Fan Cage Catch Definitions
//

include <smidge.scad>;
include <rounded.scad>;

// Catch:
//
// Catch refers to the top area of the "mound". Radius
// is nominal.
//
// top_catch_size: length, width
top_catch_size = [ 51, 10.5 ];
top_catch_radius = 1;

// Slot:
//
// Two slots, centered atop the long axis and positioned
// symmetrically about the vertical center. Depth is space
// below mount.
//
// top_slot_size: length, width, depth
top_slot_size = [ 11, 6, 11 ];
top_slot_separation = 24.5;
top_slot_centers = (top_slot_separation + top_slot_size.x)/2 * [ [ 1, 0 ], [ -1, 0 ] ];

// Box:
//
// Not really part of the catch, this is the depression
// between the slots in the center of the slots.
//
top_box_size = [ 11, top_slot_size.y, 3.25 ];
top_box_center = [ 0, 0 ];
top_box_thickness = 1;

// Fitting (tolerance) properties:
//
top_tang_multiplier = 0.97;

// top_catch_rounded_hollow: rounded hollow cube
module top_catch_rounded_hollow( size, radius, thickness ) {
echo( size.z );
  difference() {
    rounded_side_cube_upper( size, top_catch_radius/3);
    translate( [0,0,-SMIDGE] )
      rounded_side_cube_upper( size - 2 * [top_box_thickness, top_box_thickness, -SMIDGE ], top_catch_radius/3 );
  }
} // end top_catch_rounded_hollow

module top_catch_tang(style) {
  size = top_tang_multiplier * top_slot_size;

  // none: nothing
  if( style == "none" ) {
    ;
  }
  // debug: just cubes (for fitting)
  else if( style == "debug" ) {
    rounded_side_cube_upper( top_slot_size, radius=0 );
  }
  // full: straight just scaled by percentage (for fitting)
  else if( style == "full" ) {
    top_catch_rounded_hollow( size, top_catch_radius/3, top_box_thickness );
  }
  else {
    assert( false, "top_catch_tang: style unknown!" );
  }
} // end top_catch_tang

module top_catch_base( style, height ) {
  size = concat( top_catch_size, height );

  if( style == "none" || height <= 0 ) {
    ;
  }
  // full: straight just scaled by percentage
  else if( style == "full" ) {
    rounded_side_cube_upper( size, top_catch_radius );
  }
  // layout: test out the distance to cage
  else if( style == "layout" ) {
    rounded_side_cube_upper( size, top_catch_radius );

    // Side prong to cage
    {
      catch_center_to_cage = 44 + 5.7;
      translate( [-catch_center_to_cage/2,0,0] )
	rounded_side_cube_upper( [catch_center_to_cage, 3, size.z], 0 );
    }
    // Down prong to bottom level
    {
      catch_center_to_bottom = 135;
      translate( [0,+catch_center_to_bottom/2,0] )
        rounded_side_cube_upper( [3, catch_center_to_bottom, size.z+top_box_size.z], 0 );
    }
  }
  else {
    assert( false, "top_catch_base: style unknown!" );
  }
} // end top_catch_base

module top_catch_box(style) {
  size = top_box_size;

  // none: nothing
  if( style == "none" ) {
    ;
  }
  // debug: just flat panel
  else if( style == "debug" ) {
    translate( [0,0,size.z] )
      rounded_side_cube_upper( [ size.x, size.y, 1 ], radius=0 );
  }
  // full: just a box
  else if( style == "full" ) {
    top_catch_rounded_hollow( size, top_catch_radius/3, top_box_thickness );
  }
  else {
    assert( false, "top_catch_box: style unknown!" );
  }
} // end top_catch_box

module top_catch_fitting(height=3,base_style="full",tang_style="full",box_style="full") {
  assert( is_num(height) && height >= 0 );

  difference() {
    union() {
      // Base
      top_catch_base( base_style, height );

      // Box
      translate( concat( top_box_center, height ) )
	top_catch_box( box_style );

      // Slot projection
      for( p = top_slot_centers )
        translate( concat( p, height ) )
          top_catch_tang( tang_style );
    }
  }
} // end top_catch_fitting

// top_catch_get_size, top_catch_get_below_size:
//
// Returns [ length, width, height above/below case ]
//
function top_catch_get_size()         = concat( top_catch_size, top_slot_size.z );
function top_catch_get_slot_size()    = top_slot_size;
function top_catch_get_slot_centers() = top_slot_centers;
function top_catch_get_box_size()     = top_box_size;
function top_catch_get_box_center()   = top_box_center;

$fn = 32;
//top_catch_fitting( height=3, base_style="full", tang_style="full");
top_catch_fitting( height=3, base_style="layout", tang_style="full", box_style="full");
