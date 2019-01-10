module multiboot;

extern (C):
@nogc:
nothrow:

pragma(LDC_no_typeinfo);
pragma(LDC_no_moduleinfo);

struct Tag
{
    uint type;
    uint size;
}


struct MemoryArea
{
    ulong baseAddr;
    ulong length;
    uint type;
    uint reserved;
}


struct MemoryMapTag
{
    uint type;
    uint size;
    uint entrySize;
    uint entryVersion;
    MemoryArea* firstArea;

    Range memoryAreas() @nogc nothrow
    {
        auto ptr = cast(MemoryMapTag*) &this;
        auto startArea = cast(MemoryArea*) ptr.firstArea;
        return Range(startArea,
                     cast(MemoryArea*) (cast(size_t) &this + cast(size_t) (this.size + this.entrySize)),
                     this.entrySize);
    }

    struct Range
    {
        MemoryArea* currentArea;
        MemoryArea* lastArea;
        uint entrySize;

        this(MemoryArea* startArea, MemoryArea* lastArea, uint entrySize) @nogc nothrow
        {
            this.currentArea = startArea;
            this.lastArea = lastArea;
            this.entrySize = entrySize;
        }

        bool empty() @nogc nothrow
        {
            return this.currentArea > this.lastArea;
        }

        MemoryArea* front() @nogc nothrow
        {
            return this.currentArea;
        }

        void popFront() @nogc nothrow
        {
            auto area = this.currentArea;
            this.currentArea = cast(MemoryArea*) (cast(size_t) this.currentArea + cast(size_t) this.entrySize);
            if (this.currentArea.type != 1)
                popFront();
        }
    }
}


struct BootInformation
{
    uint totalSize;
    uint reserved;
    Tag firstTag;

    bool hasValidEndTag() @nogc nothrow
    {
        Tag END_TAG = Tag(0, 8);
        auto endTagAddr = cast(size_t) &this + (this.totalSize - END_TAG.size);
        auto endTag = cast(Tag*) endTagAddr;
        return endTag.type == END_TAG.type && endTag.size == END_TAG.size;
    }

    auto memoryMapTag() @nogc nothrow
    {
        return (cast(MemoryMapTag*) getTag(6)); //.memoryAreas;
    }

    Tag* getTag(uint type) @nogc nothrow
    {
        foreach (tag; tags())
            if (tag.type == type)
                return tag;
        assert(0);
    }

    Range tags() @nogc nothrow
    {
        return Range(&firstTag);
    }

    struct Range
    {
        Tag* current;

        this(Tag* current) @nogc nothrow
        {
            this.current = current;
        }

        bool empty() @nogc nothrow
        {
            return this.current.type == 0 && this.current.size == 8;
        }

        Tag* front() @nogc nothrow
        {
            return this.current;
        }

        void popFront() @nogc nothrow
        {
            size_t tagAddr = cast(size_t) this.current;
            tagAddr += this.current.size;
            tagAddr = ((tagAddr-1) & ~0x7) + 0x8;  // align at 8 bytes.
            this.current = cast(Tag*) tagAddr;
        }
    }
}

BootInformation* load(size_t address) @nogc nothrow
{
    auto multiboot =  cast(BootInformation*) address;
    assert(multiboot.hasValidEndTag());
    return multiboot;
}
