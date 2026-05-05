const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const EnvironMap = std.process.Environ.Map;

pub fn print(writer: *Io.Writer, comptime fmt: []const u8, args: anytype) Io.Writer.Error!void {
    try writer.print(fmt, args);
    try writer.flush();
}

pub fn take_input(reader: *Io.Reader) !?[]u8 {
    return try reader.takeDelimiter('\n');
}

/// free the return value
pub fn process_current_path_display(gpa: Allocator, env_map: *EnvironMap, path: []const u8) ![]u8 {
    const home = env_map.get("HOME");

    if(home) |h| {
        if(std.mem.startsWith(u8, path, h)) {
            if(path.len == h.len) return gpa.dupe(u8, "~");
            return std.fmt.allocPrint(gpa, "~/{s}", .{path[h.len + 1 ..]});
        } else return gpa.dupe(u8, path);
    } else return gpa.dupe(u8, path);
}

test "process_current_path_display" {
    const gpa = std.testing.allocator;
    var env_map = try std.testing.environ.createMap(gpa);
    defer env_map.deinit();
    const path = "/home/meowveloper/.config";
    const processed = try process_current_path_display(gpa, &env_map, path);
    defer gpa.free(processed);
    std.debug.print("{s}\n", .{processed});
}


