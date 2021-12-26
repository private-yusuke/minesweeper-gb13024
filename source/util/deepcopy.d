module util.deepcopy;

T[] deepcopy(T)(T[] a) {
	import std.traits : isArray;
	static if(isArray!T) {
		T[] res;
		foreach(i; a) {
			res ~= deepcopy(i);
		}
		return res;
	} else {
		return a.dup;
	}
}

@("deepcopy")
unittest
{
	auto a = [[[1,2],[3,4]],[[5,6],[7,8]]];
	auto b = a.deepcopy;
	b[0][0][1] = 100;
	assert(a != b);
}