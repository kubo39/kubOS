build/kernel.elf: kernel/*.d kernel/kernel.ld
	mkdir -p build
	ldc2 \
		-mtriple=riscv64-unknown-none-elf \
		-mattr=+m \
		-code-model=medium \
		--checkaction=halt \
		--relocation-model=static \
		--transition=tls \
		-betterC \
		-O2 \
		-c \
		-od=build \
		-op kernel/*.d
	ld.lld \
		-T kernel/kernel.ld \
		--orphan-handling=warn \
		-o $@ \
		$$(find build -name '*.o')

run-qemu: build/kernel.elf
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-nographic \
		--no-reboot \
		-smp 1 \
		-d int,guest_errors -D qemu.log \
		-kernel $<
