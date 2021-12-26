module board_generator.manual_board_generator;

import board_generator;
import index2d;
import std.container.rbtree;

class ManualBoardGenerator : BoardGenerator {
    private RedBlackTree!Index2D _mine_indexes;

    this(uint board_width, uint board_height)
    {
        this._board_width = board_width;
        this._board_height = board_height;
        this._mine_indexes = redBlackTree!Index2D;
    }

    /**
     * 地雷の位置を追加します。
     * すでに追加されていた場合は何もせず false を返します。
     */
    bool addMineIndex(Index2D index) {
        return this._mine_indexes.insert(index) != 0;
    }
    
    /**
     * 地雷の位置を削除します。
     * 元から入っていなかった場合は何もせず false を返します。
     */
    bool removeMineIndex(Index2D index) {
        return this._mine_indexes.removeKey(index) != 0;
    }

    @("ManualBoardGenerator add/remove mine index")
    unittest {
        ManualBoardGenerator g = new ManualBoardGenerator(2, 2);

        assert(g.addMineIndex(Index2D(0, 0)));
        assert(!g.addMineIndex(Index2D(0, 0)));
        assert(g.removeMineIndex(Index2D(0, 0)));
        assert(!g.removeMineIndex(Index2D(0, 0)));
    }

    override @property Index2D[] mineIndexes() {
        import std.range : array;
        return this._mine_indexes.array;
    }

    @("ManualBoardGenerator mineIndexes")
    unittest {
        ManualBoardGenerator g = new ManualBoardGenerator(2, 2);

        g.addMineIndex(Index2D(0, 0));
        g.addMineIndex(Index2D(1, 0));
        g.addMineIndex(Index2D(1, 1));
        g.removeMineIndex(Index2D(1, 0));

        assert(redBlackTree(g.mineIndexes) == redBlackTree([Index2D(0, 0), Index2D(1, 1)]));
    }
}
