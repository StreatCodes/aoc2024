const std = @import("std");
const allocator = std.heap.page_allocator;

fn findFileSpace(disk: []i32, fileLength: usize, until: usize) ?usize {
    var start: ?usize = null;
    for (0..until) |i| {
        if (start == null and disk[i] == -1) {
            start = i;
        }
        if (start == null) continue;
        if (disk[i] != -1) {
            start = null;
            continue;
        }
        if (i - start.? >= fileLength) return start;
    }

    return null;
}

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

    var fileEnd: ?usize = null;
    var i = disk.items.len - 1;
    while (i > 0) : (i -= 1) {
        if (fileEnd == null and disk.items[i] == -1) continue;
        if (fileEnd == null and disk.items[i] != -1) {
            fileEnd = i;
        }

        if (fileEnd != null) {
            const next = disk.items[i - 1];

            if (next == disk.items[fileEnd.?]) continue;
        }

        const fileStart = i;
        const fileLength = fileEnd.? - fileStart;

        const insertIndex = findFileSpace(disk.items, fileLength, i);
        if (insertIndex != null) {
            for (0..fileLength + 1) |j| {
                disk.items[insertIndex.? + j] = disk.items[fileStart + j];
                disk.items[fileStart + j] = -1;
            }
        }

        fileEnd = null;
    }

    var checksum: u64 = 0;
    for (disk.items, 0..) |val, x| {
        if (val == -1) continue;
        checksum += x * @as(u64, @intCast(val));
    }

    std.debug.print("Checksum: {d}\n", .{checksum});
}
