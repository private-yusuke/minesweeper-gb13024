module command.command;

import board;
import index2d;
import game;

interface Command {
    void execute(string[] args, Game game);
}

Index2D readCoordinate(string[] args) {
    import std.conv : to, ConvException;
    import std.stdio : writeln;

    uint x, y;
    try {
        x = args[0].to!uint;
        y = args[1].to!uint;
    } catch (ConvException e) {
        writeln("The index you specified is invalid. Try again.");
        return Index2D(-1, -1);
    }

    args = args[2..$];

    return Index2D(x, y);
}