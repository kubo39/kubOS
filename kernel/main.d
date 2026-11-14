module kernel.main;

import ldc.llvmasm : __asm;

extern(C) noreturn kmain() @nogc nothrow @system
{
    while (true)
        __asm("wfi", "");
}
