const std = @import("std");
const utils = @import("utils.zig");

const print = utils.print;
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub fn run_command(io: Io, argv: []const []const u8) !void {
    var child = try std.process.spawn(io, .{.argv = argv });
    _ = try child.wait(io);
}

test "run_command" {
    const io = std.testing.io;
    const argv = [_][]const u8{"ls", "-la"};
    try run_command(io, &argv);
}

pub fn run_cd(io: Io, path: []const u8) !void {
    try std.process.setCurrentPath(io, path);
}
