//
// Copyright (c) Stewart H. Whitman, 2022.
//
// File:    pair.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Simple ordering pair primitives.
//

// pair_swap:
//
// Swap pair list <list>'s elements.
//
function pair_swap(list) = [ list[1], list[0] ];

// pair_order_closest, pair_order_farthest:
//
// Order pair list <list>'s elements by euclidean norm (distance).
//
function pair_order_closest( p, list ) = norm( p - list[0]) < norm( p - list[1]) ? list : pair_swap(list);
function pair_order_farthest( p, list ) = pair_swap( pair_order_closest( p, list ) );

// _pair_order_closest_index:
//
// Order pair list <list>'s elements by smallest co-ordinate <i> difference.
//
function _pair_order_closest_index( p, list, i ) = abs( p[i] - list[0][i]) < abs( p[i] - list[1][i]) ? list : pair_swap(list);

// pair_order:
//
// Order pair list <l>'s relative to point <p> by order <order>.
//
function pair_order( p, list, order ) =
  order == "closest-x"  ? _pair_order_closest_index( p, list, 0 ) :
  order == "closest-y"  ? _pair_order_closest_index( p, list, 1 ) :
  order == "closest-z"  ? _pair_order_closest_index( p, list, 2 ) :
  order == "farthest-x" ? pair_swap( _pair_order_closest_index( p, list, 0 ) ) :
  order == "farthest-y" ? pair_swap( _pair_order_closest_index( p, list, 1 ) ) :
  order == "farthest-z" ? pair_swap( _pair_order_closest_index( p, list, 2 ) ) :
  order == "closest"    ? pair_order_closest( p, list ) :
  order == "farthest"   ? pair_order_farthest( p, list ) :
  order == "first"      ? list :
  order == "last"       ? pair_swap( list ) :
  error( "pair_order: bad order", order );

//assert( pair_swap( [[1,0], [-1,2]] ) == [[-1,2], [1,0]] );
//assert( pair_order( [0,0], [[1.1,0], [-1,2]], "closest-x" ) == [[-1,2], [1.1,0]] );
//assert( pair_order( [0,0], [[1.1,0], [-1,2]], "farthest-x" ) == [[1.1,0], [-1,2]] );
//assert( pair_order( [0,0], [[1,0], [-1,2]], "farthest-y" ) == [[-1,2], [1,0]] );
//assert( pair_order( [0,0], [[1,0], [-1,2]], "closest-y" ) == [[1,0], [-1,2]] );
//assert( pair_order( [1,0,1], [[4,0,2], [-12,20,2]], "farthest" ) == [[-12,20,2],[4,0,2]] );
//assert( pair_order( [1,0,1], [[4,0,2], [-12,20,2]], "closest" ) == [[4,0,2], [-12,20,2]] );
