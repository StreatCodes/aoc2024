const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day = b.option(u32, "day", "The challenge day") orelse 1;

    if (day < 1 or day > 25) {
        std.debug.print("Day must be between 1 and 25\n", .{});
        std.process.exit(1);
    }

    const main_file = try std.fmt.allocPrint(b.allocator, "src/day{d}.zig", .{day});
    defer b.allocator.free(main_file);

    std.debug.print("Running {s}\n", .{main_file});

    const exe = b.addExecutable(.{
        .name = "aoc2024",
        .root_source_file = b.path(main_file),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
