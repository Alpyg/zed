const std = @import("std");

const posix = std.posix;

const lib = @import("zed_lib");

pub fn main() !u8 {
    enableRawMode();

    var c: [1]u8 = .{0};
    while (std.io.getStdIn().read(&c) catch unreachable == 1 and c[0] != 'q') {}
    return 0;
}

fn enableRawMode() void {
    var termios: posix.termios = posix.tcgetattr(posix.STDIN_FILENO) catch unreachable;

    termios.lflag.ECHO = false;

    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, termios) catch unreachable;
}
