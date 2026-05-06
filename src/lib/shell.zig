const std = @import("std");
const utils = @import("utils.zig");

const print = utils.print;
const Io = std.Io;
const Allocator = std.mem.Allocator;
const Environ_Map = std.process.Environ.Map;

pub fn run_command(io: Io, argv: []const []const u8) !void {
    var child = try std.process.spawn(io, .{.argv = argv });
    _ = try child.wait(io);
}

test "run_command" {
    const io = std.testing.io;
    const argv = [_][]const u8{"ls", "-la"};
    try run_command(io, &argv);
}

pub fn run_cd(gpa: Allocator, env_map: *Environ_Map, io: Io, path: ?[]const u8) !void {
    const p_path = try process_cd_path(gpa, env_map, path);
    defer if(p_path) |p| gpa.free(p);
    if(p_path) |p| try std.process.setCurrentPath(io, p);
}

fn process_cd_path(gpa: Allocator, env_map: *Environ_Map, path: ?[]const u8) !?[]const u8 {
    const home = env_map.get("HOME");
    if(path) |pt| {
        if(std.mem.startsWith(u8, pt, "~")) {
            if(home == null) return null
            else return try std.fmt.allocPrint(gpa, "{s}/{s}", .{home.?, if(pt.len > 2) pt[2..] else ""});
        }
        else return try gpa.dupe(u8, pt);
    } else {
        return if(home) |h| try gpa.dupe(u8, h) else null;
    }
}

pub fn get_echo_val(env_map: *Environ_Map, arg: []const u8) []const u8 {
    if(std.mem.startsWith(u8, arg, "$") and arg.len > 1) {
        const env = env_map.get(arg[1..]);
        if(env) |v| {
            return v;
        } else return arg;
    }
    else return arg;
}

test "run_echo" {
    const gpa = std.testing.allocator;
    var env_map = try std.testing.environ.createMap(gpa);
    defer env_map.deinit();
    const val = get_echo_val(&env_map, "$USER");
    std.debug.print("echo val: {s}\n", .{val});
}


test "process_cd_path" {
    const gpa = std.testing.allocator;
    var env_map = try std.testing.environ.createMap(gpa);
    defer env_map.deinit();
    const result = try process_cd_path(gpa, &env_map, "~/.config");
    defer if(result) |p| gpa.free(p);
    if(result) |path| {
        std.debug.print("{s}\n", .{path});
    }
}
