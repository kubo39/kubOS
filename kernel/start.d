module kernel.start;

import ldc.llvmasm : __asm;

import kernel.main;

enum ulong MSTATUS_MPP_MASK = 3UL << 11;
enum ulong MSTATUS_MPP_S = 1UL << 11;

enum ulong PMP_R = 1UL << 0;
enum ulong PMP_W = 1UL << 1;
enum ulong PMP_X = 1UL << 2;

enum ulong PMP_A_TOR = 1UL << 3;

// DTBはブートROMや前段のブートローダがa1で渡すことを想定している。
// 今のところはQEMUでしか動かさないのでこのままで問題ない。
extern (C) void start(ulong hartid, void* dtb) @nogc nothrow @system
{
    // MPP: Machine Previous Privilege
    // Sモードにセットする
    clearCsr!"mstatus"(MSTATUS_MPP_MASK);
    setCsr!"mstatus"(MSTATUS_MPP_S);

    // mretで飛ぶ先をkmain関数にする
    writeCsr!"mepc"(cast(ulong) &kmain);

    // Sモードでのメモリへのアクセスを許可する
    writeCsr!"pmpaddr0"(0x3f_ffff_ffff_ffffUL);
    writeCsr!"pmpcfg0"(PMP_A_TOR | PMP_R | PMP_W | PMP_X);

    // satp = 0: ページング無効にした状態でSモードに入る
    writeCsr!"satp"(0);

    // 割り込み・例外をSモードに委譲する(書き込めないビットは無視される)
    writeCsr!"medeleg"(0xffff);
    writeCsr!"mideleg"(0xffff);    

    // Sモードに切り替え
    __asm("mret", "{a0},{a1}", hartid, dtb);
}

pragma(inline, true)
ulong readCsr(string csr)() @nogc nothrow @system
{
    return __asm!ulong("csrr $0, " ~ csr, "=r");
}

pragma(inline, true)
void writeCsr(string csr)(ulong v) @nogc nothrow @system
{
    __asm("csrw " ~ csr ~ ", $0", "r,~{memory}", v);
}

pragma(inline, true)
void setCsr(string csr)(ulong v) @nogc nothrow @system
{
    __asm("csrs " ~ csr ~ ", $0", "r,~{memory}", v);
}

pragma(inline, true)
void clearCsr(string csr)(ulong v) @nogc nothrow @system
{
    __asm("csrc " ~ csr ~ ", $0", "r,~{memory}", v);
}
