//
// Copyright (c) Stewart H. Whitman, 2022.
//
// File:    arm.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Curved and straight arm connectors
//

include <smidge.scad>;
include <pair.scad>;
include <expo.scad>;

// Curvature for arm
arm_default_curvature = 10;

// arm:
//
// Simple curved arm.
//
module arm( size, base_thickness, tip_thickness, curvature=arm_default_curvature ) {
  assert( is_list( size ) && len(size) >= 2 && len(size) <= 3 );
  assert( is_num(size[0]) && is_num(size[1]) && (len(size) == 2 || is_num(size[2])) );

  difference() {
    // Top curve
    expo( size, curvature );

    // Minus offset bottom curve
    if( is_list(size) && len(size) == 3 ) {
      translate( [base_thickness+SMIDGE,-SMIDGE,-SMIDGE] )
	expo( size - [ base_thickness, tip_thickness, 0 ] + [ SMIDGE, SMIDGE, 2*SMIDGE ], curvature );
    }
    else {
      translate( [base_thickness+SMIDGE,-SMIDGE] )
	expo( size - [ base_thickness, tip_thickness ] + [ SMIDGE, SMIDGE ], curvature );
    }
  }
} // end arm

// arm_mixed:
//
// Mixed curved and straight arm.
//
module arm_mixed( size, base_thickness, tip_thickness, straight_percentage=0, curvature=arm_default_curvature ) {
  assert( is_num(straight_percentage) );
  assert( straight_percentage >= 0 && straight_percentage <= 100 );

  h_straight = size.y*straight_percentage/100;
  h_curved   = size.y - h_straight;

  // Straight part
  if( h_straight > 0  ) {
    if( len(size) > 2 )
      cube( [base_thickness, h_straight, size.z] );
    else
      square( [base_thickness, h_straight ] );
  }

  // Curved part
  if( h_curved > 0 )
    translate( [0,h_straight,0] ) {
      if( len(size) > 2 )
	arm( [size.x, h_curved, size.z], base_thickness, tip_thickness, curvature );
      else
	arm( [size.x, h_curved], base_thickness, tip_thickness, curvature );
    }
} // end arm_mixed

// arm_tapered:
//
// Curved arm with different size base and tip and optional tang.
//
//   size         - the span of the arm (wxh)
//   base_profile - rectangle at base - x = width, y = thickness
//   tip_profile  - rectangle at tip  - x = width, y = thickness
//   tang_profile - tang dimensions   - x = percentage tip thickness, y = angle, z = pivot point
//   balance      - shift base from side to side
//
module arm_tapered( size, base_profile, tip_profile, tang_profile, straight_percentage=0, curvature=arm_default_curvature, balance=50 ) {
  assert( is_list( size ) && len(size) == 2 && is_num(size[0]) && is_num(size[1]) );
  assert( is_list( base_profile ) && len(base_profile) == 2 && is_num(base_profile[0]) && is_num(base_profile[1]) );
  assert( is_list( tip_profile ) && len(tip_profile) == 2 && is_num(tip_profile[0]) && is_num(tip_profile[1]) );
  assert( is_undef(tang_profile) || is_num(tang_profile) || (is_list( tang_profile ) && len(tang_profile) == 3 && is_num(tang_profile[0]) && is_num(tang_profile[1]) && is_num(tang_profile[2])) );
  assert( is_num(balance) && balance >= 0 && balance <= 100 );

  // echo( "arm_tapered", size, base_profile, tip_profile, tang_profile, straight_percentage, curvature, balance );

  function is_balanced() = (balance == 50);

  tip_width      = tip_profile[0];
  tip_thickness  = tip_profile[1];
  base_width     = base_profile[0];
  base_thickness = base_profile[1];

  function is_straight() = is_balanced() && (tip_width == base_width);

  max_width      = (is_straight() ? 1 : 2) *  max( tip_width, base_width );

  tang_height_percentage = is_undef(tang_profile) ? 0 : is_num(tang_profile) ? tang_profile : tang_profile[0];
  tang_angle             = is_undef(tang_profile) || !is_list(tang_profile) || len(tang_profile) < 2 ? 45 : tang_profile[1];
  tang_height            = tang_height_percentage / 100 * tip_thickness;
  tang_pivot_percentage  = is_undef(tang_profile) || !is_list(tang_profile) || len(tang_profile) < 3 ? 100 : tang_profile[2];
  tang_pivot             = tang_pivot_percentage / 100 * tip_thickness;

  function have_tang( h = tang_height ) = h > 0;
  function tang_length( y = tip_thickness, p = tang_pivot, h = tang_height, a = tang_angle ) = have_tang() ? p+(y+h/2)/tan(a) : 0;

  module tang_tip( y = tip_thickness, p = tang_pivot, h = tang_height, a = tang_angle ) {
    // y => the thickness of the top
    // a => the angle on the top
    // p => the pivot point on the top
    // h => the indent size
    l = tang_length( y, p, h, a );
    polygon([ [0,0], [0,y+h], [p,y+h], [l,+h/2], [l,0] ]);
  }

  difference() {
    // Build the arm of maximum width and tack on the tang
    rotate( [90,0,0] ) {
      linear_extrude( height=max_width, center=true, convexity=20 ) {
	arm_mixed( size - 0*[ tang_length(), 0 ], base_thickness, tip_thickness, straight_percentage, curvature );
	if( have_tang() )
	  translate( size + [0,-tip_thickness] )
	    tang_tip();
      }
    }

    // Construct polygons to delete extra width at base_profile/tip_profile if unequal
    if( !is_straight() ) {
      // Weights on left and right sides
      weight_left  = balance / 100;
      weight_right = 1 - weight_left;

      translate( [0,0,-SMIDGE] ) {
        total_size       = size + [ tang_length(), tang_height ];

	// Adjust clipping so that tip width is the same whether there is a tang or not
        left_base_width  = weight_left*base_width;
        left_tip_width   = tip_width/2 - tang_length() * (left_base_width  - tip_width/2) / size.x;
        right_base_width = weight_right*base_width;
        right_tip_width  = tip_width/2 - tang_length() * (right_base_width - tip_width/2) / size.x;

	linear_extrude( height=total_size.y+2*SMIDGE, center=false, convexity=20 ) {
	  polygon( [[-SMIDGE,+max_width/2+SMIDGE], [-SMIDGE,+left_base_width +SMIDGE], [total_size.x+SMIDGE,+left_tip_width +SMIDGE], [total_size.x+SMIDGE,+max_width/2+SMIDGE]] );
	  polygon( [[-SMIDGE,-max_width/2-SMIDGE], [-SMIDGE,-right_base_width-SMIDGE], [total_size.x+SMIDGE,-right_tip_width-SMIDGE], [total_size.x+SMIDGE,-max_width/2-SMIDGE]] );
	}
      }
    }
  }
} // end arm_tapered

// tangent_points_on_circle:
//
// Calculate the pair of tangent points on circle at centered at <c>
// with radius <radius> from the point <p>.
//
// https://stackoverflow.com/questions/1351746/find-a-tangent-point-on-circle
//
function tangent_points_on_circle( p, c, radius ) =
  let(
    d  = c - p,
    a  = asin( radius / norm(d) ),
    b  = atan2( d.y, d.x ),
    a1 = b - a,
    a2 = b + a,
    t1 = [ radius * sin(a1), radius * -cos(a1) ] + c,
    t2 = [ radius * -sin(a2), radius * cos(a2) ] + c
  ) [ t1, t2 ];

// tangent_points_on_circle_order:
//
// Reorder pair of tangent points based on <order> using above.
//
function tangent_points_on_circle_order( p, c, radius, order ) = pair_order( p, tangent_points_on_circle( p, c, radius ), order );

// tangent_point_on_circle:
//
// Select a single tangent point on a circle chosen based on <order>.
//
function tangent_point_on_circle( p, c, radius, order ) = tangent_points_on_circle_order( p, c, radius, order )[0];

// max_polygon_area:
//
// Create the polygon with the largest area selected from a
// list of polygons <polyies>
//
module max_polygon_area( polyies ) {
  // https://forum.openscad.org/Easy-way-to-get-the-area-of-a-polygon-td17045.html
  function sum(v, _i=0, _sum=0) = _i==len(v) ? _sum : sum(v, _i+1, _sum+v[_i] );
  function area(p) = abs( sum( [ for(i=[0:len(p)-1]) cross( p[i], p[(i+1)%len(p)] ) ] ) )/2;

  // Find areas
  areas = [ for( p = polyies ) area(p) ];

  // Select maximum area for arm
  function max_index(a, _i = 0) = (_i >= len(a)-1) ? len(a)-1 : let( o = max_index( a, _i+1 ) ) (a[_i] >= a[o] ? _i : o );
  arm = polyies[ max_index( areas ) ];

  polygon( arm );
} // end max_polygon_area

// arm_to_circle:
//
// Create an arm from <p1>..<p2> to the given circle centered at <c> with radius <r>.
//
module arm_to_circle( p1, p2, c, radius, with_circle=true ) {
  assert( is_num( radius ) && radius > 0 );
  assert( is_list( c ) && (len(c) == 2) && is_num( c.x ) && is_num( c.y ) );
  assert( is_list( p1 ) && (len(p1) == 2) && is_num( p1.x ) && is_num( p1.y ) );
  assert( is_list( p2 ) && (len(p2) == 2) && is_num( p2.x ) && is_num( p2.y ) );
  assert( p1 != p2 );
  assert( norm( p1 - c ) > radius );
  assert( norm( p2 - c ) > radius );

  // Get the tangent points
  tangents_p1 = tangent_points_on_circle( p1, c, radius );
  tangents_p2 = tangent_points_on_circle( p2, c, radius );

  // Create all possible quads that include <p1> and <p2> and their tangent points
  polyies = [ [ p1, p2, tangents_p2[0], tangents_p1[0] ],
              [ p1, p2, tangents_p2[0], tangents_p1[1] ],
              [ p1, p2, tangents_p2[1], tangents_p1[0] ],
              [ p1, p2, tangents_p2[1], tangents_p1[1] ] ];

  // Create maximum area polygon
  max_polygon_area( polyies );

  // Create circle too if requested
  if( with_circle )
    translate( [c.x, c.y] ) circle( r=radius );
} // end arm_to_circle

if( false ) {
  $fn = 80;
  //arm( [ 40, 20, 1 ], 6, 3 );
  //arm_mixed( [ 40, 50, 1 ], 6, 3, 30 );
  //arm_to_circle( [0, 0], [-20, 15], [ +20, +30 ], 4, with_circle=true );
  //arm_to_circle( [50, 0], [-20, 15], [ +20, +30 ], 8 );
  arm_tapered( [30,40], [30,5], [5,2], [75,45,100], curvature=arm_default_curvature, balance=25 );
}
