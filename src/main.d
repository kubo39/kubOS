import std.range;

@system:

extern(C):

void d_main() @nogc nothrow
{
  char[13] hello = ['H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!'];
  ubyte colorByte = 0x1f;  // white foreground, blue background
  ubyte[24] helloColored = [
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte];

  foreach (i, c; hello) {
    helloColored[i*2] = c;
  }

  ulong* bufferPtr = cast(ulong*)(0xb8000 + 1988);
  *bufferPtr = cast(ulong)(helloColored.ptr);
  for(;;){}
}
