//
// Copyright (c) Stewart H. Whitman, 2022-2024.
//
// File:    hp-z4-catch-bottom.scad
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
// bottom_catch_size: length, width
bottom_catch_size = [ 72, 10.5 ];
bottom_catch_radius = 1;

// Slot:
//
// Two slots, centered atop the long axis and positioned
// symmetrically about the vertical center. Depth is space
// below mount.
//
// bottom_slot_size: length, width, depth
bottom_slot_size = [ 19.25, 3, 8 ];
bottom_slot_separation = 26;
bottom_slot_centers = (bottom_slot_separation + bottom_slot_size.x)/2 * [ [ 1, 0 ], [ -1, 0 ] ];

// Tab:
//
// Tab is finished with metal folded over so it
// is wider at the bottom than the top. Thickness
// is nominal (but not insignificant because of the
// folds). Positioned at the center of long axis, but,
// pushed to the side of the slots so that it forms
// a mating surface.
//
// tab_size: length at bottom, thickness, height
bottom_tab_size = [ 11.5, 1.5, 11.5 ];
bottom_tab_width_at_top = 9;
bottom_tab_center = [ 0, -bottom_slot_size.y/2 ];

// Fitting (tolerance) properties:
//
bottom_tang_multiplier = 0.97;
bottom_tang_slant_scale = [ 0.9, 0.8 ];
bottom_tab_multiplier = 1.05;
bottom_tab_width_overage = 2.0;

// bottom_catch_tang:
//
// The tangs are inserted it the slots of catch on the machine.
//
module bottom_catch_tang( style ) {
  // Overall size of the tang
  size = [ bottom_tang_multiplier * bottom_slot_size.x, bottom_tang_multiplier * bottom_slot_size.y, (style == "full") ? bottom_tang_multiplier * bottom_slot_size.z : 0.9*bottom_slot_size.z ];

  if( style == "none" ) {
    ;
  }
  // debug: just cubes (for debugging)
  else if( style == "debug" ) {
    rounded_side_cube_upper( bottom_slot_size, radius=0 );
  }
  // full: straight just scaled by percentage (for fitting)
  else if( style == "full" ) {
    rounded_side_cube_upper( size, bottom_catch_radius/3);
  }
  // slant: slanted on 4-sides
  // complex: straight for a little, then slanted on 4-sides
  else if( style == "slant" || style == "complex" ) {
    complex_straight_height = (style == "complex") ? 2.0 : 0;
    assert( size.z > complex_straight_height );

    if( complex_straight_height > 0 )
      rounded_side_cube_upper( [size.x,size.y,complex_straight_height], bottom_catch_radius/3);

    translate( [ 0, 0, complex_straight_height] )
      linear_extrude( height = size.z-complex_straight_height, scale=bottom_tang_slant_scale )
	rounded_side_square( [size.x,size.y], bottom_catch_radius/3, center=true );
  }
  else {
    assert( false, "bottom_catch_tang: style unknown!" );
  }
} // end bottom_catch_tang

// bottom_catch_bottom_tab_deletion:
//
// The machine's vertical tab is inserted into this tab cutout.
//
module bottom_catch_bottom_tab_deletion( style, height ) {
  size = bottom_tab_multiplier * bottom_tab_size;

  // debug: just cubes (for debugging)
  if( style == "debug" ) {
    rounded_side_cube_upper( bottom_tab_size, radius=0 );
  }
  else if( style == "none" || height <= 0 ) {
    ;
  }
  // full: fully cutout
  else if( style == "full" ) {
    width = bottom_catch_size.x;
    translate( concat( bottom_tab_center - [0,width/2], -SMIDGE ) )
      rounded_side_cube_upper( [ size.x, width, size.z+2*SMIDGE ], bottom_catch_radius/3 );
  }
  // hole: a hole
  else if( style == "hole" ) {
    width = bottom_tab_width_overage;
    translate( concat( bottom_tab_center - [0,width/2], -SMIDGE ) )
      rounded_side_cube_upper( [ size.x, width, size.z+2*SMIDGE ], bottom_catch_radius/3 );
  }
  // tapered-hole: a hole with a taper in width direction
  else if( style == "tapered-hole" ) {
    width        = bottom_tab_width_overage;
    scale_factor = 0.85;

    translate( concat( bottom_tab_center - [0,width/2], -SMIDGE ) )
      linear_extrude( height = size.z+2*SMIDGE, scale=[ 1/scale_factor, 1.0] )
	rounded_side_square( [ size.x * scale_factor, width ], bottom_catch_radius/3, center=true );
  }
  // flared-hole: a hole with a taper in both directions
  else if( style == "flared-hole" ) {
    width        = bottom_tab_width_overage;
    scale_factor = 0.85;

    translate( concat( bottom_tab_center - [0,width/2], -SMIDGE ) )
      linear_extrude( height = size.z+2*SMIDGE, scale=[ 1/scale_factor, 1.0 ] )
        rounded_side_square( [ size.x * scale_factor, width ], bottom_catch_radius/3, center=true );

    // Flare wider at near tab entry point
    flare_height = size.z/3;
    flare_factor = 2.0;
    flare_start_size_x = size.x - size.x * (1 - scale_factor) * (flare_height / size.z);

    translate( concat( bottom_tab_center - [0,width/2], size.z-flare_height-SMIDGE ) )
      linear_extrude( height = flare_height+2*SMIDGE, scale=[ 1/scale_factor, flare_factor] )
        rounded_side_square( [ flare_start_size_x, width ], bottom_catch_radius/3, center=true );
  }
  else {
    assert( false, "bottom_catch_bottom_tab_deletion: style unknown!" );
  }
} // end bottom_catch_bottom_tab_deletion

// bottom_catch_base:
//
// The catch structure matches the machine's catch surface
//
module bottom_catch_base( style, height, width ) {
  size = [ bottom_catch_size.x, width, height ];

  if( style == "none" || height <= 0 || width <= 0 ) {
    ;
  }
  // full: straight just scaled by percentage
  else if( style == "full" ) {
    rounded_side_cube_upper( size, bottom_catch_radius );
  }
  // layout: test layout the distance to cage / front
  else if( style == "layout" ) {
    rounded_side_cube_upper( size, bottom_catch_radius );

    // Side prong to cage
    {
      catch_center_to_cage = 44;
      translate( [-catch_center_to_cage/2,0,0] )
	rounded_side_cube_upper( [catch_center_to_cage, 3, size.z], 0 );
    }
    // Rear prong to top catch layout dropdown
    {
      // to meet up with top catch layout distance actual built base height top catch
      catch_center_to_front = (26.0 + 3.25) - (3.25 + 2.7);
      catch_center_to_mid   = -5.7;
      translate( [-catch_center_to_mid,-catch_center_to_front/2,0] )
	rounded_side_cube_upper( [3, catch_center_to_front, size.z], 0 );
    }
  }
  // sloped: sides are sloped at 45 degrees
  else if( style == "sloped" ) {
    front_angle = 45;
    front_expansion = sin(front_angle)*size.z;

    expanded_size = [ size.x, size.y ] + 2*[front_expansion,front_expansion];
    linear_extrude( height=size.z, scale = [ size.x/expanded_size.x, size.y/expanded_size.y ]  )
      rounded_side_square( expanded_size, bottom_catch_radius, center=true );
  }
  // trap-both:
  else if( style == "trap-both" ) {
    assert( size.y >= bottom_catch_size.y );

    expanded_size = [ size.x, size.y ];
    linear_extrude( height=size.z, scale = [ bottom_catch_size.x/expanded_size.x, bottom_catch_size.y/expanded_size.y ]  )
      rounded_side_square( expanded_size, bottom_catch_radius, center=true );
  }
  // trap-front:
  else if( style == "trap-front" ) {
    assert( size.y >= bottom_catch_size.y );

    delta = (size.y-bottom_catch_size.y)/2;

    intersection() {
      translate( [0,+delta/2,0] )
	rounded_side_cube_upper( size - [ 0, delta, 0 ], bottom_catch_radius );

      expanded_size = [size.x, size.y];
      linear_extrude( height=size.z, scale = [ bottom_catch_size.x/expanded_size.x, bottom_catch_size.y/expanded_size.y ]  )
	rounded_side_square( expanded_size, bottom_catch_radius, center=true );
     }
  }
  else {
    assert( false, "bottom_catch_base: style unknown!" );
  }
} // end bottom_catch_base

// bottom_catch_fitting:
//
// Generate a mate to the machine's catch.
//
module bottom_catch_fitting( height=3, width=bottom_catch_size.y, base_style="full", tang_style="slant", tab_style="full" ) {
  assert( is_num(height) && height >= 0 );
  assert( is_num(width) && width >= 0 );

  difference() {
    union() {
      // Base
      bottom_catch_base( base_style, height, width );

      // Slot projection
      for( p = bottom_slot_centers )
        translate( concat( p, height ) )
          bottom_catch_tang( tang_style );

      // Tab debug means show tab
      if( tab_style == "debug" )
	translate( concat( bottom_tab_center, -bottom_tab_size.z  ) )
	  bottom_catch_bottom_tab_deletion( tab_style, height );
    }

    // Tab cutout deletion (except for debug)
    if( tab_style != "debug" )
      bottom_catch_bottom_tab_deletion( tab_style, height );
  }
} // end bottom_catch_fitting

// bottom_catch_get_size, bottom_catch_get_above_size, bottom_catch_get_below_size:
//
// Returns [ length, width, height above/below case level ]
//
function bottom_catch_get_size()       = concat( bottom_catch_size, bottom_tab_size.z+bottom_slot_size.z );
function bottom_catch_get_above_size() = concat( bottom_catch_size, bottom_tab_size.z );
function bottom_catch_get_below_size() = concat( bottom_catch_size, bottom_slot_size.z );

$fn = 32;
//bottom_catch_fitting(height=3,base_style="full",tang_style="full", tab_style="hole");
//bottom_catch_fitting(height=2.4,base_style="full",tang_style="complex", tab_style="tapered-hole");
//bottom_catch_fitting(height=bottom_tab_size.z, width=30, base_style="trap-front", tang_style="complex", tab_style="tapered-hole");
//bottom_catch_fitting(height=0, base_style="full", tang_style="debug", tab_style="debug");
//bottom_catch_fitting(height=bottom_tab_size.z, width=30, base_style="trap-front", tang_style="complex", tab_style="flared-hole");
bottom_catch_fitting(height=3,base_style="layout",tang_style="full", tab_style="hole");
