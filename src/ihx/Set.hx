/* ************************************************************************ */
/*                                                                          */
/*  Copyright (c) 2009-2020 Ian Martins (ianxm@jhu.edu)                     */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 3.0 of the License, or (at your option) any later version.       */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */

package ihx;

using Lambda;

abstract Set<T>(Array<T>) to Iterable<T>
{
        public function new( a:Array<T> )
                this = a;

        public inline function add( i:T ) {
                if ( this.indexOf(i)==-1 ) this.push( i );
        }

        public function remove( i:T ) {
                var removed = false;
                while ( this.remove(i) ) removed = true;
                return removed;
        }

        public var length(get,never):Int;
        inline function get_length() return this.length;
        public inline function iterator() return this.iterator();
        public inline function join( sep ) return this.join( sep );

        @:from public static function fromArray<T>( a:Array<T> ) {
                var s = [];
                for ( item in a ) {
                        if ( s.indexOf(item)==-1 ) s.push( item );
                }
                return new Set( s );
        }
}
