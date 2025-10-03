const std = @import("std");
const passprompt = @import("passprompt");

pub fn main() !void {
    var buffer: [32]u8 = undefined;
    var buffer2: [32]u8 = undefined;
    const size1 = try passprompt.get(&buffer, "Enter password: ", '*');
    const size2 = try passprompt.get(&buffer2, "Enter password again (no display): ", null);
    std.debug.print("Password entered: {}\n", .{std.mem.eql(u8, buffer[0..size1], buffer2[0..size2])});
}
