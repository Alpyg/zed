const std = @import("std");

const ascii = std.ascii;
const posix = std.posix;

const lib = @import("zed_lib");

var original_termios: posix.termios = undefined;

pub fn main() !u8 {
    enableRawMode();
    defer disableRawMode();

    while (true) {
        var c: [1]u8 = .{0};
        _ = std.io.getStdIn().read(&c) catch die("read");
        var out = std.io.getStdOut().writer();
        if (ascii.isControl(c[0])) {
            try out.print("{d}\r\n", .{c});
        } else {
            try out.print("{d} ({c})\r\n", .{ c, c });
        }

        if (c[0] == 'q') {
            break;
        }
    }

    return 0;
}

fn enableRawMode() void {
    original_termios = posix.tcgetattr(posix.STDIN_FILENO) catch die("tcgetattr");
    var termios = original_termios;

    termios.iflag.BRKINT = false;
    termios.iflag.ICRNL = false;
    termios.iflag.INPCK = false;
    termios.iflag.ISTRIP = false;
    termios.iflag.IXON = false;

    termios.oflag.OPOST = false;

    termios.lflag.ECHO = false;
    termios.lflag.ICANON = false;
    termios.lflag.IEXTEN = false;
    termios.lflag.ISIG = false;

    termios.cc[@intFromEnum(posix.V.MIN)] = 0;
    termios.cc[@intFromEnum(posix.V.TIME)] = 1;

    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, termios) catch die("tcsetattr");
}

fn disableRawMode() void {
    posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, original_termios) catch die("tcsetattr");
}

fn die(s: []const u8) noreturn {
    std.debug.print("{s}", .{s});
    std.posix.exit(1);
}
