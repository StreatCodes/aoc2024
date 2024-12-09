const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const text = @embedFile("inputs/9.txt");

    var disk = std.ArrayList(i32).init(allocator);
    defer disk.deinit();

    var isData = true;
    var id: i32 = 0;
    for (text) |_c| {
        const c: u8 = _c - '0';

        if (isData) {
            for (0..c) |_| {
                try disk.append(id);
            }
            id += 1;
        } else {
            const space = try allocator.alloc(i32, c);
            @memset(space, -1);
            try disk.appendSlice(space);
        }
        isData = !isData;
    }

    var i: usize = 0;
    var j: usize = disk.items.len - 1;
    while (i < disk.items.len) {
        if (disk.items[i] != -1) {
            i += 1;
            continue;
        }

        const swapWith = disk.items[j];
        if (swapWith == -1) {
            j -= 1;
            if (i >= j) break;
            continue;
        }

        disk.items[i] = swapWith;
        disk.items[j] = -1;
        i += 1;
        if (i >= j) break;
    }

    var checksum: u64 = 0;
    for (disk.items, 0..) |val, x| {
        if (val == -1) break;
        checksum += x * @as(u64, @intCast(val));
    }

    std.debug.print("Checksum: {d}\n", .{checksum});
}
