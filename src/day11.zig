const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const text = @embedFile("inputs/11.txt");

    var tokens = std.mem.splitScalar(u8, text, ' ');

    var stones = std.ArrayList(u64).init(allocator);
    defer stones.deinit();

    while (tokens.next()) |stoneText| {
        const stone = try std.fmt.parseInt(u64, stoneText, 10);
        try stones.append(stone);
    }

    var buf: [1024]u8 = undefined;
    for (0..25) |iter| {
        std.debug.print("Iteration {d}\n", .{iter});
        const stonesLen = stones.items.len;
        var i: usize = 0;
        while (i < stonesLen) : (i += 1) {
            if (stones.items[i] == 0) {
                stones.items[i] = 1;
                continue;
            }

            const textNumber = try std.fmt.bufPrint(&buf, "{d}", .{stones.items[i]});
            if (textNumber.len % 2 == 0) {
                const half = textNumber.len / 2;
                const firstStone = try std.fmt.parseInt(u64, textNumber[0..half], 10);
                const secondStone = try std.fmt.parseInt(u64, textNumber[half..], 10);
                stones.items[i] = firstStone;
                try stones.append(secondStone);
                continue;
            }

            stones.items[i] *= 2024;
        }
    }

    std.debug.print("Total: {d}\n", .{stones.items.len});
}
