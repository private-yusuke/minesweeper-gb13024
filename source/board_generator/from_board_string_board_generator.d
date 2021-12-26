module board_generator.from_board_string_board_generator;

import board_generator;
import index2d;

struct BoardSize {
    uint width;
    uint height;
}

class LoadBoardStringException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class FromBoardStringBoardGenerator : BoardGenerator {
    private Index2D[] _mine_indexes;

    this(string board_content) {
        import std.conv : to, ConvException;
        import std.array : appender, split;

        string[] lines = board_content.split("\n");
        string[] preamble = lines[0].split(" ");

        try {
            this._board_width = preamble[0].to!uint;
            this._board_height = preamble[1].to!uint;
        } catch (ConvException e) {
            throw new LoadBoardStringException("Failed to parse preamble");
        }
        
        foreach (y, row; lines[1..$]) {
            foreach (x, cell_char; row) {
                if (cell_char == '*') {
                    this._mine_indexes ~= Index2D(cast(int) x, cast(int) y);
                } else if (cell_char != '#') {
                    throw new LoadBoardStringException("Invalid character found in the board string");
                }
            }
        }
    }

    override @property Index2D[] mineIndexes() {
        return this._mine_indexes;
    }

    @("FromBoardStringBoardGenerator")
    unittest {
        string a = r"3 4
##*
*##
#*#";
        auto g = new FromBoardStringBoardGenerator(a);
        assert(g.mineIndexes == [Index2D(2, 0), Index2D(0, 1), Index2D(1, 2)]);
    }

    @("FromBoardStringBoardGenerator throws LoadBoardStringException when preamble is invalid")
    unittest {
        string a = r"1f 2i
##*
*##
#*#";
        import std.exception : assertThrown;
        assertThrown(new FromBoardStringBoardGenerator(a));
    }

    @("FromBoardStringBoardGenerator throws LoadBoardStringException when an invalid character is present in the input")
    unittest {
        string a = r"3 4
##*
*:#
#*#";
        import std.exception : assertThrown;
        assertThrown(new FromBoardStringBoardGenerator(a));
    }
}