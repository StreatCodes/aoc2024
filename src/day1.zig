const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const text = @embedFile("inputs/1.txt");

    var numberSet1 = try allocator.alloc(i32, 1000);
    var numberSet2 = try allocator.alloc(i32, 1000);

    defer allocator.free(numberSet1);
    defer allocator.free(numberSet2);

    var tokens = std.mem.tokenizeScalar(u8, text, '\n');
    var i: usize = 0;
    while (tokens.next()) |line| {
        std.debug.print("{s}\n", .{line});

        var values = std.mem.tokenizeScalar(u8, line, ' ');
        const num1 = try std.fmt.parseInt(i32, values.next().?, 10);
        const num2 = try std.fmt.parseInt(i32, values.next().?, 10);

        numberSet1[i] = num1;
        numberSet2[i] = num2;

        i += 1;
    }

    std.mem.sort(i32, numberSet1, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, numberSet2, {}, comptime std.sort.asc(i32));

    var total: u32 = 0;

    for (0..1000) |j| {
        const distance = @abs(numberSet1[j] - numberSet2[j]);
        total += distance;

        std.debug.print("{d} - {d} = {d}\n", .{ numberSet1[j], numberSet2[j], distance });
    }

    std.debug.print("Total: {d}!\n", .{total});
}
