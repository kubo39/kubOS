module util;

extern (C):
@nogc:
nothrow:

pragma(LDC_no_typeinfo);
pragma(LDC_no_moduleinfo);

immutable ubyte[] BASE_CHARS = cast(immutable ubyte[])"0123456789ABCDEF";

size_t itoa(ulong value, ubyte* buf, size_t len, uint base = 10) nothrow @nogc
{
    assert(1 < base && base <= 16);
    size_t pos = len;
    bool sign = false;

    if (value < 0)
    {
        sign = true;
        value = -value;
    }

    do
    {
        buf[--pos] = BASE_CHARS[value % base];
    } while (value /= base);

    if (sign)
        buf[--pos] = '-';

    return pos;
}

extern (C) void* memcpy(void* dest, void* src, size_t len)
{
    auto d = cast(ubyte*) dest;
    auto s = cast(ubyte*) src;
    foreach (i; 0 .. len)
        d[i] = s[i];
    return dest;
}

extern (C) void* memset(void* dest, int value, size_t len)
{
    auto d = cast(byte*) dest;
    foreach (i; 0 .. len)
        d[i] = cast(byte) value;
    return dest;
}
