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
