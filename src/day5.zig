const std = @import("std");
const allocator = std.heap.page_allocator;

fn isDescendant(rules: [][2]i32, first: i32, second: i32) bool {
    for (rules) |rule| {
        if (rule[0] == first and rule[1] == second) {
            return true;
        }
    }

    return false;
}

fn correctOrder(rules: [][2]i32, first: i32, subsequent: []i32) bool {
    for (subsequent) |sub| {
        if (isDescendant(rules, first, sub)) {
            return false;
        }
    }

    return true;
}

fn sort(ctx: [][2]i32, lhs: i32, rhs: i32) bool {
    return isDescendant(ctx, lhs, rhs);
}

pub fn main() !void {
    const text = @embedFile("inputs/5.txt");

    var tokens = std.mem.splitScalar(u8, text, '\n');

    var rules = std.ArrayList([2]i32).init(allocator);
    defer rules.deinit();
    while (tokens.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var values = std.mem.splitScalar(u8, line, '|');
        const left = try std.fmt.parseInt(i32, values.next().?, 10);
        const right = try std.fmt.parseInt(i32, values.next().?, 10);
        try rules.append([2]i32{ left, right });
    }

    var count: i32 = 0;
    while (tokens.next()) |line| {
        var values = std.mem.splitScalar(u8, line, ',');
        var numbers = std.ArrayList(i32).init(allocator);
        defer numbers.deinit();

        while (values.next()) |value| {
            const number = try std.fmt.parseInt(i32, value, 10);
            try numbers.append(number);
        }

        std.mem.reverse(i32, numbers.items);

        var correct = true;
        for (0..numbers.items.len) |i| {
            if (!correctOrder(rules.items, numbers.items[i], numbers.items[i + 1 ..])) {
                correct = false;
            }
        }
        if (correct) continue;

        std.mem.sort(i32, numbers.items, rules.items, sort);

        std.mem.reverse(i32, numbers.items);

        const middleIndex = numbers.items.len / 2;
        const middle = numbers.items[middleIndex];
        std.debug.print("Corrected {s}!\n", .{line});
        count += middle;
    }

    std.debug.print("Count {d}!\n", .{count});
}
