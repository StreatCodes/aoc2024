const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct {
    x: usize,
    y: usize,
};

inline fn asciiToInt(c: u8) u8 {
    return c - '0';
}

fn calculateTrailheadScore(map: [][]const u8, x: usize, y: usize, altitude: u32) u32 {
    if (altitude == 9) {
        return 1;
    }

    var score: u32 = 0;
    if (y > 0 and asciiToInt(map[y - 1][x]) == altitude + 1) {
        score += calculateTrailheadScore(map, x, y - 1, altitude + 1);
    }
    if (y < map.len - 1 and asciiToInt(map[y + 1][x]) == altitude + 1) {
        score += calculateTrailheadScore(map, x, y + 1, altitude + 1);
    }
    if (x > 0 and asciiToInt(map[y][x - 1]) == altitude + 1) {
        score += calculateTrailheadScore(map, x - 1, y, altitude + 1);
    }
    if (x < map[y].len - 1 and asciiToInt(map[y][x + 1]) == altitude + 1) {
        score += calculateTrailheadScore(map, x + 1, y, altitude + 1);
    }

    return score;
}

pub fn main() !void {
    const text = @embedFile("inputs/10.txt");

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var map = std.ArrayList([]const u8).init(allocator);
    defer map.deinit();

    while (tokens.next()) |line| {
        try map.append(line);
    }

    var total: u32 = 0;
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            const c = map.items[y][x];
            if (c == '0') {
                const score = calculateTrailheadScore(map.items, x, y, 0);
                total += score;
                std.debug.print("Found trailhead {d},{d} with score {d}\n", .{ x, y, score });
            }
        }
    }

    std.debug.print("Total: {d}\n", .{total});
}
