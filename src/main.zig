const std = @import("std");
const os = std.os;
const process = std.process;
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
    std.debug.print("Args:\n", .{});
    for (args) |next| {
        std.debug.print("\t{s}\n", .{next});
    }

    while (!exit) {
        std.debug.print("bonk\n", .{});
        std.time.sleep(1 * std.time.ns_per_s);
    }
}
