module command.chord_command;

import command;
import board;
import index2d;
import cell;
import game;

class ChordCommand : Command {
    void execute(string[] args, Game game) {
        import std.stdio : writeln;
        if (args.length < 2) {
            writeln("Usage: c <x> <y>");
            return;
        }
        Index2D i2d = readCoordinate(args);

        if (!game.board.isValidCellIndex(i2d)) return;

        // 開いたマスのみに対して適用できる
        if (game.board.getCell(i2d) != Cell.opened) return;
        // マスの周囲に立てた旗の数が、マス周辺の地雷の数と一致していなければ適用しない
        if (game.board.getSurroundingFlaggedCellCount(i2d) != game.board.getSurroundingMineCellCount(i2d)) return;

        const Index2D[] ds = [
            Index2D(-1, 1), Index2D(0, 1), Index2D(1, 1), Index2D(1, 0),
            Index2D(1, -1), Index2D(0, -1), Index2D(-1, -1), Index2D(-1, 0),
        ];

        foreach (d; ds) {
            const Index2D surroundIndex = i2d + d;
            if (game.board.isValidCellIndex(surroundIndex)) {
                Cell cell = game.board.getCell(surroundIndex);

                if (cell == Cell.mine) {
                    game.failed = true;
                    return;
                }
                if (cell.isFlaggedCell) continue;

                game.board.openCell(surroundIndex);
            }
        }
    }

    @("ChordCommand to unopened cell does nothing")
    unittest {
        import board_generator;
        import util.deepcopy;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        Index2D empty_index = Index2D(0, 0);
        Index2D mine_index = Index2D(1, 1);
        g.addMineIndex(mine_index);
        game.board = g.generateBoard();

        Cell[][] originalBoardCell = game.board.cells.deepcopy;

        (new ChordCommand()).execute(["0", "0"], game);
        assert(originalBoardCell == game.board.cells);
        (new ChordCommand()).execute(["1", "1"], game);
        assert(originalBoardCell == game.board.cells);
    }

    @("ChordCommand to flagged cell does nothing")
    unittest {
        import board_generator;
        import util.deepcopy;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        Index2D empty_index = Index2D(0, 0);
        Index2D mine_index = Index2D(1, 1);
        g.addMineIndex(mine_index);
        game.board = g.generateBoard();
        
        game.board.toggleFlagged(mine_index);
        game.board.toggleFlagged(empty_index);
        Cell[][] originalBoardCell = game.board.cells.deepcopy;

        (new ChordCommand()).execute(["0", "0"], game);
        assert(originalBoardCell == game.board.cells);
        (new ChordCommand()).execute(["1", "1"], game);
        assert(originalBoardCell == game.board.cells);
    }

    @("ChordCommand to opened cell opens cells around it")
    unittest {
        import board_generator;
        import util.deepcopy;

        Game game = new Game();
        string a = r"5 4
###*#
#####
#*###
#####";
        auto g = new FromBoardStringBoardGenerator(a);
        game.board = g.generateBoard();

        (new OpenCommand()).execute(["0", "0"], game);
        (new OpenCommand()).execute(["4", "3"], game);
        (new FlagCommand()).execute(["1", "2"], game);
        (new FlagCommand()).execute(["3", "0"], game);
        (new ChordCommand()).execute(["4", "1"], game);

        assert(game.board.getCell(Index2D(4, 0)) == Cell.opened);
    }

    @("ChordCommand may open mine cells when player toggled flag at wrong cell")
    unittest {
        import board_generator;
        import util.deepcopy;

        Game game = new Game();
        string a = r"5 4
###*#
#####
#*###
#####";
        auto g = new FromBoardStringBoardGenerator(a);
        game.board = g.generateBoard();

        (new OpenCommand()).execute(["0", "0"], game);
        (new OpenCommand()).execute(["4", "3"], game);
        (new FlagCommand()).execute(["0", "2"], game);
        (new ChordCommand()).execute(["0", "1"], game);

        assert(game.failed);
    }
}