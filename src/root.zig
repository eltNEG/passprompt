const std = @import("std");
// https://stackoverflow.com/a/79100144
// also check https://codeberg.org/gnarz/term and zig Termios
// https://github.com/nothke/getch-zig
// https://github.com/c-shinkle/anyline
// https://blog.fabrb.com/2024/capturing-input-in-real-time-zig-0-14/
fn buffer_on(_stdin: *const std.fs.File) !void {
    var term = try std.posix.tcgetattr(_stdin.handle);
    term.lflag.ECHO = true;
    term.lflag.ICANON = true;
    try std.posix.tcsetattr(_stdin.handle, .NOW, term);
}

fn buffer_off(_stdin: *const std.fs.File, displayon: bool) !void {
    var term = try std.posix.tcgetattr(_stdin.handle);
    if (displayon) {
        term.lflag.ICANON = false;
    } else {
        term.lflag.ECHO = false;
    }
    try std.posix.tcsetattr(_stdin.handle, .NOW, term);
}

pub fn get(buffer: []u8, msg: []const u8, display: ?u8) !usize {
    var stdout_writer = std.fs.File.stdout().writerStreaming(&.{});
    const stdin = std.fs.File.stdin();
    try buffer_off(&stdin, display != null);
    var size: usize = 0;
    try stdout_writer.interface.writeAll(msg);
    try stdout_writer.interface.flush();
    while (true) {
        var stdin_buffer: [256]u8 = undefined;
        const bytes_read = try stdin.read(&stdin_buffer);
        if (display == null) {
            try buffer_on(&stdin);
            try stdout_writer.interface.writeAll("\n");
            try stdout_writer.interface.flush();
            @memcpy(buffer[size .. size + bytes_read], stdin_buffer[0..bytes_read]);
            size += bytes_read - 1;
            return size;
        }
        if (bytes_read == 0 or stdin_buffer[0] == '\n') break;
        for (0..bytes_read) |_| {
            try stdout_writer.interface.writeAll("\x08");
        }
        for (0..bytes_read) |_| {
            if (stdin_buffer[0] != 0x7F and display != null) try stdout_writer.interface.print("{c}", .{display.?}) else {
                try stdout_writer.interface.writeAll("\x08\x08\x1B[0K"); // https://gist.github.com/ConnerWill/d4b6c776b509add763e17f9f113fd25b
            }
        }
        if (stdin_buffer[0] == 0x7F) {
            size -= 1;
        } else {
            @memcpy(buffer[size .. size + bytes_read], stdin_buffer[0..bytes_read]);
            size += bytes_read;
        }
    }
    try stdout_writer.interface.flush();
    try buffer_on(&stdin);
    return size;
}

test "getPasswordInput" {
    try std.testing.expectEqual('a', 97);
}
