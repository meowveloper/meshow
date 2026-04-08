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
    const environ_map = init.environ_map;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_file_reader = Io.File.Reader.init(.stdin(), io, &stdin_buffer);
    const stdin_reader = &stdin_file_reader.interface;

    while (true) {
        try print(stdout_writer, "\n> ", .{});
        const result = try take_input(stdin_reader);

        var list = try parse.parse_command(gpa, result);
        defer list.deinit(gpa);

        if(list.items.len < 1) {
            continue;
        }

        const builtin = parse.get_builtin(list.items[0]);
        if(builtin) |bt| {
            const bt_arg = list.items[1..];
            switch (bt) {
                .exit => break,
                .cd => {
                    const path = if(bt_arg.len > 0) bt_arg[0] else null;
                    shell.run_cd(gpa, environ_map, io, path) catch |err| {
                        std.log.err("{}", .{err});
                    };
                },
                else => {
                    std.log.err("builtin command \"{s}\" is not implemented yet.", .{list.items[0]});
                },
            }
            continue;
        }
        shell.run_command(io, list.items) catch |err| {
            std.log.err("{}\n", .{err});
            continue;
        };
    }

}

