module cell;

/// Board 上に並んだマスの種類
enum Cell {
	empty,
	mine,
	mineFlagged,
	emptyFlagged,
	opened
}

/// 与えられた Cell に旗が立っているならば true を、そうでないなら false を返します。
bool isFlaggedCell(Cell cell) @safe pure nothrow {
    // 注：この with 文のスコープ内では、Cell 名前空間の中で定義されているものを
    // "Cell." を付けることなく参照できるようになる
    with (Cell) {
        return cell == mineFlagged || cell == emptyFlagged;
    }
}

/// 与えられた Cell は爆弾マスであるならば true を、そうでないなら false を返します。
bool isMineCell(Cell cell) @safe pure nothrow {
    // 注：この with 文のスコープ内では、Cell 名前空間の中で定義されているものを
    // "Cell." を付けることなく参照できるようになる
    with (Cell) {
        return cell == mine || cell == mineFlagged;
    }
}