module game;

import std.stdio : writeln;

import board;
import board_generator;
import program_argument;
import index2d;
import command;

class Game { 
    Board board;
    private Command[string] _commands;
    bool failed = false;
    @property bool won() const @safe pure nothrow {
        return this.board.opened_count == this.board.width * this.board.height - this.board.mine_amount;
    }

    this() {}

    void initialize() {
        this.registerCommand("o", new OpenCommand());
        this.registerCommand("f", new FlagCommand());
        this.registerCommand("c", new ChordCommand());
        this.registerCommand("h", new HelpCommand());
    }

    void registerCommand(string commandName, Command command) {
        this._commands[commandName] = command;
    }

    static Board generateBoardWith(ProgramArgument pa) {
        BoardGenerator generator;

        if (pa.board_file_path) {
            import std.file : readText;
            generator = new FromBoardStringBoardGenerator(readText(pa.board_file_path));
        } else {
            generator = new RandomBoardGenerator(pa.board_height, pa.board_width, pa.mine_amount);
        }

        return generator.generateBoard();
    }
    
    int mainLoop() {
        import std.stdio : write, readln, stdin;
        import std.string : split;
        import std.conv : to;

        while (!failed && !stdin.eof) {
            this.board.writeln;
            write("> ");
            auto commandArguments = readln.split;

            if (commandArguments.length == 0) continue;
            Command* command_ptr = commandArguments[0] in this._commands;
            if (!command_ptr) {
                writeln("Command not found");
                (new HelpCommand()).execute([], this);
                continue;
            }
            (*command_ptr).execute(commandArguments[1..$], this);
            if (this.won) {
                writeln("You won!");
                break;
            }
        }

        if (failed) {
            writeln("You touched a mine!");
        }
        return 0;
    }
}