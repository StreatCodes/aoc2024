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
            const vector = Point{
                .x = if (a.x < b.x) -dist.x else dist.x,
                .y = if (a.y < b.y) -dist.y else dist.y,
            };

            try antinodes.put(a, {});

            var iter: i32 = 0;
            while (true) {
                iter += 1;
                const point = Point{ .x = a.x + (iter * vector.x), .y = a.y + (iter * vector.y) };

                if (point.x >= 0 and point.x < width and point.y >= 0 and point.y < height) {
                    try antinodes.put(point, {});
                } else {
                    break;
                }
            }

            iter = 0;
            while (true) {
                iter += 1;
                const point = Point{ .x = a.x + (iter * -vector.x), .y = a.y + (iter * -vector.y) };

                if (point.x >= 0 and point.x < width and point.y >= 0 and point.y < height) {
                    try antinodes.put(point, {});
                } else {
                    break;
                }
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

    //render the map
    for (map.items, 0..) |line, y| {
        for (line, 0..) |antenna, x| {
            if (antenna == '.') {
                const node = antinodes.get(Point{ .x = @intCast(x), .y = @intCast(y) });
                if (node != null) {
                    std.debug.print("{c}", .{'#'});
                } else {
                    std.debug.print("{c}", .{'.'});
                }
            } else {
                std.debug.print("{c}", .{antenna});
            }
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("Total antinodes: {d}\n", .{antinodes.count()});
}
