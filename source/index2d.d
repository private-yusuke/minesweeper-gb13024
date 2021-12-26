module index2d;

/// ボード上の座標を表すための構造体
struct Index2D {
    int x;
    int y;

    int opCmp(const Index2D other) const
    {
        const long a = (cast(long) this.y << 31) + this.x;
        const long b = (cast(long) other.y << 31) + other.x;

        if (a < b) return -1;
        else if (a > b) return 1;
        else return 0;
    }

    @("Index2D opCmp")
    unittest {
        assert(Index2D(0, 0) == Index2D(0, 0));
        assert(Index2D(0, 0) < Index2D(1, 0));
        assert(Index2D(0, 0) < Index2D(0, 1));
        assert(Index2D(0, 0) < Index2D(1, 1));

        assert(Index2D(1, 0) > Index2D(0, 0));
        assert(Index2D(0, 1) > Index2D(0, 0));
        assert(Index2D(1, 1) > Index2D(0, 0));

        assert(Index2D(0, 1) > Index2D(1, 0));
        assert(Index2D(1, 0) < Index2D(0, 1));

        assert(Index2D(int.max, 0) < Index2D(0, 1));
        assert(Index2D(int.max, int.max - 1) < Index2D(int.max, int.max));
        assert(Index2D(int.max - 1, int.max) < Index2D(int.max, int.max));
    }

    Index2D opBinary(string op)(const Index2D rhs) const if (op == "+") {
        return Index2D(this.x + rhs.x, this.y + rhs.y);
    }

    Index2D opBinary(string op)(const Index2D rhs) const if (op == "-") {
        return Index2D(this.x - rhs.x, this.y - rhs.y);
    }

    @("opBinary")
    unittest {
        assert(Index2D(1, 2) + Index2D(3, 4) == Index2D(4, 6));
        assert(Index2D(1, 2) - Index2D(3, 4) == Index2D(-2, -2));
    }
}