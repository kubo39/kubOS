module vgabuffer;

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

  auto write(ubyte b) nothrow @nogc
  {
    if (columnPos >= BUFFER_WIDTH) {
    }
    auto row = BUFFER_HEIGHT - 1;
    auto col = columnPos;
    buffer.chars[row][col] = ScreenChar(b, colorCode);
    ++columnPos;
  }
}

void printHello() nothrow @nogc
{
  char[13] hello = ['H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!'];
  auto writer = Writer(0, Color.LightGreen, Color.Black, cast(Buffer*)0xb8000);

  foreach (c; hello) {
    writer.write(c);
  }
}