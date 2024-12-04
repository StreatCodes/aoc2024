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
            //horizontal
            if (x + 3 < lines.items[y].len) {
                const matchForward = std.mem.eql(u8, lines.items[y][x .. x + 4], "XMAS");
                if (matchForward) {
                    std.debug.print("found horizontal {d} {d}\n", .{ x, y });
                    count += 1;
                }
                const matchBackward = std.mem.eql(u8, lines.items[y][x .. x + 4], "SAMX");
                if (matchBackward) {
                    std.debug.print("found horizontal backwards {d} {d}\n", .{ x, y });
                    count += 1;
                }
            }
            //vertical
            if (y + 3 < lines.items.len) {
                if (lines.items[y][x] == 'X' and lines.items[y + 1][x] == 'M' and lines.items[y + 2][x] == 'A' and lines.items[y + 3][x] == 'S') {
                    std.debug.print("found vertical {d} {d}\n", .{ x, y });
                    count += 1;
                }
                if (lines.items[y][x] == 'S' and lines.items[y + 1][x] == 'A' and lines.items[y + 2][x] == 'M' and lines.items[y + 3][x] == 'X') {
                    std.debug.print("found vertical backwards {d} {d}\n", .{ x, y });
                    count += 1;
                }
            }
            //diagonal \
            if (x + 3 < lines.items[y].len and y + 3 < lines.items.len) {
                if (lines.items[y][x] == 'X' and lines.items[y + 1][x + 1] == 'M' and lines.items[y + 2][x + 2] == 'A' and lines.items[y + 3][x + 3] == 'S') {
                    std.debug.print("found diagonal \\ {d} {d}\n", .{ x, y });
                    count += 1;
                }
                if (lines.items[y][x] == 'S' and lines.items[y + 1][x + 1] == 'A' and lines.items[y + 2][x + 2] == 'M' and lines.items[y + 3][x + 3] == 'X') {
                    std.debug.print("found diagonal \\ backwards {d} {d}\n", .{ x, y });
                    count += 1;
                }
            }
            //diagonal /
            if (x >= 3 and y + 3 < lines.items.len) {
                if (lines.items[y][x] == 'X' and lines.items[y + 1][x - 1] == 'M' and lines.items[y + 2][x - 2] == 'A' and lines.items[y + 3][x - 3] == 'S') {
                    std.debug.print("found diagonal / {d} {d}\n", .{ x, y });
                    count += 1;
                }
                if (lines.items[y][x] == 'S' and lines.items[y + 1][x - 1] == 'A' and lines.items[y + 2][x - 2] == 'M' and lines.items[y + 3][x - 3] == 'X') {
                    std.debug.print("found diagonal / backwards {d} {d}\n", .{ x, y });
                    count += 1;
                }
            }
        }
    }

    std.debug.print("Found {d}!\n", .{count});
}
