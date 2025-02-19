const std = @import("std");

const posix = std.posix;

const lib = @import("zed_lib");

var original_termios: posix.termios = undefined;

pub fn main() !u8 {
    enableRawMode();
    defer disableRawMode();

    var c: [1]u8 = .{0};
    while (std.io.getStdIn().read(&c) catch unreachable == 1 and c[0] != 'q') {}
    return 0;
}

fn enableRawMode() void {
    original_termios = posix.tcgetattr(posix.STDIN_FILENO) catch unreachable;
    var termios = original_termios;
    termios.lflag.ECHO = false;
    termios.lflag.ICANON = false;
    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, termios) catch unreachable;
}

fn disableRawMode() void {
    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, original_termios) catch unreachable;
}
