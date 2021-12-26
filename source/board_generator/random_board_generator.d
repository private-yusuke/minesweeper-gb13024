module board_generator.random_board_generator;

import board_generator.board_generator;
import index2d;

class TooManyMineException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class RandomBoardGenerator : BoardGenerator {
    private uint _mine_amount;

    this(uint board_height, uint board_width, uint mine_amount)
    {
        if (mine_amount >= board_height * board_width) {
            import std.string : format;
            
            throw new TooManyMineException("Too many mine: %d >= %d * %d = %d"
                .format(mine_amount, board_height, board_width, board_height * board_width)
            );
        }

        this._board_width = board_width;
        this._board_height = board_height;
        this._mine_amount = mine_amount;
    }

    override @property Index2D[] mineIndexes() {
        import std.random : uniform;
        import std.container.rbtree : redBlackTree;
        import std.range : array;

        ulong generated_count;
        auto indexesSet = redBlackTree!Index2D;

        while (generated_count < this._mine_amount) {
            uint y = uniform(0, this._board_height);
            uint x = uniform(0, this._board_width);

            if (indexesSet.insert(Index2D(x, y))) {
                generated_count++;
            }
        }

        return indexesSet.array;
    }
}
