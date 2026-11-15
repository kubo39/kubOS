# 3. D言語・LDC

## D言語

自作OSではほとんどC言語かRustが用いられているが、他のプログラミング言語でも開発することは可能だ(低レイヤ領域を触ることができる言語でなければできない領域というのもあるが)。

今回はD言語を利用するが、上述のRustやシステムプログラミング言語としてZigやNimで書き直してみることもできる。

OS開発でのD言語の特徴として、

- テンプレートによる強力な抽象化が可能
- `extern(C)` でC言語の呼び出し規約を利用できる、OS開発ではCの呼び出し規約を前提にするような仕組みもあるのでこれは有用になる
- `noreturn` で戻ってこない関数呼び出しを表現可能

といった点があげられる。

## LDC

LDCはLLVMをバックエンドとしたD言語のコンパイラで、本OSではこれを利用していく。

OS開発においてよく利用する機能としては、

- インラインアセンブリ
- 一部の関数属性 (`ldc.attributes.naked`, `ldc.attributes.section`)
- volatile load/store (`core.volatile.volatileLoad`, `core.volatile.volatileStore`)

といったものがある。

### インラインアセンブリ

LDCのインラインアセンブリはほとんどLLVM内部に渡すだけだが、一部意識しておくことがある。

- 常にvolatile/memory clobber相当が付与されているので、最適化によって消されたり並べ替えられたりしない(CPUのリオーダリングは別なのでfence命令などでガードする必要はある)。
  - 参考: [LLVMインラインアセンブラのmemory constraints/clobberのはなし](https://qiita.com/kubo39/items/a121a3c4c8cbaa5e5807)
- コメントも書けるが、上述のようにLLVMに渡しているだけなのでLLVM側の仕様(アーキテクチャによってコメント表現がかわる)を意識する必要がある。RISC-Vは # でコメントになる。

インラインアセンブリは以下のような記述になる:

```d
    __asm(`
        la sp, __stack_top # spに__stack_topのアドレスをセット
        csrr a0, mhartid   # 自身のhartidをa0にセット
        slli t0, a0, 12    # a0 << 12: 各hartごとに4096バイトのスタック領域をあてるために
        sub sp, sp, t0     # ここでhartごとにスタック領域割り当て
        j kmain            # カーネルのメイン関数にジャンプ
    `, "");
```

また、これはLDC固有のはなしというわけではないのだが、LLVMのインラインアセンブリは[RISC-VのpsABI](https://github.com/riscv-non-isa/riscv-c-api-doc/blob/main/src/c-api.adoc#constraints-on-operands-of-inline-assembly-statements)と対応していないケースがある(執筆時:2026/11/14時点)。たとえばLLVMには `n` 制約(整数の即値を渡せるがリロケーション可能な値はわたせない)という制約があるが、これはRISC-V側では定義されていない。こういったケースは実際に動作を確認しながら地道に判断を重ねていくしかなかったりする。

- 例: `n` 制約を使ったコードの例

```d
    __asm(`
        li t0, $0
        csrw sepc, t0
        li t0, $1
        csrw sstatus, t0
        sret
    `, "n,n", USER_BASE, SSTATUS_SPIE | SSTATUS_SUM);
```
