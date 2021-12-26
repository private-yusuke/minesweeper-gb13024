module command.open_command;

import command;
import board;
import game;
import index2d;
import cell;

class OpenCommand : Command {
    void execute(string[] args, Game game) {
        import std.stdio : writeln;
        if (args.length < 2) {
            writeln("Usage: o <x> <y>");
            return;
        }
        Index2D i2d = readCoordinate(args);

        if (game.board.isValidCellIndex(i2d)) {
            if (game.board.getCell(i2d) == Cell.mine) {
                game.failed = true;
                return;
            }
            game.board.openCell(i2d);
        }
    }

    @("OpenCommand to mine cell ends game as failed")
    unittest {
        import board_generator;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        g.addMineIndex(Index2D(0, 0));
        game.board = g.generateBoard();

        (new OpenCommand()).execute(["0", "0"], game);
        assert(game.failed);
    }

    @("OpenCommand to empty cell doesn't end game as failed")
    unittest {
        import board_generator;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        game.board = g.generateBoard();

        (new OpenCommand()).execute(["0", "0"], game);
        assert(!game.failed);
    }

    @("OpenCommand to the last empty cell ends game as won")
    unittest {
        import board_generator;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        g.addMineIndex(Index2D(1, 1));
        game.board = g.generateBoard();

        (new OpenCommand()).execute(["0", "0"], game);
        assert(!game.won);
        (new OpenCommand()).execute(["1", "0"], game);
        assert(!game.won);
        (new OpenCommand()).execute(["0", "1"], game);
        assert(game.won);
    }

    @("OpenCommand to flagged cell does nothing")
    unittest {
        import board_generator;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        Index2D empty_index = Index2D(0, 0);
        Index2D mine_index = Index2D(1, 1);
        g.addMineIndex(mine_index);
        game.board = g.generateBoard();
        
        game.board.toggleFlagged(mine_index);
        game.board.toggleFlagged(empty_index);

        (new OpenCommand()).execute(["0", "0"], game);
        assert(game.board.getCell(empty_index) == Cell.emptyFlagged);
        (new OpenCommand()).execute(["1", "1"], game);
        assert(game.board.getCell(mine_index) == Cell.mineFlagged);
    }
}