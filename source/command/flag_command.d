module command.flag_command;

import command;
import board;
import index2d;
import game;

class FlagCommand : Command {
    void execute(string[] args, Game game) {
        import std.stdio : writeln;
        if (args.length < 2) {
            writeln("Usage: f <x> <y>");
            return;
        }
        Index2D i2d = readCoordinate(args);

        if (game.board.isValidCellIndex(i2d)) {
            game.board.toggleFlagged(i2d);
        }
    }

    @("FlagCommand to mine cell changes it to mineFlagged cell, and vice versa")
    unittest {
        import board_generator;
        import cell;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        Index2D mine_index = Index2D(0, 0);
        g.addMineIndex(mine_index);
        game.board = g.generateBoard();

        (new FlagCommand()).execute(["0", "0"], game);
        assert(game.board.getCell(mine_index) == Cell.mineFlagged);

        (new FlagCommand()).execute(["0", "0"], game);
        assert(game.board.getCell(mine_index) == Cell.mine);
    }

    @("FlagCommand to empty cell changes it to emptyFlagged cell, and vice versa")
    unittest {
        import board_generator;
        import cell;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        game.board = g.generateBoard();
        Index2D empty_index = Index2D(0, 0);

        (new FlagCommand()).execute(["0", "0"], game);
        assert(game.board.getCell(empty_index) == Cell.emptyFlagged);

        (new FlagCommand()).execute(["0", "0"], game);
        assert(game.board.getCell(empty_index) == Cell.empty);
    }

    @("FlagCommand to opened cell does nothing")
    unittest {
        import board_generator;
        import cell;

        Game game = new Game();
        auto g = new ManualBoardGenerator(2, 2);
        game.board = g.generateBoard();
        Index2D cell_index = Index2D(0, 0);

        (new OpenCommand()).execute(["0", "0"], game);
        (new FlagCommand()).execute(["0", "0"], game);
        assert(game.board.getCell(cell_index) == Cell.opened);
    }
}