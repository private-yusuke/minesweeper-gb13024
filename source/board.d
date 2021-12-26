module board;

import cell;

import index2d;

class InvalidIndexException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }

    this(string file = __FILE__, size_t line = __LINE__) {
        super("", file, line);
    }
}

class Board {
    private uint _height;
    private uint _width;
    private uint _mine_amount;
    private uint _flag_count;
    private uint _opened_count;

    /// ボード上の各マスの種類
    private Cell[][] _cells;

    /// 近傍 8 マスにある爆弾マスの個数をメモするための配列。メモされていない場合は -1 が格納される
    private byte[][] _surrounding_mine_cell_counts;

    // setter は private だが、getter は外からアクセス可能
    @property uint height() const @safe pure nothrow { return _height; }
    @property uint width() const @safe pure nothrow { return _width; }
    @property uint mine_amount() const @safe pure nothrow { return _mine_amount; }
    @property uint flag_count() const @safe pure nothrow { return _flag_count; }
    @property uint opened_count() const @safe pure nothrow { return _opened_count; }

    /// デバッグ時・unittest 実行時にのみ _cells にアクセス可能
    debug @property Cell[][] cells() @safe pure nothrow { return _cells; }

    this(uint height, uint width) {
        this._cells = new Cell[][](height, width);

        this._surrounding_mine_cell_counts = new byte[][](height, width);
        // _surrounding_mine_cell_counts のすべての要素を -1 に設定する
        foreach (ref row; this._surrounding_mine_cell_counts) {
            row[] = -1;
        }

        this._width = width;
        this._height = height;
    }

    /// 与えられた座標にあるマスの種類を取得します。
    Cell getCell(Index2D i2d) const
    in {
        assert(this.isValidCellIndex(i2d));
    } do {
        if (!this.isValidCellIndex(i2d)) {
            throw new InvalidIndexException;
        }
        return this._cells[i2d.y][i2d.x];
    }

    /// 与えられた座標にあるマスの種類を設定します。
    private void setCell(Index2D i2d, Cell cell)
    in {
        assert(this.isValidCellIndex(i2d));
    } do {
        if (!this.isValidCellIndex(i2d)) {
            throw new InvalidIndexException;
        }
        this._cells[i2d.y][i2d.x] = cell;
    }

    /// 与えられた座標にあるマスを地雷に設定します。
    bool setMine(Index2D i2d) {
        if (this.getCell(i2d) == Cell.mine) return false;

        this._mine_amount++;
        this.setCell(i2d, Cell.mine);
        return true;
    }

    /**
     * 与えられた座標にあるマスを開きます。このとき、周囲のマスで開けられるものは可能な限り開けます。
     * 与えられた座標に地雷があったとしても、なかったものとして開けることに注意してください。
     */
    void openCell(Index2D i2d) {
        const Index2D[] ds = [
            Index2D(-1, 1), Index2D(0, 1), Index2D(1, 1), Index2D(1, 0),
            Index2D(1, -1), Index2D(0, -1), Index2D(-1, -1), Index2D(-1, 0),
        ];

        Cell cell = this.getCell(i2d);

        if (cell != Cell.opened && !cell.isFlaggedCell) {
            this.setCell(i2d, Cell.opened);
            this._opened_count++;
        }

        if (this.getSurroundingMineCellCount(i2d) != 0) return;

        foreach (d; ds) {
            Index2D surroundingIndex = i2d + d;
            if (!this.isValidCellIndex(surroundingIndex) || this.getCell(surroundingIndex) == Cell.opened) continue;

            this.openCell(surroundingIndex);
        }
    }

    /**
     * 与えられた座標にあるマスの旗の切り替えを行い、true を返します。
     * すでに開けられたマスに対して操作をしようとした場合は、何もせずに false を返します。
     */
    bool toggleFlagged(Index2D i2d)
    in {
        assert(this.isValidCellIndex(i2d));
    } out (result) {
        if (this.getCell(i2d) == Cell.opened) {
            assert(!result);
        }
    } do {
        Cell cell = this.getCell(i2d);
        const Cell[Cell] toggleMapping = [
            Cell.empty: Cell.emptyFlagged,
            Cell.mine: Cell.mineFlagged,
            Cell.emptyFlagged: Cell.empty,
            Cell.mineFlagged: Cell.mine,
        ];
        if (cell in toggleMapping) {
            this.setCell(i2d, toggleMapping[cell]);

            if (toggleMapping[cell].isFlaggedCell) {
                this._flag_count++;
            } else this._flag_count--;

            return true;
        } else return false;
    }

    /**
     * 与えられた座標の近傍 8 マスにある爆弾マスの個数を取得します。
     * 高頻度で呼び出される想定のため、計算済みのマスについては結果が保持されます。
     */
    ubyte getSurroundingMineCellCount(Index2D i2d)
    in {
        assert(this.isValidCellIndex(i2d));
    } do {
        // すでに計算済みだった場合、それを返す
        if (this._surrounding_mine_cell_counts[i2d.y][i2d.x] >= 0) {
            return this._surrounding_mine_cell_counts[i2d.y][i2d.x];
        }

        ubyte mineCellCount;
        /*
         * 次のような順序で爆弾マスの探索を行う（x は与えられた座標にあるマス）
         *     012
         *     7x3
         *     654
         */
        const Index2D[] ds = [
            Index2D(-1, 1), Index2D(0, 1), Index2D(1, 1), Index2D(1, 0),
            Index2D(1, -1), Index2D(0, -1), Index2D(-1, -1), Index2D(-1, 0),
        ];
        foreach (d; ds) {
            const surroundIndex = i2d + d;
            if (this.isValidCellIndex(surroundIndex) && isMineCell(this.getCell(surroundIndex))) {
                mineCellCount++;
            }
        }

        this._surrounding_mine_cell_counts[i2d.y][i2d.x] = mineCellCount;
        return mineCellCount;
    }

    /// 与えられた座標の近傍 8 マスにある旗の付いたマスの個数を取得します。
    ubyte getSurroundingFlaggedCellCount(Index2D i2d)
    in {
        assert(this.isValidCellIndex(i2d));
    } do {
        ubyte flaggedCellCount;

        const Index2D[] ds = [
            Index2D(-1, 1), Index2D(0, 1), Index2D(1, 1), Index2D(1, 0),
            Index2D(1, -1), Index2D(0, -1), Index2D(-1, -1), Index2D(-1, 0),
        ];
        foreach (d; ds) {
            const surroundIndex = i2d + d;
            if (this.isValidCellIndex(surroundIndex) && isFlaggedCell(this.getCell(surroundIndex))) {
                flaggedCellCount++;
            }
        }

        return flaggedCellCount;
    }

    /// 与えられた座標がボード上に存在するマスを指しているならば true を、そうでないなら false を返します。
    bool isValidCellIndex(Index2D i2d) const @safe pure nothrow {
        return 0 <= i2d.y && i2d.y < this._height && 0 <= i2d.x && i2d.x < this._width;
    }

    /// 与えられた Cell をアスキーアート用の文字列にして返します。
    private string getCellString(Index2D i2d)
    in {
        assert(this.isValidCellIndex(i2d));
    } do {
        Cell cell = this.getCell(i2d);

        with (Cell) switch (cell) {
            case empty, mine:
                return "x";
            case emptyFlagged, mineFlagged:
                return "F";
            case opened:
                import std.string : format;

                ubyte surroundingMineCount = this.getSurroundingMineCellCount(i2d);
                if (surroundingMineCount == 0) return " ";
                else return "%d".format(surroundingMineCount);
            default:
                assert(0);
        }
    }

    /// ボードの状況をアスキーアートにして返します。
    override string toString()
    {
        // Java の StringBuilder のようなもの（String 以外の用途でも使用可能）
        import std.array : appender;
        import std.string : format;
        import std.range : repeat;

        auto strBuilder = appender!string;

        strBuilder.put("Remaining flags: %d\n".format(this.mine_amount - this.flag_count));
        strBuilder.put(" [y]\n");
        foreach(y; 0..this.height) {
            strBuilder.put(" %2d│".format(y));
            foreach(x; 0..this.width) {
                Index2D cellIndex = Index2D(x, y);
                strBuilder.put(" %s".format(this.getCellString(cellIndex)));
            }
            strBuilder.put("\n");
        }
        strBuilder.put("   └─");
        strBuilder.put('─'.repeat(this.width * 2));
        strBuilder.put("\n");

        // 横軸ラベルの描画
        strBuilder.put("    ");
        foreach(x; 0..this.width) {
            strBuilder.put(" %d".format(x % 10));
        }
        strBuilder.put(" [x]\n");
        return strBuilder.data;
    }

    /// デバッグ用：このボード上に実際にある地雷の数を返します。
    debug ulong getActualMineCount() const {
        import std.algorithm : map, count, sum;
        return this._cells.map!(row => row.count!(cell => cell == Cell.mine)).sum;
    }

    /// ボードの等価判定は Cell にのみ基いて行われます。
    override bool opEquals(Object other)
    {
        import std.algorithm.comparison : equal;
        Board rhs = cast(Board) other;
        return rhs && equal!equal(this._cells, rhs._cells);
    }

    @("Board opEquals")
    unittest {
        import board_generator;

        // 異なった方法で Board を生成しても、中身が同じであるなら等価なものとされる
        auto g = new ManualBoardGenerator(2, 2);
        g.addMineIndex(Index2D(0, 0));
        Board a = g.generateBoard();

        Board b = new Board(2, 2);
        b.setCell(Index2D(0, 0), Cell.mine);
        assert(a == b);

        Board c = new Board(2, 2);
        c.setCell(Index2D(0, 0), Cell.mineFlagged);
        assert(b != c);
    }
}