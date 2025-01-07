//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

pub fn main() !void {
    // Zig struct
    const Token = extern struct {
        type: i32,
        value: [32]u8,
        line: i32,
        column: i32,
    };
    const token = Token{ .type = 1, .value = "x", .line = 1, .column = 1 };
    const file = try std.fs.cwd().createFile("tokens.bin", .{});
    defer file.close();
    try file.writeAll(std.mem.asBytes(&token));
}
