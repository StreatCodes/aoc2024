const std = @import("std");
const allocator = std.heap.page_allocator;

const Direction = enum { up, right, down, left };
const Point = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    const text = @embedFile("inputs/6.txt");

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var map = std.ArrayList([]u8).init(allocator);
    defer map.deinit();

    while (tokens.next()) |line| {
        const data = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, data, line);
        try map.append(data);
    }

    var direction = Direction.up;
    var position = Point{ .x = 0, .y = 0 };
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            if (map.items[y][x] == '^') {
                position.x = x;
                position.y = y;
                map.items[position.y][position.x] = 'X';
            }
        }
    }

    outer: while (true) {
        switch (direction) {
            Direction.up => {
                if (position.y == 0) break :outer;
                if (map.items[position.y - 1][position.x] == '#') {
                    direction = Direction.right;
                    continue :outer;
                }
                position.y -= 1;
                map.items[position.y][position.x] = 'X';
            },
            Direction.right => {
                if (position.x + 1 >= map.items[position.y].len) break :outer;
                if (map.items[position.y][position.x + 1] == '#') {
                    direction = Direction.down;
                    continue :outer;
                }
                position.x += 1;
                map.items[position.y][position.x] = 'X';
            },
            Direction.down => {
                if (position.y + 1 >= map.items.len) break :outer;
                if (map.items[position.y + 1][position.x] == '#') {
                    direction = Direction.left;
                    continue :outer;
                }
                position.y += 1;
                map.items[position.y][position.x] = 'X';
            },
            Direction.left => {
                if (position.x == 0) break :outer;
                if (map.items[position.y][position.x - 1] == '#') {
                    direction = Direction.up;
                    continue :outer;
                }
                position.x -= 1;
                map.items[position.y][position.x] = 'X';
            },
        }
    }

    var count: u32 = 0;
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            if (map.items[y][x] == 'X') {
                count += 1;
            }
        }
    }

    std.debug.print("Unique positions {d}!\n", .{count});
}
