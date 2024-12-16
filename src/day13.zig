const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct {
    x: u64,
    y: u64,
};

const GameParams = struct {
    button_a: Point,
    button_b: Point,
    prize: Point,
};

fn parsePoint(line: []const u8, adder: u64) !Point {
    var x: u64 = 0;
    var y: u64 = 0;

    var start: ?usize = null;

    for (0..line.len) |i| {
        const current = line[i];
        var next: ?u8 = null;
        if (i != line.len - 1) {
            next = line[i + 1];
        }

        if (start == null and current >= '0' and current <= '9') {
            start = i;
            continue;
        }
        if (start != null and (next == null or next.? < '0' or next.? > '9')) {
            const number = try std.fmt.parseInt(u64, line[start.? .. i + 1], 10);
            if (x == 0) {
                x = adder + number;
            } else {
                y = adder + number;
            }
            start = null;
        }
    }

    return Point{ .x = x, .y = y };
}

pub fn main() !void {
    const text = @embedFile("inputs/13.txt");

    var lines = std.mem.tokenizeScalar(u8, text, '\n');

    var gameParams = std.ArrayList(GameParams).init(allocator);
    defer gameParams.deinit();

    while (true) {
        const line = lines.next();
        if (line == null) break;

        const pointA = try parsePoint(line.?, 0);
        const pointB = try parsePoint(lines.next().?, 0);
        const prize = try parsePoint(lines.next().?, 0);

        try gameParams.append(GameParams{ .button_a = pointA, .button_b = pointB, .prize = prize });
    }

    var tokens: u64 = 0;
    outer: for (gameParams.items) |params| {
        for (0..100) |i| {
            for (0..100) |j| {
                const resY = j * params.button_a.y + i * params.button_b.y;
                const resX = j * params.button_a.x + i * params.button_b.x;

                if (resY == params.prize.y and resX == params.prize.x) {
                    std.debug.print("Found A:{d} B:{d}\n", .{ j * 3, i });
                    tokens += @as(u64, @intCast(i)) + @as(u64, @intCast(j * 3));
                    continue :outer;
                }
            }
        }

        std.debug.print("No result for X:{d} Y:{d}\n", .{ params.prize.x, params.prize.y });
    }

    std.debug.print("Tokens: {d}\n", .{tokens});
}
