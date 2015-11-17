@system:

extern(C):

void d_main() @nogc nothrow
{
  auto hello = cast(ubyte[])"Hello, World!";
  ubyte colorByte = 0x1f;  // white foreground, blue background
  ubyte[24] helloColored = [
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte,
    colorByte, colorByte, colorByte, colorByte, colorByte, colorByte];
  for (int i; i < hello.length; ++i) {
    helloColored[i*2] = hello[i];
  }
  ubyte* bufferPtr = cast(ubyte*)(0xb8000 + 1988);
  bufferPtr = helloColored.ptr;
  for(;;){}
}
