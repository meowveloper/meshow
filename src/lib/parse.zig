const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub fn parse_command(gpa: Allocator, command: []const u8) !std.ArrayList([]const u8) {
    var list = std.ArrayList([]const u8).empty;
    var it = std.mem.tokenizeAny(u8, command, " \n");

    while (it.next()) |word| {
        try list.append(gpa, word);
    }
    return list;
}

test "parse_command" {
    const gpa = std.testing.allocator;
    var list = try parse_command(gpa, "ls -la");
    defer list.deinit(gpa);
    for(list.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
}
