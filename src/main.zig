const std = @import("std");
const utils = @import("lib/utils.zig");
const parse = @import("lib/parse.zig");
const shell = @import("lib/shell.zig");

const print = utils.print;
const take_input = utils.take_input;
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub fn main(init: std.process.Init) !void {
    const arena: Allocator = init.arena.allocator();
    const gpa: Allocator = init.gpa;

    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_file_reader = Io.File.Reader.init(.stdin(), io, &stdin_buffer);
    const stdin_reader = &stdin_file_reader.interface;

    try print(stdout_writer, "hello world\n", .{});

    while (true) {
        try print(stdout_writer, "> ", .{});
        const result = try take_input(stdin_reader);
        if(result) |val| {
            var list = try parse.parse_command(gpa, val);
            defer list.deinit(gpa);

            if(list.items.len < 1) {
                continue;
            }
            if (std.mem.eql(u8, list.items[0], "exit")) {
                break;
            } else {
                const run_result = shell.run_command(gpa, io, list.items) catch |err| {
                    std.log.err("ERROR: {}\n", .{err});
                    continue;
                };
                defer run_result.deinit();
                try print(stdout_writer, "{s}\n", .{run_result.stdout});
                try print(stdout_writer, "{s}\n", .{run_result.stderr});
            }
        } else try print(stdout_writer, "\n", .{});
    }

}

