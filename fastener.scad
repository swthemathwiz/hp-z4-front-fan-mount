//
// Copyright (c) Stewart H. Whitman, 2022-2024.
//
// File:    fastener.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Fastener Definitions and Models (Simplified)
//

include <hash.scad>;
include <smidge.scad>;

use <threadlib/threadlib.scad>
use <MCAD/regular_shapes.scad>

// Overview:
//
// Access a metric fastener's specification:
//    spec = fastener_get_spec( "M6" );
//
// Get an attributes:
//    echo( "Thread pitch of ", fastener_get_attribute( spec, "name" ) ,
//             " is ",  fastener_get_attribute( spec, "thread_pitch" ) ); // -> Thread pitch of M6 is 1
//
// Produce models:
//    spec = fastener_get_spec( "M6" );
//    fastener_hex_nut( spec );
//    fastener_hex_bolt( spec );
//    fastener_washer( spec );
//    fastener_fender_washer( spec );
//
//    fastener_fender_washer( "M6" ); // -> also produces a model of fender washer
//
// Models are centered with outlet face centered on X/Y origin and Z positive.
//

// Attributes:
//   name -
//   thread_pitch -
//   thread_spec -
//   thread_diameter -
//   head_thickness -
//   head_thickness_max -
//   head_thickness_min -
//   head_across_flats -
//   head_across_flats_max -
//   head_across_flats_min -
//   washer_inner_diameter -
//   washer_outer_diameter -
//   washer_thickness -
//   fender_washer_inner_diameter -
//   fender_washer_outer_diameter -
//   fender_washer_thickness -
//   nut_thickness -
//   nut_thickness_max -
//   nut_thickness_min -
//

// fastener_get_spec:
//
// Get the specification associated with <name>.
//
function fastener_get_spec( name ) = hash_get( fastener_specifications, name );

// _fastener_get_spec_from_string:
//
// Auto convert string to fastener spec. (internal)
//
function _fastener_get_spec_from_string( s ) = is_string(s) ? fastener_get_spec(s) : s;

// fastener_get_attribute:
//
// Retrieves an <attribute> from a <spec>.
//
function fastener_get_attribute( spec, attribute ) = hash_get( _fastener_get_spec_from_string( spec ), attribute );

// fastener_get_attribute_or_zero:
//
// Retrieves an <attribute> from a <spec> or returns 0 if it does not exist.
//
function fastener_get_attribute_or_zero( spec, attribute ) = hash_get_default( _fastener_get_spec_from_string( spec ), attribute, 0 );

// fastener_has_attribute:
//
// Returns true if a <spec> has an <attribute>.
//
function fastener_has_attribute( spec, attribute ) = hash_exists( _fastener_get_spec_from_string( spec ), attribute );

// fastener_hex_across_flats_to_diameter, fastener_hex_across_flats_to_radius:
//
// Convert hex flats value <distance> to circular diameter or radius.
//
function fastener_hex_across_flats_to_diameter( distance ) = distance / cos(30);
function fastener_hex_across_flats_to_radius( distance ) = fastener_hex_across_flats_to_diameter( distance ) / 2;

// fastener_distance_to_turns, fastener_turns_to_distance:
//
// Converts a <distance> to a number of turns of threads based on the
// thread pitch of <spec> and vice versa.
//
function fastener_distance_to_turns( spec, distance ) = distance / fastener_get_attribute( spec, "thread_pitch" );
function fastener_turns_to_distance( spec, turns ) = turns * fastener_get_attribute( spec, "thread_pitch" );

// fastener_nominal_circular_diameter, fastener_nominal_circular_radius:
//
// Circular diameter or radius occupied by <spec> (head or nut).
//
function fastener_nominal_circular_diameter( spec ) = fastener_hex_across_flats_to_diameter( fastener_get_attribute( spec, "head_across_flats" ) );
function fastener_nominal_circular_radius( spec ) = fastener_hex_across_flats_to_radius( fastener_get_attribute( spec, "head_across_flats" ) );

// fastener_hex_bolt:
//
// Model of hex bolt from specification <s>.
//
module fastener_hex_bolt( s, length, shank=0 ) {
  assert( length >= 0 );
  assert( length >= shank );

  spec = _fastener_get_spec_from_string(s);

  head_thickness     = fastener_get_attribute( spec, "head_thickness" );
  head_across_flats  = fastener_get_attribute( spec, "head_across_flats" );
  thread_pitch       = fastener_get_attribute( spec, "thread_pitch" );
  thread_spec        = fastener_get_attribute( spec, "thread_spec" );
  thread_diameter    = fastener_get_attribute( spec, "thread_diameter" );

  linear_extrude( head_thickness ) regular_polygon( 6, fastener_hex_across_flats_to_radius( head_across_flats ) );

  if( shank > 0 )
    translate( [ 0, 0, head_thickness ] )
      cylinder( h=shank, d=thread_diameter );

  translate( [0, 0, head_thickness+shank] )
    bolt( thread_spec, turns=fastener_distance_to_turns( spec, length-shank ), higbee_arc=30 );
} // end fastener_hex_bolt

// fastener_hex_nut:
//
// Model of hex nut from specification <s> of <thickness> (or spec default).
//
module fastener_hex_nut( s, thickness = 0 ) {
  spec = _fastener_get_spec_from_string(s);

  nut_thickness       = thickness > 0 ? thickness : fastener_get_attribute( spec, "nut_thickness" );
  head_across_flats   = fastener_get_attribute( spec, "head_across_flats" );
  thread_pitch        = fastener_get_attribute( spec, "thread_pitch" );
  thread_spec         = fastener_get_attribute( spec, "thread_spec" );
  thread_diameter_max = fastener_get_attribute( spec, "thread_diameter_max" );

  // N.B. threadlib's nut adds one turn spacing each end, leaves nut below zero
  translate( [ 0, 0, thread_pitch/2 ] )
    nut( thread_spec, turns=fastener_distance_to_turns( spec, nut_thickness )-1, Douter=head_across_flats );

  // Head
  linear_extrude( nut_thickness )
    difference() {
      regular_polygon( 6, fastener_hex_across_flats_to_radius( head_across_flats ) );
      circle( d=head_across_flats-.1 );
    }
} // end fastener_hex_nut

// fastener_washer:
//
// Model of fender washer from specification <s> of <thickness> (or spec default).
//
module fastener_washer( s, thickness = 0 ) {
  spec = _fastener_get_spec_from_string(s);

  washer_thickness      = thickness > 0 ? thickness : fastener_get_attribute( spec, "washer_thickness" );
  washer_inner_diameter = fastener_get_attribute( spec, "washer_inner_diameter" );
  washer_outer_diameter = fastener_get_attribute( spec, "washer_outer_diameter" );

  translate( [0,0,washer_thickness/2] )
    difference() {
      cylinder( h=washer_thickness, d=washer_outer_diameter, center=true );
      cylinder( h=washer_thickness+2*SMIDGE, d=washer_inner_diameter, center=true );
    }
} // end fastener_washer

// fastener_fender_washer:
//
// Model of fender washer from specification <s> of <thickness> (or spec default).
//
module fastener_fender_washer( s, thickness = 0 ) {
  spec = _fastener_get_spec_from_string(s);

  fender_washer_thickness      = thickness > 0 ? thickness : fastener_get_attribute( spec, "fender_washer_thickness" );
  fender_washer_inner_diameter = fastener_get_attribute( spec, "fender_washer_inner_diameter" );
  fender_washer_outer_diameter = fastener_get_attribute( spec, "fender_washer_outer_diameter" );

  translate( [0,0,fender_washer_thickness/2] )
    difference() {
      cylinder( h=fender_washer_thickness, d=fender_washer_outer_diameter, center=true );
      cylinder( h=fender_washer_thickness+2*SMIDGE, d=fender_washer_inner_diameter, center=true );
    }
} // end fastener_fender_washer

// fastener_demo:
//
// Model all components.
//
module fastener_demo(_i=0,_pos=0, $fn=20) {
  if( _i < len(fastener_specifications) ) {
    // Get the specification
    spec = fastener_get_spec( fastener_specifications[_i][0] );

    echo( fastener_get_attribute( spec, "name" ) );
    // Sanityf check thread pitch
    //echo( fastener_get_attribute( spec, "name" ), fastener_get_attribute( spec, "thread_pitch" ), fastener_get_attribute( spec, "thread_spec" ), thread_specs( str(fastener_get_attribute( spec, "thread_spec" ),"-ext") )[0] );

    // Vertical spacing between components
    demo_height_spacing = 4;

    // Horizontal spacing between threads
    demo_width_multiplier = 2;

    // Multiplier based on head height
    demo_bolt_length_multiplier = 10;

    // Get component heights
    head_height          = fastener_get_attribute_or_zero( spec, "head_thickness" );
    bolt_height          = head_height ? head_height + demo_bolt_length_multiplier * head_height : 0;
    nut_height           = fastener_get_attribute_or_zero( spec, "nut_thickness" );
    washer_height        = fastener_get_attribute_or_zero( spec, "washer_thickness" );
    fender_washer_height = fastener_get_attribute_or_zero( spec, "fender_washer_thickness" );

    // Bolt's nominal length
    demo_thread_length = bolt_height ? bolt_height-head_height : 0;

    if( bolt_height != 0 )
      translate( [_pos,0,0] )
	fastener_hex_bolt( spec, demo_thread_length, 0.2*demo_thread_length  );

    if( washer_height != 0 )
      translate( [_pos, 0, bolt_height + demo_height_spacing ] )
	fastener_washer( spec );

    if( fender_washer_height != 0 )
      translate( [_pos,0, bolt_height + washer_height + 2*demo_height_spacing ] )
	fastener_fender_washer( spec );

    if( nut_height != 0 )
      translate( [_pos,0, bolt_height + washer_height + fender_washer_height + 3*demo_height_spacing ] )
	fastener_hex_nut( spec );

    // Get all the widths for horizontal spacing
    bolt_width          = bolt_height ? fastener_hex_across_flats_to_diameter( fastener_get_attribute( spec, "head_across_flats" ) ) : 0;
    nut_width           = nut_height ? fastener_hex_across_flats_to_diameter( fastener_get_attribute( spec, "head_across_flats" ) ) : 0;
    washer_width        = washer_height ? fastener_get_attribute( spec, "washer_outer_diameter" ) : 0;
    fender_washer_width = fender_washer_height ? fastener_get_attribute( spec, "fender_washer_outer_diameter" ) : 0;

    fastener_demo( _i + 1, _pos + demo_width_multiplier*max( bolt_width, nut_width, washer_width, fender_washer_width ) );
  }
} // end fastener_demo

//
// Specifications:
//   Generally DIN 931 / ASME mix
//
// Collected from:
//   https://www.ebninc.com/images/pdf/technical/metric-fasteners.pdf
//   https://www.engineersedge.com/hardware/bs_en_iso_4032_hexagon_nuts__14571.htm
//   https://www.atlrod.com/metric-hex-bolt-dimensions/
//   http://boltingspecialist.com/dimensions/asme-b18.2.3.1m-metric-hex-cap-screws/
//   http://boltingspecialist.com/dimensions/din-931-hex-bolts/
//   https://torqbolt.com/asme-b18-2-3-1m-hex-cap-screws-dimensions-standards-specifications
//   https://www.fast-rite.com/wp-content/uploads/Fast-Rite_TechnicalSpecsForFasteners_20181210.pdf
//   https://mechanicalc.com/reference/fastener-size-tables
//   https://www.woodstockindustrial.com/wam.html
//   https://www.beaconcorporation.co.uk/products/washers/din-9021-dimensions/
//   https://www.brikksen.com/Home/Page/catalog
//
fastener_specifications = [
  [ "M1.6", [
    [ "name", "M1.6" ],
    [ "thread_pitch", 0.35 ],
    [ "thread_spec", "M1.6x0.35" ],
    [ "thread_diameter", 1.60 ],
    [ "thread_diameter_max", 1.60 ],
    [ "thread_diameter_min", 1.60 ],
    [ "head_thickness", 1.1 ],
    [ "head_thickness_max", 0.98 ],
    [ "head_thickness_min", 1.22 ],
    [ "head_across_flats", 3.20 ],
    [ "head_across_flats_max", 3.20 ],
    [ "head_across_flats_min", 3.02 ],
    [ "washer_inner_diameter", 1.7 ],
    [ "washer_outer_diameter", 4 ],
    [ "washer_thickness", 0.3 ],
    [ "nut_thickness", 1.175 ],
    [ "nut_thickness_max", 1.3 ],
    [ "nut_thickness_min", 1.05 ],
    // Missing fender washer
  ] ],
  [ "M2", [
    [ "name", "M2" ],
    [ "thread_pitch", 0.4 ],
    [ "thread_spec", "M2x0.4" ],
    [ "thread_diameter", 2.00 ],
    [ "thread_diameter_max", 2.00 ],
    [ "thread_diameter_min", 2.00 ],
    [ "head_thickness", 1.4 ],
    [ "head_thickness_max", 1.28 ],
    [ "head_thickness_min", 1.52 ],
    [ "head_across_flats", 4.00 ],
    [ "head_across_flats_max", 4.00 ],
    [ "head_across_flats_min", 3.82 ],
    [ "washer_inner_diameter", 2.2 ],
    [ "washer_outer_diameter", 5 ],
    [ "washer_thickness", 0.3 ],
    [ "nut_thickness", 1.475 ],
    [ "nut_thickness_max", 1.6 ],
    [ "nut_thickness_min", 1.35 ],
    // Missing fender washer
  ] ],
  [ "M3", [
    [ "name", "M3" ],
    [ "thread_pitch", 0.5 ],
    [ "thread_spec", "M3x0.5" ],
    [ "thread_diameter", 3.00 ],
    [ "thread_diameter_max", 3.00 ],
    [ "thread_diameter_min", 3.00 ],
    [ "head_thickness", 2 ],
    [ "head_thickness_max", 1.88 ],
    [ "head_thickness_min", 2.12 ],
    [ "head_across_flats", 5.50 ],
    [ "head_across_flats_max", 5.50 ],
    [ "head_across_flats_min", 5.32 ],
    [ "washer_inner_diameter", 3.2 ],
    [ "washer_outer_diameter", 7 ],
    [ "washer_thickness", 0.5 ],
    [ "fender_washer_inner_diameter", 3.2 ],
    [ "fender_washer_outer_diameter", 9 ],
    [ "fender_washer_thickness", 0.8 ],
    [ "nut_thickness", 2.275 ],
    [ "nut_thickness_max", 2.4 ],
    [ "nut_thickness_min", 2.15 ],
  ] ],
  [ "M3.5", [
    [ "name", "M3.5" ],
    [ "thread_pitch", 0.6 ],
    [ "thread_spec", "M3.5x0.6" ],
    [ "thread_diameter", 3.50 ],
    [ "thread_diameter_max", 3.50 ],
    [ "thread_diameter_min", 3.50 ],
    // [ "head_thickness", 0 ],
    // [ "head_thickness_max", 0 ],
    // [ "head_thickness_min", 0 ],
    [ "head_across_flats", 6.00 ],
    [ "head_across_flats_max", 6.00 ],
    [ "head_across_flats_min", 5.82 ],
    [ "washer_inner_diameter", 3.7 ],
    [ "washer_outer_diameter", 8 ],
    [ "washer_thickness", 0.5 ],
    [ "fender_washer_inner_diameter", 3.7 ],
    [ "fender_washer_outer_diameter", 11 ],
    [ "fender_washer_thickness", 0.8 ],
    [ "nut_thickness", 2.7 ],
    [ "nut_thickness_max", 2.95 ],
    [ "nut_thickness_min", 2.55 ],
  ] ],
  [ "M4", [
    [ "name", "M4" ],
    [ "thread_pitch", 0.7 ],
    [ "thread_spec", "M4x0.7" ],
    [ "thread_diameter", 4.00 ],
    [ "thread_diameter_max", 4.00 ],
    [ "thread_diameter_min", 4.00 ],
    [ "head_thickness", 2.8 ],
    [ "head_thickness_max", 2.68 ],
    [ "head_thickness_min", 2.92 ],
    [ "head_across_flats", 7.00 ],
    [ "head_across_flats_max", 7.00 ],
    [ "head_across_flats_min", 6.78 ],
    [ "washer_inner_diameter", 4.3 ],
    [ "washer_outer_diameter", 9 ],
    [ "washer_thickness", 0.8 ],
    [ "fender_washer_inner_diameter", 4.3 ],
    [ "fender_washer_outer_diameter", 12 ],
    [ "fender_washer_thickness", 1.0 ],
    [ "nut_thickness", 3.05 ],
    [ "nut_thickness_max", 3.2 ],
    [ "nut_thickness_min", 2.9 ],
  ] ],
  [ "M5", [
    [ "name", "M5" ],
    [ "thread_pitch", 0.8 ],
    [ "thread_spec", "M5x0.8" ],
    [ "thread_diameter", 5.00 ],
    [ "thread_diameter_max", 5.00 ],
    [ "thread_diameter_min", 4.82 ],
    [ "head_thickness", 3.5 ],
    [ "head_thickness_max", 3.35 ],
    [ "head_thickness_min", 3.65 ],
    [ "head_across_flats", 8.00 ],
    [ "head_across_flats_max", 8.00 ],
    [ "head_across_flats_min", 7.78 ],
    [ "washer_inner_diameter", 5.3 ],
    [ "washer_outer_diameter", 10 ],
    [ "washer_thickness", 1.0 ],
    [ "fender_washer_inner_diameter", 5.3 ],
    [ "fender_washer_outer_diameter", 15 ],
    [ "fender_washer_thickness", 1.2 ],
    [ "nut_thickness", 4.55 ],
    [ "nut_thickness_max", 4.7 ],
    [ "nut_thickness_min", 4.4 ],
  ] ],
  [ "M6", [
    [ "name", "M6" ],
    [ "thread_pitch", 1 ],
    [ "thread_spec", "M6x1" ],
    [ "thread_diameter", 6.00 ],
    [ "thread_diameter_max", 6.00 ],
    [ "thread_diameter_min", 5.82 ],
    [ "head_thickness", 4 ],
    [ "head_thickness_max", 3.85 ],
    [ "head_thickness_min", 4.15 ],
    [ "head_across_flats", 10.00 ],
    [ "head_across_flats_max", 10.00 ],
    [ "head_across_flats_min", 9.78 ],
    [ "washer_inner_diameter", 6.4 ],
    [ "washer_outer_diameter", 12 ],
    [ "washer_thickness", 1.6 ],
    [ "fender_washer_inner_diameter", 6.4 ],
    [ "fender_washer_outer_diameter", 18 ],
    [ "fender_washer_thickness", 1.6 ],
    [ "nut_thickness", 5.05 ],
    [ "nut_thickness_max", 5.2 ],
    [ "nut_thickness_min", 4.9 ],
  ] ],
  [ "M8", [
    [ "name", "M8" ],
    [ "thread_pitch", 1.25 ],
    [ "thread_spec", "M8x1.25" ],
    [ "thread_diameter", 8.00 ],
    [ "thread_diameter_max", 8.00 ],
    [ "thread_diameter_min", 7.78 ],
    [ "head_thickness", 5.3 ],
    [ "head_thickness_max", 5.15 ],
    [ "head_thickness_min", 5.45 ],
    [ "head_across_flats", 13.00 ],
    [ "head_across_flats_max", 13.00 ],
    [ "head_across_flats_min", 12.73 ],
    [ "washer_inner_diameter", 8.4 ],
    [ "washer_outer_diameter", 16 ],
    [ "washer_thickness", 1.6 ],
    [ "fender_washer_inner_diameter", 8.4 ],
    [ "fender_washer_outer_diameter", 24 ],
    [ "fender_washer_thickness", 2.0 ],
    [ "nut_thickness", 6.62 ],
    [ "nut_thickness_max", 6.8 ],
    [ "nut_thickness_min", 6.44 ],
  ] ],
  [ "M10", [
    [ "name", "M10" ],
    [ "thread_pitch", 1.5 ],
    [ "thread_spec", "M10x1.5" ],
    [ "thread_diameter", 10.00 ],
    [ "thread_diameter_max", 10.00 ],
    [ "thread_diameter_min", 9.78 ],
    [ "head_thickness", 6.4 ],
    [ "head_thickness_max", 6.22 ],
    [ "head_thickness_min", 6.58 ],
    [ "head_across_flats", 17.00 ],
    [ "head_across_flats_max", 17.00 ],
    [ "head_across_flats_min", 16.73 ],
    [ "washer_inner_diameter", 10.5 ],
    [ "washer_outer_diameter", 20 ],
    [ "washer_thickness", 2.0 ],
    [ "fender_washer_inner_diameter", 10.5 ],
    [ "fender_washer_outer_diameter", 30 ],
    [ "fender_washer_thickness", 2.5 ],
    [ "nut_thickness", 8.22 ],
    [ "nut_thickness_max", 8.4 ],
    [ "nut_thickness_min", 8.04 ],
  ] ],
  [ "M12", [
    [ "name", "M12" ],
    [ "thread_pitch", 1.75 ],
    [ "thread_spec", "M12x1.75" ],
    [ "thread_diameter", 12.00 ],
    [ "thread_diameter_max", 12.00 ],
    [ "thread_diameter_min", 11.73 ],
    [ "head_thickness", 7.5 ],
    [ "head_thickness_max", 7.32 ],
    [ "head_thickness_min", 7.68 ],
    [ "head_across_flats", 19.00 ],
    [ "head_across_flats_max", 19.00 ],
    [ "head_across_flats_min", 18.67 ],
    [ "washer_inner_diameter", 13.0 ],
    [ "washer_outer_diameter", 24 ],
    [ "washer_thickness", 2.5 ],
    [ "fender_washer_inner_diameter", 13.0 ],
    [ "fender_washer_outer_diameter", 37 ],
    [ "fender_washer_thickness", 3.0 ],
    [ "nut_thickness", 10.585 ],
    [ "nut_thickness_max", 10.8 ],
    [ "nut_thickness_min", 10.37 ],
  ] ],
  [ "M14", [
    [ "name", "M14" ],
    [ "thread_pitch", 2 ],
    [ "thread_spec", "M14x2" ],
    [ "thread_diameter", 14.00 ],
    [ "thread_diameter_max", 14.00 ],
    [ "thread_diameter_min", 13.73 ],
    [ "head_thickness", 8.8 ],
    [ "head_thickness_max", 8.62 ],
    [ "head_thickness_min", 8.98 ],
    [ "head_across_flats", 22.00 ],
    [ "head_across_flats_max", 22.00 ],
    [ "head_across_flats_min", 21.67 ],
    [ "washer_inner_diameter", 15.0 ],
    [ "washer_outer_diameter", 28 ],
    [ "washer_thickness", 2.5 ],
    [ "fender_washer_inner_diameter", 15.0 ],
    [ "fender_washer_outer_diameter", 44 ],
    [ "fender_washer_thickness", 3.0 ],
    [ "nut_thickness", 12.45 ],
    [ "nut_thickness_max", 12.8 ],
    [ "nut_thickness_min", 12.1 ],
  ] ],
  [ "M16", [
    [ "name", "M16" ],
    [ "thread_pitch", 2 ],
    [ "thread_spec", "M16x2" ],
    [ "thread_diameter", 16.00 ],
    [ "thread_diameter_max", 16.00 ],
    [ "thread_diameter_min", 15.73 ],
    [ "head_thickness", 10 ],
    [ "head_thickness_max", 9.82 ],
    [ "head_thickness_min", 10.20 ],
    [ "head_across_flats", 24.00 ],
    [ "head_across_flats_max", 24.00 ],
    [ "head_across_flats_min", 23.67 ],
    [ "washer_inner_diameter", 17.0 ],
    [ "washer_outer_diameter", 30 ],
    [ "washer_thickness", 3.0 ],
    [ "fender_washer_inner_diameter", 17.0 ],
    [ "fender_washer_outer_diameter", 50 ],
    [ "fender_washer_thickness", 3.0 ],
    [ "nut_thickness", 14.45 ],
    [ "nut_thickness_max", 14.8 ],
    [ "nut_thickness_min", 14.1 ],
  ] ],
  [ "M20", [
    [ "name", "M20" ],
    [ "thread_pitch", 2.5 ],
    [ "thread_spec", "M20x2.5" ],
    [ "thread_diameter", 20.00 ],
    [ "thread_diameter_max", 20.00 ],
    [ "thread_diameter_min", 19.67 ],
    [ "head_thickness", 12.5 ],
    [ "head_thickness_max", 12.28 ],
    [ "head_thickness_min", 12.70 ],
    [ "head_across_flats", 30.00 ],
    [ "head_across_flats_max", 30.00 ],
    [ "head_across_flats_min", 29.16 ],
    [ "washer_inner_diameter", 21.0 ],
    [ "washer_outer_diameter", 37 ],
    [ "washer_thickness", 3.0 ],
    [ "fender_washer_inner_diameter", 22.0 ],
    [ "fender_washer_outer_diameter", 60 ],
    [ "fender_washer_thickness", 4.0 ],
    [ "nut_thickness", 17.45 ],
    [ "nut_thickness_max", 18 ],
    [ "nut_thickness_min", 16.9 ],
  ] ],
  [ "M24", [
    [ "name", "M24" ],
    [ "thread_pitch", 3 ],
    [ "thread_spec", "M24x3" ],
    [ "thread_diameter", 24.00 ],
    [ "thread_diameter_max", 24.00 ],
    [ "thread_diameter_min", 23.67 ],
    [ "head_thickness", 15 ],
    [ "head_thickness_max", 14.78 ],
    [ "head_thickness_min", 15.20 ],
    [ "head_across_flats", 36.00 ],
    [ "head_across_flats_max", 36.00 ],
    [ "head_across_flats_min", 35.00 ],
    [ "washer_inner_diameter", 25.0 ],
    [ "washer_outer_diameter", 44 ],
    [ "washer_thickness", 4.0 ],
    [ "fender_washer_inner_diameter", 26 ],
    [ "fender_washer_outer_diameter", 72 ],
    [ "fender_washer_thickness", 5.0 ],
    [ "nut_thickness", 20.85 ],
    [ "nut_thickness_max", 21.5 ],
    [ "nut_thickness_min", 20.2 ],
  ] ],
  [ "M30", [
    [ "name", "M30" ],
    [ "thread_pitch", 3.5 ],
    [ "thread_spec", "M30x3.5" ],
    [ "thread_diameter", 30.00 ],
    [ "thread_diameter_max", 30.00 ],
    [ "thread_diameter_min", 29.67 ],
    [ "head_thickness", 18.7 ],
    [ "head_thickness_max", 18.28 ],
    [ "head_thickness_min", 19.10 ],
    [ "head_across_flats", 46.00 ],
    [ "head_across_flats_max", 46.00 ],
    [ "head_across_flats_min", 45.00 ],
    [ "washer_inner_diameter", 31.0 ],
    [ "washer_outer_diameter", 56 ],
    [ "washer_thickness", 4.0 ],
    [ "fender_washer_inner_diameter", 33 ],
    [ "fender_washer_outer_diameter", 92 ],
    [ "fender_washer_thickness", 6.0 ],
    [ "nut_thickness", 24.95 ],
    [ "nut_thickness_max", 25.6 ],
    [ "nut_thickness_min", 24.3 ],
  ] ],
  [ "M36", [
    [ "name", "M36" ],
    [ "thread_pitch", 4 ],
    [ "thread_spec", "M36x4" ],
    [ "thread_diameter", 36.00 ],
    [ "thread_diameter_max", 36.00 ],
    [ "thread_diameter_min", 35.61 ],
    [ "head_thickness", 22.5 ],
    [ "head_thickness_max", 22.08 ],
    [ "head_thickness_min", 22.90 ],
    [ "head_across_flats", 55.00 ],
    [ "head_across_flats_max", 55.00 ],
    [ "head_across_flats_min", 53.80 ],
    [ "washer_inner_diameter", 37.0 ],
    [ "washer_outer_diameter", 66 ],
    [ "washer_thickness", 5.0 ],
    [ "fender_washer_inner_diameter", 39 ],
    [ "fender_washer_outer_diameter", 110 ],
    [ "fender_washer_thickness", 8.0 ],
    [ "nut_thickness", 30.2 ],
    [ "nut_thickness_max", 31 ],
    [ "nut_thickness_min", 29.4 ],
  ] ],
  [ "M42", [
    [ "name", "M42" ],
    [ "thread_pitch", 4.5 ],
    [ "thread_spec", "M42x4.5" ],
    [ "thread_diameter", 42.00 ],
    [ "thread_diameter_max", 42.00 ],
    [ "thread_diameter_min", 41.38 ],
    [ "head_thickness", 26 ],
    [ "head_thickness_max", 25.58 ],
    [ "head_thickness_min", 26.40 ],
    [ "head_across_flats", 65.00 ],
    [ "head_across_flats_max", 65.00 ],
    [ "head_across_flats_min", 63.10 ],
    [ "nut_thickness", 33.2 ],
    [ "nut_thickness_max", 34 ],
    [ "nut_thickness_min", 32.4 ],
    [ "washer_inner_diameter", 43 ],
    [ "washer_outer_diameter", 78 ],
    [ "washer_thickness", 7.0 ],
    // missing fender washer information
  ] ],
  [ "M48", [
    [ "name", "M48" ],
    [ "thread_pitch", 5 ],
    [ "thread_spec", "M48x5" ],
    [ "thread_diameter", 48.00 ],
    [ "thread_diameter_max", 48.00 ],
    [ "thread_diameter_min", 47.38 ],
    [ "head_thickness", 30 ],
    [ "head_thickness_max", 29.58 ],
    [ "head_thickness_min", 30.40 ],
    [ "head_across_flats", 75.00 ],
    [ "head_across_flats_max", 75.00 ],
    [ "head_across_flats_min", 72.60 ],
    [ "nut_thickness", 37.2 ],
    [ "nut_thickness_max", 38 ],
    [ "nut_thickness_min", 36.4 ],
    [ "washer_inner_diameter", 50 ],
    [ "washer_outer_diameter", 92 ],
    [ "washer_thickness", 8.0 ],
    // missing fender washer information
  ] ],
  [ "M56", [
    [ "name", "M56" ],
    [ "thread_pitch", 5.5 ],
    [ "thread_spec", "M56x5.5" ],
    [ "thread_diameter", 56.00 ],
    [ "thread_diameter_max", 56.00 ],
    [ "thread_diameter_min", 55.26 ],
    [ "head_thickness", 35 ],
    [ "head_thickness_max", 34.50 ],
    [ "head_thickness_min", 35.50 ],
    [ "head_across_flats", 85.00 ],
    [ "head_across_flats_max", 85.00 ],
    [ "head_across_flats_min", 82.80 ],
    [ "nut_thickness", 44.2 ],
    [ "nut_thickness_max", 45 ],
    [ "nut_thickness_min", 43.4 ],
    [ "washer_inner_diameter", 58 ],
    [ "washer_outer_diameter", 105 ],
    [ "washer_thickness", 9.0 ],
    // missing fender washer information
  ] ],
  [ "M64", [
    [ "name", "M64" ],
    [ "thread_pitch", 6 ],
    [ "thread_spec", "M64x6" ],
    [ "thread_diameter", 64.00 ],
    [ "thread_diameter_max", 64.00 ],
    [ "thread_diameter_min", 63.26 ],
    [ "head_thickness", 40 ],
    [ "head_thickness_max", 39.50 ],
    [ "head_thickness_min", 40.50 ],
    [ "head_across_flats", 95.00 ],
    [ "head_across_flats_max", 95.00 ],
    [ "head_across_flats_min", 92.80 ],
    [ "nut_thickness", 50.05 ],
    [ "nut_thickness_max", 51 ],
    [ "nut_thickness_min", 49.1 ],
    [ "washer_inner_diameter", 66 ],
    [ "washer_outer_diameter", 115 ],
    [ "washer_thickness", 9.0 ],
    // missing fender washer information
  ] ],

  [ "UNC-#2", [
    [ "name", "UNC-#2" ],
    [ "thread_pitch", 0.453571 ],
    [ "thread_spec", "UNC-#2" ],
    [ "thread_diameter", 2.1844 ],
    [ "thread_diameter_max", 2.1844 ],
    [ "head_thickness", 1.27 ],
    [ "head_thickness_max", 1.27 ],
    [ "head_thickness_min", 1.016 ],
    [ "head_across_flats", 3.175 ],
    [ "head_across_flats_max", 3.175 ],
    [ "head_across_flats_min", 3.048 ],
    [ "washer_inner_diameter", 2.38125 ],
    [ "washer_outer_diameter", 6.35 ],
    [ "washer_thickness", 0.396875 ],
    [ "nut_thickness", 1.6764 ],
    [ "nut_thickness_max", 1.4478 ],
    [ "nut_thickness_min", 1.6764 ],
  ] ],
  [ "UNC-#4", [
    [ "name", "UNC-#4" ],
    [ "thread_pitch", 0.635 ],
    [ "thread_spec", "UNC-#4" ],
    [ "thread_diameter", 2.8448 ],
    [ "thread_diameter_max", 2.8448 ],
    [ "head_thickness", 1.524 ],
    [ "head_thickness_max", 1.524 ],
    [ "head_thickness_min", 1.2446 ],
    [ "head_across_flats", 4.7625 ],
    [ "head_across_flats_max", 4.7752 ],
    [ "head_across_flats_min", 4.5974 ],
    [ "washer_inner_diameter", 3.175 ],
    [ "washer_outer_diameter", 7.9375 ],
    [ "washer_thickness", 0.79375 ],
    [ "nut_thickness", 2.4892 ],
    [ "nut_thickness_max", 2.2098 ],
    [ "nut_thickness_min", 2.4892 ],
  ] ],
  [ "UNC-#6", [
    [ "name", "UNC-#6" ],
    [ "thread_pitch", 0.79375 ],
    [ "thread_spec", "UNC-#6" ],
    [ "thread_diameter", 3.5052 ],
    [ "thread_diameter_max", 3.5052 ],
    [ "head_thickness", 2.3622 ],
    [ "head_thickness_max", 2.3622 ],
    [ "head_thickness_min", 2.032 ],
    [ "head_across_flats", 6.35 ],
    [ "head_across_flats_max", 6.35 ],
    [ "head_across_flats_min", 6.1976 ],
    [ "washer_inner_diameter", 3.96875 ],
    [ "washer_outer_diameter", 9.525 ],
    [ "washer_thickness", 1.190625 ],
    [ "nut_thickness", 2.8956 ],
    [ "nut_thickness_max", 2.5908 ],
    [ "nut_thickness_min", 2.8956 ],
  ] ],
  [ "UNC-#8", [
    [ "name", "UNC-#8" ],
    [ "thread_pitch", 0.79375 ],
    [ "thread_spec", "UNC-#8" ],
    [ "thread_diameter", 4.1656 ],
    [ "thread_diameter_max", 4.1656 ],
    [ "head_thickness", 2.794 ],
    [ "head_thickness_max", 2.794 ],
    [ "head_thickness_min", 2.4384 ],
    [ "head_across_flats", 6.35 ],
    [ "head_across_flats_max", 6.35 ],
    [ "head_across_flats_min", 6.1976 ],
    [ "washer_inner_diameter", 4.7625 ],
    [ "washer_outer_diameter", 11.1125 ],
    [ "washer_thickness", 1.190625 ],
    [ "nut_thickness", 3.302 ],
    [ "nut_thickness_max", 2.9718 ],
    [ "nut_thickness_min", 3.302 ],
  ] ],
  [ "UNC-#10", [
    [ "name", "UNC-#10" ],
    [ "thread_pitch", 1.05833 ],
    [ "thread_spec", "UNC-#10" ],
    [ "thread_diameter", 4.826 ],
    [ "thread_diameter_max", 4.826 ],
    [ "head_thickness", 3.048 ],
    [ "head_thickness_max", 3.048 ],
    [ "head_thickness_min", 2.667 ],
    [ "head_across_flats", 7.9375 ],
    [ "head_across_flats_max", 7.747 ],
    [ "head_across_flats_min", 7.9248 ],
    [ "washer_inner_diameter", 5.55625 ],
    [ "washer_outer_diameter", 12.7 ],
    [ "washer_thickness", 1.190625 ],
    [ "nut_thickness", 3.302 ],
    [ "nut_thickness_max", 2.9718 ],
    [ "nut_thickness_min", 3.302 ],
  ] ],
  [ "UNC-#12", [
    [ "name", "UNC-#12" ],
    [ "thread_pitch", 1.05833 ],
    [ "thread_spec", "UNC-#12" ],
    [ "thread_diameter", 5.461 ],
    [ "thread_diameter_max", 5.461 ],
    [ "head_thickness", 3.937 ],
    [ "head_thickness_max", 3.937 ],
    [ "head_thickness_min", 3.5306 ],
    [ "head_across_flats", 7.9375 ],
    [ "head_across_flats_max", 7.747 ],
    [ "head_across_flats_min", 7.9248 ],
    [ "washer_inner_diameter", 6.35 ],
    [ "washer_outer_diameter", 14.2875 ],
    [ "washer_thickness", 1.5875 ],
    [ "nut_thickness", 4.0894 ],
    [ "nut_thickness_max", 3.7592 ],
    [ "nut_thickness_min", 4.0894 ],
  ] ],
  [ "UNC-1/4", [
    [ "name", "UNC-1/4" ],
    [ "thread_pitch", 1.27 ],
    [ "thread_spec", "UNC-1/4" ],
    [ "thread_diameter", 6.35 ],
    [ "thread_diameter_max", 6.35 ],
    [ "thread_diameter_min", 6.1087 ],
    [ "head_thickness", 3.96875 ],
    [ "head_thickness_max", 4.1402 ],
    [ "head_thickness_min", 3.81 ],
    [ "head_across_flats", 11.1125 ],
    [ "head_across_flats_max", 11.1252 ],
    [ "head_across_flats_min", 10.8712 ],
    [ "washer_inner_diameter", 7.14375 ],
    [ "washer_outer_diameter", 15.875 ],
    [ "washer_thickness", 1.5875 ],
    [ "fender_washer_inner_diameter", 7.9248 ],
    [ "fender_washer_outer_diameter", 18.6436 ],
    [ "fender_washer_thickness", 1.651 ],
    [ "nut_thickness", 5.55625 ],
    [ "nut_thickness_max", 5.3848 ],
    [ "nut_thickness_min", 5.7404 ],
  ] ],
  [ "UNC-5/16", [
    [ "name", "UNC-5/16" ],
    [ "thread_pitch", 1.41111 ],
    [ "thread_spec", "UNC-5/16" ],
    [ "thread_diameter", 7.9375 ],
    [ "thread_diameter_max", 7.9375 ],
    [ "thread_diameter_min", 7.7851 ],
    [ "head_thickness", 5.159375 ],
    [ "head_thickness_max", 5.3594 ],
    [ "head_thickness_min", 4.953 ],
    [ "head_across_flats", 12.7 ],
    [ "head_across_flats_max", 12.7 ],
    [ "head_across_flats_min", 12.4206 ],
    [ "washer_inner_diameter", 8.73125 ],
    [ "washer_outer_diameter", 17.4625 ],
    [ "washer_thickness", 1.5875 ],
    [ "fender_washer_inner_diameter", 9.525 ],
    [ "fender_washer_outer_diameter", 22.225 ],
    [ "fender_washer_thickness", 2.1082 ],
    [ "nut_thickness", 6.746875 ],
    [ "nut_thickness_max", 6.5532 ],
    [ "nut_thickness_min", 6.9342 ],
  ] ],
  [ "UNC-3/8", [
    [ "name", "UNC-3/8" ],
    [ "thread_pitch", 1.5875 ],
    [ "thread_spec", "UNC-3/8" ],
    [ "thread_diameter", 9.525 ],
    [ "thread_diameter_max", 0.9525 ],
    [ "thread_diameter_min", 9.3726 ],
    [ "head_thickness", 5.953125 ],
    [ "head_thickness_max", 6.1722 ],
    [ "head_thickness_min", 5.7404 ],
    [ "head_across_flats", 14.2875 ],
    [ "head_across_flats_max", 14.2748 ],
    [ "head_across_flats_min", 13.9954 ],
    [ "washer_inner_diameter", 10.31875 ],
    [ "washer_outer_diameter", 20.6375 ],
    [ "washer_thickness", 1.5875 ],
    [ "fender_washer_inner_diameter", 11.1252 ],
    [ "fender_washer_outer_diameter", 25.4 ],
    [ "fender_washer_thickness", 2.1082 ],
    [ "nut_thickness", 8.334375 ],
    [ "nut_thickness_max", 8.128 ],
    [ "nut_thickness_min", 8.5598 ],
  ] ],
  [ "UNC-7/16", [
    [ "name", "UNC-7/16" ],
    [ "thread_pitch", 1.81429 ],
    [ "thread_spec", "UNC-7/16" ],
    [ "thread_diameter", 11.1125 ],
    [ "thread_diameter_max", 11.1125 ],
    [ "thread_diameter_min", 10.9347 ],
    [ "head_thickness", 7.14375 ],
    [ "head_thickness_max", 7.3914 ],
    [ "head_thickness_min", 6.9088 ],
    [ "head_across_flats", 17.4625 ],
    [ "head_across_flats_max", 17.4752 ],
    [ "head_across_flats_min", 17.145 ],
    [ "washer_inner_diameter", 11.90625 ],
    [ "washer_outer_diameter", 23.415625 ],
    [ "washer_thickness", 1.5875 ],
    [ "fender_washer_inner_diameter", 12.7 ],
    [ "fender_washer_outer_diameter", 31.75 ],
    [ "fender_washer_thickness", 2.1082 ],
    [ "nut_thickness", 9.525 ],
    [ "nut_thickness_max", 9.271 ],
    [ "nut_thickness_min", 9.779 ],
  ] ],
  [ "UNC-1/2", [
    [ "name", "UNC-1/2" ],
    [ "thread_pitch", 1.95385 ],
    [ "thread_spec", "UNC-1/2" ],
    [ "thread_diameter", 12.7 ],
    [ "thread_diameter_max", 12.7 ],
    [ "thread_diameter_min", 12.5222 ],
    [ "head_thickness", 7.9375 ],
    [ "head_thickness_max", 8.2042 ],
    [ "head_thickness_min", 7.6708 ],
    [ "head_across_flats", 19.05 ],
    [ "head_across_flats_max", 19.05 ],
    [ "head_across_flats_min", 18.6944 ],
    [ "washer_inner_diameter", 13.49375 ],
    [ "washer_outer_diameter", 26.9875 ],
    [ "washer_thickness", 2.38125 ],
    [ "fender_washer_inner_diameter", 14.2748 ],
    [ "fender_washer_outer_diameter", 34.925 ],
    [ "fender_washer_thickness", 2.7686 ],
    [ "nut_thickness", 11.1125 ],
    [ "nut_thickness_max", 10.8458 ],
    [ "nut_thickness_min", 11.3792 ],
  ] ],
  [ "UNC-9/16", [
    [ "name", "UNC-9/16" ],
    [ "thread_pitch", 2.11667 ],
    [ "thread_spec", "UNC-9/16" ],
    [ "thread_diameter", 14.2875 ],
    [ "thread_diameter_max", 14.2875 ],
    [ "thread_diameter_min", 14.0843 ],
    [ "head_thickness", 9.128125 ],
    [ "head_thickness_max", 9.4234 ],
    [ "head_thickness_min", 8.8392 ],
    [ "head_across_flats", 22.225 ],
    [ "head_across_flats_max", 22.225 ],
    [ "head_across_flats_min", 21.8694 ],
    [ "washer_inner_diameter", 15.08125 ],
    [ "washer_outer_diameter", 30.1625 ],
    [ "washer_thickness", 2.38125 ],
    [ "fender_washer_inner_diameter", 15.875 ],
    [ "fender_washer_outer_diameter", 37.3126 ],
    [ "fender_washer_thickness", 2.7686 ],
    [ "nut_thickness", 12.303125 ],
    [ "nut_thickness_max", 12.0142 ],
    [ "nut_thickness_min", 12.5984 ],
  ] ],
  [ "UNC-5/8", [
    [ "name", "UNC-5/8" ],
    [ "thread_pitch", 2.30909 ],
    [ "thread_spec", "UNC-5/8" ],
    [ "thread_diameter", 15.875 ],
    [ "thread_diameter_max", 15.875 ],
    [ "thread_diameter_min", 15.6718 ],
    [ "head_thickness", 9.921875 ],
    [ "head_thickness_max", 10.2362 ],
    [ "head_thickness_min", 9.6012 ],
    [ "head_across_flats", 23.8125 ],
    [ "head_across_flats_max", 23.8252 ],
    [ "head_across_flats_min", 23.4188 ],
    [ "washer_inner_diameter", 16.66875 ],
    [ "washer_outer_diameter", 33.3375 ],
    [ "washer_thickness", 2.38125 ],
    [ "fender_washer_inner_diameter", 17.4752 ],
    [ "fender_washer_outer_diameter", 44.45 ],
    [ "fender_washer_thickness", 3.4036 ],
    [ "nut_thickness", 13.890625 ],
    [ "nut_thickness_max", 13.589 ],
    [ "nut_thickness_min", 14.1986 ],
  ] ],
  [ "UNC-3/4", [
    [ "name", "UNC-3/4" ],
    [ "thread_pitch", 2.54 ],
    [ "thread_spec", "UNC-3/4" ],
    [ "thread_diameter", 19.05 ],
    [ "thread_diameter_max", 19.05 ],
    [ "thread_diameter_min", 18.8214 ],
    [ "head_thickness", 11.90625 ],
    [ "head_thickness_max", 12.2682 ],
    [ "head_thickness_min", 11.557 ],
    [ "head_across_flats", 28.575 ],
    [ "head_across_flats_max", 28.575 ],
    [ "head_across_flats_min", 27.6352 ],
    [ "washer_inner_diameter", 20.6375 ],
    [ "washer_outer_diameter", 38.1 ],
    [ "washer_thickness", 3.571875 ],
    [ "fender_washer_inner_diameter", 20.6248 ],
    [ "fender_washer_outer_diameter", 50.8 ],
    [ "fender_washer_thickness", 3.7592 ],
    [ "nut_thickness", 16.271875 ],
    [ "nut_thickness_max", 15.6718 ],
    [ "nut_thickness_min", 16.891 ],
  ] ],
  [ "UNC-7/8", [
    [ "name", "UNC-7/8" ],
    [ "thread_pitch", 2.82222 ],
    [ "thread_spec", "UNC-7/8" ],
    [ "thread_diameter", 22.225 ],
    [ "thread_diameter_max", 22.225 ],
    [ "thread_diameter_min", 21.9964 ],
    [ "head_thickness", 13.890625 ],
    [ "head_thickness_max", 14.3002 ],
    [ "head_thickness_min", 13.4874 ],
    [ "head_across_flats", 33.3375 ],
    [ "head_across_flats_max", 33.3248 ],
    [ "head_across_flats_min", 32.2326 ],
    [ "washer_inner_diameter", 23.8125 ],
    [ "washer_outer_diameter", 44.45 ],
    [ "washer_thickness", 3.571875 ],
    [ "fender_washer_inner_diameter", 23.8252 ],
    [ "fender_washer_outer_diameter", 57.15 ],
    [ "fender_washer_thickness", 4.191 ],
    [ "nut_thickness", 19.05 ],
    [ "nut_thickness_max", 18.3896 ],
    [ "nut_thickness_min", 19.7104 ],
  ] ],
  [ "UNC-1", [
    [ "name", "UNC-1" ],
    [ "thread_pitch", 3.175 ],
    [ "thread_spec", "UNC-1" ],
    [ "thread_diameter", 25.4 ],
    [ "thread_diameter_max", 25.4 ],
    [ "thread_diameter_min", 25.146 ],
    [ "head_thickness", 15.478125 ],
    [ "head_thickness_max", 15.9258 ],
    [ "head_thickness_min", 15.0114 ],
    [ "head_across_flats", 38.1 ],
    [ "head_across_flats_max", 38.1 ],
    [ "head_across_flats_min", 36.83 ],
    [ "washer_inner_diameter", 26.9875 ],
    [ "washer_outer_diameter", 50.8 ],
    [ "washer_thickness", 3.571875 ],
    [ "fender_washer_inner_diameter", 26.9748 ],
    [ "fender_washer_outer_diameter", 63.5 ],
    [ "fender_washer_thickness", 4.191 ],
    [ "nut_thickness", 21.828125 ],
    [ "nut_thickness_max", 21.1074 ],
    [ "nut_thickness_min", 22.5298 ],
  ] ],
  [ "UNC-1 1/8", [
    [ "name", "UNC-1 1/8" ],
    [ "thread_pitch", 3.62857 ],
    [ "thread_spec", "UNC-1 1/8" ],
    [ "thread_diameter", 28.575 ],
    [ "thread_diameter_max", 28.575 ],
    [ "thread_diameter_min", 28.2956 ],
    [ "head_thickness", 17.4625 ],
    [ "head_thickness_max", 18.2372 ],
    [ "head_thickness_min", 16.7132 ],
    [ "head_across_flats", 42.8625 ],
    [ "head_across_flats_max", 42.8752 ],
    [ "head_across_flats_min", 41.4274 ],
    [ "washer_inner_diameter", 30.1625 ],
    [ "washer_outer_diameter", 57.15 ],
    [ "washer_thickness", 3.571875 ],
    [ "fender_washer_inner_diameter", 31.75 ],
    [ "fender_washer_outer_diameter", 69.85 ],
    [ "fender_washer_thickness", 4.191 ],
    [ "nut_thickness", 24.60625 ],
    [ "nut_thickness_max", 23.8506 ],
    [ "nut_thickness_min", 25.3746 ],
  ] ],
  [ "UNC-1 1/4", [
    [ "name", "UNC-1 1/4" ],
    [ "thread_pitch", 3.62857 ],
    [ "thread_spec", "UNC-1 1/4" ],
    [ "thread_diameter", 31.75 ],
    [ "thread_diameter_max", 31.75 ],
    [ "thread_diameter_min", 31.4706 ],
    [ "head_thickness", 19.84375 ],
    [ "head_thickness_max", 20.6502 ],
    [ "head_thickness_min", 19.0246 ],
    [ "head_across_flats", 47.625 ],
    [ "head_across_flats_max", 47.625 ],
    [ "head_across_flats_min", 46.0248 ],
    [ "washer_inner_diameter", 33.3375 ],
    [ "washer_outer_diameter", 63.5 ],
    [ "washer_thickness", 3.96875 ],
    [ "fender_washer_inner_diameter", 34.925 ],
    [ "fender_washer_outer_diameter", 76.2 ],
    [ "fender_washer_thickness", 4.191 ],
    [ "nut_thickness", 26.9875 ],
    [ "nut_thickness_max", 26.162 ],
    [ "nut_thickness_min", 27.7876 ],
  ] ],
  [ "UNC-1 3/8", [
    [ "name", "UNC-1 3/8" ],
    [ "thread_pitch", 4.23333 ],
    [ "thread_spec", "UNC-1 3/8" ],
    [ "thread_diameter", 34.925 ],
    [ "thread_diameter_max", 34.925 ],
    [ "head_thickness", 21.43125 ],
    [ "head_thickness_max", 22.3012 ],
    [ "head_thickness_min", 20.574 ],
    [ "head_across_flats", 52.3875 ],
    [ "head_across_flats_max", 52.3748 ],
    [ "head_across_flats_min", 50.6476 ],
    [ "washer_inner_diameter", 36.5125 ],
    [ "washer_outer_diameter", 69.85 ],
    [ "washer_thickness", 3.96875 ],
    [ "fender_washer_inner_diameter", 38.1 ],
    [ "fender_washer_outer_diameter", 82.55 ],
    [ "fender_washer_thickness", 4.572 ],
    [ "nut_thickness", 29.765625 ],
    [ "nut_thickness_max", 28.9052 ],
    [ "nut_thickness_min", 30.6324 ],
  ] ],
  [ "UNC-1 1/2", [
    [ "name", "UNC-1 1/2" ],
    [ "thread_pitch", 4.23333 ],
    [ "thread_spec", "UNC-1 1/2" ],
    [ "thread_diameter", 38.1 ],
    [ "thread_diameter_max", 38.1 ],
    [ "thread_diameter_min", 37.7952 ],
    [ "head_thickness", 33.3375 ],
    [ "head_thickness_max", 24.7396 ],
    [ "head_thickness_min", 22.9108 ],
    [ "head_across_flats", 57.15 ],
    [ "head_across_flats_max", 57.15 ],
    [ "head_across_flats_min", 55.245 ],
    [ "washer_inner_diameter", 39.6875 ],
    [ "washer_outer_diameter", 76.2 ],
    [ "washer_thickness", 3.96875 ],
    [ "fender_washer_inner_diameter", 41.275 ],
    [ "fender_washer_outer_diameter", 88.9 ],
    [ "fender_washer_thickness", 4.572 ],
    [ "nut_thickness", 32.54375 ],
    [ "nut_thickness_max", 31.623 ],
    [ "nut_thickness_min", 33.4518 ],
  ] ],
];

//fastener_demo();
