const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "SaltyOS",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);
    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-riscv32",
    });
    run_cmd.addArgs(&.{
        "-machine",
        "virt",
        "-bios",
        "default",
        "-nographic",
        "-serial",
        "mon:stdio",
        "--no-reboot",
    });
    const run_step = b.step("run", "Run QEMU");
    run_step.dependOn(&run_cmd.step);
}
