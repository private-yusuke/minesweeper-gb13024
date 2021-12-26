import board, cell, game, program_argument;
import board_generator : TooManyMineException;

import std.getopt;
import std.stdio : stderr, writeln;

version (unittest) {}
else {
    void printUsage(GetoptResult commandOptions) {
        defaultGetoptPrinter("Let's play one of the best games created in the good old days!", commandOptions.options);
    }

    int main(string[] args)
    {
        ProgramArgument pa;

        auto commandOptions = getopt(
            args,
            "height", "Height of the board", &pa.board_height,
            "width", "Width of the board", &pa.board_width,
            "mine", "Amount of mine", &pa.mine_amount,
            "board_file_path|f", "Path to board file", &pa.board_file_path
        );

        if (commandOptions.helpWanted) {
            printUsage(commandOptions);
            return 0;
        }

        Game game;

        try {
            game = new Game;
            game.board = Game.generateBoardWith(pa);
            game.initialize();
        } catch (TooManyMineException e) {
            stderr.writefln(e.message);
            return 1;
        }

        return game.mainLoop();
    }
}