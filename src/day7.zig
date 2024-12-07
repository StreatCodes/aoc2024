const std = @import("std");

fn concat(allocator: std.mem.Allocator, a: u64, b: u64) !u64 {
    const res = try std.fmt.allocPrint(allocator, "{d}{d}", .{ a, b });
    defer allocator.free(res);
    return try std.fmt.parseInt(u64, res, 10);
}

fn calculateNext(allocator: std.mem.Allocator, expectedResult: u64, current: u64, values: []u64) !bool {
    if (values.len == 0) return current == expectedResult;

    const next = values[0];

    if (try calculateNext(allocator, expectedResult, current + next, values[1..])) return true;
    if (try calculateNext(allocator, expectedResult, current * next, values[1..])) return true;
    if (try calculateNext(allocator, expectedResult, try concat(allocator, current, next), values[1..])) return true;

    return false;
}

pub fn main() !void {
    const text = @embedFile("inputs/7.txt");
    var buffer: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var total: u64 = 0;
    while (tokens.next()) |line| {
        var valuesText = std.mem.splitScalar(u8, line, ' ');
        const resultText = valuesText.next().?;
        const result = try std.fmt.parseInt(u64, resultText[0 .. resultText.len - 1], 10);

        var values = std.ArrayList(u64).init(allocator);
        defer values.deinit();

        while (valuesText.next()) |valueText| {
            const value = try std.fmt.parseInt(u64, valueText, 10);
            try values.append(value);
        }

        const canSolve = try calculateNext(allocator, result, 0, values.items);
        if (canSolve) {
            std.debug.print("Solved {d}\n", .{result});
            total += result;
        }
    }

    std.debug.print("Total {d}\n", .{total});
}
