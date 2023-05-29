const gui = @import("zgui");
const glfw = @import("glfw");
const gl = @import("gl");

pub fn init(window: glfw.Window) void {
    if (!ImGui_ImplGlfw_InitForOpenGL(window.handle, true)) {
        unreachable;
    }

    if (!ImGui_ImplOpenGL3_Init(null)) {
        unreachable;
    }
}

pub fn deinit() void {
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
}

pub fn newFrame() void {
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();

    gui.newFrame();
}

pub fn draw(window: glfw.Window) void {
    gui.render();
    const size = window.getFramebufferSize();
    gl.viewport(0, 0, @intCast(gl.GLint, size.width), @intCast(gl.GLint, size.height));
    gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.2, 0.4, 0.8, 1.0 });
    ImGui_ImplOpenGL3_RenderDrawData(gui.getDrawData());
}

// Those functions are defined in `imgui_impl_glfw.cpp` and 'imgui_impl_wgpu.cpp`
// (they include few custom changes).
extern fn ImGui_ImplGlfw_InitForOpenGL(window: *const anyopaque, install_callbacks: bool) bool;
extern fn ImGui_ImplGlfw_NewFrame() void;
extern fn ImGui_ImplGlfw_Shutdown() void;

extern fn ImGui_ImplOpenGL3_Init(?*const anyopaque) bool;
extern fn ImGui_ImplOpenGL3_Shutdown() void;
extern fn ImGui_ImplOpenGL3_NewFrame() void;
extern fn ImGui_ImplOpenGL3_RenderDrawData(draw_data: gui.DrawData) void;
