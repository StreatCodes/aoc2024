const std = @import("std");
const allocator = std.heap.page_allocator;

const Direction = enum { up, right, down, left };
const Point = struct {
    x: usize,
    y: usize,
    direction: Direction,
};

fn historyContainsPosition(history: []Point, position: Point) bool {
    for (history) |point| {
        if (point.x == position.x and point.y == position.y and point.direction == position.direction) {
            return true;
        }
    }
    return false;
}

fn detectLoop(map: *std.ArrayList([]u8), pos: Point) !bool {
    var position = pos;

    var history = std.ArrayList(Point).init(allocator);
    defer history.deinit();
    outer: while (true) {
        switch (position.direction) {
            Direction.up => {
                if (position.y == 0) break :outer;
                if (map.items[position.y - 1][position.x] == '#' or map.items[position.y - 1][position.x] == '@') {
                    position.direction = Direction.right;
                    if (historyContainsPosition(history.items, position)) {
                        return true;
                    }
                    try history.append(position);
                    continue :outer;
                }
                position.y -= 1;
            },
            Direction.right => {
                if (position.x + 1 >= map.items[position.y].len) break :outer;
                if (map.items[position.y][position.x + 1] == '#' or map.items[position.y][position.x + 1] == '@') {
                    position.direction = Direction.down;
                    if (historyContainsPosition(history.items, position)) {
                        return true;
                    }
                    try history.append(position);
                    continue :outer;
                }
                position.x += 1;
            },
            Direction.down => {
                if (position.y + 1 >= map.items.len) break :outer;
                if (map.items[position.y + 1][position.x] == '#' or map.items[position.y + 1][position.x] == '@') {
                    position.direction = Direction.left;
                    if (historyContainsPosition(history.items, position)) {
                        return true;
                    }
                    try history.append(position);
                    continue :outer;
                }
                position.y += 1;
            },
            Direction.left => {
                if (position.x == 0) break :outer;
                if (map.items[position.y][position.x - 1] == '#' or map.items[position.y][position.x - 1] == '@') {
                    position.direction = Direction.up;
                    if (historyContainsPosition(history.items, position)) {
                        return true;
                    }
                    try history.append(position);
                    continue :outer;
                }
                position.x -= 1;
            },
        }
    }
    return false;
}

fn clearMap(map: *std.ArrayList([]u8)) void {
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            if (map.items[y][x] != '#' and map.items[y][x] != '.') {
                map.items[y][x] = '.';
            }
        }
    }
}

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

    var startingPosition = Point{ .x = 0, .y = 0, .direction = Direction.up };
    var position = Point{ .x = 0, .y = 0, .direction = Direction.up };
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            if (map.items[y][x] == '^') {
                position.x = x;
                position.y = y;
                startingPosition.x = x;
                startingPosition.y = y;
                map.items[position.y][position.x] = '|';
            }
        }
    }

    var count: u32 = 0;
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            if (startingPosition.x == x and startingPosition.y == y or map.items[y][x] == '#') {
                continue;
            }
            clearMap(&map);
            map.items[y][x] = '@';
            if (try detectLoop(&map, position)) {
                count += 1;
            }
        }
    }

    std.debug.print("Possible loop spots {d}\n", .{count});
}
