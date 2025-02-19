const std = @import("std");
const lib = @import("zed_lib");

pub fn main() !u8 {
    var c: [1]u8 = .{0};
    while (std.io.getStdIn().read(&c) catch unreachable == 1 and c[0] != 'q') {}
    return 0;
}
