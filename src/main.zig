const std = @import("std");
const ascii = @import("std").ascii;
const os = @import("std").os;

const stdin = @import("std").io.getStdIn();
const stdout = @import("std").io.getStdOut().writer();

const stdin_fd = stdin.handle;
var original_termios: os.termios = undefined;

pub fn main() !void {
    try enableRawMode();
    defer disableRawMode();

    var buf: [1]u8 = undefined;
    while (true) {
        const n = try stdin.read(buf[0..]);
        _ = n;

        if (ascii.isControl(buf[0])) {
            try stdout.print("{d}\r\n", .{buf[0]});
        } else {
            try stdout.print("{d} ('{c}')\r\n", .{ buf[0], buf[0] });
        }

        if (buf[0] == 'q') break;
    }
}

fn enableRawMode() !void {
    original_termios = os.tcgetattr(stdin_fd) catch die("tcsetattr", null);
    var raw = original_termios;
    raw.iflag &= ~@as(os.tcflag_t, os.linux.BRKINT | os.linux.ICRNL | os.linux.INPCK | os.linux.ISTRIP | os.linux.IXON);
    raw.oflag &= ~@as(os.tcflag_t, os.linux.OPOST);
    raw.cflag |= @as(os.tcflag_t, os.linux.CS8);
    raw.lflag &= ~@as(os.tcflag_t, os.linux.ECHO | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);
    //raw.cc[os.VMIN] = 0;
    //raw.cc[os.VTIME] = 1;
    os.tcsetattr(stdin_fd, os.TCSA.FLUSH, raw) catch die("tcsetattr", null);
}

fn disableRawMode() void {
    os.tcsetattr(stdin_fd, os.TCSA.FLUSH, original_termios) catch die("tcsetattr", null);
}

fn die(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
    stdout.writeAll("\x1b[2J") catch {};
    stdout.writeAll("\x1b[H") catch {};
    std.builtin.default_panic(msg, error_return_trace, null);
}
