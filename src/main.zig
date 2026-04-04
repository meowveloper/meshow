const std = @import("std");
const utils = @import("utils.zig");
const print = utils.print;
const take_input = utils.take_input;
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

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
            if (std.mem.eql(u8, val, "exit")) {return;}
            else {try print(stdout_writer, "{s}\n", .{val});}
        }
    }

}

