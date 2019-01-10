ARCH ?= x86_64
TARGET ?= $(ARCH)-unknown-linux-gnu
KERNEL := build/kernel-$(ARCH).bin
ISO := build/os-$(ARCH).iso

DLANG_OS := target/$(TARGET)/debug/libkubos.a
LINKER_SCRIPT := src/arch/$(ARCH)/linker.ld
GRUB_CFG := src/arch/$(ARCH)/grub.cfg
ASSEMBLY_SRCS := $(wildcard src/arch/$(ARCH)/*.asm)
ASSEMBLY_OBJS := $(patsubst src/arch/$(ARCH)/%.asm, \
	build/arch/$(ARCH)/%.o, $(ASSEMBLY_SRCS))
D_SRCS := $(wildcard src/*.d)

LDC ?= ldc2

DFLAGS = \
	-disable-red-zone \
	-lib \
	-mattr=-mmx,-sse,+soft-float \
	-mtriple=$(TARGET) \
	-nogc \
	-release \
	-relocation-model=static

LINKFLAGS = \
	-I./src \
    -Xcc=-nostartfiles \
    -defaultlib= # Do not link libphobos2.a

.PHONY: all clean run iso

all: $(KERNEL)

clean:
	@rm -rf build
	@rm -rf target

run: $(ISO)
	@qemu-system-x86_64 -drive format=raw,file=$(ISO)

ISO: $(ISO)

$(ISO): $(KERNEL) $(GRUB_CFG)
	@mkdir -p build/isofiles/boot/grub
	@cp $(KERNEL) build/isofiles/boot/kernel.bin
	@cp $(GRUB_CFG) build/isofiles/boot/grub
	@grub-mkrescue -o $(ISO) build/isofiles 2> /dev/null
	@rm -r build/isofiles

$(KERNEL): $(ASSEMBLY_OBJS) $(LINKER_SCRIPT)
	@$(LDC) -of=$(DLANG_OS) $(DFLAGS) $(LINKFLAGS) $(D_SRCS)
	@ld -n --gc-sections -T $(LINKER_SCRIPT) -o $(KERNEL) $(ASSEMBLY_OBJS) $(DLANG_OS)

# compile assembly files
build/arch/$(ARCH)/%.o: src/arch/$(ARCH)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@
