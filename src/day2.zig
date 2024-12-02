const std = @import("std");
const allocator = std.heap.page_allocator;

fn isSafeReport(levels: []u32) bool {
    const decrementing = levels[0] > levels[1];
    for (0..levels.len - 1) |i| {
        const current = levels[i];
        const next = levels[i + 1];

        if (next == current) {
            return false;
        }
        if (decrementing) {
            if (next > current or current - next > 3) {
                return false;
            }
        } else {
            if (next < current or next - current > 3) {
                return false;
            }
        }
    }

    return true;
}

pub fn main() !void {
    const text = @embedFile("inputs/2.txt");

    var safeReports: u32 = 0;
    var tokens = std.mem.tokenizeScalar(u8, text, '\n');
    while (tokens.next()) |line| {
        var levels = std.ArrayList(u32).init(allocator);
        defer levels.deinit();

        var values = std.mem.tokenizeScalar(u8, line, ' ');
        while (values.next()) |value| {
            const num = try std.fmt.parseInt(u32, value, 10);
            try levels.append(num);
        }

        for (0..levels.items.len) |i| {
            var partialLevels = try levels.clone();
            defer partialLevels.deinit();

            _ = partialLevels.orderedRemove(i);
            const safe = isSafeReport(partialLevels.items);

            if (safe) {
                std.debug.print("Safe!\n", .{});
                safeReports += 1;
                break;
            } else {
                std.debug.print("Unsafe!\n", .{});
            }
        }
    }

    std.debug.print("Safe reports: {d}!\n", .{safeReports});
}
