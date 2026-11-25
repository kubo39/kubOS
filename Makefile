build/kernel.elf: kernel/*.d kernel/kernel.ld
	mkdir -p build
	ldc2 \
		-mtriple=riscv64-unknown-none-elf \
		-mattr=+m,+c,+relax \
		-code-model=medium \
		--checkaction=halt \
		--relocation-model=static \
		--transition=tls \
		-g \
		--force-dwarf-frame-section \
		-betterC \
		-O2 \
		-c \
		-od=build \
		-op kernel/*.d
	ld.lld \
		--discard-locals \
		-T kernel/kernel.ld \
		--orphan-handling=warn \
		-o $@ \
		$$(find build -name '*.o')

QEMU_DEBUG := $(if $(filter 1,$(DEBUG)),-s -S)

.PHONY: run-qemu
run-qemu: build/kernel.elf
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-nographic \
		--no-reboot \
		-smp 1 \
		-d int,guest_errors -D qemu.log \
		$(QEMU_DEBUG) \
		-kernel $<
