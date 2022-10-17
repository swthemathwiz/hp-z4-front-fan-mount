//
// Copyright (c) Stewart H. Whitman, 2022.
//
// File:    hp-z4-catch-top.scad
// Project: HP Z4 G4 Fan Mount
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    HP Z4 G4 Bottom Front Fan Cage Catch Definitions
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
top_slot_separation = 25;
top_slot_centers = (top_slot_separation + top_slot_size.x)/2 * [ [ 1, 0 ], [ -1, 0 ] ];

// Fitting (tolerance) properties:
//
top_tang_multiplier = 0.97;

module top_catch_tang(style) {
  // debug: just cubes (for fitting)
  if( style == "debug" ) {
    rounded_side_cube_upper( top_slot_size, radius=0 );
  }
  // full: straight just scaled by percentage (for fitting)
  else if( style == "full" ) {
    rounded_side_cube_upper( top_tang_multiplier * top_slot_size, top_catch_radius/3);
  }
  else {
    assert( false, "top_catch_tang: style unknown!" );
  }
} // end top_catch_tang

module top_catch_base( style, height ) {
  if( height <= 0 ) {
    ;
  }
  // full: straight just scaled by percentage
  else if( style == "full" ) {
    rounded_side_cube_upper( concat( top_catch_size, height ), top_catch_radius );
  }
  else {
    assert( false, "top_catch_base: style unknown!" );
  }
} // end top_catch_base

module top_catch_fitting(height=3,base_style="full",tang_style="full") {
  assert( is_num(height) && height >= 0 );

  difference() {
    union() {
      // Base
      top_catch_base( base_style, height );

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

$fn = 32;
top_catch_fitting( height=2.4, base_style="full", tang_style="full");
