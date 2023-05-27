const std = @import("std");

pub const Cartridge = struct {
    title: [16:0]u8,
    manufacturer_code: [4]u8,
    cgb_flag: u8,
    new_licensee_code: [2]u8,
    sgb_flag: u8,
    cartridge_type: u8,
    rom_size: u8,
    ram_size: u8,
    destination_code: u8,
    old_licensee_code: u8,
    mask_rom_version_number: u8,
    header_checksum: u8,
    global_checksum: u16,
    rom: []const u8,

    fn parse_title(self: *Cartridge, raw: []const u8) void {
        @memcpy(self.title[0..raw.len], raw);
        // terminate the title on the first non printable char to cope with bad roms.
        for (&self.title) |*c| {
            if (!std.ascii.isPrint(c.*)) {
                c.* = 0;
                break;
            }
        }
    }

    pub fn init(rom: []const u8) Cartridge {
        var self: Cartridge = .{
            .title = std.mem.zeroes([16:0]u8),
            .manufacturer_code = rom[0x013F .. 0x0142 + 1].*,
            .cgb_flag = rom[0x0143],
            .new_licensee_code = rom[0x0144 .. 0x0145 + 1].*,
            .sgb_flag = rom[0x0146],
            .cartridge_type = rom[0x0147],
            .rom_size = rom[0x0148],
            .ram_size = rom[0x0149],
            .destination_code = rom[0x014A],
            .old_licensee_code = rom[0x014B],
            .mask_rom_version_number = rom[0x014C],
            .header_checksum = rom[0x014D],
            .global_checksum = std.mem.readIntSliceBig(u16, rom[0x14E .. 0x14F + 1]),
            .rom = rom,
        };

        if (self.cgb_flag == 0x80 or self.cgb_flag == 0xC0) {
            self.parse_title(rom[0x0134 .. 0x0142 + 1]);
        } else {
            self.parse_title(rom[0x0134 .. 0x0143 + 1]);
        }

        return self;
    }
};
