const std = @import("std");

const ascii = std.ascii;
const posix = std.posix;

const lib = @import("zed_lib");

var original_termios: posix.termios = undefined;

pub fn main() !u8 {
    enableRawMode();
    defer disableRawMode();

    var c: [1]u8 = .{0};
    while (std.io.getStdIn().read(&c) catch unreachable == 1 and c[0] != 'q') {
        var out = std.io.getStdOut().writer();
        if (ascii.isControl(c[0])) {
            try out.print("{d}\n", .{c});
        } else {
            try out.print("{d} ({c})\n", .{ c, c });
        }
    }

    return 0;
}

fn enableRawMode() void {
    original_termios = posix.tcgetattr(posix.STDIN_FILENO) catch unreachable;
    var termios = original_termios;

    termios.iflag.IXON = false;

    termios.lflag.ECHO = false;
    termios.lflag.ICANON = false;
    termios.lflag.IEXTEN = false;
    termios.lflag.ISIG = false;

    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, termios) catch unreachable;
}

fn disableRawMode() void {
    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, original_termios) catch unreachable;
}
