module vgabuffer;

import std.conv : to;

@system:

extern(C):

immutable BUFFER_HEIGHT = 25;
immutable BUFFER_WIDTH  = 80;

enum Color : ubyte
{
  Black      = 0,
  Blue       = 1,
  Green      = 2,
  Cyan       = 3,
  Red        = 4,
  Magenta    = 5,
  Brown      = 6,
  LightGray  = 7,
  DarkGray   = 8,
  LightBlue  = 9,
  LightGreen = 10,
  LightCyan  = 11,
  LightRed   = 12,
  Pink       = 13,
  Yellow     = 14,
  White      = 15
}

struct ScreenChar
{
  ubyte asciiChar;
  Color colorCode;
}

struct Buffer
{
  ScreenChar[BUFFER_WIDTH][BUFFER_HEIGHT] chars;
}

struct Writer
{
  ulong columnPos;
  Color colorCode;
  Buffer* buffer;

  this(ulong _columnPos, Color foreground, Color background, Buffer* _buffer) nothrow @nogc
  {
    columnPos = _columnPos;
    colorCode = cast(Color)(background << 4 | foreground);
    buffer = _buffer;
  }

  void write(ubyte b) nothrow @nogc
  {
    auto row = BUFFER_HEIGHT - 1;
    auto col = columnPos;
    buffer.chars[row][col] = ScreenChar(b, colorCode);
    ++columnPos;
  }

  void write(char c) nothrow @nogc
  {
    write(c.to!ubyte);
  }

  void write(const char[] chars) nothrow @nogc
  {
    foreach (c; chars) {
      write(c);
    }
  }
}

void printHello() nothrow @nogc
{
  const char[13] hello = ['H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!'];
  auto writer = Writer(0, Color.LightGreen, Color.Black, cast(Buffer*)0xb8000);
  writer.write(hello);
}
