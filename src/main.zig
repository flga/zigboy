const std = @import("std");
const os = std.os;
const process = std.process;

const zigboy = @import("zigboy/zigboy.zig");

var exit = false;

fn handleSigInt(_: c_int) callconv(.C) void {
    exit = true;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        std.debug.print("bye!\n", .{});
        _ = gpa.deinit();
    }

    try os.sigaction(os.SIG.INT, &os.Sigaction{
        .handler = .{
            .handler = handleSigInt,
        },
        .mask = os.empty_sigset,
        .flags = 0,
    }, null);

    var args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);
    const rom_path = args[1];

    var console = zigboy.Console.init(allocator);
    defer console.deinit();

    try console.load_rom_from_file(rom_path);
    try console.dump_cart_info(std.io.getStdOut().writer());
}
