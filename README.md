# kubOS

Trying to write OS, but D.

https://github.com/phil-opp/blog_os

## prerequirements

Currently x86_64 only.

* qemu -- for running OS on qemu.
* nasm -- for compiling assembly sources.
* dmd -- for compiling D sources.
* dub -- for building D language project.
* xorriso -- for create ISO image.
* grub-pc-bin -- (optional.) because of Linux on EFI

### Ubuntu

Get system requirements.

```console
$ apt install -y qemu-system-x86 nasm xorriso
```

Install DMD.

```console
$ curl https://dlang.org/install.sh | bash -s dmd
```

## Build && Run

```
$ make run
```
