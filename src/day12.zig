const std = @import("std");
const allocator = std.heap.page_allocator;

const Direction = enum { up, down, left, right };

const Point = struct {
    x: usize,
    y: usize,
};

const Edge = struct {
    x: usize,
    y: usize,
    side: Direction,
};

const CheckedList = std.AutoHashMap(Point, void);
const EdgeList = std.AutoHashMap(Edge, void);

fn removeConnectedEdges(map: [][]const u8, edgeList: *EdgeList, _edge: Edge) void {
    const edge = Edge{ .x = _edge.x, .y = _edge.y, .side = _edge.side };
    _ = edgeList.remove(_edge);
    if (edge.side == Direction.up) {
        if (edge.x > 0) {
            const nextEdge = Edge{ .x = edge.x - 1, .y = edge.y, .side = Direction.up };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
        if (edge.x < map[edge.y].len - 1) {
            const nextEdge = Edge{ .x = edge.x + 1, .y = edge.y, .side = Direction.up };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
    }

    if (edge.side == Direction.down) {
        if (edge.x > 0) {
            const nextEdge = Edge{ .x = edge.x - 1, .y = edge.y, .side = Direction.down };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
        if (edge.x < map[edge.y].len - 1) {
            const nextEdge = Edge{ .x = edge.x + 1, .y = edge.y, .side = Direction.down };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
    }

    if (edge.side == Direction.left) {
        if (edge.y > 0) {
            const nextEdge = Edge{ .x = edge.x, .y = edge.y - 1, .side = Direction.left };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
        if (edge.y < map.len - 1) {
            const nextEdge = Edge{ .x = edge.x, .y = edge.y + 1, .side = Direction.left };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
    }

    if (edge.side == Direction.right) {
        if (edge.y > 0) {
            const nextEdge = Edge{ .x = edge.x, .y = edge.y - 1, .side = Direction.right };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
        if (edge.y < map.len - 1) {
            const nextEdge = Edge{ .x = edge.x, .y = edge.y + 1, .side = Direction.right };
            if (edgeList.contains(nextEdge)) removeConnectedEdges(map, edgeList, nextEdge);
        }
    }
}

fn calculateArea(map: [][]const u8, plantType: u8, point: Point, checkList: *CheckedList, edgeList: *EdgeList) !u32 {
    try checkList.put(point, void{});
    var area: u32 = 1;
    if (point.y > 0 and map[point.y - 1][point.x] == plantType) {
        const nextPoint = Point{ .x = point.x, .y = point.y - 1 };
        if (!checkList.contains(nextPoint)) {
            area += try calculateArea(map, plantType, nextPoint, checkList, edgeList);
        }
    } else {
        try edgeList.put(Edge{ .x = point.x, .y = point.y, .side = Direction.up }, {});
    }

    if (point.y < map.len - 1 and map[point.y + 1][point.x] == plantType) {
        const nextPoint = Point{ .x = point.x, .y = point.y + 1 };
        if (!checkList.contains(nextPoint)) {
            area += try calculateArea(map, plantType, nextPoint, checkList, edgeList);
        }
    } else {
        try edgeList.put(Edge{ .x = point.x, .y = point.y, .side = Direction.down }, {});
    }

    if (point.x > 0 and map[point.y][point.x - 1] == plantType) {
        const nextPoint = Point{ .x = point.x - 1, .y = point.y };
        if (!checkList.contains(nextPoint)) {
            area += try calculateArea(map, plantType, nextPoint, checkList, edgeList);
        }
    } else {
        try edgeList.put(Edge{ .x = point.x, .y = point.y, .side = Direction.left }, {});
    }

    if (point.x < map[point.y].len - 1 and map[point.y][point.x + 1] == plantType) {
        const nextPoint = Point{ .x = point.x + 1, .y = point.y };
        if (!checkList.contains(nextPoint)) {
            area += try calculateArea(map, plantType, nextPoint, checkList, edgeList);
        }
    } else {
        try edgeList.put(Edge{ .x = point.x, .y = point.y, .side = Direction.right }, {});
    }

    return area;
}

pub fn main() !void {
    const text = @embedFile("inputs/12.txt");

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var map = std.ArrayList([]const u8).init(allocator);
    defer map.deinit();

    while (tokens.next()) |line| {
        try map.append(line);
    }

    var areaCheckList = CheckedList.init(allocator);
    defer areaCheckList.deinit();

    var edgeList = EdgeList.init(allocator);
    defer edgeList.deinit();

    var total: u32 = 0;
    for (0..map.items.len) |y| {
        for (0..map.items[y].len) |x| {
            const point = Point{ .x = x, .y = y };
            if (areaCheckList.contains(point)) continue;

            const area = try calculateArea(map.items, map.items[y][x], point, &areaCheckList, &edgeList);

            var perimeter: u32 = 0;
            while (true) {
                var iter = edgeList.iterator();
                const edge = iter.next();
                if (edge == null) break;

                removeConnectedEdges(map.items, &edgeList, edge.?.key_ptr.*);
                perimeter += 1;
            }

            std.debug.print("A region of {c} plants with price {d} * {d} = {d}.\n", .{ map.items[y][x], area, perimeter, area * perimeter });
            total += area * perimeter;
        }
    }

    std.debug.print("Price: {d}\n", .{total});
}
