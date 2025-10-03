# PassPrompt

A simple Zig library for secure password input from the terminal with customizable display options.

## Installation

### Using Zig Package Manager

Add this package to your `build.zig.zon`:

```zig
.dependencies = .{
    .passprompt = .{
        .url = "https://github.com/yourusername/passprompt/archive/main.tar.gz",
        .hash = "...", // Will be filled automatically by `zig fetch`
    },
},
```

Then in your `build.zig`:

```zig
const passprompt_dep = b.dependency("passprompt", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("passprompt", passprompt_dep.module("passprompt"));
```

## Usage

```zig
const std = @import("std");
const passprompt = @import("passprompt");

pub fn main() !void {
    var buffer: [256]u8 = undefined;

    // Get password with asterisk masking
    const size = try passprompt.get(&buffer, "Enter password: ", '*');
    const password = buffer[0..size];

    // Get password with no display (completely hidden)
    const size2 = try passprompt.get(&buffer, "Enter secret: ", null);
    const secret = buffer[0..size2];

    // Check if passwords match
    const match = std.mem.eql(u8, password, secret);
    std.debug.print("Passwords match: {}\n", .{match});
}
```

## API Reference

### `get(buffer: []u8, msg: []const u8, display: ?u8) !usize`

Prompts the user for password input.

**Parameters:**
- `buffer`: Byte slice to store the input password
- `msg`: Prompt message to display to the user
- `display`: Optional character to display instead of the actual input
  - `'*'` - Show asterisks for each character
  - `'#'` - Show hash symbols for each character
  - `null` - Completely hide input (no visual feedback)

**Returns:**
- `usize`: Number of characters entered (excluding newline)

**Errors:**
- Returns error if terminal control operations fail

## License
- MIT License
