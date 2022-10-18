//
// Copyright (c) Stewart H. Whitman, 2022.
//
// File:    expo.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Exponential curve shape.
//

// Curvature for arm
expo_default_curvature = 10;

// expo:
//
// Asymptotic exponential function builds a model of size (either 2D or 3D)
//
module expo( size, curvature ) {
  assert( is_num(size) || (is_list(size) && (len(size) == 2 || len(size) == 3)) );

  w = is_num(size) ? size : size.x;
  h = is_num(size) ? size : size.y;

  assert( is_num(w) && w > 0 );
  assert( is_num(h) && h > 0 );
  assert( !is_list(size) ? true : ((len(size) == 2) || is_num(size.z)) );

  assert( is_num(curvature) && curvature != 0 );

  // Artificial starting point
  artificial_start = 0.01;

  function asym_raw(x,s) = 1-exp(-x/s) / x;
  function asym(x,s) = asym_raw( x/w+artificial_start*s, s );

  // Determine the number of steps
  endpoint = w;
  step     = endpoint / ($fn == 0 ? 180/$fa : $fn);

  // Set up to scale function results
  peak  = asym( endpoint, abs(curvature) );
  sub   = asym( 0, abs(curvature) );
  mult  = h/(peak - sub);
  function scale_function(y) = (y-sub)*mult;

  // Generate the points
  coords = [ for( x = [ 0 : step : +endpoint+step/2 ] ) [ x, scale_function(asym(x,abs(curvature)) ) ] ];

  // Patch endpoints to [ 0, 0 ] .. [ 0, h ], add return to [w,0] at the end for polygon
  coords_min_index = 0;
  coords_max_index = len(coords);
  coords_patched = [ for( i = [coords_min_index:coords_max_index] ) i == coords_max_index ? [ w, 0 ] : [ coords[i].x, (i == coords_min_index) ? 0 : ((i == coords_max_index-1) ? h : coords[i].y) ] ];

  // Reflect function about x=y
  function is_terminus( p ) = p.x == w && p.y == 0;
  function reflect_function(p) = curvature >= 0 || is_terminus(p) ? p : [ p.y/h*w, p.x/w*h ];
  coords_reflect = [ for( p = coords_patched ) reflect_function(p) ];

  // Create the polygon
  if( is_list(size) && len(size) == 3 )
    linear_extrude( height=size.z ) polygon( coords_reflect );
  else
    polygon( coords_reflect );
} // end expo

if( false ) {
  $fn = 80;
  color( "blue" ) expo( [40, 20, 1], abs(expo_default_curvature) );
  translate( [0,0,+2] ) color( "red" ) expo( [40, 20, 1], -abs(expo_default_curvature) );
}
