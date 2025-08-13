const std = @import("std");

pub fn build(b: *std.Build) void {
    const elf = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("src/kernel.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .riscv32,
            .os_tag = .freestanding,
            .abi = .none,
        }),
        .optimize = .ReleaseSmall,
        .strip = false,
    });
    elf.entry = .disabled;
    elf.setLinkerScript(b.path("src/kernel.ld"));

    b.installArtifact(elf);

    const run_cmd = b.addSystemCommand(&.{"qemu-system-riscv32"});
    run_cmd.addArgs(&.{
        "-machine",
        "virt",
        "-bios",
        "default",
        "-nographic",
        "-serial",
        "mon:stdio",
        "--no-reboot",
        "-kernel",
    });
    run_cmd.addArtifactArg(elf);

    const run_step = b.step("run", "Run QEMU");
    run_step.dependOn(&run_cmd.step);
}
