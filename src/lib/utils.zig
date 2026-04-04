const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub fn print(writer: *Io.Writer, comptime fmt: []const u8, args: anytype) Io.Writer.Error!void {
    try writer.print(fmt, args);
    try writer.flush();
}

pub fn take_input(reader: *Io.Reader) !?[]u8 {
    return try reader.takeDelimiter('\n');
}


