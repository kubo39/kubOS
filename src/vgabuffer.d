module vgabuffer;

import util;

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

    // Writes its argument to the VGA buffer.
    void write(ubyte b) nothrow @nogc
    {
        if (b == cast(ubyte) '\n')
        {
            newline;
            return;
        }
        if (columnPos >= BUFFER_WIDTH)
            newline;
        auto row = BUFFER_HEIGHT - 1;
        auto col = columnPos;
        buffer.chars[row][col] = ScreenChar(b, colorCode);
        ++columnPos;
    }

    // ditto.
    void write(string str) nothrow @nogc
    {
        foreach (c; cast(ubyte[])str)
            write(c);
    }

    // ditto.
    void write(int num, uint base = 10) nothrow @nogc
    {
        ubyte[int.sizeof * 8] buf = void;
		auto start = itoa(num, buf.ptr, buf.length, base);
		for (size_t i = start; i < buf.length; ++i)
			write(buf[i]);
    }

    // ditto.
    void write(ulong num, uint base) nothrow @nogc
    {
        ubyte[ulong.sizeof * 8] buf = void;
		auto start = itoa(num, buf.ptr, buf.length, base);
		for (size_t i = start; i < buf.length; ++i)
			write(buf[i]);
    }

    // Writes its arguments to the VGA buffer.
    void write(S...)(S args) nothrow @nogc
    {
        foreach (arg; args)
            write(arg);
    }

    // Writes its arguments to the VGA buffer, followed by a newline.
    void writeln(S...)(S args) nothrow @nogc
    {
        write(args, '\n');
    }

    void newline() nothrow @nogc
    {
        foreach (row; 0..BUFFER_HEIGHT-1)
            buffer.chars[row] = buffer.chars[row+1];
        clearRow(BUFFER_HEIGHT-1);
        columnPos = 0;
    }

    void clearRow(int row) nothrow @nogc
    {
        auto blank = ScreenChar(cast(ubyte) ' ', colorCode);
        ScreenChar[BUFFER_WIDTH] arr;
        for (int i; i < BUFFER_WIDTH; ++i)
            arr[i] = blank;
        buffer.chars[row] = arr;
    }
}


__gshared static Writer WRITER = Writer(0, Color.LightGreen, Color.Black, cast(Buffer*)0xb8000);


void clearScreen() nothrow @nogc
{
    foreach (_; 0..BUFFER_HEIGHT)
        WRITER.writeln("");
}
