import vgabuffer;
import multiboot;

extern (C):
@nogc:
nothrow:

pragma(LDC_no_typeinfo);
pragma(LDC_no_moduleinfo);

__gshared void _d_dso_registry() {}

void d_main(size_t address) @nogc nothrow
{
    clearScreen;
    WRITER.writeln("Hello, World!");

    auto bootInfo = multiboot.load(address);
    auto memoryMapTag  = bootInfo.memoryMapTag();

    WRITER.writeln("memory areas: ");
    foreach (area; memoryMapTag.memoryAreas)
    {
        WRITER.write("  start: ");
        WRITER.write(area.baseAddr, 16);
        WRITER.write("  length: ");
        WRITER.write(area.length, 16);
        WRITER.writeln("");
    }
    for(;;){}
}
