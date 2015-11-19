import vgabuffer;

@system:

extern(C):

void d_main() @nogc nothrow
{
  printHello();
  for(;;){}
}
