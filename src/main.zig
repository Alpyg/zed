const std = @import("std");

const ascii = std.ascii;
const posix = std.posix;

const lib = @import("zed_lib");

var original_termios: posix.termios = undefined;

pub fn main() !u8 {
    enableRawMode();
    defer disableRawMode();

    while (true) {
        editorRefreshScreen();
        editorProcessKeypress();
    }

    return 0;
}

fn editorProcessKeypress() void {
    const c: [1]u8 = editorReadKey();

    switch (c[0]) {
        'q' & 0x1f => std.posix.exit(0),
        else => {},
    }
}

fn editorReadKey() [1]u8 {
    var c: [1]u8 = undefined;
    var len: usize = undefined;

    while (true) {
        len = std.io.getStdIn().read(&c) catch die("read");
        if (len != -1) break;
    }
    return c;
}

fn editorRefreshScreen() void {
    _ = std.io.getStdOut().writer().write("\x1b[2J") catch unreachable;
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
