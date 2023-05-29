const std = @import("std");
const os = std.os;
const glfw = @import("glfw");
const gl = @import("gl");
const zgui = @import("zgui");
const backend = @import("backend_glfw_opengl.zig");

var exit = false;

fn handleSigInt(_: c_int) callconv(.C) void {
    exit = true;
}

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
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

    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const window = glfw.Window.create(640, 480, "zigboy", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 0,
        .resizable = true,
        .opengl_forward_compat = true,
    }) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);
    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    glfw.swapInterval(1);

    zgui.init(allocator);
    defer zgui.deinit();

    backend.init(window);
    defer backend.deinit();

    while (!window.shouldClose() and !exit) {
        backend.newFrame();
        zgui.showDemoWindow(null);
        backend.draw(window);
        window.swapBuffers();
        glfw.pollEvents();
    }
}
