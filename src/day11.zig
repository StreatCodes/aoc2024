const std = @import("std");
const allocator = std.heap.page_allocator;

const StoneMap = std.AutoHashMap(u64, u64);

fn setOrAdd(stoneMap: *StoneMap, stone: u64, value: u64) !void {
    const res = stoneMap.getPtr(stone);
    if (res != null) {
        res.?.* += value;
        return;
    }
    try stoneMap.put(stone, value);
}

pub fn main() !void {
    const text = @embedFile("inputs/11.txt");

    var tokens = std.mem.splitScalar(u8, text, ' ');

    var stones = std.ArrayList(u64).init(allocator);
    defer stones.deinit();

    var currentMap = StoneMap.init(allocator);

    while (tokens.next()) |stoneText| {
        const stone = try std.fmt.parseInt(u64, stoneText, 10);
        try setOrAdd(&currentMap, stone, 1);
    }

    var buf: [1024]u8 = undefined;
    for (0..75) |i| {
        std.debug.print("Iteration {d}\n", .{i});
        var nextMap = StoneMap.init(allocator);
        var iter = currentMap.iterator();
        while (iter.next()) |entry| {
            if (entry.key_ptr.* == 0) {
                try setOrAdd(&nextMap, 1, entry.value_ptr.*);
                continue;
            }

            const textNumber = try std.fmt.bufPrint(&buf, "{d}", .{entry.key_ptr.*});
            if (textNumber.len % 2 == 0) {
                const half = textNumber.len / 2;
                const firstStone = try std.fmt.parseInt(u64, textNumber[0..half], 10);
                const secondStone = try std.fmt.parseInt(u64, textNumber[half..], 10);
                try setOrAdd(&nextMap, firstStone, entry.value_ptr.*);
                try setOrAdd(&nextMap, secondStone, entry.value_ptr.*);
                continue;
            }

            const nextStone = entry.key_ptr.* * 2024;
            try setOrAdd(&nextMap, nextStone, entry.value_ptr.*);
        }
        currentMap.deinit();
        currentMap = nextMap;
    }

    var total: u64 = 0;
    var iter = currentMap.iterator();
    while (iter.next()) |entry| {
        total += entry.value_ptr.*;
    }

    std.debug.print("Total: {d}\n", .{total});
    currentMap.deinit();
}
