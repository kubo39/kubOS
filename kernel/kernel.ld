ENTRY(entry);

SECTIONS
{
    . = 0x80000000;

    .text : {
        KEEP(*(.text.boot));
        *(.text .text.*);
    }

    .rodata : ALIGN(16) {
        *(.rodata .rodata.*);
    }

    .data : ALIGN(16) {
        *(.data .data.*);
    }

    .bss : ALIGN(16) {
        *(.bss .bss.*);
    }

    .stack(NOLOAD) : ALIGN(16) {
        . += 4096;
        PROVIDE(__stack_top = .);
    }

    .comment          0 : { *(.comment) }
    .riscv.attributes 0 : { *(.riscv.attributes) }
    .symtab           0 : { *(.symtab) }
    .strtab           0 : { *(.strtab) }
    .shstrtab         0 : { *(.shstrtab) }

    /DISCARD/ : {
        *(.eh_frame);
    }
}
