const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub const Builtins = enum {
    cd,
    exit,
};

pub fn parse_command(gpa: Allocator, command: ?[]const u8) !std.ArrayList([]const u8) {
    var list = std.ArrayList([]const u8).empty;
    if(command) |cmd| {
        var it = std.mem.tokenizeAny(u8, cmd, " ");

        while (it.next()) |word| {
            try list.append(gpa, word);
        }
    }
    return list;
}

pub fn get_builtin(cmd: []const u8) ?Builtins {
    if(std.meta.stringToEnum(Builtins, cmd)) |bt| {
        return bt;
    } else return null;
}

test "parse_not_builtin_command" {
    const gpa = std.testing.allocator;
    var list = try parse_command(gpa, "ls -la");
    defer list.deinit(gpa);
    for(list.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
    try std.testing.expect(get_builtin(list.items[0]) == null);
}

test "parse_builtin_command" {
    const gpa = std.testing.allocator;
    var list = try parse_command(gpa, "cd ~/.config/nvim");
    defer list.deinit(gpa);
    for(list.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
    try std.testing.expect(get_builtin(list.items[0]) != null);
}
