const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct {
    x: i32,
    y: i32,
};

fn getAllOnFrequency(map: [][]const u8, freq: u8) ![]Point {
    var list = std.ArrayList(Point).init(allocator);

    for (map, 0..) |line, y| {
        for (line, 0..) |antenna, x| {
            if (antenna == freq) {
                try list.append(.{ .x = @intCast(x), .y = @intCast(y) });
            }
        }
    }

    return list.toOwnedSlice();
}

fn findAntinodes(antinodes: *std.AutoHashMap(Point, void), antennas: []Point, width: i32, height: i32) !void {
    for (0..antennas.len) |i| {
        for (i + 1..antennas.len) |j| {
            const a = antennas[i];
            const b = antennas[j];

            const dist = Point{ .x = @intCast(@abs(b.x - a.x)), .y = @intCast(@abs(b.y - a.y)) };

            var result: Point = undefined;
            var result2: Point = undefined;

            result.x = if (a.x < b.x) a.x - dist.x else a.x + dist.x;
            result.y = if (a.y < b.y) a.y - dist.y else a.y + dist.y;

            result2.x = if (b.x < a.x) b.x - dist.x else b.x + dist.x;
            result2.y = if (b.y < a.y) b.y - dist.y else b.y + dist.y;

            if (result.x >= 0 and result.x < width and result.y >= 0 and result.y < height) {
                try antinodes.put(result, {});
            }
            if (result2.x >= 0 and result2.x < width and result2.y >= 0 and result2.y < height) {
                try antinodes.put(result2, {});
            }
        }
    }
}

pub fn main() !void {
    const text = @embedFile("inputs/8.txt");

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var map = std.ArrayList([]const u8).init(allocator);
    defer map.deinit();

    while (tokens.next()) |line| {
        try map.append(line);
    }

    var solved = std.ArrayList(u8).init(allocator);
    defer solved.deinit();

    var antinodes = std.AutoHashMap(Point, void).init(allocator);
    defer antinodes.deinit();

    for (map.items) |line| {
        for (line) |antenna| {
            if (antenna == '.') continue;
            const found = std.mem.indexOfScalar(u8, solved.items, antenna);
            if (found != null) continue;

            const list = try getAllOnFrequency(map.items, antenna);
            defer allocator.free(list);

            const height: i32 = @intCast(map.items.len);
            const width: i32 = @intCast(map.items[0].len);
            try findAntinodes(&antinodes, list, width, height);
            std.debug.print("Creating list for {c} found {d}. Total of {d} antinodes\n", .{ antenna, list.len, antinodes.count() });

            try solved.append(antenna);
        }
    }

    std.debug.print("Total antinodes: {d}\n", .{antinodes.count()});
}
