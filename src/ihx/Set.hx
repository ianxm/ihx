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

	@:from public static function fromArray( a:Array<T> ) {
		var s = [];
		for ( item in a ) {
			if ( s.indexOf(item)==-1 ) s.push( item );
		}
		return new Set( s );
	}
}