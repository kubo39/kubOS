@system:

extern(C):

int d_main() @nogc nothrow
{
  char[13] hello = ['H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!'];
  ubyte colorByte = 0x1f;  // white foreground, blue background
  ubyte[24] helloColored = [
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte];
  for (int i; i < hello.length; ++i) {
    helloColored[i*2] = hello[i];
  }
  ulong* bufferPtr = cast(ulong*)(0xb8000 + 1988);
  *bufferPtr = cast(ulong)(helloColored.ptr);
  for(;;){}
}
