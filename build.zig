const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const minhook_lib = b.addLibrary(.{
        .name = "minhook",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    minhook_lib.linkLibC();
    minhook_lib.addCSourceFiles(.{
        .files = &.{
            "minhook/src/hook.c",
            "minhook/src/buffer.c",
            "minhook/src/trampoline.c",
        },
    });

    if (target.result.cpu.arch == .x86_64) {
        minhook_lib.addCSourceFile(.{ .file = b.path("minhook/src/hde/hde64.c") });
    } else {
        minhook_lib.addCSourceFile(.{ .file = b.path("minhook/src/hde/hde32.c") });
    }

    const module = b.addModule("minhook", .{
        .root_source_file = b.path("src/minhook.zig"),
        .target = target,
        .optimize = optimize,
    });
    module.addIncludePath(b.path("minhook/include"));
    module.linkLibrary(minhook_lib);
}
