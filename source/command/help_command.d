module command.help_command;

import command;
import game;

class HelpCommand : Command {
    const string HOW_TO_PLAY =
    r"h: print this help

    <command> <x> <y>
    o: open the cell
    f: flag/unflag the cell
    c: open all the cells around the cell
    ";

    void execute(string[] args, Game game) {
        import std.stdio : writeln;

        writeln(HOW_TO_PLAY);
    }
}