import ldc.attributes : naked, section;
import ldc.llvmasm : __asm;

@section(".text.boot")
extern(C) @naked void entry() @nogc nothrow @system
{
    __asm(`
        la sp, __stack_top # spに__stack_topのアドレスをセット
        csrr a0, mhartid   # 自身のhartidをa0にセット
        slli t0, a0, 12    # a0 << 12: 各hartごとに4096バイトのスタック領域をあてるために
        sub sp, sp, t0     # ここでhartごとにスタック領域割り当て
        j start            # start(Sモード移行設定)にジャンプ
    `, "");
}
