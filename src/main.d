import vgabuffer;

@system:

extern(C):

void d_main() @nogc nothrow
{
  clearScreen;
  WRITER.writeln("Hello, World!");
  for(;;){}
}
