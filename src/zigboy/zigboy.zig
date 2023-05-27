const std = @import("std");
const fmt = std.fmt;

pub const Cartridge = @import("cartridge.zig").Cartridge;

pub const Console = struct {
    arena: std.heap.ArenaAllocator,
    cartridge: Cartridge,

    pub fn init(allocator: std.mem.Allocator) Console {
        return .{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .cartridge = undefined,
        };
    }

    pub fn deinit(self: *Console) void {
        self.arena.deinit();
    }

    fn reset(self: *Console) void {
        _ = self.arena.reset(.retain_capacity);
    }

    pub fn load_rom(self: *Console, rom: []const u8) void {
        self.reset();
        self.cartridge = Cartridge.init(rom);
    }

    pub fn load_rom_from_file(self: *Console, path: []const u8) !void {
        self.reset();
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();

        const stat = try file.stat();
        const rom = try file.readToEndAllocOptions(self.arena.allocator(), stat.size, stat.size, @alignOf(u8), null);
        self.cartridge = Cartridge.init(rom);
    }

    pub fn dump_cart_info(self: *Console, w: anytype) !void {
        try fmt.format(w, "title: {s}.\n", .{self.cartridge.title});
        try fmt.format(w, "manufacturer_code: {s}\n", .{self.cartridge.manufacturer_code});
        try fmt.format(w, "cgb_flag: ${X:0<2}\n", .{self.cartridge.cgb_flag});
        try fmt.format(w, "new_licensee_code: {s}\n", .{self.cartridge.new_licensee_code});
        try fmt.format(w, "sgb_flag: ${X:0<2}\n", .{self.cartridge.sgb_flag});
        try fmt.format(w, "cartridge_type: ${X:0<2}\n", .{self.cartridge.cartridge_type});
        try fmt.format(w, "rom_size: ${X:0<2}\n", .{self.cartridge.rom_size});
        try fmt.format(w, "ram_size: ${X:0<2}\n", .{self.cartridge.ram_size});
        try fmt.format(w, "destination_code: ${X:0<2}\n", .{self.cartridge.destination_code});
        try fmt.format(w, "old_licensee_code: ${X:0<2}\n", .{self.cartridge.old_licensee_code});
        try fmt.format(w, "mask_rom_version_number: ${X:0<2}\n", .{self.cartridge.mask_rom_version_number});
        try fmt.format(w, "header_checksum: ${X:0<2}\n", .{self.cartridge.header_checksum});
        try fmt.format(w, "global_checksum: ${X:0<4}\n", .{self.cartridge.global_checksum});
    }
};
