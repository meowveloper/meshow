const std = @import("std");
const utils = @import("utils.zig");

const print = utils.print;
const Io = std.Io;
const Allocator = std.mem.Allocator;

const Runner_Result = struct {
    gpa: Allocator,
    stderr: []u8,
    stdout: []u8,
    pub fn deinit (self: *const Runner_Result) void {
        self.gpa.free(self.stdout);
        self.gpa.free(self.stderr);
    }
};

pub fn run_command(gpa: Allocator, io: Io, argv: []const []const u8) !Runner_Result {
    const result = try std.process.run(gpa, io, .{ .argv = argv });
    return .{
        .gpa = gpa,
        .stderr = result.stderr,
        .stdout = result.stdout,
    };
}

test "run_command" {
    const io = std.testing.io;
    const gpa = std.testing.allocator;
    const argv = [_][]const u8{"ls", "-la"};
    const result = try run_command(gpa, io, &argv);
    defer result.deinit();
    std.debug.print("{s}\n", .{result.stdout});
    std.debug.print("{s}\n", .{result.stderr});
}

pub fn run_cd(io: Io, path: []const u8) !void {
    try std.process.setCurrentPath(io, path);
}
