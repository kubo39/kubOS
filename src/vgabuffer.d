module vgabuffer;

import std.conv : to;

@system:

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
    if (b == '\n'.to!ubyte) {
      newline;
    }
    if (columnPos >= BUFFER_WIDTH) {
      newline;
    }
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

  void write(string str) nothrow @nogc
  {
    foreach (c; str) {
      write(c);
    }
  }

  void write(S...)(S args) nothrow @nogc
  {
    foreach (arg; args) {
      alias A = typeof(arg);
      static if (is(A == string) || is(A == char) || is(A == ubyte)) {
        write(arg);
      }
    }
  }

  void writeln(S...)(S args) nothrow @nogc
  {
    write(args, '\n');
  }

  void newline() nothrow @nogc
  {
    foreach (row; 0..BUFFER_HEIGHT-1) {
      buffer.chars[row] = buffer.chars[row+1];
    }
    clearRow(BUFFER_HEIGHT-1);
    columnPos = 0;
  }

  void clearRow(int row) nothrow @nogc
  {
    auto blank = ScreenChar(' '.to!ubyte, colorCode);
    ScreenChar[BUFFER_WIDTH] arr = void;  // avoid calling memset().
    for (int i; i < BUFFER_HEIGHT; ++i) {
      arr[i] = ScreenChar(' '.to!ubyte, colorCode);
    }
    buffer.chars[row] = arr;
  }
}

void printHello() nothrow @nogc
{
  string hello = "Hello, World!";
  auto writer = Writer(0, Color.LightGreen, Color.Black, cast(Buffer*)0xb8000);
  writer.writeln(hello);
}
