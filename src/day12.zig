const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct {
    x: usize,
    y: usize,
};

const Result = struct {
    area: u32,
    perimeter: u32,
};

const CheckedList = std.AutoHashMap(Point, void);

fn solveRegion(map: [][]const u8, plantType: u8, point: Point, checkList: *CheckedList) !Result {
    try checkList.put(point, void{});
    var result = Result{ .area = 1, .perimeter = 0 };
    if (point.y > 0 and map[point.y - 1][point.x] == plantType) {
        const nextPoint = Point{ .x = point.x, .y = point.y - 1 };
        if (!checkList.contains(nextPoint)) {
            const nextResult = try solveRegion(map, plantType, nextPoint, checkList);
            result.area += nextResult.area;
            result.perimeter += nextResult.perimeter;
        }
    } else {
        result.perimeter += 1;
    }

    if (point.y < map.len - 1 and map[point.y + 1][point.x] == plantType) {
        const nextPoint = Point{ .x = point.x, .y = point.y + 1 };
        if (!checkList.contains(nextPoint)) {
            const nextResult = try solveRegion(map, plantType, nextPoint, checkList);
            result.area += nextResult.area;
            result.perimeter += nextResult.perimeter;
        }
    } else {
        result.perimeter += 1;
    }

    if (point.x > 0 and map[point.y][point.x - 1] == plantType) {
        const nextPoint = Point{ .x = point.x - 1, .y = point.y };
        if (!checkList.contains(nextPoint)) {
            const nextResult = try solveRegion(map, plantType, nextPoint, checkList);
            result.area += nextResult.area;
            result.perimeter += nextResult.perimeter;
        }
    } else {
        result.perimeter += 1;
    }

    if (point.x < map[point.y].len - 1 and map[point.y][point.x + 1] == plantType) {
        const nextPoint = Point{ .x = point.x + 1, .y = point.y };
        if (!checkList.contains(nextPoint)) {
            const nextResult = try solveRegion(map, plantType, nextPoint, checkList);
            result.area += nextResult.area;
            result.perimeter += nextResult.perimeter;
        }
    } else {
        result.perimeter += 1;
    }

    return result;
}

pub fn main() !void {
    const text = @embedFile("inputs/12.txt");

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var map = std.ArrayList([]const u8).init(allocator);
    defer map.deinit();

    while (tokens.next()) |line| {
        try map.append(line);
    }

    var checkList = CheckedList.init(allocator);
    defer checkList.deinit();

    var total: u32 = 0;
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            const point = Point{ .x = x, .y = y };
            if (checkList.contains(point)) continue;
            const result = try solveRegion(map.items, map.items[y][x], point, &checkList);
            std.debug.print("{c} area: {d}, perimeter: {d}\n", .{ map.items[y][x], result.area, result.perimeter });
            total += result.area * result.perimeter;
        }
    }

    std.debug.print("Price: {d}\n", .{total});
}
