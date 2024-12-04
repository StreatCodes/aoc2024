const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const text = @embedFile("inputs/4.txt");

    var tokens = std.mem.tokenizeScalar(u8, text, '\n');

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();
    while (tokens.next()) |line| {
        try lines.append(line);
    }

    var count: u32 = 0;
    for (0..lines.items.len) |y| {
        for (0..lines.items[y].len) |x| {
            var match: u32 = 0;
            //diagonal \
            if (x + 1 < lines.items[y].len and x > 0 and y + 1 < lines.items.len and y > 0) {
                if (lines.items[y - 1][x - 1] == 'M' and lines.items[y][x] == 'A' and lines.items[y + 1][x + 1] == 'S') {
                    std.debug.print("found diagonal \\ {d} {d}\n", .{ x, y });
                    match += 1;
                } else if (lines.items[y - 1][x - 1] == 'S' and lines.items[y][x] == 'A' and lines.items[y + 1][x + 1] == 'M') {
                    std.debug.print("found diagonal \\ backwards {d} {d}\n", .{ x, y });
                    match += 1;
                }
            }
            //diagonal /
            if (x > 0 and x + 1 < lines.items[y].len and y > 0 and y + 1 < lines.items.len) {
                if (lines.items[y - 1][x + 1] == 'M' and lines.items[y][x] == 'A' and lines.items[y + 1][x - 1] == 'S') {
                    std.debug.print("found diagonal / {d} {d}\n", .{ x, y });
                    match += 1;
                } else if (lines.items[y - 1][x + 1] == 'S' and lines.items[y][x] == 'A' and lines.items[y + 1][x - 1] == 'M') {
                    std.debug.print("found diagonal / backwards {d} {d}\n", .{ x, y });
                    match += 1;
                }
            }

            if (match == 2) {
                count += 1;
            }
        }
    }

    std.debug.print("Found {d}!\n", .{count});
}
