
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 60 d6 10 80       	mov    $0x8010d660,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 90 38 10 80       	mov    $0x80103890,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 90 89 10 80       	push   $0x80108990
80100042:	68 60 d6 10 80       	push   $0x8010d660
80100047:	e8 fc 53 00 00       	call   80105448 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 15 11 80       	mov    0x80111574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 15 11 80       	mov    $0x80111564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 d6 10 80       	push   $0x8010d660
801000c1:	e8 a4 53 00 00       	call   8010546a <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 15 11 80       	mov    0x80111574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 d6 10 80       	push   $0x8010d660
8010010c:	e8 c0 53 00 00       	call   801054d1 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 d6 10 80       	push   $0x8010d660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 d3 4e 00 00       	call   80104fff <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 15 11 80       	mov    0x80111570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 d6 10 80       	push   $0x8010d660
80100188:	e8 44 53 00 00       	call   801054d1 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 97 89 10 80       	push   $0x80108997
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 27 27 00 00       	call   8010290e <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 a8 89 10 80       	push   $0x801089a8
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 e6 26 00 00       	call   8010290e <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 af 89 10 80       	push   $0x801089af
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 d6 10 80       	push   $0x8010d660
80100255:	e8 10 52 00 00       	call   8010546a <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 15 11 80       	mov    0x80111574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 2f 4e 00 00       	call   801050ed <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 d6 10 80       	push   $0x8010d660
801002c9:	e8 03 52 00 00       	call   801054d1 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 c5 10 80       	push   $0x8010c5c0
801003e2:	e8 83 50 00 00       	call   8010546a <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 b6 89 10 80       	push   $0x801089b6
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec bf 89 10 80 	movl   $0x801089bf,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 c5 10 80       	push   $0x8010c5c0
8010055b:	e8 71 4f 00 00       	call   801054d1 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 c6 89 10 80       	push   $0x801089c6
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 d5 89 10 80       	push   $0x801089d5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 5c 4f 00 00       	call   80105523 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 d7 89 10 80       	push   $0x801089d7
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 db 89 10 80       	push   $0x801089db
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 90 50 00 00       	call   8010578c <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 a7 4f 00 00       	call   801056cd <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 5e 68 00 00       	call   80107019 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 51 68 00 00       	call   80107019 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 44 68 00 00       	call   80107019 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 34 68 00 00       	call   80107019 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 c5 10 80       	push   $0x8010c5c0
8010080e:	e8 57 4c 00 00       	call   8010546a <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 08 18 11 80       	mov    0x80111808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 18 11 80       	mov    %eax,0x80111808
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 08 18 11 80    	mov    0x80111808,%edx
80100870:	a1 04 18 11 80       	mov    0x80111804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 18 11 80       	mov    0x80111808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 17 11 80 	movzbl -0x7feee880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 08 18 11 80    	mov    0x80111808,%edx
8010089e:	a1 04 18 11 80       	mov    0x80111804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 18 11 80       	mov    0x80111808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 18 11 80       	mov    %eax,0x80111808
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 08 18 11 80    	mov    0x80111808,%edx
801008dd:	a1 00 18 11 80       	mov    0x80111800,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 08 18 11 80       	mov    0x80111808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 18 11 80    	mov    %edx,0x80111808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 17 11 80    	mov    %dl,-0x7feee880(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 08 18 11 80       	mov    0x80111808,%eax
80100937:	8b 15 00 18 11 80    	mov    0x80111800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 18 11 80       	mov    0x80111808,%eax
80100949:	a3 04 18 11 80       	mov    %eax,0x80111804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 18 11 80       	push   $0x80111800
80100956:	e8 92 47 00 00       	call   801050ed <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 c5 10 80       	push   $0x8010c5c0
80100979:	e8 53 4b 00 00       	call   801054d1 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 1f 48 00 00       	call   801051ab <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 29 11 00 00       	call   80101ac9 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 b4 4a 00 00       	call   8010546a <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 2c             	mov    0x2c(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 c5 10 80       	push   $0x8010c5c0
801009d3:	e8 f9 4a 00 00       	call   801054d1 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 85 0f 00 00       	call   8010196b <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 00 18 11 80       	push   $0x80111800
80100a00:	e8 fa 45 00 00       	call   80104fff <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 18 11 80    	mov    0x80111800,%edx
80100a0e:	a1 04 18 11 80       	mov    0x80111804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 18 11 80       	mov    0x80111800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 18 11 80    	mov    %edx,0x80111800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 17 11 80 	movzbl -0x7feee880(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 00 18 11 80       	mov    0x80111800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 18 11 80       	mov    %eax,0x80111800
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a7e:	e8 4e 4a 00 00       	call   801054d1 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 da 0e 00 00       	call   8010196b <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 18 10 00 00       	call   80101ac9 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 a9 49 00 00       	call   8010546a <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 c5 10 80       	push   $0x8010c5c0
80100afe:	e8 ce 49 00 00       	call   801054d1 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 5a 0e 00 00       	call   8010196b <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 ee 89 10 80       	push   $0x801089ee
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 17 49 00 00       	call   80105448 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 21 11 80 a0 	movl   $0x80100aa0,0x801121cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 21 11 80 8f 	movl   $0x8010098f,0x801121c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 d0 33 00 00       	call   80103f2c <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 70 1f 00 00       	call   80102adb <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 cf 29 00 00       	call   8010354e <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 9f 19 00 00       	call   80102529 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 3f 2a 00 00       	call   801035da <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 cf 03 00 00       	jmp    80100f74 <exec+0x403>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 bb 0d 00 00       	call   8010196b <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 0c 13 00 00       	call   80101ed9 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 4a 03 00 00    	jbe    80100f23 <exec+0x3b2>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3c 03 00 00    	jne    80100f26 <exec+0x3b5>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 7f 75 00 00       	call   8010816e <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2d 03 00 00    	je     80100f29 <exec+0x3b8>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 ac 12 00 00       	call   80101ed9 <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f3 02 00 00    	jne    80100f2c <exec+0x3bb>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d7 02 00 00    	jb     80100f2f <exec+0x3be>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 a0 78 00 00       	call   80108515 <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ad 02 00 00    	je     80100f32 <exec+0x3c1>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 96 77 00 00       	call   8010843e <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 82 02 00 00    	js     80100f35 <exec+0x3c4>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 4a 0f 00 00       	call   80101c2b <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 f1 28 00 00       	call   801035da <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 fe 77 00 00       	call   80108515 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 11 02 00 00    	je     80100f38 <exec+0x3c7>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 00 7a 00 00       	call   8010873b <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e1 01 00 00    	ja     80100f3b <exec+0x3ca>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 a6 4b 00 00       	call   8010591a <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 79 4b 00 00       	call   8010591a <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 2b 7b 00 00       	call   801088f2 <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6c 01 00 00    	js     80100f3e <exec+0x3cd>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 8f 7a 00 00       	call   801088f2 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d3 00 00 00    	js     80100f41 <exec+0x3d0>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 74             	add    $0x74,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 1c 4a 00 00       	call   801058d0 <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 0c             	mov    0xc(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 0c             	mov    %edx,0xc(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 50 08             	mov    %edx,0x8(%eax)
  proc->tf->eip = elf.entry;  // main
80100edb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee1:	8b 40 20             	mov    0x20(%eax),%eax
80100ee4:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100eea:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef3:	8b 40 20             	mov    0x20(%eax),%eax
80100ef6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef9:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100efc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f02:	83 ec 0c             	sub    $0xc,%esp
80100f05:	50                   	push   %eax
80100f06:	e8 4a 73 00 00       	call   80108255 <switchuvm>
80100f0b:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0e:	83 ec 0c             	sub    $0xc,%esp
80100f11:	ff 75 d0             	pushl  -0x30(%ebp)
80100f14:	e8 82 77 00 00       	call   8010869b <freevm>
80100f19:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1c:	b8 00 00 00 00       	mov    $0x0,%eax
80100f21:	eb 51                	jmp    80100f74 <exec+0x403>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f23:	90                   	nop
80100f24:	eb 1c                	jmp    80100f42 <exec+0x3d1>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f26:	90                   	nop
80100f27:	eb 19                	jmp    80100f42 <exec+0x3d1>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f29:	90                   	nop
80100f2a:	eb 16                	jmp    80100f42 <exec+0x3d1>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f2c:	90                   	nop
80100f2d:	eb 13                	jmp    80100f42 <exec+0x3d1>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f2f:	90                   	nop
80100f30:	eb 10                	jmp    80100f42 <exec+0x3d1>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f32:	90                   	nop
80100f33:	eb 0d                	jmp    80100f42 <exec+0x3d1>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f35:	90                   	nop
80100f36:	eb 0a                	jmp    80100f42 <exec+0x3d1>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f38:	90                   	nop
80100f39:	eb 07                	jmp    80100f42 <exec+0x3d1>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f3b:	90                   	nop
80100f3c:	eb 04                	jmp    80100f42 <exec+0x3d1>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f3e:	90                   	nop
80100f3f:	eb 01                	jmp    80100f42 <exec+0x3d1>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f41:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f42:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f46:	74 0e                	je     80100f56 <exec+0x3e5>
    freevm(pgdir);
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4e:	e8 48 77 00 00       	call   8010869b <freevm>
80100f53:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f56:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f5a:	74 13                	je     80100f6f <exec+0x3fe>
    iunlockput(ip);
80100f5c:	83 ec 0c             	sub    $0xc,%esp
80100f5f:	ff 75 d8             	pushl  -0x28(%ebp)
80100f62:	e8 c4 0c 00 00       	call   80101c2b <iunlockput>
80100f67:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f6a:	e8 6b 26 00 00       	call   801035da <end_op>
  }
  return -1;
80100f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f74:	c9                   	leave  
80100f75:	c3                   	ret    

80100f76 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f76:	55                   	push   %ebp
80100f77:	89 e5                	mov    %esp,%ebp
80100f79:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f7c:	83 ec 08             	sub    $0x8,%esp
80100f7f:	68 f6 89 10 80       	push   $0x801089f6
80100f84:	68 20 18 11 80       	push   $0x80111820
80100f89:	e8 ba 44 00 00       	call   80105448 <initlock>
80100f8e:	83 c4 10             	add    $0x10,%esp
}
80100f91:	90                   	nop
80100f92:	c9                   	leave  
80100f93:	c3                   	ret    

80100f94 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f94:	55                   	push   %ebp
80100f95:	89 e5                	mov    %esp,%ebp
80100f97:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f9a:	83 ec 0c             	sub    $0xc,%esp
80100f9d:	68 20 18 11 80       	push   $0x80111820
80100fa2:	e8 c3 44 00 00       	call   8010546a <acquire>
80100fa7:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100faa:	c7 45 f4 54 18 11 80 	movl   $0x80111854,-0xc(%ebp)
80100fb1:	eb 2d                	jmp    80100fe0 <filealloc+0x4c>
    if(f->ref == 0){
80100fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb6:	8b 40 04             	mov    0x4(%eax),%eax
80100fb9:	85 c0                	test   %eax,%eax
80100fbb:	75 1f                	jne    80100fdc <filealloc+0x48>
      f->ref = 1;
80100fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fc7:	83 ec 0c             	sub    $0xc,%esp
80100fca:	68 20 18 11 80       	push   $0x80111820
80100fcf:	e8 fd 44 00 00       	call   801054d1 <release>
80100fd4:	83 c4 10             	add    $0x10,%esp
      return f;
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	eb 23                	jmp    80100fff <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdc:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fe0:	b8 b4 21 11 80       	mov    $0x801121b4,%eax
80100fe5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe8:	72 c9                	jb     80100fb3 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fea:	83 ec 0c             	sub    $0xc,%esp
80100fed:	68 20 18 11 80       	push   $0x80111820
80100ff2:	e8 da 44 00 00       	call   801054d1 <release>
80100ff7:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ffa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fff:	c9                   	leave  
80101000:	c3                   	ret    

80101001 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101001:	55                   	push   %ebp
80101002:	89 e5                	mov    %esp,%ebp
80101004:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101007:	83 ec 0c             	sub    $0xc,%esp
8010100a:	68 20 18 11 80       	push   $0x80111820
8010100f:	e8 56 44 00 00       	call   8010546a <acquire>
80101014:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101017:	8b 45 08             	mov    0x8(%ebp),%eax
8010101a:	8b 40 04             	mov    0x4(%eax),%eax
8010101d:	85 c0                	test   %eax,%eax
8010101f:	7f 0d                	jg     8010102e <filedup+0x2d>
    panic("filedup");
80101021:	83 ec 0c             	sub    $0xc,%esp
80101024:	68 fd 89 10 80       	push   $0x801089fd
80101029:	e8 38 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102e:	8b 45 08             	mov    0x8(%ebp),%eax
80101031:	8b 40 04             	mov    0x4(%eax),%eax
80101034:	8d 50 01             	lea    0x1(%eax),%edx
80101037:	8b 45 08             	mov    0x8(%ebp),%eax
8010103a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 20 18 11 80       	push   $0x80111820
80101045:	e8 87 44 00 00       	call   801054d1 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return f;
8010104d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101050:	c9                   	leave  
80101051:	c3                   	ret    

80101052 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101052:	55                   	push   %ebp
80101053:	89 e5                	mov    %esp,%ebp
80101055:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101058:	83 ec 0c             	sub    $0xc,%esp
8010105b:	68 20 18 11 80       	push   $0x80111820
80101060:	e8 05 44 00 00       	call   8010546a <acquire>
80101065:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	8b 40 04             	mov    0x4(%eax),%eax
8010106e:	85 c0                	test   %eax,%eax
80101070:	7f 0d                	jg     8010107f <fileclose+0x2d>
    panic("fileclose");
80101072:	83 ec 0c             	sub    $0xc,%esp
80101075:	68 05 8a 10 80       	push   $0x80108a05
8010107a:	e8 e7 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010107f:	8b 45 08             	mov    0x8(%ebp),%eax
80101082:	8b 40 04             	mov    0x4(%eax),%eax
80101085:	8d 50 ff             	lea    -0x1(%eax),%edx
80101088:	8b 45 08             	mov    0x8(%ebp),%eax
8010108b:	89 50 04             	mov    %edx,0x4(%eax)
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	8b 40 04             	mov    0x4(%eax),%eax
80101094:	85 c0                	test   %eax,%eax
80101096:	7e 15                	jle    801010ad <fileclose+0x5b>
    release(&ftable.lock);
80101098:	83 ec 0c             	sub    $0xc,%esp
8010109b:	68 20 18 11 80       	push   $0x80111820
801010a0:	e8 2c 44 00 00       	call   801054d1 <release>
801010a5:	83 c4 10             	add    $0x10,%esp
801010a8:	e9 8b 00 00 00       	jmp    80101138 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010ad:	8b 45 08             	mov    0x8(%ebp),%eax
801010b0:	8b 10                	mov    (%eax),%edx
801010b2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010b5:	8b 50 04             	mov    0x4(%eax),%edx
801010b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010bb:	8b 50 08             	mov    0x8(%eax),%edx
801010be:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010c1:	8b 50 0c             	mov    0xc(%eax),%edx
801010c4:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010c7:	8b 50 10             	mov    0x10(%eax),%edx
801010ca:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010cd:	8b 40 14             	mov    0x14(%eax),%eax
801010d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010d3:	8b 45 08             	mov    0x8(%ebp),%eax
801010d6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e6:	83 ec 0c             	sub    $0xc,%esp
801010e9:	68 20 18 11 80       	push   $0x80111820
801010ee:	e8 de 43 00 00       	call   801054d1 <release>
801010f3:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010f9:	83 f8 01             	cmp    $0x1,%eax
801010fc:	75 19                	jne    80101117 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101102:	0f be d0             	movsbl %al,%edx
80101105:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101108:	83 ec 08             	sub    $0x8,%esp
8010110b:	52                   	push   %edx
8010110c:	50                   	push   %eax
8010110d:	e8 83 30 00 00       	call   80104195 <pipeclose>
80101112:	83 c4 10             	add    $0x10,%esp
80101115:	eb 21                	jmp    80101138 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101117:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010111a:	83 f8 02             	cmp    $0x2,%eax
8010111d:	75 19                	jne    80101138 <fileclose+0xe6>
    begin_op();
8010111f:	e8 2a 24 00 00       	call   8010354e <begin_op>
    iput(ff.ip);
80101124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101127:	83 ec 0c             	sub    $0xc,%esp
8010112a:	50                   	push   %eax
8010112b:	e8 0b 0a 00 00       	call   80101b3b <iput>
80101130:	83 c4 10             	add    $0x10,%esp
    end_op();
80101133:	e8 a2 24 00 00       	call   801035da <end_op>
  }
}
80101138:	c9                   	leave  
80101139:	c3                   	ret    

8010113a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010113a:	55                   	push   %ebp
8010113b:	89 e5                	mov    %esp,%ebp
8010113d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 00                	mov    (%eax),%eax
80101145:	83 f8 02             	cmp    $0x2,%eax
80101148:	75 40                	jne    8010118a <filestat+0x50>
    ilock(f->ip);
8010114a:	8b 45 08             	mov    0x8(%ebp),%eax
8010114d:	8b 40 10             	mov    0x10(%eax),%eax
80101150:	83 ec 0c             	sub    $0xc,%esp
80101153:	50                   	push   %eax
80101154:	e8 12 08 00 00       	call   8010196b <ilock>
80101159:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115c:	8b 45 08             	mov    0x8(%ebp),%eax
8010115f:	8b 40 10             	mov    0x10(%eax),%eax
80101162:	83 ec 08             	sub    $0x8,%esp
80101165:	ff 75 0c             	pushl  0xc(%ebp)
80101168:	50                   	push   %eax
80101169:	e8 25 0d 00 00       	call   80101e93 <stati>
8010116e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 40 10             	mov    0x10(%eax),%eax
80101177:	83 ec 0c             	sub    $0xc,%esp
8010117a:	50                   	push   %eax
8010117b:	e8 49 09 00 00       	call   80101ac9 <iunlock>
80101180:	83 c4 10             	add    $0x10,%esp
    return 0;
80101183:	b8 00 00 00 00       	mov    $0x0,%eax
80101188:	eb 05                	jmp    8010118f <filestat+0x55>
  }
  return -1;
8010118a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010118f:	c9                   	leave  
80101190:	c3                   	ret    

80101191 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101191:	55                   	push   %ebp
80101192:	89 e5                	mov    %esp,%ebp
80101194:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
8010119a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010119e:	84 c0                	test   %al,%al
801011a0:	75 0a                	jne    801011ac <fileread+0x1b>
    return -1;
801011a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a7:	e9 9b 00 00 00       	jmp    80101247 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ac:	8b 45 08             	mov    0x8(%ebp),%eax
801011af:	8b 00                	mov    (%eax),%eax
801011b1:	83 f8 01             	cmp    $0x1,%eax
801011b4:	75 1a                	jne    801011d0 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	8b 40 0c             	mov    0xc(%eax),%eax
801011bc:	83 ec 04             	sub    $0x4,%esp
801011bf:	ff 75 10             	pushl  0x10(%ebp)
801011c2:	ff 75 0c             	pushl  0xc(%ebp)
801011c5:	50                   	push   %eax
801011c6:	e8 72 31 00 00       	call   8010433d <piperead>
801011cb:	83 c4 10             	add    $0x10,%esp
801011ce:	eb 77                	jmp    80101247 <fileread+0xb6>
  if(f->type == FD_INODE){
801011d0:	8b 45 08             	mov    0x8(%ebp),%eax
801011d3:	8b 00                	mov    (%eax),%eax
801011d5:	83 f8 02             	cmp    $0x2,%eax
801011d8:	75 60                	jne    8010123a <fileread+0xa9>
    ilock(f->ip);
801011da:	8b 45 08             	mov    0x8(%ebp),%eax
801011dd:	8b 40 10             	mov    0x10(%eax),%eax
801011e0:	83 ec 0c             	sub    $0xc,%esp
801011e3:	50                   	push   %eax
801011e4:	e8 82 07 00 00       	call   8010196b <ilock>
801011e9:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011ef:	8b 45 08             	mov    0x8(%ebp),%eax
801011f2:	8b 50 14             	mov    0x14(%eax),%edx
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 40 10             	mov    0x10(%eax),%eax
801011fb:	51                   	push   %ecx
801011fc:	52                   	push   %edx
801011fd:	ff 75 0c             	pushl  0xc(%ebp)
80101200:	50                   	push   %eax
80101201:	e8 d3 0c 00 00       	call   80101ed9 <readi>
80101206:	83 c4 10             	add    $0x10,%esp
80101209:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101210:	7e 11                	jle    80101223 <fileread+0x92>
      f->off += r;
80101212:	8b 45 08             	mov    0x8(%ebp),%eax
80101215:	8b 50 14             	mov    0x14(%eax),%edx
80101218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121b:	01 c2                	add    %eax,%edx
8010121d:	8b 45 08             	mov    0x8(%ebp),%eax
80101220:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 97 08 00 00       	call   80101ac9 <iunlock>
80101232:	83 c4 10             	add    $0x10,%esp
    return r;
80101235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101238:	eb 0d                	jmp    80101247 <fileread+0xb6>
  }
  panic("fileread");
8010123a:	83 ec 0c             	sub    $0xc,%esp
8010123d:	68 0f 8a 10 80       	push   $0x80108a0f
80101242:	e8 1f f3 ff ff       	call   80100566 <panic>
}
80101247:	c9                   	leave  
80101248:	c3                   	ret    

80101249 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101249:	55                   	push   %ebp
8010124a:	89 e5                	mov    %esp,%ebp
8010124c:	53                   	push   %ebx
8010124d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101250:	8b 45 08             	mov    0x8(%ebp),%eax
80101253:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101257:	84 c0                	test   %al,%al
80101259:	75 0a                	jne    80101265 <filewrite+0x1c>
    return -1;
8010125b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101260:	e9 1b 01 00 00       	jmp    80101380 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 00                	mov    (%eax),%eax
8010126a:	83 f8 01             	cmp    $0x1,%eax
8010126d:	75 1d                	jne    8010128c <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010126f:	8b 45 08             	mov    0x8(%ebp),%eax
80101272:	8b 40 0c             	mov    0xc(%eax),%eax
80101275:	83 ec 04             	sub    $0x4,%esp
80101278:	ff 75 10             	pushl  0x10(%ebp)
8010127b:	ff 75 0c             	pushl  0xc(%ebp)
8010127e:	50                   	push   %eax
8010127f:	e8 bb 2f 00 00       	call   8010423f <pipewrite>
80101284:	83 c4 10             	add    $0x10,%esp
80101287:	e9 f4 00 00 00       	jmp    80101380 <filewrite+0x137>
  if(f->type == FD_INODE){
8010128c:	8b 45 08             	mov    0x8(%ebp),%eax
8010128f:	8b 00                	mov    (%eax),%eax
80101291:	83 f8 02             	cmp    $0x2,%eax
80101294:	0f 85 d9 00 00 00    	jne    80101373 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010129a:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012a8:	e9 a3 00 00 00       	jmp    80101350 <filewrite+0x107>
      int n1 = n - i;
801012ad:	8b 45 10             	mov    0x10(%ebp),%eax
801012b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bc:	7e 06                	jle    801012c4 <filewrite+0x7b>
        n1 = max;
801012be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c1:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c4:	e8 85 22 00 00       	call   8010354e <begin_op>
      ilock(f->ip);
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8b 40 10             	mov    0x10(%eax),%eax
801012cf:	83 ec 0c             	sub    $0xc,%esp
801012d2:	50                   	push   %eax
801012d3:	e8 93 06 00 00       	call   8010196b <ilock>
801012d8:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012db:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012de:	8b 45 08             	mov    0x8(%ebp),%eax
801012e1:	8b 50 14             	mov    0x14(%eax),%edx
801012e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ea:	01 c3                	add    %eax,%ebx
801012ec:	8b 45 08             	mov    0x8(%ebp),%eax
801012ef:	8b 40 10             	mov    0x10(%eax),%eax
801012f2:	51                   	push   %ecx
801012f3:	52                   	push   %edx
801012f4:	53                   	push   %ebx
801012f5:	50                   	push   %eax
801012f6:	e8 35 0d 00 00       	call   80102030 <writei>
801012fb:	83 c4 10             	add    $0x10,%esp
801012fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101301:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101305:	7e 11                	jle    80101318 <filewrite+0xcf>
        f->off += r;
80101307:	8b 45 08             	mov    0x8(%ebp),%eax
8010130a:	8b 50 14             	mov    0x14(%eax),%edx
8010130d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101310:	01 c2                	add    %eax,%edx
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 40 10             	mov    0x10(%eax),%eax
8010131e:	83 ec 0c             	sub    $0xc,%esp
80101321:	50                   	push   %eax
80101322:	e8 a2 07 00 00       	call   80101ac9 <iunlock>
80101327:	83 c4 10             	add    $0x10,%esp
      end_op();
8010132a:	e8 ab 22 00 00       	call   801035da <end_op>

      if(r < 0)
8010132f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101333:	78 29                	js     8010135e <filewrite+0x115>
        break;
      if(r != n1)
80101335:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101338:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133b:	74 0d                	je     8010134a <filewrite+0x101>
        panic("short filewrite");
8010133d:	83 ec 0c             	sub    $0xc,%esp
80101340:	68 18 8a 10 80       	push   $0x80108a18
80101345:	e8 1c f2 ff ff       	call   80100566 <panic>
      i += r;
8010134a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134d:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101353:	3b 45 10             	cmp    0x10(%ebp),%eax
80101356:	0f 8c 51 ff ff ff    	jl     801012ad <filewrite+0x64>
8010135c:	eb 01                	jmp    8010135f <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010135e:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010135f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101362:	3b 45 10             	cmp    0x10(%ebp),%eax
80101365:	75 05                	jne    8010136c <filewrite+0x123>
80101367:	8b 45 10             	mov    0x10(%ebp),%eax
8010136a:	eb 14                	jmp    80101380 <filewrite+0x137>
8010136c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101371:	eb 0d                	jmp    80101380 <filewrite+0x137>
  }
  panic("filewrite");
80101373:	83 ec 0c             	sub    $0xc,%esp
80101376:	68 28 8a 10 80       	push   $0x80108a28
8010137b:	e8 e6 f1 ff ff       	call   80100566 <panic>
}
80101380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101383:	c9                   	leave  
80101384:	c3                   	ret    

80101385 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101385:	55                   	push   %ebp
80101386:	89 e5                	mov    %esp,%ebp
80101388:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010138b:	8b 45 08             	mov    0x8(%ebp),%eax
8010138e:	83 ec 08             	sub    $0x8,%esp
80101391:	6a 01                	push   $0x1
80101393:	50                   	push   %eax
80101394:	e8 1d ee ff ff       	call   801001b6 <bread>
80101399:	83 c4 10             	add    $0x10,%esp
8010139c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a2:	83 c0 18             	add    $0x18,%eax
801013a5:	83 ec 04             	sub    $0x4,%esp
801013a8:	6a 1c                	push   $0x1c
801013aa:	50                   	push   %eax
801013ab:	ff 75 0c             	pushl  0xc(%ebp)
801013ae:	e8 d9 43 00 00       	call   8010578c <memmove>
801013b3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013b6:	83 ec 0c             	sub    $0xc,%esp
801013b9:	ff 75 f4             	pushl  -0xc(%ebp)
801013bc:	e8 6d ee ff ff       	call   8010022e <brelse>
801013c1:	83 c4 10             	add    $0x10,%esp
}
801013c4:	90                   	nop
801013c5:	c9                   	leave  
801013c6:	c3                   	ret    

801013c7 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013c7:	55                   	push   %ebp
801013c8:	89 e5                	mov    %esp,%ebp
801013ca:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801013d0:	8b 45 08             	mov    0x8(%ebp),%eax
801013d3:	83 ec 08             	sub    $0x8,%esp
801013d6:	52                   	push   %edx
801013d7:	50                   	push   %eax
801013d8:	e8 d9 ed ff ff       	call   801001b6 <bread>
801013dd:	83 c4 10             	add    $0x10,%esp
801013e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e6:	83 c0 18             	add    $0x18,%eax
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	68 00 02 00 00       	push   $0x200
801013f1:	6a 00                	push   $0x0
801013f3:	50                   	push   %eax
801013f4:	e8 d4 42 00 00       	call   801056cd <memset>
801013f9:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013fc:	83 ec 0c             	sub    $0xc,%esp
801013ff:	ff 75 f4             	pushl  -0xc(%ebp)
80101402:	e8 7f 23 00 00       	call   80103786 <log_write>
80101407:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010140a:	83 ec 0c             	sub    $0xc,%esp
8010140d:	ff 75 f4             	pushl  -0xc(%ebp)
80101410:	e8 19 ee ff ff       	call   8010022e <brelse>
80101415:	83 c4 10             	add    $0x10,%esp
}
80101418:	90                   	nop
80101419:	c9                   	leave  
8010141a:	c3                   	ret    

8010141b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010141b:	55                   	push   %ebp
8010141c:	89 e5                	mov    %esp,%ebp
8010141e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101421:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101428:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010142f:	e9 13 01 00 00       	jmp    80101547 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101437:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010143d:	85 c0                	test   %eax,%eax
8010143f:	0f 48 c2             	cmovs  %edx,%eax
80101442:	c1 f8 0c             	sar    $0xc,%eax
80101445:	89 c2                	mov    %eax,%edx
80101447:	a1 38 22 11 80       	mov    0x80112238,%eax
8010144c:	01 d0                	add    %edx,%eax
8010144e:	83 ec 08             	sub    $0x8,%esp
80101451:	50                   	push   %eax
80101452:	ff 75 08             	pushl  0x8(%ebp)
80101455:	e8 5c ed ff ff       	call   801001b6 <bread>
8010145a:	83 c4 10             	add    $0x10,%esp
8010145d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101460:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101467:	e9 a6 00 00 00       	jmp    80101512 <balloc+0xf7>
      m = 1 << (bi % 8);
8010146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146f:	99                   	cltd   
80101470:	c1 ea 1d             	shr    $0x1d,%edx
80101473:	01 d0                	add    %edx,%eax
80101475:	83 e0 07             	and    $0x7,%eax
80101478:	29 d0                	sub    %edx,%eax
8010147a:	ba 01 00 00 00       	mov    $0x1,%edx
8010147f:	89 c1                	mov    %eax,%ecx
80101481:	d3 e2                	shl    %cl,%edx
80101483:	89 d0                	mov    %edx,%eax
80101485:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101488:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148b:	8d 50 07             	lea    0x7(%eax),%edx
8010148e:	85 c0                	test   %eax,%eax
80101490:	0f 48 c2             	cmovs  %edx,%eax
80101493:	c1 f8 03             	sar    $0x3,%eax
80101496:	89 c2                	mov    %eax,%edx
80101498:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149b:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014a0:	0f b6 c0             	movzbl %al,%eax
801014a3:	23 45 e8             	and    -0x18(%ebp),%eax
801014a6:	85 c0                	test   %eax,%eax
801014a8:	75 64                	jne    8010150e <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ad:	8d 50 07             	lea    0x7(%eax),%edx
801014b0:	85 c0                	test   %eax,%eax
801014b2:	0f 48 c2             	cmovs  %edx,%eax
801014b5:	c1 f8 03             	sar    $0x3,%eax
801014b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014bb:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014c0:	89 d1                	mov    %edx,%ecx
801014c2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c5:	09 ca                	or     %ecx,%edx
801014c7:	89 d1                	mov    %edx,%ecx
801014c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cc:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014d0:	83 ec 0c             	sub    $0xc,%esp
801014d3:	ff 75 ec             	pushl  -0x14(%ebp)
801014d6:	e8 ab 22 00 00       	call   80103786 <log_write>
801014db:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014de:	83 ec 0c             	sub    $0xc,%esp
801014e1:	ff 75 ec             	pushl  -0x14(%ebp)
801014e4:	e8 45 ed ff ff       	call   8010022e <brelse>
801014e9:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f2:	01 c2                	add    %eax,%edx
801014f4:	8b 45 08             	mov    0x8(%ebp),%eax
801014f7:	83 ec 08             	sub    $0x8,%esp
801014fa:	52                   	push   %edx
801014fb:	50                   	push   %eax
801014fc:	e8 c6 fe ff ff       	call   801013c7 <bzero>
80101501:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101504:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150a:	01 d0                	add    %edx,%eax
8010150c:	eb 57                	jmp    80101565 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010150e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101512:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101519:	7f 17                	jg     80101532 <balloc+0x117>
8010151b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101521:	01 d0                	add    %edx,%eax
80101523:	89 c2                	mov    %eax,%edx
80101525:	a1 20 22 11 80       	mov    0x80112220,%eax
8010152a:	39 c2                	cmp    %eax,%edx
8010152c:	0f 82 3a ff ff ff    	jb     8010146c <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101532:	83 ec 0c             	sub    $0xc,%esp
80101535:	ff 75 ec             	pushl  -0x14(%ebp)
80101538:	e8 f1 ec ff ff       	call   8010022e <brelse>
8010153d:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101540:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101547:	8b 15 20 22 11 80    	mov    0x80112220,%edx
8010154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101550:	39 c2                	cmp    %eax,%edx
80101552:	0f 87 dc fe ff ff    	ja     80101434 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101558:	83 ec 0c             	sub    $0xc,%esp
8010155b:	68 34 8a 10 80       	push   $0x80108a34
80101560:	e8 01 f0 ff ff       	call   80100566 <panic>
}
80101565:	c9                   	leave  
80101566:	c3                   	ret    

80101567 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101567:	55                   	push   %ebp
80101568:	89 e5                	mov    %esp,%ebp
8010156a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010156d:	83 ec 08             	sub    $0x8,%esp
80101570:	68 20 22 11 80       	push   $0x80112220
80101575:	ff 75 08             	pushl  0x8(%ebp)
80101578:	e8 08 fe ff ff       	call   80101385 <readsb>
8010157d:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101580:	8b 45 0c             	mov    0xc(%ebp),%eax
80101583:	c1 e8 0c             	shr    $0xc,%eax
80101586:	89 c2                	mov    %eax,%edx
80101588:	a1 38 22 11 80       	mov    0x80112238,%eax
8010158d:	01 c2                	add    %eax,%edx
8010158f:	8b 45 08             	mov    0x8(%ebp),%eax
80101592:	83 ec 08             	sub    $0x8,%esp
80101595:	52                   	push   %edx
80101596:	50                   	push   %eax
80101597:	e8 1a ec ff ff       	call   801001b6 <bread>
8010159c:	83 c4 10             	add    $0x10,%esp
8010159f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a5:	25 ff 0f 00 00       	and    $0xfff,%eax
801015aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b0:	99                   	cltd   
801015b1:	c1 ea 1d             	shr    $0x1d,%edx
801015b4:	01 d0                	add    %edx,%eax
801015b6:	83 e0 07             	and    $0x7,%eax
801015b9:	29 d0                	sub    %edx,%eax
801015bb:	ba 01 00 00 00       	mov    $0x1,%edx
801015c0:	89 c1                	mov    %eax,%ecx
801015c2:	d3 e2                	shl    %cl,%edx
801015c4:	89 d0                	mov    %edx,%eax
801015c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cc:	8d 50 07             	lea    0x7(%eax),%edx
801015cf:	85 c0                	test   %eax,%eax
801015d1:	0f 48 c2             	cmovs  %edx,%eax
801015d4:	c1 f8 03             	sar    $0x3,%eax
801015d7:	89 c2                	mov    %eax,%edx
801015d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015dc:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e1:	0f b6 c0             	movzbl %al,%eax
801015e4:	23 45 ec             	and    -0x14(%ebp),%eax
801015e7:	85 c0                	test   %eax,%eax
801015e9:	75 0d                	jne    801015f8 <bfree+0x91>
    panic("freeing free block");
801015eb:	83 ec 0c             	sub    $0xc,%esp
801015ee:	68 4a 8a 10 80       	push   $0x80108a4a
801015f3:	e8 6e ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fb:	8d 50 07             	lea    0x7(%eax),%edx
801015fe:	85 c0                	test   %eax,%eax
80101600:	0f 48 c2             	cmovs  %edx,%eax
80101603:	c1 f8 03             	sar    $0x3,%eax
80101606:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101609:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010160e:	89 d1                	mov    %edx,%ecx
80101610:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101613:	f7 d2                	not    %edx
80101615:	21 ca                	and    %ecx,%edx
80101617:	89 d1                	mov    %edx,%ecx
80101619:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161c:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101620:	83 ec 0c             	sub    $0xc,%esp
80101623:	ff 75 f4             	pushl  -0xc(%ebp)
80101626:	e8 5b 21 00 00       	call   80103786 <log_write>
8010162b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010162e:	83 ec 0c             	sub    $0xc,%esp
80101631:	ff 75 f4             	pushl  -0xc(%ebp)
80101634:	e8 f5 eb ff ff       	call   8010022e <brelse>
80101639:	83 c4 10             	add    $0x10,%esp
}
8010163c:	90                   	nop
8010163d:	c9                   	leave  
8010163e:	c3                   	ret    

8010163f <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010163f:	55                   	push   %ebp
80101640:	89 e5                	mov    %esp,%ebp
80101642:	57                   	push   %edi
80101643:	56                   	push   %esi
80101644:	53                   	push   %ebx
80101645:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101648:	83 ec 08             	sub    $0x8,%esp
8010164b:	68 5d 8a 10 80       	push   $0x80108a5d
80101650:	68 40 22 11 80       	push   $0x80112240
80101655:	e8 ee 3d 00 00       	call   80105448 <initlock>
8010165a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010165d:	83 ec 08             	sub    $0x8,%esp
80101660:	68 20 22 11 80       	push   $0x80112220
80101665:	ff 75 08             	pushl  0x8(%ebp)
80101668:	e8 18 fd ff ff       	call   80101385 <readsb>
8010166d:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101670:	a1 38 22 11 80       	mov    0x80112238,%eax
80101675:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101678:	8b 3d 34 22 11 80    	mov    0x80112234,%edi
8010167e:	8b 35 30 22 11 80    	mov    0x80112230,%esi
80101684:	8b 1d 2c 22 11 80    	mov    0x8011222c,%ebx
8010168a:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80101690:	8b 15 24 22 11 80    	mov    0x80112224,%edx
80101696:	a1 20 22 11 80       	mov    0x80112220,%eax
8010169b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010169e:	57                   	push   %edi
8010169f:	56                   	push   %esi
801016a0:	53                   	push   %ebx
801016a1:	51                   	push   %ecx
801016a2:	52                   	push   %edx
801016a3:	50                   	push   %eax
801016a4:	68 64 8a 10 80       	push   $0x80108a64
801016a9:	e8 18 ed ff ff       	call   801003c6 <cprintf>
801016ae:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016b1:	90                   	nop
801016b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b5:	5b                   	pop    %ebx
801016b6:	5e                   	pop    %esi
801016b7:	5f                   	pop    %edi
801016b8:	5d                   	pop    %ebp
801016b9:	c3                   	ret    

801016ba <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016ba:	55                   	push   %ebp
801016bb:	89 e5                	mov    %esp,%ebp
801016bd:	83 ec 28             	sub    $0x28,%esp
801016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c3:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016c7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ce:	e9 9e 00 00 00       	jmp    80101771 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d6:	c1 e8 03             	shr    $0x3,%eax
801016d9:	89 c2                	mov    %eax,%edx
801016db:	a1 34 22 11 80       	mov    0x80112234,%eax
801016e0:	01 d0                	add    %edx,%eax
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	50                   	push   %eax
801016e6:	ff 75 08             	pushl  0x8(%ebp)
801016e9:	e8 c8 ea ff ff       	call   801001b6 <bread>
801016ee:	83 c4 10             	add    $0x10,%esp
801016f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f7:	8d 50 18             	lea    0x18(%eax),%edx
801016fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016fd:	83 e0 07             	and    $0x7,%eax
80101700:	c1 e0 06             	shl    $0x6,%eax
80101703:	01 d0                	add    %edx,%eax
80101705:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101708:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170b:	0f b7 00             	movzwl (%eax),%eax
8010170e:	66 85 c0             	test   %ax,%ax
80101711:	75 4c                	jne    8010175f <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101713:	83 ec 04             	sub    $0x4,%esp
80101716:	6a 40                	push   $0x40
80101718:	6a 00                	push   $0x0
8010171a:	ff 75 ec             	pushl  -0x14(%ebp)
8010171d:	e8 ab 3f 00 00       	call   801056cd <memset>
80101722:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101725:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101728:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172c:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010172f:	83 ec 0c             	sub    $0xc,%esp
80101732:	ff 75 f0             	pushl  -0x10(%ebp)
80101735:	e8 4c 20 00 00       	call   80103786 <log_write>
8010173a:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010173d:	83 ec 0c             	sub    $0xc,%esp
80101740:	ff 75 f0             	pushl  -0x10(%ebp)
80101743:	e8 e6 ea ff ff       	call   8010022e <brelse>
80101748:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010174b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174e:	83 ec 08             	sub    $0x8,%esp
80101751:	50                   	push   %eax
80101752:	ff 75 08             	pushl  0x8(%ebp)
80101755:	e8 f8 00 00 00       	call   80101852 <iget>
8010175a:	83 c4 10             	add    $0x10,%esp
8010175d:	eb 30                	jmp    8010178f <ialloc+0xd5>
    }
    brelse(bp);
8010175f:	83 ec 0c             	sub    $0xc,%esp
80101762:	ff 75 f0             	pushl  -0x10(%ebp)
80101765:	e8 c4 ea ff ff       	call   8010022e <brelse>
8010176a:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010176d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101771:	8b 15 28 22 11 80    	mov    0x80112228,%edx
80101777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177a:	39 c2                	cmp    %eax,%edx
8010177c:	0f 87 51 ff ff ff    	ja     801016d3 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101782:	83 ec 0c             	sub    $0xc,%esp
80101785:	68 b7 8a 10 80       	push   $0x80108ab7
8010178a:	e8 d7 ed ff ff       	call   80100566 <panic>
}
8010178f:	c9                   	leave  
80101790:	c3                   	ret    

80101791 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101791:	55                   	push   %ebp
80101792:	89 e5                	mov    %esp,%ebp
80101794:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101797:	8b 45 08             	mov    0x8(%ebp),%eax
8010179a:	8b 40 04             	mov    0x4(%eax),%eax
8010179d:	c1 e8 03             	shr    $0x3,%eax
801017a0:	89 c2                	mov    %eax,%edx
801017a2:	a1 34 22 11 80       	mov    0x80112234,%eax
801017a7:	01 c2                	add    %eax,%edx
801017a9:	8b 45 08             	mov    0x8(%ebp),%eax
801017ac:	8b 00                	mov    (%eax),%eax
801017ae:	83 ec 08             	sub    $0x8,%esp
801017b1:	52                   	push   %edx
801017b2:	50                   	push   %eax
801017b3:	e8 fe e9 ff ff       	call   801001b6 <bread>
801017b8:	83 c4 10             	add    $0x10,%esp
801017bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8d 50 18             	lea    0x18(%eax),%edx
801017c4:	8b 45 08             	mov    0x8(%ebp),%eax
801017c7:	8b 40 04             	mov    0x4(%eax),%eax
801017ca:	83 e0 07             	and    $0x7,%eax
801017cd:	c1 e0 06             	shl    $0x6,%eax
801017d0:	01 d0                	add    %edx,%eax
801017d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017d5:	8b 45 08             	mov    0x8(%ebp),%eax
801017d8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017df:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ec:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017f0:	8b 45 08             	mov    0x8(%ebp),%eax
801017f3:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fa:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101801:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101808:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010180c:	8b 45 08             	mov    0x8(%ebp),%eax
8010180f:	8b 50 18             	mov    0x18(%eax),%edx
80101812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101815:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101818:	8b 45 08             	mov    0x8(%ebp),%eax
8010181b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101821:	83 c0 0c             	add    $0xc,%eax
80101824:	83 ec 04             	sub    $0x4,%esp
80101827:	6a 34                	push   $0x34
80101829:	52                   	push   %edx
8010182a:	50                   	push   %eax
8010182b:	e8 5c 3f 00 00       	call   8010578c <memmove>
80101830:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101833:	83 ec 0c             	sub    $0xc,%esp
80101836:	ff 75 f4             	pushl  -0xc(%ebp)
80101839:	e8 48 1f 00 00       	call   80103786 <log_write>
8010183e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101841:	83 ec 0c             	sub    $0xc,%esp
80101844:	ff 75 f4             	pushl  -0xc(%ebp)
80101847:	e8 e2 e9 ff ff       	call   8010022e <brelse>
8010184c:	83 c4 10             	add    $0x10,%esp
}
8010184f:	90                   	nop
80101850:	c9                   	leave  
80101851:	c3                   	ret    

80101852 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101852:	55                   	push   %ebp
80101853:	89 e5                	mov    %esp,%ebp
80101855:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101858:	83 ec 0c             	sub    $0xc,%esp
8010185b:	68 40 22 11 80       	push   $0x80112240
80101860:	e8 05 3c 00 00       	call   8010546a <acquire>
80101865:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101868:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010186f:	c7 45 f4 74 22 11 80 	movl   $0x80112274,-0xc(%ebp)
80101876:	eb 5d                	jmp    801018d5 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187b:	8b 40 08             	mov    0x8(%eax),%eax
8010187e:	85 c0                	test   %eax,%eax
80101880:	7e 39                	jle    801018bb <iget+0x69>
80101882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101885:	8b 00                	mov    (%eax),%eax
80101887:	3b 45 08             	cmp    0x8(%ebp),%eax
8010188a:	75 2f                	jne    801018bb <iget+0x69>
8010188c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188f:	8b 40 04             	mov    0x4(%eax),%eax
80101892:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101895:	75 24                	jne    801018bb <iget+0x69>
      ip->ref++;
80101897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189a:	8b 40 08             	mov    0x8(%eax),%eax
8010189d:	8d 50 01             	lea    0x1(%eax),%edx
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a6:	83 ec 0c             	sub    $0xc,%esp
801018a9:	68 40 22 11 80       	push   $0x80112240
801018ae:	e8 1e 3c 00 00       	call   801054d1 <release>
801018b3:	83 c4 10             	add    $0x10,%esp
      return ip;
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	eb 74                	jmp    8010192f <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018bf:	75 10                	jne    801018d1 <iget+0x7f>
801018c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c4:	8b 40 08             	mov    0x8(%eax),%eax
801018c7:	85 c0                	test   %eax,%eax
801018c9:	75 06                	jne    801018d1 <iget+0x7f>
      empty = ip;
801018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d1:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d5:	81 7d f4 14 32 11 80 	cmpl   $0x80113214,-0xc(%ebp)
801018dc:	72 9a                	jb     80101878 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e2:	75 0d                	jne    801018f1 <iget+0x9f>
    panic("iget: no inodes");
801018e4:	83 ec 0c             	sub    $0xc,%esp
801018e7:	68 c9 8a 10 80       	push   $0x80108ac9
801018ec:	e8 75 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fa:	8b 55 08             	mov    0x8(%ebp),%edx
801018fd:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	8b 55 0c             	mov    0xc(%ebp),%edx
80101905:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010191c:	83 ec 0c             	sub    $0xc,%esp
8010191f:	68 40 22 11 80       	push   $0x80112240
80101924:	e8 a8 3b 00 00       	call   801054d1 <release>
80101929:	83 c4 10             	add    $0x10,%esp

  return ip;
8010192c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010192f:	c9                   	leave  
80101930:	c3                   	ret    

80101931 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101931:	55                   	push   %ebp
80101932:	89 e5                	mov    %esp,%ebp
80101934:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101937:	83 ec 0c             	sub    $0xc,%esp
8010193a:	68 40 22 11 80       	push   $0x80112240
8010193f:	e8 26 3b 00 00       	call   8010546a <acquire>
80101944:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101947:	8b 45 08             	mov    0x8(%ebp),%eax
8010194a:	8b 40 08             	mov    0x8(%eax),%eax
8010194d:	8d 50 01             	lea    0x1(%eax),%edx
80101950:	8b 45 08             	mov    0x8(%ebp),%eax
80101953:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101956:	83 ec 0c             	sub    $0xc,%esp
80101959:	68 40 22 11 80       	push   $0x80112240
8010195e:	e8 6e 3b 00 00       	call   801054d1 <release>
80101963:	83 c4 10             	add    $0x10,%esp
  return ip;
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101969:	c9                   	leave  
8010196a:	c3                   	ret    

8010196b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010196b:	55                   	push   %ebp
8010196c:	89 e5                	mov    %esp,%ebp
8010196e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101971:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101975:	74 0a                	je     80101981 <ilock+0x16>
80101977:	8b 45 08             	mov    0x8(%ebp),%eax
8010197a:	8b 40 08             	mov    0x8(%eax),%eax
8010197d:	85 c0                	test   %eax,%eax
8010197f:	7f 0d                	jg     8010198e <ilock+0x23>
    panic("ilock");
80101981:	83 ec 0c             	sub    $0xc,%esp
80101984:	68 d9 8a 10 80       	push   $0x80108ad9
80101989:	e8 d8 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010198e:	83 ec 0c             	sub    $0xc,%esp
80101991:	68 40 22 11 80       	push   $0x80112240
80101996:	e8 cf 3a 00 00       	call   8010546a <acquire>
8010199b:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010199e:	eb 13                	jmp    801019b3 <ilock+0x48>
    sleep(ip, &icache.lock);
801019a0:	83 ec 08             	sub    $0x8,%esp
801019a3:	68 40 22 11 80       	push   $0x80112240
801019a8:	ff 75 08             	pushl  0x8(%ebp)
801019ab:	e8 4f 36 00 00       	call   80104fff <sleep>
801019b0:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	8b 40 0c             	mov    0xc(%eax),%eax
801019b9:	83 e0 01             	and    $0x1,%eax
801019bc:	85 c0                	test   %eax,%eax
801019be:	75 e0                	jne    801019a0 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	8b 40 0c             	mov    0xc(%eax),%eax
801019c6:	83 c8 01             	or     $0x1,%eax
801019c9:	89 c2                	mov    %eax,%edx
801019cb:	8b 45 08             	mov    0x8(%ebp),%eax
801019ce:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d1:	83 ec 0c             	sub    $0xc,%esp
801019d4:	68 40 22 11 80       	push   $0x80112240
801019d9:	e8 f3 3a 00 00       	call   801054d1 <release>
801019de:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019e1:	8b 45 08             	mov    0x8(%ebp),%eax
801019e4:	8b 40 0c             	mov    0xc(%eax),%eax
801019e7:	83 e0 02             	and    $0x2,%eax
801019ea:	85 c0                	test   %eax,%eax
801019ec:	0f 85 d4 00 00 00    	jne    80101ac6 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019f2:	8b 45 08             	mov    0x8(%ebp),%eax
801019f5:	8b 40 04             	mov    0x4(%eax),%eax
801019f8:	c1 e8 03             	shr    $0x3,%eax
801019fb:	89 c2                	mov    %eax,%edx
801019fd:	a1 34 22 11 80       	mov    0x80112234,%eax
80101a02:	01 c2                	add    %eax,%edx
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	8b 00                	mov    (%eax),%eax
80101a09:	83 ec 08             	sub    $0x8,%esp
80101a0c:	52                   	push   %edx
80101a0d:	50                   	push   %eax
80101a0e:	e8 a3 e7 ff ff       	call   801001b6 <bread>
80101a13:	83 c4 10             	add    $0x10,%esp
80101a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1c:	8d 50 18             	lea    0x18(%eax),%edx
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 04             	mov    0x4(%eax),%eax
80101a25:	83 e0 07             	and    $0x7,%eax
80101a28:	c1 e0 06             	shl    $0x6,%eax
80101a2b:	01 d0                	add    %edx,%eax
80101a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a33:	0f b7 10             	movzwl (%eax),%edx
80101a36:	8b 45 08             	mov    0x8(%ebp),%eax
80101a39:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a40:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a44:	8b 45 08             	mov    0x8(%ebp),%eax
80101a47:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a52:	8b 45 08             	mov    0x8(%ebp),%eax
80101a55:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a60:	8b 45 08             	mov    0x8(%ebp),%eax
80101a63:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6a:	8b 50 08             	mov    0x8(%eax),%edx
80101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a70:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	8d 50 0c             	lea    0xc(%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	83 c0 1c             	add    $0x1c,%eax
80101a7f:	83 ec 04             	sub    $0x4,%esp
80101a82:	6a 34                	push   $0x34
80101a84:	52                   	push   %edx
80101a85:	50                   	push   %eax
80101a86:	e8 01 3d 00 00       	call   8010578c <memmove>
80101a8b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a8e:	83 ec 0c             	sub    $0xc,%esp
80101a91:	ff 75 f4             	pushl  -0xc(%ebp)
80101a94:	e8 95 e7 ff ff       	call   8010022e <brelse>
80101a99:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa2:	83 c8 02             	or     $0x2,%eax
80101aa5:	89 c2                	mov    %eax,%edx
80101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaa:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab4:	66 85 c0             	test   %ax,%ax
80101ab7:	75 0d                	jne    80101ac6 <ilock+0x15b>
      panic("ilock: no type");
80101ab9:	83 ec 0c             	sub    $0xc,%esp
80101abc:	68 df 8a 10 80       	push   $0x80108adf
80101ac1:	e8 a0 ea ff ff       	call   80100566 <panic>
  }
}
80101ac6:	90                   	nop
80101ac7:	c9                   	leave  
80101ac8:	c3                   	ret    

80101ac9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac9:	55                   	push   %ebp
80101aca:	89 e5                	mov    %esp,%ebp
80101acc:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101acf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad3:	74 17                	je     80101aec <iunlock+0x23>
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad8:	8b 40 0c             	mov    0xc(%eax),%eax
80101adb:	83 e0 01             	and    $0x1,%eax
80101ade:	85 c0                	test   %eax,%eax
80101ae0:	74 0a                	je     80101aec <iunlock+0x23>
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	8b 40 08             	mov    0x8(%eax),%eax
80101ae8:	85 c0                	test   %eax,%eax
80101aea:	7f 0d                	jg     80101af9 <iunlock+0x30>
    panic("iunlock");
80101aec:	83 ec 0c             	sub    $0xc,%esp
80101aef:	68 ee 8a 10 80       	push   $0x80108aee
80101af4:	e8 6d ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af9:	83 ec 0c             	sub    $0xc,%esp
80101afc:	68 40 22 11 80       	push   $0x80112240
80101b01:	e8 64 39 00 00       	call   8010546a <acquire>
80101b06:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0f:	83 e0 fe             	and    $0xfffffffe,%eax
80101b12:	89 c2                	mov    %eax,%edx
80101b14:	8b 45 08             	mov    0x8(%ebp),%eax
80101b17:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	ff 75 08             	pushl  0x8(%ebp)
80101b20:	e8 c8 35 00 00       	call   801050ed <wakeup>
80101b25:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b28:	83 ec 0c             	sub    $0xc,%esp
80101b2b:	68 40 22 11 80       	push   $0x80112240
80101b30:	e8 9c 39 00 00       	call   801054d1 <release>
80101b35:	83 c4 10             	add    $0x10,%esp
}
80101b38:	90                   	nop
80101b39:	c9                   	leave  
80101b3a:	c3                   	ret    

80101b3b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3b:	55                   	push   %ebp
80101b3c:	89 e5                	mov    %esp,%ebp
80101b3e:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b41:	83 ec 0c             	sub    $0xc,%esp
80101b44:	68 40 22 11 80       	push   $0x80112240
80101b49:	e8 1c 39 00 00       	call   8010546a <acquire>
80101b4e:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	8b 40 08             	mov    0x8(%eax),%eax
80101b57:	83 f8 01             	cmp    $0x1,%eax
80101b5a:	0f 85 a9 00 00 00    	jne    80101c09 <iput+0xce>
80101b60:	8b 45 08             	mov    0x8(%ebp),%eax
80101b63:	8b 40 0c             	mov    0xc(%eax),%eax
80101b66:	83 e0 02             	and    $0x2,%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	0f 84 98 00 00 00    	je     80101c09 <iput+0xce>
80101b71:	8b 45 08             	mov    0x8(%ebp),%eax
80101b74:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b78:	66 85 c0             	test   %ax,%ax
80101b7b:	0f 85 88 00 00 00    	jne    80101c09 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	8b 40 0c             	mov    0xc(%eax),%eax
80101b87:	83 e0 01             	and    $0x1,%eax
80101b8a:	85 c0                	test   %eax,%eax
80101b8c:	74 0d                	je     80101b9b <iput+0x60>
      panic("iput busy");
80101b8e:	83 ec 0c             	sub    $0xc,%esp
80101b91:	68 f6 8a 10 80       	push   $0x80108af6
80101b96:	e8 cb e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9e:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba1:	83 c8 01             	or     $0x1,%eax
80101ba4:	89 c2                	mov    %eax,%edx
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bac:	83 ec 0c             	sub    $0xc,%esp
80101baf:	68 40 22 11 80       	push   $0x80112240
80101bb4:	e8 18 39 00 00       	call   801054d1 <release>
80101bb9:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bbc:	83 ec 0c             	sub    $0xc,%esp
80101bbf:	ff 75 08             	pushl  0x8(%ebp)
80101bc2:	e8 a8 01 00 00       	call   80101d6f <itrunc>
80101bc7:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bd3:	83 ec 0c             	sub    $0xc,%esp
80101bd6:	ff 75 08             	pushl  0x8(%ebp)
80101bd9:	e8 b3 fb ff ff       	call   80101791 <iupdate>
80101bde:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101be1:	83 ec 0c             	sub    $0xc,%esp
80101be4:	68 40 22 11 80       	push   $0x80112240
80101be9:	e8 7c 38 00 00       	call   8010546a <acquire>
80101bee:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bfb:	83 ec 0c             	sub    $0xc,%esp
80101bfe:	ff 75 08             	pushl  0x8(%ebp)
80101c01:	e8 e7 34 00 00       	call   801050ed <wakeup>
80101c06:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c09:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0c:	8b 40 08             	mov    0x8(%eax),%eax
80101c0f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c12:	8b 45 08             	mov    0x8(%ebp),%eax
80101c15:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c18:	83 ec 0c             	sub    $0xc,%esp
80101c1b:	68 40 22 11 80       	push   $0x80112240
80101c20:	e8 ac 38 00 00       	call   801054d1 <release>
80101c25:	83 c4 10             	add    $0x10,%esp
}
80101c28:	90                   	nop
80101c29:	c9                   	leave  
80101c2a:	c3                   	ret    

80101c2b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c2b:	55                   	push   %ebp
80101c2c:	89 e5                	mov    %esp,%ebp
80101c2e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c31:	83 ec 0c             	sub    $0xc,%esp
80101c34:	ff 75 08             	pushl  0x8(%ebp)
80101c37:	e8 8d fe ff ff       	call   80101ac9 <iunlock>
80101c3c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3f:	83 ec 0c             	sub    $0xc,%esp
80101c42:	ff 75 08             	pushl  0x8(%ebp)
80101c45:	e8 f1 fe ff ff       	call   80101b3b <iput>
80101c4a:	83 c4 10             	add    $0x10,%esp
}
80101c4d:	90                   	nop
80101c4e:	c9                   	leave  
80101c4f:	c3                   	ret    

80101c50 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c50:	55                   	push   %ebp
80101c51:	89 e5                	mov    %esp,%ebp
80101c53:	53                   	push   %ebx
80101c54:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c57:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5b:	77 42                	ja     80101c9f <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c63:	83 c2 04             	add    $0x4,%edx
80101c66:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c71:	75 24                	jne    80101c97 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c73:	8b 45 08             	mov    0x8(%ebp),%eax
80101c76:	8b 00                	mov    (%eax),%eax
80101c78:	83 ec 0c             	sub    $0xc,%esp
80101c7b:	50                   	push   %eax
80101c7c:	e8 9a f7 ff ff       	call   8010141b <balloc>
80101c81:	83 c4 10             	add    $0x10,%esp
80101c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c87:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8d:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c93:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c9a:	e9 cb 00 00 00       	jmp    80101d6a <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c9f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca3:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca7:	0f 87 b0 00 00 00    	ja     80101d5d <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cba:	75 1d                	jne    80101cd9 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbf:	8b 00                	mov    (%eax),%eax
80101cc1:	83 ec 0c             	sub    $0xc,%esp
80101cc4:	50                   	push   %eax
80101cc5:	e8 51 f7 ff ff       	call   8010141b <balloc>
80101cca:	83 c4 10             	add    $0x10,%esp
80101ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd6:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	8b 00                	mov    (%eax),%eax
80101cde:	83 ec 08             	sub    $0x8,%esp
80101ce1:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce4:	50                   	push   %eax
80101ce5:	e8 cc e4 ff ff       	call   801001b6 <bread>
80101cea:	83 c4 10             	add    $0x10,%esp
80101ced:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf3:	83 c0 18             	add    $0x18,%eax
80101cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d06:	01 d0                	add    %edx,%eax
80101d08:	8b 00                	mov    (%eax),%eax
80101d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d11:	75 37                	jne    80101d4a <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d20:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	8b 00                	mov    (%eax),%eax
80101d28:	83 ec 0c             	sub    $0xc,%esp
80101d2b:	50                   	push   %eax
80101d2c:	e8 ea f6 ff ff       	call   8010141b <balloc>
80101d31:	83 c4 10             	add    $0x10,%esp
80101d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3a:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d3c:	83 ec 0c             	sub    $0xc,%esp
80101d3f:	ff 75 f0             	pushl  -0x10(%ebp)
80101d42:	e8 3f 1a 00 00       	call   80103786 <log_write>
80101d47:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d4a:	83 ec 0c             	sub    $0xc,%esp
80101d4d:	ff 75 f0             	pushl  -0x10(%ebp)
80101d50:	e8 d9 e4 ff ff       	call   8010022e <brelse>
80101d55:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5b:	eb 0d                	jmp    80101d6a <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d5d:	83 ec 0c             	sub    $0xc,%esp
80101d60:	68 00 8b 10 80       	push   $0x80108b00
80101d65:	e8 fc e7 ff ff       	call   80100566 <panic>
}
80101d6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d6d:	c9                   	leave  
80101d6e:	c3                   	ret    

80101d6f <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6f:	55                   	push   %ebp
80101d70:	89 e5                	mov    %esp,%ebp
80101d72:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7c:	eb 45                	jmp    80101dc3 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d84:	83 c2 04             	add    $0x4,%edx
80101d87:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8b:	85 c0                	test   %eax,%eax
80101d8d:	74 30                	je     80101dbf <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d95:	83 c2 04             	add    $0x4,%edx
80101d98:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9c:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9f:	8b 12                	mov    (%edx),%edx
80101da1:	83 ec 08             	sub    $0x8,%esp
80101da4:	50                   	push   %eax
80101da5:	52                   	push   %edx
80101da6:	e8 bc f7 ff ff       	call   80101567 <bfree>
80101dab:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db4:	83 c2 04             	add    $0x4,%edx
80101db7:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbe:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dbf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc3:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc7:	7e b5                	jle    80101d7e <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcc:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dcf:	85 c0                	test   %eax,%eax
80101dd1:	0f 84 a1 00 00 00    	je     80101e78 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dda:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80101de0:	8b 00                	mov    (%eax),%eax
80101de2:	83 ec 08             	sub    $0x8,%esp
80101de5:	52                   	push   %edx
80101de6:	50                   	push   %eax
80101de7:	e8 ca e3 ff ff       	call   801001b6 <bread>
80101dec:	83 c4 10             	add    $0x10,%esp
80101def:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df5:	83 c0 18             	add    $0x18,%eax
80101df8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e02:	eb 3c                	jmp    80101e40 <itrunc+0xd1>
      if(a[j])
80101e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e11:	01 d0                	add    %edx,%eax
80101e13:	8b 00                	mov    (%eax),%eax
80101e15:	85 c0                	test   %eax,%eax
80101e17:	74 23                	je     80101e3c <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e26:	01 d0                	add    %edx,%eax
80101e28:	8b 00                	mov    (%eax),%eax
80101e2a:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2d:	8b 12                	mov    (%edx),%edx
80101e2f:	83 ec 08             	sub    $0x8,%esp
80101e32:	50                   	push   %eax
80101e33:	52                   	push   %edx
80101e34:	e8 2e f7 ff ff       	call   80101567 <bfree>
80101e39:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e3c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e43:	83 f8 7f             	cmp    $0x7f,%eax
80101e46:	76 bc                	jbe    80101e04 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	ff 75 ec             	pushl  -0x14(%ebp)
80101e4e:	e8 db e3 ff ff       	call   8010022e <brelse>
80101e53:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e56:	8b 45 08             	mov    0x8(%ebp),%eax
80101e59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e5c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5f:	8b 12                	mov    (%edx),%edx
80101e61:	83 ec 08             	sub    $0x8,%esp
80101e64:	50                   	push   %eax
80101e65:	52                   	push   %edx
80101e66:	e8 fc f6 ff ff       	call   80101567 <bfree>
80101e6b:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e71:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e78:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e82:	83 ec 0c             	sub    $0xc,%esp
80101e85:	ff 75 08             	pushl  0x8(%ebp)
80101e88:	e8 04 f9 ff ff       	call   80101791 <iupdate>
80101e8d:	83 c4 10             	add    $0x10,%esp
}
80101e90:	90                   	nop
80101e91:	c9                   	leave  
80101e92:	c3                   	ret    

80101e93 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e93:	55                   	push   %ebp
80101e94:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e96:	8b 45 08             	mov    0x8(%ebp),%eax
80101e99:	8b 00                	mov    (%eax),%eax
80101e9b:	89 c2                	mov    %eax,%edx
80101e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea0:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea6:	8b 50 04             	mov    0x4(%eax),%edx
80101ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eac:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb9:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec6:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecd:	8b 50 18             	mov    0x18(%eax),%edx
80101ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed3:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed6:	90                   	nop
80101ed7:	5d                   	pop    %ebp
80101ed8:	c3                   	ret    

80101ed9 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed9:	55                   	push   %ebp
80101eda:	89 e5                	mov    %esp,%ebp
80101edc:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee6:	66 83 f8 03          	cmp    $0x3,%ax
80101eea:	75 5c                	jne    80101f48 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eec:	8b 45 08             	mov    0x8(%ebp),%eax
80101eef:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef3:	66 85 c0             	test   %ax,%ax
80101ef6:	78 20                	js     80101f18 <readi+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eff:	66 83 f8 09          	cmp    $0x9,%ax
80101f03:	7f 13                	jg     80101f18 <readi+0x3f>
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0c:	98                   	cwtl   
80101f0d:	8b 04 c5 c0 21 11 80 	mov    -0x7feede40(,%eax,8),%eax
80101f14:	85 c0                	test   %eax,%eax
80101f16:	75 0a                	jne    80101f22 <readi+0x49>
      return -1;
80101f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1d:	e9 0c 01 00 00       	jmp    8010202e <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f29:	98                   	cwtl   
80101f2a:	8b 04 c5 c0 21 11 80 	mov    -0x7feede40(,%eax,8),%eax
80101f31:	8b 55 14             	mov    0x14(%ebp),%edx
80101f34:	83 ec 04             	sub    $0x4,%esp
80101f37:	52                   	push   %edx
80101f38:	ff 75 0c             	pushl  0xc(%ebp)
80101f3b:	ff 75 08             	pushl  0x8(%ebp)
80101f3e:	ff d0                	call   *%eax
80101f40:	83 c4 10             	add    $0x10,%esp
80101f43:	e9 e6 00 00 00       	jmp    8010202e <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f48:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4b:	8b 40 18             	mov    0x18(%eax),%eax
80101f4e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f51:	72 0d                	jb     80101f60 <readi+0x87>
80101f53:	8b 55 10             	mov    0x10(%ebp),%edx
80101f56:	8b 45 14             	mov    0x14(%ebp),%eax
80101f59:	01 d0                	add    %edx,%eax
80101f5b:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5e:	73 0a                	jae    80101f6a <readi+0x91>
    return -1;
80101f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f65:	e9 c4 00 00 00       	jmp    8010202e <readi+0x155>
  if(off + n > ip->size)
80101f6a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f70:	01 c2                	add    %eax,%edx
80101f72:	8b 45 08             	mov    0x8(%ebp),%eax
80101f75:	8b 40 18             	mov    0x18(%eax),%eax
80101f78:	39 c2                	cmp    %eax,%edx
80101f7a:	76 0c                	jbe    80101f88 <readi+0xaf>
    n = ip->size - off;
80101f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7f:	8b 40 18             	mov    0x18(%eax),%eax
80101f82:	2b 45 10             	sub    0x10(%ebp),%eax
80101f85:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8f:	e9 8b 00 00 00       	jmp    8010201f <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f94:	8b 45 10             	mov    0x10(%ebp),%eax
80101f97:	c1 e8 09             	shr    $0x9,%eax
80101f9a:	83 ec 08             	sub    $0x8,%esp
80101f9d:	50                   	push   %eax
80101f9e:	ff 75 08             	pushl  0x8(%ebp)
80101fa1:	e8 aa fc ff ff       	call   80101c50 <bmap>
80101fa6:	83 c4 10             	add    $0x10,%esp
80101fa9:	89 c2                	mov    %eax,%edx
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	8b 00                	mov    (%eax),%eax
80101fb0:	83 ec 08             	sub    $0x8,%esp
80101fb3:	52                   	push   %edx
80101fb4:	50                   	push   %eax
80101fb5:	e8 fc e1 ff ff       	call   801001b6 <bread>
80101fba:	83 c4 10             	add    $0x10,%esp
80101fbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc0:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc3:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc8:	ba 00 02 00 00       	mov    $0x200,%edx
80101fcd:	29 c2                	sub    %eax,%edx
80101fcf:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd5:	39 c2                	cmp    %eax,%edx
80101fd7:	0f 46 c2             	cmovbe %edx,%eax
80101fda:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe0:	8d 50 18             	lea    0x18(%eax),%edx
80101fe3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101feb:	01 d0                	add    %edx,%eax
80101fed:	83 ec 04             	sub    $0x4,%esp
80101ff0:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff3:	50                   	push   %eax
80101ff4:	ff 75 0c             	pushl  0xc(%ebp)
80101ff7:	e8 90 37 00 00       	call   8010578c <memmove>
80101ffc:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	ff 75 f0             	pushl  -0x10(%ebp)
80102005:	e8 24 e2 ff ff       	call   8010022e <brelse>
8010200a:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102010:	01 45 f4             	add    %eax,-0xc(%ebp)
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 10             	add    %eax,0x10(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 0c             	add    %eax,0xc(%ebp)
8010201f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102022:	3b 45 14             	cmp    0x14(%ebp),%eax
80102025:	0f 82 69 ff ff ff    	jb     80101f94 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010202b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202e:	c9                   	leave  
8010202f:	c3                   	ret    

80102030 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102030:	55                   	push   %ebp
80102031:	89 e5                	mov    %esp,%ebp
80102033:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102036:	8b 45 08             	mov    0x8(%ebp),%eax
80102039:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010203d:	66 83 f8 03          	cmp    $0x3,%ax
80102041:	75 5c                	jne    8010209f <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102043:	8b 45 08             	mov    0x8(%ebp),%eax
80102046:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010204a:	66 85 c0             	test   %ax,%ax
8010204d:	78 20                	js     8010206f <writei+0x3f>
8010204f:	8b 45 08             	mov    0x8(%ebp),%eax
80102052:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102056:	66 83 f8 09          	cmp    $0x9,%ax
8010205a:	7f 13                	jg     8010206f <writei+0x3f>
8010205c:	8b 45 08             	mov    0x8(%ebp),%eax
8010205f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102063:	98                   	cwtl   
80102064:	8b 04 c5 c4 21 11 80 	mov    -0x7feede3c(,%eax,8),%eax
8010206b:	85 c0                	test   %eax,%eax
8010206d:	75 0a                	jne    80102079 <writei+0x49>
      return -1;
8010206f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102074:	e9 3d 01 00 00       	jmp    801021b6 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102079:	8b 45 08             	mov    0x8(%ebp),%eax
8010207c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102080:	98                   	cwtl   
80102081:	8b 04 c5 c4 21 11 80 	mov    -0x7feede3c(,%eax,8),%eax
80102088:	8b 55 14             	mov    0x14(%ebp),%edx
8010208b:	83 ec 04             	sub    $0x4,%esp
8010208e:	52                   	push   %edx
8010208f:	ff 75 0c             	pushl  0xc(%ebp)
80102092:	ff 75 08             	pushl  0x8(%ebp)
80102095:	ff d0                	call   *%eax
80102097:	83 c4 10             	add    $0x10,%esp
8010209a:	e9 17 01 00 00       	jmp    801021b6 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 40 18             	mov    0x18(%eax),%eax
801020a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a8:	72 0d                	jb     801020b7 <writei+0x87>
801020aa:	8b 55 10             	mov    0x10(%ebp),%edx
801020ad:	8b 45 14             	mov    0x14(%ebp),%eax
801020b0:	01 d0                	add    %edx,%eax
801020b2:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b5:	73 0a                	jae    801020c1 <writei+0x91>
    return -1;
801020b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bc:	e9 f5 00 00 00       	jmp    801021b6 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020c1:	8b 55 10             	mov    0x10(%ebp),%edx
801020c4:	8b 45 14             	mov    0x14(%ebp),%eax
801020c7:	01 d0                	add    %edx,%eax
801020c9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020ce:	76 0a                	jbe    801020da <writei+0xaa>
    return -1;
801020d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d5:	e9 dc 00 00 00       	jmp    801021b6 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e1:	e9 99 00 00 00       	jmp    8010217f <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e6:	8b 45 10             	mov    0x10(%ebp),%eax
801020e9:	c1 e8 09             	shr    $0x9,%eax
801020ec:	83 ec 08             	sub    $0x8,%esp
801020ef:	50                   	push   %eax
801020f0:	ff 75 08             	pushl  0x8(%ebp)
801020f3:	e8 58 fb ff ff       	call   80101c50 <bmap>
801020f8:	83 c4 10             	add    $0x10,%esp
801020fb:	89 c2                	mov    %eax,%edx
801020fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102100:	8b 00                	mov    (%eax),%eax
80102102:	83 ec 08             	sub    $0x8,%esp
80102105:	52                   	push   %edx
80102106:	50                   	push   %eax
80102107:	e8 aa e0 ff ff       	call   801001b6 <bread>
8010210c:	83 c4 10             	add    $0x10,%esp
8010210f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102112:	8b 45 10             	mov    0x10(%ebp),%eax
80102115:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211a:	ba 00 02 00 00       	mov    $0x200,%edx
8010211f:	29 c2                	sub    %eax,%edx
80102121:	8b 45 14             	mov    0x14(%ebp),%eax
80102124:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102127:	39 c2                	cmp    %eax,%edx
80102129:	0f 46 c2             	cmovbe %edx,%eax
8010212c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010212f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102132:	8d 50 18             	lea    0x18(%eax),%edx
80102135:	8b 45 10             	mov    0x10(%ebp),%eax
80102138:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213d:	01 d0                	add    %edx,%eax
8010213f:	83 ec 04             	sub    $0x4,%esp
80102142:	ff 75 ec             	pushl  -0x14(%ebp)
80102145:	ff 75 0c             	pushl  0xc(%ebp)
80102148:	50                   	push   %eax
80102149:	e8 3e 36 00 00       	call   8010578c <memmove>
8010214e:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102151:	83 ec 0c             	sub    $0xc,%esp
80102154:	ff 75 f0             	pushl  -0x10(%ebp)
80102157:	e8 2a 16 00 00       	call   80103786 <log_write>
8010215c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010215f:	83 ec 0c             	sub    $0xc,%esp
80102162:	ff 75 f0             	pushl  -0x10(%ebp)
80102165:	e8 c4 e0 ff ff       	call   8010022e <brelse>
8010216a:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102170:	01 45 f4             	add    %eax,-0xc(%ebp)
80102173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102176:	01 45 10             	add    %eax,0x10(%ebp)
80102179:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217c:	01 45 0c             	add    %eax,0xc(%ebp)
8010217f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102182:	3b 45 14             	cmp    0x14(%ebp),%eax
80102185:	0f 82 5b ff ff ff    	jb     801020e6 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010218b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218f:	74 22                	je     801021b3 <writei+0x183>
80102191:	8b 45 08             	mov    0x8(%ebp),%eax
80102194:	8b 40 18             	mov    0x18(%eax),%eax
80102197:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219a:	73 17                	jae    801021b3 <writei+0x183>
    ip->size = off;
8010219c:	8b 45 08             	mov    0x8(%ebp),%eax
8010219f:	8b 55 10             	mov    0x10(%ebp),%edx
801021a2:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021a5:	83 ec 0c             	sub    $0xc,%esp
801021a8:	ff 75 08             	pushl  0x8(%ebp)
801021ab:	e8 e1 f5 ff ff       	call   80101791 <iupdate>
801021b0:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b3:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b6:	c9                   	leave  
801021b7:	c3                   	ret    

801021b8 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b8:	55                   	push   %ebp
801021b9:	89 e5                	mov    %esp,%ebp
801021bb:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021be:	83 ec 04             	sub    $0x4,%esp
801021c1:	6a 0e                	push   $0xe
801021c3:	ff 75 0c             	pushl  0xc(%ebp)
801021c6:	ff 75 08             	pushl  0x8(%ebp)
801021c9:	e8 54 36 00 00       	call   80105822 <strncmp>
801021ce:	83 c4 10             	add    $0x10,%esp
}
801021d1:	c9                   	leave  
801021d2:	c3                   	ret    

801021d3 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d3:	55                   	push   %ebp
801021d4:	89 e5                	mov    %esp,%ebp
801021d6:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d9:	8b 45 08             	mov    0x8(%ebp),%eax
801021dc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021e0:	66 83 f8 01          	cmp    $0x1,%ax
801021e4:	74 0d                	je     801021f3 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e6:	83 ec 0c             	sub    $0xc,%esp
801021e9:	68 13 8b 10 80       	push   $0x80108b13
801021ee:	e8 73 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fa:	eb 7b                	jmp    80102277 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fc:	6a 10                	push   $0x10
801021fe:	ff 75 f4             	pushl  -0xc(%ebp)
80102201:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102204:	50                   	push   %eax
80102205:	ff 75 08             	pushl  0x8(%ebp)
80102208:	e8 cc fc ff ff       	call   80101ed9 <readi>
8010220d:	83 c4 10             	add    $0x10,%esp
80102210:	83 f8 10             	cmp    $0x10,%eax
80102213:	74 0d                	je     80102222 <dirlookup+0x4f>
      panic("dirlink read");
80102215:	83 ec 0c             	sub    $0xc,%esp
80102218:	68 25 8b 10 80       	push   $0x80108b25
8010221d:	e8 44 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102222:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102226:	66 85 c0             	test   %ax,%ax
80102229:	74 47                	je     80102272 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222b:	83 ec 08             	sub    $0x8,%esp
8010222e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102231:	83 c0 02             	add    $0x2,%eax
80102234:	50                   	push   %eax
80102235:	ff 75 0c             	pushl  0xc(%ebp)
80102238:	e8 7b ff ff ff       	call   801021b8 <namecmp>
8010223d:	83 c4 10             	add    $0x10,%esp
80102240:	85 c0                	test   %eax,%eax
80102242:	75 2f                	jne    80102273 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102244:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102248:	74 08                	je     80102252 <dirlookup+0x7f>
        *poff = off;
8010224a:	8b 45 10             	mov    0x10(%ebp),%eax
8010224d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102250:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102252:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102256:	0f b7 c0             	movzwl %ax,%eax
80102259:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225c:	8b 45 08             	mov    0x8(%ebp),%eax
8010225f:	8b 00                	mov    (%eax),%eax
80102261:	83 ec 08             	sub    $0x8,%esp
80102264:	ff 75 f0             	pushl  -0x10(%ebp)
80102267:	50                   	push   %eax
80102268:	e8 e5 f5 ff ff       	call   80101852 <iget>
8010226d:	83 c4 10             	add    $0x10,%esp
80102270:	eb 19                	jmp    8010228b <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102272:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102273:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	8b 40 18             	mov    0x18(%eax),%eax
8010227d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102280:	0f 87 76 ff ff ff    	ja     801021fc <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102286:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228b:	c9                   	leave  
8010228c:	c3                   	ret    

8010228d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228d:	55                   	push   %ebp
8010228e:	89 e5                	mov    %esp,%ebp
80102290:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102293:	83 ec 04             	sub    $0x4,%esp
80102296:	6a 00                	push   $0x0
80102298:	ff 75 0c             	pushl  0xc(%ebp)
8010229b:	ff 75 08             	pushl  0x8(%ebp)
8010229e:	e8 30 ff ff ff       	call   801021d3 <dirlookup>
801022a3:	83 c4 10             	add    $0x10,%esp
801022a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ad:	74 18                	je     801022c7 <dirlink+0x3a>
    iput(ip);
801022af:	83 ec 0c             	sub    $0xc,%esp
801022b2:	ff 75 f0             	pushl  -0x10(%ebp)
801022b5:	e8 81 f8 ff ff       	call   80101b3b <iput>
801022ba:	83 c4 10             	add    $0x10,%esp
    return -1;
801022bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c2:	e9 9c 00 00 00       	jmp    80102363 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ce:	eb 39                	jmp    80102309 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d3:	6a 10                	push   $0x10
801022d5:	50                   	push   %eax
801022d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d9:	50                   	push   %eax
801022da:	ff 75 08             	pushl  0x8(%ebp)
801022dd:	e8 f7 fb ff ff       	call   80101ed9 <readi>
801022e2:	83 c4 10             	add    $0x10,%esp
801022e5:	83 f8 10             	cmp    $0x10,%eax
801022e8:	74 0d                	je     801022f7 <dirlink+0x6a>
      panic("dirlink read");
801022ea:	83 ec 0c             	sub    $0xc,%esp
801022ed:	68 25 8b 10 80       	push   $0x80108b25
801022f2:	e8 6f e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022f7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fb:	66 85 c0             	test   %ax,%ax
801022fe:	74 18                	je     80102318 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102303:	83 c0 10             	add    $0x10,%eax
80102306:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102309:	8b 45 08             	mov    0x8(%ebp),%eax
8010230c:	8b 50 18             	mov    0x18(%eax),%edx
8010230f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102312:	39 c2                	cmp    %eax,%edx
80102314:	77 ba                	ja     801022d0 <dirlink+0x43>
80102316:	eb 01                	jmp    80102319 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102318:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102319:	83 ec 04             	sub    $0x4,%esp
8010231c:	6a 0e                	push   $0xe
8010231e:	ff 75 0c             	pushl  0xc(%ebp)
80102321:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102324:	83 c0 02             	add    $0x2,%eax
80102327:	50                   	push   %eax
80102328:	e8 4b 35 00 00       	call   80105878 <strncpy>
8010232d:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102330:	8b 45 10             	mov    0x10(%ebp),%eax
80102333:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233a:	6a 10                	push   $0x10
8010233c:	50                   	push   %eax
8010233d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102340:	50                   	push   %eax
80102341:	ff 75 08             	pushl  0x8(%ebp)
80102344:	e8 e7 fc ff ff       	call   80102030 <writei>
80102349:	83 c4 10             	add    $0x10,%esp
8010234c:	83 f8 10             	cmp    $0x10,%eax
8010234f:	74 0d                	je     8010235e <dirlink+0xd1>
    panic("dirlink");
80102351:	83 ec 0c             	sub    $0xc,%esp
80102354:	68 32 8b 10 80       	push   $0x80108b32
80102359:	e8 08 e2 ff ff       	call   80100566 <panic>
  
  return 0;
8010235e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102363:	c9                   	leave  
80102364:	c3                   	ret    

80102365 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102365:	55                   	push   %ebp
80102366:	89 e5                	mov    %esp,%ebp
80102368:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236b:	eb 04                	jmp    80102371 <skipelem+0xc>
    path++;
8010236d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102371:	8b 45 08             	mov    0x8(%ebp),%eax
80102374:	0f b6 00             	movzbl (%eax),%eax
80102377:	3c 2f                	cmp    $0x2f,%al
80102379:	74 f2                	je     8010236d <skipelem+0x8>
    path++;
  if(*path == 0)
8010237b:	8b 45 08             	mov    0x8(%ebp),%eax
8010237e:	0f b6 00             	movzbl (%eax),%eax
80102381:	84 c0                	test   %al,%al
80102383:	75 07                	jne    8010238c <skipelem+0x27>
    return 0;
80102385:	b8 00 00 00 00       	mov    $0x0,%eax
8010238a:	eb 7b                	jmp    80102407 <skipelem+0xa2>
  s = path;
8010238c:	8b 45 08             	mov    0x8(%ebp),%eax
8010238f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102392:	eb 04                	jmp    80102398 <skipelem+0x33>
    path++;
80102394:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102398:	8b 45 08             	mov    0x8(%ebp),%eax
8010239b:	0f b6 00             	movzbl (%eax),%eax
8010239e:	3c 2f                	cmp    $0x2f,%al
801023a0:	74 0a                	je     801023ac <skipelem+0x47>
801023a2:	8b 45 08             	mov    0x8(%ebp),%eax
801023a5:	0f b6 00             	movzbl (%eax),%eax
801023a8:	84 c0                	test   %al,%al
801023aa:	75 e8                	jne    80102394 <skipelem+0x2f>
    path++;
  len = path - s;
801023ac:	8b 55 08             	mov    0x8(%ebp),%edx
801023af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b2:	29 c2                	sub    %eax,%edx
801023b4:	89 d0                	mov    %edx,%eax
801023b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023bd:	7e 15                	jle    801023d4 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023bf:	83 ec 04             	sub    $0x4,%esp
801023c2:	6a 0e                	push   $0xe
801023c4:	ff 75 f4             	pushl  -0xc(%ebp)
801023c7:	ff 75 0c             	pushl  0xc(%ebp)
801023ca:	e8 bd 33 00 00       	call   8010578c <memmove>
801023cf:	83 c4 10             	add    $0x10,%esp
801023d2:	eb 26                	jmp    801023fa <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d7:	83 ec 04             	sub    $0x4,%esp
801023da:	50                   	push   %eax
801023db:	ff 75 f4             	pushl  -0xc(%ebp)
801023de:	ff 75 0c             	pushl  0xc(%ebp)
801023e1:	e8 a6 33 00 00       	call   8010578c <memmove>
801023e6:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ef:	01 d0                	add    %edx,%eax
801023f1:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f4:	eb 04                	jmp    801023fa <skipelem+0x95>
    path++;
801023f6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
801023fd:	0f b6 00             	movzbl (%eax),%eax
80102400:	3c 2f                	cmp    $0x2f,%al
80102402:	74 f2                	je     801023f6 <skipelem+0x91>
    path++;
  return path;
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102407:	c9                   	leave  
80102408:	c3                   	ret    

80102409 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102409:	55                   	push   %ebp
8010240a:	89 e5                	mov    %esp,%ebp
8010240c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240f:	8b 45 08             	mov    0x8(%ebp),%eax
80102412:	0f b6 00             	movzbl (%eax),%eax
80102415:	3c 2f                	cmp    $0x2f,%al
80102417:	75 17                	jne    80102430 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102419:	83 ec 08             	sub    $0x8,%esp
8010241c:	6a 01                	push   $0x1
8010241e:	6a 01                	push   $0x1
80102420:	e8 2d f4 ff ff       	call   80101852 <iget>
80102425:	83 c4 10             	add    $0x10,%esp
80102428:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242b:	e9 bb 00 00 00       	jmp    801024eb <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102430:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102436:	8b 40 70             	mov    0x70(%eax),%eax
80102439:	83 ec 0c             	sub    $0xc,%esp
8010243c:	50                   	push   %eax
8010243d:	e8 ef f4 ff ff       	call   80101931 <idup>
80102442:	83 c4 10             	add    $0x10,%esp
80102445:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102448:	e9 9e 00 00 00       	jmp    801024eb <namex+0xe2>
    ilock(ip);
8010244d:	83 ec 0c             	sub    $0xc,%esp
80102450:	ff 75 f4             	pushl  -0xc(%ebp)
80102453:	e8 13 f5 ff ff       	call   8010196b <ilock>
80102458:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102462:	66 83 f8 01          	cmp    $0x1,%ax
80102466:	74 18                	je     80102480 <namex+0x77>
      iunlockput(ip);
80102468:	83 ec 0c             	sub    $0xc,%esp
8010246b:	ff 75 f4             	pushl  -0xc(%ebp)
8010246e:	e8 b8 f7 ff ff       	call   80101c2b <iunlockput>
80102473:	83 c4 10             	add    $0x10,%esp
      return 0;
80102476:	b8 00 00 00 00       	mov    $0x0,%eax
8010247b:	e9 a7 00 00 00       	jmp    80102527 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102480:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102484:	74 20                	je     801024a6 <namex+0x9d>
80102486:	8b 45 08             	mov    0x8(%ebp),%eax
80102489:	0f b6 00             	movzbl (%eax),%eax
8010248c:	84 c0                	test   %al,%al
8010248e:	75 16                	jne    801024a6 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102490:	83 ec 0c             	sub    $0xc,%esp
80102493:	ff 75 f4             	pushl  -0xc(%ebp)
80102496:	e8 2e f6 ff ff       	call   80101ac9 <iunlock>
8010249b:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a1:	e9 81 00 00 00       	jmp    80102527 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a6:	83 ec 04             	sub    $0x4,%esp
801024a9:	6a 00                	push   $0x0
801024ab:	ff 75 10             	pushl  0x10(%ebp)
801024ae:	ff 75 f4             	pushl  -0xc(%ebp)
801024b1:	e8 1d fd ff ff       	call   801021d3 <dirlookup>
801024b6:	83 c4 10             	add    $0x10,%esp
801024b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c0:	75 15                	jne    801024d7 <namex+0xce>
      iunlockput(ip);
801024c2:	83 ec 0c             	sub    $0xc,%esp
801024c5:	ff 75 f4             	pushl  -0xc(%ebp)
801024c8:	e8 5e f7 ff ff       	call   80101c2b <iunlockput>
801024cd:	83 c4 10             	add    $0x10,%esp
      return 0;
801024d0:	b8 00 00 00 00       	mov    $0x0,%eax
801024d5:	eb 50                	jmp    80102527 <namex+0x11e>
    }
    iunlockput(ip);
801024d7:	83 ec 0c             	sub    $0xc,%esp
801024da:	ff 75 f4             	pushl  -0xc(%ebp)
801024dd:	e8 49 f7 ff ff       	call   80101c2b <iunlockput>
801024e2:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024eb:	83 ec 08             	sub    $0x8,%esp
801024ee:	ff 75 10             	pushl  0x10(%ebp)
801024f1:	ff 75 08             	pushl  0x8(%ebp)
801024f4:	e8 6c fe ff ff       	call   80102365 <skipelem>
801024f9:	83 c4 10             	add    $0x10,%esp
801024fc:	89 45 08             	mov    %eax,0x8(%ebp)
801024ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102503:	0f 85 44 ff ff ff    	jne    8010244d <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102509:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250d:	74 15                	je     80102524 <namex+0x11b>
    iput(ip);
8010250f:	83 ec 0c             	sub    $0xc,%esp
80102512:	ff 75 f4             	pushl  -0xc(%ebp)
80102515:	e8 21 f6 ff ff       	call   80101b3b <iput>
8010251a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251d:	b8 00 00 00 00       	mov    $0x0,%eax
80102522:	eb 03                	jmp    80102527 <namex+0x11e>
  }
  return ip;
80102524:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102527:	c9                   	leave  
80102528:	c3                   	ret    

80102529 <namei>:

struct inode*
namei(char *path)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252f:	83 ec 04             	sub    $0x4,%esp
80102532:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102535:	50                   	push   %eax
80102536:	6a 00                	push   $0x0
80102538:	ff 75 08             	pushl  0x8(%ebp)
8010253b:	e8 c9 fe ff ff       	call   80102409 <namex>
80102540:	83 c4 10             	add    $0x10,%esp
}
80102543:	c9                   	leave  
80102544:	c3                   	ret    

80102545 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102545:	55                   	push   %ebp
80102546:	89 e5                	mov    %esp,%ebp
80102548:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254b:	83 ec 04             	sub    $0x4,%esp
8010254e:	ff 75 0c             	pushl  0xc(%ebp)
80102551:	6a 01                	push   $0x1
80102553:	ff 75 08             	pushl  0x8(%ebp)
80102556:	e8 ae fe ff ff       	call   80102409 <namex>
8010255b:	83 c4 10             	add    $0x10,%esp
}
8010255e:	c9                   	leave  
8010255f:	c3                   	ret    

80102560 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
80102563:	83 ec 14             	sub    $0x14,%esp
80102566:	8b 45 08             	mov    0x8(%ebp),%eax
80102569:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102571:	89 c2                	mov    %eax,%edx
80102573:	ec                   	in     (%dx),%al
80102574:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102577:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257b:	c9                   	leave  
8010257c:	c3                   	ret    

8010257d <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010257d:	55                   	push   %ebp
8010257e:	89 e5                	mov    %esp,%ebp
80102580:	57                   	push   %edi
80102581:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102582:	8b 55 08             	mov    0x8(%ebp),%edx
80102585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102588:	8b 45 10             	mov    0x10(%ebp),%eax
8010258b:	89 cb                	mov    %ecx,%ebx
8010258d:	89 df                	mov    %ebx,%edi
8010258f:	89 c1                	mov    %eax,%ecx
80102591:	fc                   	cld    
80102592:	f3 6d                	rep insl (%dx),%es:(%edi)
80102594:	89 c8                	mov    %ecx,%eax
80102596:	89 fb                	mov    %edi,%ebx
80102598:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259b:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010259e:	90                   	nop
8010259f:	5b                   	pop    %ebx
801025a0:	5f                   	pop    %edi
801025a1:	5d                   	pop    %ebp
801025a2:	c3                   	ret    

801025a3 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a3:	55                   	push   %ebp
801025a4:	89 e5                	mov    %esp,%ebp
801025a6:	83 ec 08             	sub    $0x8,%esp
801025a9:	8b 55 08             	mov    0x8(%ebp),%edx
801025ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801025af:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025ba:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025be:	ee                   	out    %al,(%dx)
}
801025bf:	90                   	nop
801025c0:	c9                   	leave  
801025c1:	c3                   	ret    

801025c2 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c2:	55                   	push   %ebp
801025c3:	89 e5                	mov    %esp,%ebp
801025c5:	56                   	push   %esi
801025c6:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c7:	8b 55 08             	mov    0x8(%ebp),%edx
801025ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025cd:	8b 45 10             	mov    0x10(%ebp),%eax
801025d0:	89 cb                	mov    %ecx,%ebx
801025d2:	89 de                	mov    %ebx,%esi
801025d4:	89 c1                	mov    %eax,%ecx
801025d6:	fc                   	cld    
801025d7:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d9:	89 c8                	mov    %ecx,%eax
801025db:	89 f3                	mov    %esi,%ebx
801025dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e0:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e3:	90                   	nop
801025e4:	5b                   	pop    %ebx
801025e5:	5e                   	pop    %esi
801025e6:	5d                   	pop    %ebp
801025e7:	c3                   	ret    

801025e8 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e8:	55                   	push   %ebp
801025e9:	89 e5                	mov    %esp,%ebp
801025eb:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ee:	90                   	nop
801025ef:	68 f7 01 00 00       	push   $0x1f7
801025f4:	e8 67 ff ff ff       	call   80102560 <inb>
801025f9:	83 c4 04             	add    $0x4,%esp
801025fc:	0f b6 c0             	movzbl %al,%eax
801025ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102602:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102605:	25 c0 00 00 00       	and    $0xc0,%eax
8010260a:	83 f8 40             	cmp    $0x40,%eax
8010260d:	75 e0                	jne    801025ef <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102613:	74 11                	je     80102626 <idewait+0x3e>
80102615:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102618:	83 e0 21             	and    $0x21,%eax
8010261b:	85 c0                	test   %eax,%eax
8010261d:	74 07                	je     80102626 <idewait+0x3e>
    return -1;
8010261f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102624:	eb 05                	jmp    8010262b <idewait+0x43>
  return 0;
80102626:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262b:	c9                   	leave  
8010262c:	c3                   	ret    

8010262d <ideinit>:

void
ideinit(void)
{
8010262d:	55                   	push   %ebp
8010262e:	89 e5                	mov    %esp,%ebp
80102630:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102633:	83 ec 08             	sub    $0x8,%esp
80102636:	68 3a 8b 10 80       	push   $0x80108b3a
8010263b:	68 00 c6 10 80       	push   $0x8010c600
80102640:	e8 03 2e 00 00       	call   80105448 <initlock>
80102645:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102648:	83 ec 0c             	sub    $0xc,%esp
8010264b:	6a 0e                	push   $0xe
8010264d:	e8 da 18 00 00       	call   80103f2c <picenable>
80102652:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102655:	a1 40 39 11 80       	mov    0x80113940,%eax
8010265a:	83 e8 01             	sub    $0x1,%eax
8010265d:	83 ec 08             	sub    $0x8,%esp
80102660:	50                   	push   %eax
80102661:	6a 0e                	push   $0xe
80102663:	e8 73 04 00 00       	call   80102adb <ioapicenable>
80102668:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010266b:	83 ec 0c             	sub    $0xc,%esp
8010266e:	6a 00                	push   $0x0
80102670:	e8 73 ff ff ff       	call   801025e8 <idewait>
80102675:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102678:	83 ec 08             	sub    $0x8,%esp
8010267b:	68 f0 00 00 00       	push   $0xf0
80102680:	68 f6 01 00 00       	push   $0x1f6
80102685:	e8 19 ff ff ff       	call   801025a3 <outb>
8010268a:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010268d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102694:	eb 24                	jmp    801026ba <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102696:	83 ec 0c             	sub    $0xc,%esp
80102699:	68 f7 01 00 00       	push   $0x1f7
8010269e:	e8 bd fe ff ff       	call   80102560 <inb>
801026a3:	83 c4 10             	add    $0x10,%esp
801026a6:	84 c0                	test   %al,%al
801026a8:	74 0c                	je     801026b6 <ideinit+0x89>
      havedisk1 = 1;
801026aa:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
801026b1:	00 00 00 
      break;
801026b4:	eb 0d                	jmp    801026c3 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026ba:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c1:	7e d3                	jle    80102696 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026c3:	83 ec 08             	sub    $0x8,%esp
801026c6:	68 e0 00 00 00       	push   $0xe0
801026cb:	68 f6 01 00 00       	push   $0x1f6
801026d0:	e8 ce fe ff ff       	call   801025a3 <outb>
801026d5:	83 c4 10             	add    $0x10,%esp
}
801026d8:	90                   	nop
801026d9:	c9                   	leave  
801026da:	c3                   	ret    

801026db <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026db:	55                   	push   %ebp
801026dc:	89 e5                	mov    %esp,%ebp
801026de:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e5:	75 0d                	jne    801026f4 <idestart+0x19>
    panic("idestart");
801026e7:	83 ec 0c             	sub    $0xc,%esp
801026ea:	68 3e 8b 10 80       	push   $0x80108b3e
801026ef:	e8 72 de ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801026f4:	8b 45 08             	mov    0x8(%ebp),%eax
801026f7:	8b 40 08             	mov    0x8(%eax),%eax
801026fa:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026ff:	76 0d                	jbe    8010270e <idestart+0x33>
    panic("incorrect blockno");
80102701:	83 ec 0c             	sub    $0xc,%esp
80102704:	68 47 8b 10 80       	push   $0x80108b47
80102709:	e8 58 de ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010270e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102715:	8b 45 08             	mov    0x8(%ebp),%eax
80102718:	8b 50 08             	mov    0x8(%eax),%edx
8010271b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271e:	0f af c2             	imul   %edx,%eax
80102721:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102724:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102728:	7e 0d                	jle    80102737 <idestart+0x5c>
8010272a:	83 ec 0c             	sub    $0xc,%esp
8010272d:	68 3e 8b 10 80       	push   $0x80108b3e
80102732:	e8 2f de ff ff       	call   80100566 <panic>
  
  idewait(0);
80102737:	83 ec 0c             	sub    $0xc,%esp
8010273a:	6a 00                	push   $0x0
8010273c:	e8 a7 fe ff ff       	call   801025e8 <idewait>
80102741:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102744:	83 ec 08             	sub    $0x8,%esp
80102747:	6a 00                	push   $0x0
80102749:	68 f6 03 00 00       	push   $0x3f6
8010274e:	e8 50 fe ff ff       	call   801025a3 <outb>
80102753:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102759:	0f b6 c0             	movzbl %al,%eax
8010275c:	83 ec 08             	sub    $0x8,%esp
8010275f:	50                   	push   %eax
80102760:	68 f2 01 00 00       	push   $0x1f2
80102765:	e8 39 fe ff ff       	call   801025a3 <outb>
8010276a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010276d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102770:	0f b6 c0             	movzbl %al,%eax
80102773:	83 ec 08             	sub    $0x8,%esp
80102776:	50                   	push   %eax
80102777:	68 f3 01 00 00       	push   $0x1f3
8010277c:	e8 22 fe ff ff       	call   801025a3 <outb>
80102781:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102787:	c1 f8 08             	sar    $0x8,%eax
8010278a:	0f b6 c0             	movzbl %al,%eax
8010278d:	83 ec 08             	sub    $0x8,%esp
80102790:	50                   	push   %eax
80102791:	68 f4 01 00 00       	push   $0x1f4
80102796:	e8 08 fe ff ff       	call   801025a3 <outb>
8010279b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010279e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a1:	c1 f8 10             	sar    $0x10,%eax
801027a4:	0f b6 c0             	movzbl %al,%eax
801027a7:	83 ec 08             	sub    $0x8,%esp
801027aa:	50                   	push   %eax
801027ab:	68 f5 01 00 00       	push   $0x1f5
801027b0:	e8 ee fd ff ff       	call   801025a3 <outb>
801027b5:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027b8:	8b 45 08             	mov    0x8(%ebp),%eax
801027bb:	8b 40 04             	mov    0x4(%eax),%eax
801027be:	83 e0 01             	and    $0x1,%eax
801027c1:	c1 e0 04             	shl    $0x4,%eax
801027c4:	89 c2                	mov    %eax,%edx
801027c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c9:	c1 f8 18             	sar    $0x18,%eax
801027cc:	83 e0 0f             	and    $0xf,%eax
801027cf:	09 d0                	or     %edx,%eax
801027d1:	83 c8 e0             	or     $0xffffffe0,%eax
801027d4:	0f b6 c0             	movzbl %al,%eax
801027d7:	83 ec 08             	sub    $0x8,%esp
801027da:	50                   	push   %eax
801027db:	68 f6 01 00 00       	push   $0x1f6
801027e0:	e8 be fd ff ff       	call   801025a3 <outb>
801027e5:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027e8:	8b 45 08             	mov    0x8(%ebp),%eax
801027eb:	8b 00                	mov    (%eax),%eax
801027ed:	83 e0 04             	and    $0x4,%eax
801027f0:	85 c0                	test   %eax,%eax
801027f2:	74 30                	je     80102824 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027f4:	83 ec 08             	sub    $0x8,%esp
801027f7:	6a 30                	push   $0x30
801027f9:	68 f7 01 00 00       	push   $0x1f7
801027fe:	e8 a0 fd ff ff       	call   801025a3 <outb>
80102803:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102806:	8b 45 08             	mov    0x8(%ebp),%eax
80102809:	83 c0 18             	add    $0x18,%eax
8010280c:	83 ec 04             	sub    $0x4,%esp
8010280f:	68 80 00 00 00       	push   $0x80
80102814:	50                   	push   %eax
80102815:	68 f0 01 00 00       	push   $0x1f0
8010281a:	e8 a3 fd ff ff       	call   801025c2 <outsl>
8010281f:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102822:	eb 12                	jmp    80102836 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102824:	83 ec 08             	sub    $0x8,%esp
80102827:	6a 20                	push   $0x20
80102829:	68 f7 01 00 00       	push   $0x1f7
8010282e:	e8 70 fd ff ff       	call   801025a3 <outb>
80102833:	83 c4 10             	add    $0x10,%esp
  }
}
80102836:	90                   	nop
80102837:	c9                   	leave  
80102838:	c3                   	ret    

80102839 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102839:	55                   	push   %ebp
8010283a:	89 e5                	mov    %esp,%ebp
8010283c:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010283f:	83 ec 0c             	sub    $0xc,%esp
80102842:	68 00 c6 10 80       	push   $0x8010c600
80102847:	e8 1e 2c 00 00       	call   8010546a <acquire>
8010284c:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010284f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102854:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285b:	75 15                	jne    80102872 <ideintr+0x39>
    release(&idelock);
8010285d:	83 ec 0c             	sub    $0xc,%esp
80102860:	68 00 c6 10 80       	push   $0x8010c600
80102865:	e8 67 2c 00 00       	call   801054d1 <release>
8010286a:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010286d:	e9 9a 00 00 00       	jmp    8010290c <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102875:	8b 40 14             	mov    0x14(%eax),%eax
80102878:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010287d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102880:	8b 00                	mov    (%eax),%eax
80102882:	83 e0 04             	and    $0x4,%eax
80102885:	85 c0                	test   %eax,%eax
80102887:	75 2d                	jne    801028b6 <ideintr+0x7d>
80102889:	83 ec 0c             	sub    $0xc,%esp
8010288c:	6a 01                	push   $0x1
8010288e:	e8 55 fd ff ff       	call   801025e8 <idewait>
80102893:	83 c4 10             	add    $0x10,%esp
80102896:	85 c0                	test   %eax,%eax
80102898:	78 1c                	js     801028b6 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	83 c0 18             	add    $0x18,%eax
801028a0:	83 ec 04             	sub    $0x4,%esp
801028a3:	68 80 00 00 00       	push   $0x80
801028a8:	50                   	push   %eax
801028a9:	68 f0 01 00 00       	push   $0x1f0
801028ae:	e8 ca fc ff ff       	call   8010257d <insl>
801028b3:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b9:	8b 00                	mov    (%eax),%eax
801028bb:	83 c8 02             	or     $0x2,%eax
801028be:	89 c2                	mov    %eax,%edx
801028c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c3:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c8:	8b 00                	mov    (%eax),%eax
801028ca:	83 e0 fb             	and    $0xfffffffb,%eax
801028cd:	89 c2                	mov    %eax,%edx
801028cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028d4:	83 ec 0c             	sub    $0xc,%esp
801028d7:	ff 75 f4             	pushl  -0xc(%ebp)
801028da:	e8 0e 28 00 00       	call   801050ed <wakeup>
801028df:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028e2:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801028e7:	85 c0                	test   %eax,%eax
801028e9:	74 11                	je     801028fc <ideintr+0xc3>
    idestart(idequeue);
801028eb:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801028f0:	83 ec 0c             	sub    $0xc,%esp
801028f3:	50                   	push   %eax
801028f4:	e8 e2 fd ff ff       	call   801026db <idestart>
801028f9:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028fc:	83 ec 0c             	sub    $0xc,%esp
801028ff:	68 00 c6 10 80       	push   $0x8010c600
80102904:	e8 c8 2b 00 00       	call   801054d1 <release>
80102909:	83 c4 10             	add    $0x10,%esp
}
8010290c:	c9                   	leave  
8010290d:	c3                   	ret    

8010290e <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010290e:	55                   	push   %ebp
8010290f:	89 e5                	mov    %esp,%ebp
80102911:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	8b 00                	mov    (%eax),%eax
80102919:	83 e0 01             	and    $0x1,%eax
8010291c:	85 c0                	test   %eax,%eax
8010291e:	75 0d                	jne    8010292d <iderw+0x1f>
    panic("iderw: buf not busy");
80102920:	83 ec 0c             	sub    $0xc,%esp
80102923:	68 59 8b 10 80       	push   $0x80108b59
80102928:	e8 39 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010292d:	8b 45 08             	mov    0x8(%ebp),%eax
80102930:	8b 00                	mov    (%eax),%eax
80102932:	83 e0 06             	and    $0x6,%eax
80102935:	83 f8 02             	cmp    $0x2,%eax
80102938:	75 0d                	jne    80102947 <iderw+0x39>
    panic("iderw: nothing to do");
8010293a:	83 ec 0c             	sub    $0xc,%esp
8010293d:	68 6d 8b 10 80       	push   $0x80108b6d
80102942:	e8 1f dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102947:	8b 45 08             	mov    0x8(%ebp),%eax
8010294a:	8b 40 04             	mov    0x4(%eax),%eax
8010294d:	85 c0                	test   %eax,%eax
8010294f:	74 16                	je     80102967 <iderw+0x59>
80102951:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102956:	85 c0                	test   %eax,%eax
80102958:	75 0d                	jne    80102967 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010295a:	83 ec 0c             	sub    $0xc,%esp
8010295d:	68 82 8b 10 80       	push   $0x80108b82
80102962:	e8 ff db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 00 c6 10 80       	push   $0x8010c600
8010296f:	e8 f6 2a 00 00       	call   8010546a <acquire>
80102974:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102977:	8b 45 08             	mov    0x8(%ebp),%eax
8010297a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102981:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102988:	eb 0b                	jmp    80102995 <iderw+0x87>
8010298a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298d:	8b 00                	mov    (%eax),%eax
8010298f:	83 c0 14             	add    $0x14,%eax
80102992:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102998:	8b 00                	mov    (%eax),%eax
8010299a:	85 c0                	test   %eax,%eax
8010299c:	75 ec                	jne    8010298a <iderw+0x7c>
    ;
  *pp = b;
8010299e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a1:	8b 55 08             	mov    0x8(%ebp),%edx
801029a4:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029a6:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029ab:	3b 45 08             	cmp    0x8(%ebp),%eax
801029ae:	75 23                	jne    801029d3 <iderw+0xc5>
    idestart(b);
801029b0:	83 ec 0c             	sub    $0xc,%esp
801029b3:	ff 75 08             	pushl  0x8(%ebp)
801029b6:	e8 20 fd ff ff       	call   801026db <idestart>
801029bb:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029be:	eb 13                	jmp    801029d3 <iderw+0xc5>
    sleep(b, &idelock);
801029c0:	83 ec 08             	sub    $0x8,%esp
801029c3:	68 00 c6 10 80       	push   $0x8010c600
801029c8:	ff 75 08             	pushl  0x8(%ebp)
801029cb:	e8 2f 26 00 00       	call   80104fff <sleep>
801029d0:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029d3:	8b 45 08             	mov    0x8(%ebp),%eax
801029d6:	8b 00                	mov    (%eax),%eax
801029d8:	83 e0 06             	and    $0x6,%eax
801029db:	83 f8 02             	cmp    $0x2,%eax
801029de:	75 e0                	jne    801029c0 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029e0:	83 ec 0c             	sub    $0xc,%esp
801029e3:	68 00 c6 10 80       	push   $0x8010c600
801029e8:	e8 e4 2a 00 00       	call   801054d1 <release>
801029ed:	83 c4 10             	add    $0x10,%esp
}
801029f0:	90                   	nop
801029f1:	c9                   	leave  
801029f2:	c3                   	ret    

801029f3 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029f3:	55                   	push   %ebp
801029f4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f6:	a1 14 32 11 80       	mov    0x80113214,%eax
801029fb:	8b 55 08             	mov    0x8(%ebp),%edx
801029fe:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a00:	a1 14 32 11 80       	mov    0x80113214,%eax
80102a05:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a08:	5d                   	pop    %ebp
80102a09:	c3                   	ret    

80102a0a <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a0a:	55                   	push   %ebp
80102a0b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a0d:	a1 14 32 11 80       	mov    0x80113214,%eax
80102a12:	8b 55 08             	mov    0x8(%ebp),%edx
80102a15:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a17:	a1 14 32 11 80       	mov    0x80113214,%eax
80102a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a1f:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a22:	90                   	nop
80102a23:	5d                   	pop    %ebp
80102a24:	c3                   	ret    

80102a25 <ioapicinit>:

void
ioapicinit(void)
{
80102a25:	55                   	push   %ebp
80102a26:	89 e5                	mov    %esp,%ebp
80102a28:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a2b:	a1 44 33 11 80       	mov    0x80113344,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	0f 84 a0 00 00 00    	je     80102ad8 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a38:	c7 05 14 32 11 80 00 	movl   $0xfec00000,0x80113214
80102a3f:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a42:	6a 01                	push   $0x1
80102a44:	e8 aa ff ff ff       	call   801029f3 <ioapicread>
80102a49:	83 c4 04             	add    $0x4,%esp
80102a4c:	c1 e8 10             	shr    $0x10,%eax
80102a4f:	25 ff 00 00 00       	and    $0xff,%eax
80102a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a57:	6a 00                	push   $0x0
80102a59:	e8 95 ff ff ff       	call   801029f3 <ioapicread>
80102a5e:	83 c4 04             	add    $0x4,%esp
80102a61:	c1 e8 18             	shr    $0x18,%eax
80102a64:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a67:	0f b6 05 40 33 11 80 	movzbl 0x80113340,%eax
80102a6e:	0f b6 c0             	movzbl %al,%eax
80102a71:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a74:	74 10                	je     80102a86 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a76:	83 ec 0c             	sub    $0xc,%esp
80102a79:	68 a0 8b 10 80       	push   $0x80108ba0
80102a7e:	e8 43 d9 ff ff       	call   801003c6 <cprintf>
80102a83:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a8d:	eb 3f                	jmp    80102ace <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a92:	83 c0 20             	add    $0x20,%eax
80102a95:	0d 00 00 01 00       	or     $0x10000,%eax
80102a9a:	89 c2                	mov    %eax,%edx
80102a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9f:	83 c0 08             	add    $0x8,%eax
80102aa2:	01 c0                	add    %eax,%eax
80102aa4:	83 ec 08             	sub    $0x8,%esp
80102aa7:	52                   	push   %edx
80102aa8:	50                   	push   %eax
80102aa9:	e8 5c ff ff ff       	call   80102a0a <ioapicwrite>
80102aae:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab4:	83 c0 08             	add    $0x8,%eax
80102ab7:	01 c0                	add    %eax,%eax
80102ab9:	83 c0 01             	add    $0x1,%eax
80102abc:	83 ec 08             	sub    $0x8,%esp
80102abf:	6a 00                	push   $0x0
80102ac1:	50                   	push   %eax
80102ac2:	e8 43 ff ff ff       	call   80102a0a <ioapicwrite>
80102ac7:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ad4:	7e b9                	jle    80102a8f <ioapicinit+0x6a>
80102ad6:	eb 01                	jmp    80102ad9 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ad8:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ad9:	c9                   	leave  
80102ada:	c3                   	ret    

80102adb <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102adb:	55                   	push   %ebp
80102adc:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102ade:	a1 44 33 11 80       	mov    0x80113344,%eax
80102ae3:	85 c0                	test   %eax,%eax
80102ae5:	74 39                	je     80102b20 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aea:	83 c0 20             	add    $0x20,%eax
80102aed:	89 c2                	mov    %eax,%edx
80102aef:	8b 45 08             	mov    0x8(%ebp),%eax
80102af2:	83 c0 08             	add    $0x8,%eax
80102af5:	01 c0                	add    %eax,%eax
80102af7:	52                   	push   %edx
80102af8:	50                   	push   %eax
80102af9:	e8 0c ff ff ff       	call   80102a0a <ioapicwrite>
80102afe:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b04:	c1 e0 18             	shl    $0x18,%eax
80102b07:	89 c2                	mov    %eax,%edx
80102b09:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0c:	83 c0 08             	add    $0x8,%eax
80102b0f:	01 c0                	add    %eax,%eax
80102b11:	83 c0 01             	add    $0x1,%eax
80102b14:	52                   	push   %edx
80102b15:	50                   	push   %eax
80102b16:	e8 ef fe ff ff       	call   80102a0a <ioapicwrite>
80102b1b:	83 c4 08             	add    $0x8,%esp
80102b1e:	eb 01                	jmp    80102b21 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102b20:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102b21:	c9                   	leave  
80102b22:	c3                   	ret    

80102b23 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b23:	55                   	push   %ebp
80102b24:	89 e5                	mov    %esp,%ebp
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	05 00 00 00 80       	add    $0x80000000,%eax
80102b2e:	5d                   	pop    %ebp
80102b2f:	c3                   	ret    

80102b30 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b30:	55                   	push   %ebp
80102b31:	89 e5                	mov    %esp,%ebp
80102b33:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b36:	83 ec 08             	sub    $0x8,%esp
80102b39:	68 d2 8b 10 80       	push   $0x80108bd2
80102b3e:	68 20 32 11 80       	push   $0x80113220
80102b43:	e8 00 29 00 00       	call   80105448 <initlock>
80102b48:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b4b:	c7 05 54 32 11 80 00 	movl   $0x0,0x80113254
80102b52:	00 00 00 
  freerange(vstart, vend);
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	ff 75 0c             	pushl  0xc(%ebp)
80102b5b:	ff 75 08             	pushl  0x8(%ebp)
80102b5e:	e8 2a 00 00 00       	call   80102b8d <freerange>
80102b63:	83 c4 10             	add    $0x10,%esp
}
80102b66:	90                   	nop
80102b67:	c9                   	leave  
80102b68:	c3                   	ret    

80102b69 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b69:	55                   	push   %ebp
80102b6a:	89 e5                	mov    %esp,%ebp
80102b6c:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b6f:	83 ec 08             	sub    $0x8,%esp
80102b72:	ff 75 0c             	pushl  0xc(%ebp)
80102b75:	ff 75 08             	pushl  0x8(%ebp)
80102b78:	e8 10 00 00 00       	call   80102b8d <freerange>
80102b7d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b80:	c7 05 54 32 11 80 01 	movl   $0x1,0x80113254
80102b87:	00 00 00 
}
80102b8a:	90                   	nop
80102b8b:	c9                   	leave  
80102b8c:	c3                   	ret    

80102b8d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b8d:	55                   	push   %ebp
80102b8e:	89 e5                	mov    %esp,%ebp
80102b90:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b93:	8b 45 08             	mov    0x8(%ebp),%eax
80102b96:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ba3:	eb 15                	jmp    80102bba <freerange+0x2d>
    kfree(p);
80102ba5:	83 ec 0c             	sub    $0xc,%esp
80102ba8:	ff 75 f4             	pushl  -0xc(%ebp)
80102bab:	e8 1a 00 00 00       	call   80102bca <kfree>
80102bb0:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbd:	05 00 10 00 00       	add    $0x1000,%eax
80102bc2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bc5:	76 de                	jbe    80102ba5 <freerange+0x18>
    kfree(p);
}
80102bc7:	90                   	nop
80102bc8:	c9                   	leave  
80102bc9:	c3                   	ret    

80102bca <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bca:	55                   	push   %ebp
80102bcb:	89 e5                	mov    %esp,%ebp
80102bcd:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bd8:	85 c0                	test   %eax,%eax
80102bda:	75 1b                	jne    80102bf7 <kfree+0x2d>
80102bdc:	81 7d 08 3c 63 11 80 	cmpl   $0x8011633c,0x8(%ebp)
80102be3:	72 12                	jb     80102bf7 <kfree+0x2d>
80102be5:	ff 75 08             	pushl  0x8(%ebp)
80102be8:	e8 36 ff ff ff       	call   80102b23 <v2p>
80102bed:	83 c4 04             	add    $0x4,%esp
80102bf0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bf5:	76 0d                	jbe    80102c04 <kfree+0x3a>
    panic("kfree");
80102bf7:	83 ec 0c             	sub    $0xc,%esp
80102bfa:	68 d7 8b 10 80       	push   $0x80108bd7
80102bff:	e8 62 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c04:	83 ec 04             	sub    $0x4,%esp
80102c07:	68 00 10 00 00       	push   $0x1000
80102c0c:	6a 01                	push   $0x1
80102c0e:	ff 75 08             	pushl  0x8(%ebp)
80102c11:	e8 b7 2a 00 00       	call   801056cd <memset>
80102c16:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c19:	a1 54 32 11 80       	mov    0x80113254,%eax
80102c1e:	85 c0                	test   %eax,%eax
80102c20:	74 10                	je     80102c32 <kfree+0x68>
    acquire(&kmem.lock);
80102c22:	83 ec 0c             	sub    $0xc,%esp
80102c25:	68 20 32 11 80       	push   $0x80113220
80102c2a:	e8 3b 28 00 00       	call   8010546a <acquire>
80102c2f:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c32:	8b 45 08             	mov    0x8(%ebp),%eax
80102c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c38:	8b 15 58 32 11 80    	mov    0x80113258,%edx
80102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c41:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c46:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102c4b:	a1 54 32 11 80       	mov    0x80113254,%eax
80102c50:	85 c0                	test   %eax,%eax
80102c52:	74 10                	je     80102c64 <kfree+0x9a>
    release(&kmem.lock);
80102c54:	83 ec 0c             	sub    $0xc,%esp
80102c57:	68 20 32 11 80       	push   $0x80113220
80102c5c:	e8 70 28 00 00       	call   801054d1 <release>
80102c61:	83 c4 10             	add    $0x10,%esp
}
80102c64:	90                   	nop
80102c65:	c9                   	leave  
80102c66:	c3                   	ret    

80102c67 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c67:	55                   	push   %ebp
80102c68:	89 e5                	mov    %esp,%ebp
80102c6a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c6d:	a1 54 32 11 80       	mov    0x80113254,%eax
80102c72:	85 c0                	test   %eax,%eax
80102c74:	74 10                	je     80102c86 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c76:	83 ec 0c             	sub    $0xc,%esp
80102c79:	68 20 32 11 80       	push   $0x80113220
80102c7e:	e8 e7 27 00 00       	call   8010546a <acquire>
80102c83:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c86:	a1 58 32 11 80       	mov    0x80113258,%eax
80102c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c92:	74 0a                	je     80102c9e <kalloc+0x37>
    kmem.freelist = r->next;
80102c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c97:	8b 00                	mov    (%eax),%eax
80102c99:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102c9e:	a1 54 32 11 80       	mov    0x80113254,%eax
80102ca3:	85 c0                	test   %eax,%eax
80102ca5:	74 10                	je     80102cb7 <kalloc+0x50>
    release(&kmem.lock);
80102ca7:	83 ec 0c             	sub    $0xc,%esp
80102caa:	68 20 32 11 80       	push   $0x80113220
80102caf:	e8 1d 28 00 00       	call   801054d1 <release>
80102cb4:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cba:	c9                   	leave  
80102cbb:	c3                   	ret    

80102cbc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cbc:	55                   	push   %ebp
80102cbd:	89 e5                	mov    %esp,%ebp
80102cbf:	83 ec 14             	sub    $0x14,%esp
80102cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ccd:	89 c2                	mov    %eax,%edx
80102ccf:	ec                   	in     (%dx),%al
80102cd0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cd7:	c9                   	leave  
80102cd8:	c3                   	ret    

80102cd9 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cd9:	55                   	push   %ebp
80102cda:	89 e5                	mov    %esp,%ebp
80102cdc:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cdf:	6a 64                	push   $0x64
80102ce1:	e8 d6 ff ff ff       	call   80102cbc <inb>
80102ce6:	83 c4 04             	add    $0x4,%esp
80102ce9:	0f b6 c0             	movzbl %al,%eax
80102cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf2:	83 e0 01             	and    $0x1,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 0a                	jne    80102d03 <kbdgetc+0x2a>
    return -1;
80102cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cfe:	e9 23 01 00 00       	jmp    80102e26 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d03:	6a 60                	push   $0x60
80102d05:	e8 b2 ff ff ff       	call   80102cbc <inb>
80102d0a:	83 c4 04             	add    $0x4,%esp
80102d0d:	0f b6 c0             	movzbl %al,%eax
80102d10:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d13:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d1a:	75 17                	jne    80102d33 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d1c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102d21:	83 c8 40             	or     $0x40,%eax
80102d24:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102d29:	b8 00 00 00 00       	mov    $0x0,%eax
80102d2e:	e9 f3 00 00 00       	jmp    80102e26 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d36:	25 80 00 00 00       	and    $0x80,%eax
80102d3b:	85 c0                	test   %eax,%eax
80102d3d:	74 45                	je     80102d84 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d3f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102d44:	83 e0 40             	and    $0x40,%eax
80102d47:	85 c0                	test   %eax,%eax
80102d49:	75 08                	jne    80102d53 <kbdgetc+0x7a>
80102d4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d4e:	83 e0 7f             	and    $0x7f,%eax
80102d51:	eb 03                	jmp    80102d56 <kbdgetc+0x7d>
80102d53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d56:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d59:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5c:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d61:	0f b6 00             	movzbl (%eax),%eax
80102d64:	83 c8 40             	or     $0x40,%eax
80102d67:	0f b6 c0             	movzbl %al,%eax
80102d6a:	f7 d0                	not    %eax
80102d6c:	89 c2                	mov    %eax,%edx
80102d6e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102d73:	21 d0                	and    %edx,%eax
80102d75:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102d7a:	b8 00 00 00 00       	mov    $0x0,%eax
80102d7f:	e9 a2 00 00 00       	jmp    80102e26 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d84:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102d89:	83 e0 40             	and    $0x40,%eax
80102d8c:	85 c0                	test   %eax,%eax
80102d8e:	74 14                	je     80102da4 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d90:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d97:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102d9c:	83 e0 bf             	and    $0xffffffbf,%eax
80102d9f:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102da4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da7:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102dac:	0f b6 00             	movzbl (%eax),%eax
80102daf:	0f b6 d0             	movzbl %al,%edx
80102db2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102db7:	09 d0                	or     %edx,%eax
80102db9:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102dbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc1:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102dc6:	0f b6 00             	movzbl (%eax),%eax
80102dc9:	0f b6 d0             	movzbl %al,%edx
80102dcc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102dd1:	31 d0                	xor    %edx,%eax
80102dd3:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dd8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ddd:	83 e0 03             	and    $0x3,%eax
80102de0:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102de7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dea:	01 d0                	add    %edx,%eax
80102dec:	0f b6 00             	movzbl (%eax),%eax
80102def:	0f b6 c0             	movzbl %al,%eax
80102df2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102df5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102dfa:	83 e0 08             	and    $0x8,%eax
80102dfd:	85 c0                	test   %eax,%eax
80102dff:	74 22                	je     80102e23 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e01:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e05:	76 0c                	jbe    80102e13 <kbdgetc+0x13a>
80102e07:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e0b:	77 06                	ja     80102e13 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e0d:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e11:	eb 10                	jmp    80102e23 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e13:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e17:	76 0a                	jbe    80102e23 <kbdgetc+0x14a>
80102e19:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e1d:	77 04                	ja     80102e23 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e1f:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e23:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e26:	c9                   	leave  
80102e27:	c3                   	ret    

80102e28 <kbdintr>:

void
kbdintr(void)
{
80102e28:	55                   	push   %ebp
80102e29:	89 e5                	mov    %esp,%ebp
80102e2b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e2e:	83 ec 0c             	sub    $0xc,%esp
80102e31:	68 d9 2c 10 80       	push   $0x80102cd9
80102e36:	e8 be d9 ff ff       	call   801007f9 <consoleintr>
80102e3b:	83 c4 10             	add    $0x10,%esp
}
80102e3e:	90                   	nop
80102e3f:	c9                   	leave  
80102e40:	c3                   	ret    

80102e41 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e41:	55                   	push   %ebp
80102e42:	89 e5                	mov    %esp,%ebp
80102e44:	83 ec 14             	sub    $0x14,%esp
80102e47:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e4e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e52:	89 c2                	mov    %eax,%edx
80102e54:	ec                   	in     (%dx),%al
80102e55:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e58:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e5c:	c9                   	leave  
80102e5d:	c3                   	ret    

80102e5e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e5e:	55                   	push   %ebp
80102e5f:	89 e5                	mov    %esp,%ebp
80102e61:	83 ec 08             	sub    $0x8,%esp
80102e64:	8b 55 08             	mov    0x8(%ebp),%edx
80102e67:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e6a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e6e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e71:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e75:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e79:	ee                   	out    %al,(%dx)
}
80102e7a:	90                   	nop
80102e7b:	c9                   	leave  
80102e7c:	c3                   	ret    

80102e7d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e7d:	55                   	push   %ebp
80102e7e:	89 e5                	mov    %esp,%ebp
80102e80:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e83:	9c                   	pushf  
80102e84:	58                   	pop    %eax
80102e85:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e8b:	c9                   	leave  
80102e8c:	c3                   	ret    

80102e8d <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e8d:	55                   	push   %ebp
80102e8e:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e90:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102e95:	8b 55 08             	mov    0x8(%ebp),%edx
80102e98:	c1 e2 02             	shl    $0x2,%edx
80102e9b:	01 c2                	add    %eax,%edx
80102e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ea0:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ea2:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102ea7:	83 c0 20             	add    $0x20,%eax
80102eaa:	8b 00                	mov    (%eax),%eax
}
80102eac:	90                   	nop
80102ead:	5d                   	pop    %ebp
80102eae:	c3                   	ret    

80102eaf <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102eaf:	55                   	push   %ebp
80102eb0:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102eb2:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102eb7:	85 c0                	test   %eax,%eax
80102eb9:	0f 84 0b 01 00 00    	je     80102fca <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ebf:	68 3f 01 00 00       	push   $0x13f
80102ec4:	6a 3c                	push   $0x3c
80102ec6:	e8 c2 ff ff ff       	call   80102e8d <lapicw>
80102ecb:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ece:	6a 0b                	push   $0xb
80102ed0:	68 f8 00 00 00       	push   $0xf8
80102ed5:	e8 b3 ff ff ff       	call   80102e8d <lapicw>
80102eda:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102edd:	68 20 00 02 00       	push   $0x20020
80102ee2:	68 c8 00 00 00       	push   $0xc8
80102ee7:	e8 a1 ff ff ff       	call   80102e8d <lapicw>
80102eec:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102eef:	68 80 96 98 00       	push   $0x989680
80102ef4:	68 e0 00 00 00       	push   $0xe0
80102ef9:	e8 8f ff ff ff       	call   80102e8d <lapicw>
80102efe:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f01:	68 00 00 01 00       	push   $0x10000
80102f06:	68 d4 00 00 00       	push   $0xd4
80102f0b:	e8 7d ff ff ff       	call   80102e8d <lapicw>
80102f10:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f13:	68 00 00 01 00       	push   $0x10000
80102f18:	68 d8 00 00 00       	push   $0xd8
80102f1d:	e8 6b ff ff ff       	call   80102e8d <lapicw>
80102f22:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f25:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102f2a:	83 c0 30             	add    $0x30,%eax
80102f2d:	8b 00                	mov    (%eax),%eax
80102f2f:	c1 e8 10             	shr    $0x10,%eax
80102f32:	0f b6 c0             	movzbl %al,%eax
80102f35:	83 f8 03             	cmp    $0x3,%eax
80102f38:	76 12                	jbe    80102f4c <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f3a:	68 00 00 01 00       	push   $0x10000
80102f3f:	68 d0 00 00 00       	push   $0xd0
80102f44:	e8 44 ff ff ff       	call   80102e8d <lapicw>
80102f49:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f4c:	6a 33                	push   $0x33
80102f4e:	68 dc 00 00 00       	push   $0xdc
80102f53:	e8 35 ff ff ff       	call   80102e8d <lapicw>
80102f58:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f5b:	6a 00                	push   $0x0
80102f5d:	68 a0 00 00 00       	push   $0xa0
80102f62:	e8 26 ff ff ff       	call   80102e8d <lapicw>
80102f67:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f6a:	6a 00                	push   $0x0
80102f6c:	68 a0 00 00 00       	push   $0xa0
80102f71:	e8 17 ff ff ff       	call   80102e8d <lapicw>
80102f76:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f79:	6a 00                	push   $0x0
80102f7b:	6a 2c                	push   $0x2c
80102f7d:	e8 0b ff ff ff       	call   80102e8d <lapicw>
80102f82:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f85:	6a 00                	push   $0x0
80102f87:	68 c4 00 00 00       	push   $0xc4
80102f8c:	e8 fc fe ff ff       	call   80102e8d <lapicw>
80102f91:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f94:	68 00 85 08 00       	push   $0x88500
80102f99:	68 c0 00 00 00       	push   $0xc0
80102f9e:	e8 ea fe ff ff       	call   80102e8d <lapicw>
80102fa3:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fa6:	90                   	nop
80102fa7:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102fac:	05 00 03 00 00       	add    $0x300,%eax
80102fb1:	8b 00                	mov    (%eax),%eax
80102fb3:	25 00 10 00 00       	and    $0x1000,%eax
80102fb8:	85 c0                	test   %eax,%eax
80102fba:	75 eb                	jne    80102fa7 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fbc:	6a 00                	push   $0x0
80102fbe:	6a 20                	push   $0x20
80102fc0:	e8 c8 fe ff ff       	call   80102e8d <lapicw>
80102fc5:	83 c4 08             	add    $0x8,%esp
80102fc8:	eb 01                	jmp    80102fcb <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102fca:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102fcb:	c9                   	leave  
80102fcc:	c3                   	ret    

80102fcd <cpunum>:

int
cpunum(void)
{
80102fcd:	55                   	push   %ebp
80102fce:	89 e5                	mov    %esp,%ebp
80102fd0:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd3:	e8 a5 fe ff ff       	call   80102e7d <readeflags>
80102fd8:	25 00 02 00 00       	and    $0x200,%eax
80102fdd:	85 c0                	test   %eax,%eax
80102fdf:	74 26                	je     80103007 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fe1:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80102fe6:	8d 50 01             	lea    0x1(%eax),%edx
80102fe9:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80102fef:	85 c0                	test   %eax,%eax
80102ff1:	75 14                	jne    80103007 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff3:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff6:	83 ec 08             	sub    $0x8,%esp
80102ff9:	50                   	push   %eax
80102ffa:	68 e0 8b 10 80       	push   $0x80108be0
80102fff:	e8 c2 d3 ff ff       	call   801003c6 <cprintf>
80103004:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103007:	a1 5c 32 11 80       	mov    0x8011325c,%eax
8010300c:	85 c0                	test   %eax,%eax
8010300e:	74 0f                	je     8010301f <cpunum+0x52>
    return lapic[ID]>>24;
80103010:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80103015:	83 c0 20             	add    $0x20,%eax
80103018:	8b 00                	mov    (%eax),%eax
8010301a:	c1 e8 18             	shr    $0x18,%eax
8010301d:	eb 05                	jmp    80103024 <cpunum+0x57>
  return 0;
8010301f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103024:	c9                   	leave  
80103025:	c3                   	ret    

80103026 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103026:	55                   	push   %ebp
80103027:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103029:	a1 5c 32 11 80       	mov    0x8011325c,%eax
8010302e:	85 c0                	test   %eax,%eax
80103030:	74 0c                	je     8010303e <lapiceoi+0x18>
    lapicw(EOI, 0);
80103032:	6a 00                	push   $0x0
80103034:	6a 2c                	push   $0x2c
80103036:	e8 52 fe ff ff       	call   80102e8d <lapicw>
8010303b:	83 c4 08             	add    $0x8,%esp
}
8010303e:	90                   	nop
8010303f:	c9                   	leave  
80103040:	c3                   	ret    

80103041 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103041:	55                   	push   %ebp
80103042:	89 e5                	mov    %esp,%ebp
}
80103044:	90                   	nop
80103045:	5d                   	pop    %ebp
80103046:	c3                   	ret    

80103047 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103047:	55                   	push   %ebp
80103048:	89 e5                	mov    %esp,%ebp
8010304a:	83 ec 14             	sub    $0x14,%esp
8010304d:	8b 45 08             	mov    0x8(%ebp),%eax
80103050:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103053:	6a 0f                	push   $0xf
80103055:	6a 70                	push   $0x70
80103057:	e8 02 fe ff ff       	call   80102e5e <outb>
8010305c:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010305f:	6a 0a                	push   $0xa
80103061:	6a 71                	push   $0x71
80103063:	e8 f6 fd ff ff       	call   80102e5e <outb>
80103068:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010306b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103072:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103075:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010307a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307d:	83 c0 02             	add    $0x2,%eax
80103080:	8b 55 0c             	mov    0xc(%ebp),%edx
80103083:	c1 ea 04             	shr    $0x4,%edx
80103086:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103089:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010308d:	c1 e0 18             	shl    $0x18,%eax
80103090:	50                   	push   %eax
80103091:	68 c4 00 00 00       	push   $0xc4
80103096:	e8 f2 fd ff ff       	call   80102e8d <lapicw>
8010309b:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010309e:	68 00 c5 00 00       	push   $0xc500
801030a3:	68 c0 00 00 00       	push   $0xc0
801030a8:	e8 e0 fd ff ff       	call   80102e8d <lapicw>
801030ad:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030b0:	68 c8 00 00 00       	push   $0xc8
801030b5:	e8 87 ff ff ff       	call   80103041 <microdelay>
801030ba:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030bd:	68 00 85 00 00       	push   $0x8500
801030c2:	68 c0 00 00 00       	push   $0xc0
801030c7:	e8 c1 fd ff ff       	call   80102e8d <lapicw>
801030cc:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030cf:	6a 64                	push   $0x64
801030d1:	e8 6b ff ff ff       	call   80103041 <microdelay>
801030d6:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030e0:	eb 3d                	jmp    8010311f <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030e2:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030e6:	c1 e0 18             	shl    $0x18,%eax
801030e9:	50                   	push   %eax
801030ea:	68 c4 00 00 00       	push   $0xc4
801030ef:	e8 99 fd ff ff       	call   80102e8d <lapicw>
801030f4:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801030fa:	c1 e8 0c             	shr    $0xc,%eax
801030fd:	80 cc 06             	or     $0x6,%ah
80103100:	50                   	push   %eax
80103101:	68 c0 00 00 00       	push   $0xc0
80103106:	e8 82 fd ff ff       	call   80102e8d <lapicw>
8010310b:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010310e:	68 c8 00 00 00       	push   $0xc8
80103113:	e8 29 ff ff ff       	call   80103041 <microdelay>
80103118:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010311b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010311f:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103123:	7e bd                	jle    801030e2 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103125:	90                   	nop
80103126:	c9                   	leave  
80103127:	c3                   	ret    

80103128 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103128:	55                   	push   %ebp
80103129:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010312b:	8b 45 08             	mov    0x8(%ebp),%eax
8010312e:	0f b6 c0             	movzbl %al,%eax
80103131:	50                   	push   %eax
80103132:	6a 70                	push   $0x70
80103134:	e8 25 fd ff ff       	call   80102e5e <outb>
80103139:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010313c:	68 c8 00 00 00       	push   $0xc8
80103141:	e8 fb fe ff ff       	call   80103041 <microdelay>
80103146:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103149:	6a 71                	push   $0x71
8010314b:	e8 f1 fc ff ff       	call   80102e41 <inb>
80103150:	83 c4 04             	add    $0x4,%esp
80103153:	0f b6 c0             	movzbl %al,%eax
}
80103156:	c9                   	leave  
80103157:	c3                   	ret    

80103158 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103158:	55                   	push   %ebp
80103159:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010315b:	6a 00                	push   $0x0
8010315d:	e8 c6 ff ff ff       	call   80103128 <cmos_read>
80103162:	83 c4 04             	add    $0x4,%esp
80103165:	89 c2                	mov    %eax,%edx
80103167:	8b 45 08             	mov    0x8(%ebp),%eax
8010316a:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010316c:	6a 02                	push   $0x2
8010316e:	e8 b5 ff ff ff       	call   80103128 <cmos_read>
80103173:	83 c4 04             	add    $0x4,%esp
80103176:	89 c2                	mov    %eax,%edx
80103178:	8b 45 08             	mov    0x8(%ebp),%eax
8010317b:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010317e:	6a 04                	push   $0x4
80103180:	e8 a3 ff ff ff       	call   80103128 <cmos_read>
80103185:	83 c4 04             	add    $0x4,%esp
80103188:	89 c2                	mov    %eax,%edx
8010318a:	8b 45 08             	mov    0x8(%ebp),%eax
8010318d:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103190:	6a 07                	push   $0x7
80103192:	e8 91 ff ff ff       	call   80103128 <cmos_read>
80103197:	83 c4 04             	add    $0x4,%esp
8010319a:	89 c2                	mov    %eax,%edx
8010319c:	8b 45 08             	mov    0x8(%ebp),%eax
8010319f:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031a2:	6a 08                	push   $0x8
801031a4:	e8 7f ff ff ff       	call   80103128 <cmos_read>
801031a9:	83 c4 04             	add    $0x4,%esp
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	8b 45 08             	mov    0x8(%ebp),%eax
801031b1:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031b4:	6a 09                	push   $0x9
801031b6:	e8 6d ff ff ff       	call   80103128 <cmos_read>
801031bb:	83 c4 04             	add    $0x4,%esp
801031be:	89 c2                	mov    %eax,%edx
801031c0:	8b 45 08             	mov    0x8(%ebp),%eax
801031c3:	89 50 14             	mov    %edx,0x14(%eax)
}
801031c6:	90                   	nop
801031c7:	c9                   	leave  
801031c8:	c3                   	ret    

801031c9 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031c9:	55                   	push   %ebp
801031ca:	89 e5                	mov    %esp,%ebp
801031cc:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031cf:	6a 0b                	push   $0xb
801031d1:	e8 52 ff ff ff       	call   80103128 <cmos_read>
801031d6:	83 c4 04             	add    $0x4,%esp
801031d9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031df:	83 e0 04             	and    $0x4,%eax
801031e2:	85 c0                	test   %eax,%eax
801031e4:	0f 94 c0             	sete   %al
801031e7:	0f b6 c0             	movzbl %al,%eax
801031ea:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031ed:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f0:	50                   	push   %eax
801031f1:	e8 62 ff ff ff       	call   80103158 <fill_rtcdate>
801031f6:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031f9:	6a 0a                	push   $0xa
801031fb:	e8 28 ff ff ff       	call   80103128 <cmos_read>
80103200:	83 c4 04             	add    $0x4,%esp
80103203:	25 80 00 00 00       	and    $0x80,%eax
80103208:	85 c0                	test   %eax,%eax
8010320a:	75 27                	jne    80103233 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010320c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010320f:	50                   	push   %eax
80103210:	e8 43 ff ff ff       	call   80103158 <fill_rtcdate>
80103215:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103218:	83 ec 04             	sub    $0x4,%esp
8010321b:	6a 18                	push   $0x18
8010321d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103220:	50                   	push   %eax
80103221:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103224:	50                   	push   %eax
80103225:	e8 0a 25 00 00       	call   80105734 <memcmp>
8010322a:	83 c4 10             	add    $0x10,%esp
8010322d:	85 c0                	test   %eax,%eax
8010322f:	74 05                	je     80103236 <cmostime+0x6d>
80103231:	eb ba                	jmp    801031ed <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103233:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103234:	eb b7                	jmp    801031ed <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103236:	90                   	nop
  }

  // convert
  if (bcd) {
80103237:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010323b:	0f 84 b4 00 00 00    	je     801032f5 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103241:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103244:	c1 e8 04             	shr    $0x4,%eax
80103247:	89 c2                	mov    %eax,%edx
80103249:	89 d0                	mov    %edx,%eax
8010324b:	c1 e0 02             	shl    $0x2,%eax
8010324e:	01 d0                	add    %edx,%eax
80103250:	01 c0                	add    %eax,%eax
80103252:	89 c2                	mov    %eax,%edx
80103254:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103257:	83 e0 0f             	and    $0xf,%eax
8010325a:	01 d0                	add    %edx,%eax
8010325c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010325f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103262:	c1 e8 04             	shr    $0x4,%eax
80103265:	89 c2                	mov    %eax,%edx
80103267:	89 d0                	mov    %edx,%eax
80103269:	c1 e0 02             	shl    $0x2,%eax
8010326c:	01 d0                	add    %edx,%eax
8010326e:	01 c0                	add    %eax,%eax
80103270:	89 c2                	mov    %eax,%edx
80103272:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103275:	83 e0 0f             	and    $0xf,%eax
80103278:	01 d0                	add    %edx,%eax
8010327a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010327d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103280:	c1 e8 04             	shr    $0x4,%eax
80103283:	89 c2                	mov    %eax,%edx
80103285:	89 d0                	mov    %edx,%eax
80103287:	c1 e0 02             	shl    $0x2,%eax
8010328a:	01 d0                	add    %edx,%eax
8010328c:	01 c0                	add    %eax,%eax
8010328e:	89 c2                	mov    %eax,%edx
80103290:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103293:	83 e0 0f             	and    $0xf,%eax
80103296:	01 d0                	add    %edx,%eax
80103298:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010329b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010329e:	c1 e8 04             	shr    $0x4,%eax
801032a1:	89 c2                	mov    %eax,%edx
801032a3:	89 d0                	mov    %edx,%eax
801032a5:	c1 e0 02             	shl    $0x2,%eax
801032a8:	01 d0                	add    %edx,%eax
801032aa:	01 c0                	add    %eax,%eax
801032ac:	89 c2                	mov    %eax,%edx
801032ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b1:	83 e0 0f             	and    $0xf,%eax
801032b4:	01 d0                	add    %edx,%eax
801032b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032bc:	c1 e8 04             	shr    $0x4,%eax
801032bf:	89 c2                	mov    %eax,%edx
801032c1:	89 d0                	mov    %edx,%eax
801032c3:	c1 e0 02             	shl    $0x2,%eax
801032c6:	01 d0                	add    %edx,%eax
801032c8:	01 c0                	add    %eax,%eax
801032ca:	89 c2                	mov    %eax,%edx
801032cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032cf:	83 e0 0f             	and    $0xf,%eax
801032d2:	01 d0                	add    %edx,%eax
801032d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032da:	c1 e8 04             	shr    $0x4,%eax
801032dd:	89 c2                	mov    %eax,%edx
801032df:	89 d0                	mov    %edx,%eax
801032e1:	c1 e0 02             	shl    $0x2,%eax
801032e4:	01 d0                	add    %edx,%eax
801032e6:	01 c0                	add    %eax,%eax
801032e8:	89 c2                	mov    %eax,%edx
801032ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ed:	83 e0 0f             	and    $0xf,%eax
801032f0:	01 d0                	add    %edx,%eax
801032f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032f5:	8b 45 08             	mov    0x8(%ebp),%eax
801032f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032fb:	89 10                	mov    %edx,(%eax)
801032fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103300:	89 50 04             	mov    %edx,0x4(%eax)
80103303:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103306:	89 50 08             	mov    %edx,0x8(%eax)
80103309:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010330c:	89 50 0c             	mov    %edx,0xc(%eax)
8010330f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103312:	89 50 10             	mov    %edx,0x10(%eax)
80103315:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103318:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010331b:	8b 45 08             	mov    0x8(%ebp),%eax
8010331e:	8b 40 14             	mov    0x14(%eax),%eax
80103321:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103327:	8b 45 08             	mov    0x8(%ebp),%eax
8010332a:	89 50 14             	mov    %edx,0x14(%eax)
}
8010332d:	90                   	nop
8010332e:	c9                   	leave  
8010332f:	c3                   	ret    

80103330 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103330:	55                   	push   %ebp
80103331:	89 e5                	mov    %esp,%ebp
80103333:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103336:	83 ec 08             	sub    $0x8,%esp
80103339:	68 0c 8c 10 80       	push   $0x80108c0c
8010333e:	68 60 32 11 80       	push   $0x80113260
80103343:	e8 00 21 00 00       	call   80105448 <initlock>
80103348:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010334b:	83 ec 08             	sub    $0x8,%esp
8010334e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103351:	50                   	push   %eax
80103352:	ff 75 08             	pushl  0x8(%ebp)
80103355:	e8 2b e0 ff ff       	call   80101385 <readsb>
8010335a:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010335d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103360:	a3 94 32 11 80       	mov    %eax,0x80113294
  log.size = sb.nlog;
80103365:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103368:	a3 98 32 11 80       	mov    %eax,0x80113298
  log.dev = dev;
8010336d:	8b 45 08             	mov    0x8(%ebp),%eax
80103370:	a3 a4 32 11 80       	mov    %eax,0x801132a4
  recover_from_log();
80103375:	e8 b2 01 00 00       	call   8010352c <recover_from_log>
}
8010337a:	90                   	nop
8010337b:	c9                   	leave  
8010337c:	c3                   	ret    

8010337d <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010337d:	55                   	push   %ebp
8010337e:	89 e5                	mov    %esp,%ebp
80103380:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103383:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010338a:	e9 95 00 00 00       	jmp    80103424 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010338f:	8b 15 94 32 11 80    	mov    0x80113294,%edx
80103395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103398:	01 d0                	add    %edx,%eax
8010339a:	83 c0 01             	add    $0x1,%eax
8010339d:	89 c2                	mov    %eax,%edx
8010339f:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801033a4:	83 ec 08             	sub    $0x8,%esp
801033a7:	52                   	push   %edx
801033a8:	50                   	push   %eax
801033a9:	e8 08 ce ff ff       	call   801001b6 <bread>
801033ae:	83 c4 10             	add    $0x10,%esp
801033b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b7:	83 c0 10             	add    $0x10,%eax
801033ba:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
801033c1:	89 c2                	mov    %eax,%edx
801033c3:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801033c8:	83 ec 08             	sub    $0x8,%esp
801033cb:	52                   	push   %edx
801033cc:	50                   	push   %eax
801033cd:	e8 e4 cd ff ff       	call   801001b6 <bread>
801033d2:	83 c4 10             	add    $0x10,%esp
801033d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033db:	8d 50 18             	lea    0x18(%eax),%edx
801033de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e1:	83 c0 18             	add    $0x18,%eax
801033e4:	83 ec 04             	sub    $0x4,%esp
801033e7:	68 00 02 00 00       	push   $0x200
801033ec:	52                   	push   %edx
801033ed:	50                   	push   %eax
801033ee:	e8 99 23 00 00       	call   8010578c <memmove>
801033f3:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	ff 75 ec             	pushl  -0x14(%ebp)
801033fc:	e8 ee cd ff ff       	call   801001ef <bwrite>
80103401:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103404:	83 ec 0c             	sub    $0xc,%esp
80103407:	ff 75 f0             	pushl  -0x10(%ebp)
8010340a:	e8 1f ce ff ff       	call   8010022e <brelse>
8010340f:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103412:	83 ec 0c             	sub    $0xc,%esp
80103415:	ff 75 ec             	pushl  -0x14(%ebp)
80103418:	e8 11 ce ff ff       	call   8010022e <brelse>
8010341d:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103420:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103424:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103429:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342c:	0f 8f 5d ff ff ff    	jg     8010338f <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103432:	90                   	nop
80103433:	c9                   	leave  
80103434:	c3                   	ret    

80103435 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103435:	55                   	push   %ebp
80103436:	89 e5                	mov    %esp,%ebp
80103438:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010343b:	a1 94 32 11 80       	mov    0x80113294,%eax
80103440:	89 c2                	mov    %eax,%edx
80103442:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103447:	83 ec 08             	sub    $0x8,%esp
8010344a:	52                   	push   %edx
8010344b:	50                   	push   %eax
8010344c:	e8 65 cd ff ff       	call   801001b6 <bread>
80103451:	83 c4 10             	add    $0x10,%esp
80103454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010345a:	83 c0 18             	add    $0x18,%eax
8010345d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103463:	8b 00                	mov    (%eax),%eax
80103465:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  for (i = 0; i < log.lh.n; i++) {
8010346a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103471:	eb 1b                	jmp    8010348e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103473:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103479:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010347d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103480:	83 c2 10             	add    $0x10,%edx
80103483:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010348a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010348e:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103493:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103496:	7f db                	jg     80103473 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103498:	83 ec 0c             	sub    $0xc,%esp
8010349b:	ff 75 f0             	pushl  -0x10(%ebp)
8010349e:	e8 8b cd ff ff       	call   8010022e <brelse>
801034a3:	83 c4 10             	add    $0x10,%esp
}
801034a6:	90                   	nop
801034a7:	c9                   	leave  
801034a8:	c3                   	ret    

801034a9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034a9:	55                   	push   %ebp
801034aa:	89 e5                	mov    %esp,%ebp
801034ac:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034af:	a1 94 32 11 80       	mov    0x80113294,%eax
801034b4:	89 c2                	mov    %eax,%edx
801034b6:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801034bb:	83 ec 08             	sub    $0x8,%esp
801034be:	52                   	push   %edx
801034bf:	50                   	push   %eax
801034c0:	e8 f1 cc ff ff       	call   801001b6 <bread>
801034c5:	83 c4 10             	add    $0x10,%esp
801034c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	83 c0 18             	add    $0x18,%eax
801034d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034d4:	8b 15 a8 32 11 80    	mov    0x801132a8,%edx
801034da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e6:	eb 1b                	jmp    80103503 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034eb:	83 c0 10             	add    $0x10,%eax
801034ee:	8b 0c 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%ecx
801034f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103503:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103508:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010350b:	7f db                	jg     801034e8 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010350d:	83 ec 0c             	sub    $0xc,%esp
80103510:	ff 75 f0             	pushl  -0x10(%ebp)
80103513:	e8 d7 cc ff ff       	call   801001ef <bwrite>
80103518:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010351b:	83 ec 0c             	sub    $0xc,%esp
8010351e:	ff 75 f0             	pushl  -0x10(%ebp)
80103521:	e8 08 cd ff ff       	call   8010022e <brelse>
80103526:	83 c4 10             	add    $0x10,%esp
}
80103529:	90                   	nop
8010352a:	c9                   	leave  
8010352b:	c3                   	ret    

8010352c <recover_from_log>:

static void
recover_from_log(void)
{
8010352c:	55                   	push   %ebp
8010352d:	89 e5                	mov    %esp,%ebp
8010352f:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103532:	e8 fe fe ff ff       	call   80103435 <read_head>
  install_trans(); // if committed, copy from log to disk
80103537:	e8 41 fe ff ff       	call   8010337d <install_trans>
  log.lh.n = 0;
8010353c:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
80103543:	00 00 00 
  write_head(); // clear the log
80103546:	e8 5e ff ff ff       	call   801034a9 <write_head>
}
8010354b:	90                   	nop
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103554:	83 ec 0c             	sub    $0xc,%esp
80103557:	68 60 32 11 80       	push   $0x80113260
8010355c:	e8 09 1f 00 00       	call   8010546a <acquire>
80103561:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103564:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103569:	85 c0                	test   %eax,%eax
8010356b:	74 17                	je     80103584 <begin_op+0x36>
      sleep(&log, &log.lock);
8010356d:	83 ec 08             	sub    $0x8,%esp
80103570:	68 60 32 11 80       	push   $0x80113260
80103575:	68 60 32 11 80       	push   $0x80113260
8010357a:	e8 80 1a 00 00       	call   80104fff <sleep>
8010357f:	83 c4 10             	add    $0x10,%esp
80103582:	eb e0                	jmp    80103564 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103584:	8b 0d a8 32 11 80    	mov    0x801132a8,%ecx
8010358a:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010358f:	8d 50 01             	lea    0x1(%eax),%edx
80103592:	89 d0                	mov    %edx,%eax
80103594:	c1 e0 02             	shl    $0x2,%eax
80103597:	01 d0                	add    %edx,%eax
80103599:	01 c0                	add    %eax,%eax
8010359b:	01 c8                	add    %ecx,%eax
8010359d:	83 f8 1e             	cmp    $0x1e,%eax
801035a0:	7e 17                	jle    801035b9 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	68 60 32 11 80       	push   $0x80113260
801035aa:	68 60 32 11 80       	push   $0x80113260
801035af:	e8 4b 1a 00 00       	call   80104fff <sleep>
801035b4:	83 c4 10             	add    $0x10,%esp
801035b7:	eb ab                	jmp    80103564 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035b9:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801035be:	83 c0 01             	add    $0x1,%eax
801035c1:	a3 9c 32 11 80       	mov    %eax,0x8011329c
      release(&log.lock);
801035c6:	83 ec 0c             	sub    $0xc,%esp
801035c9:	68 60 32 11 80       	push   $0x80113260
801035ce:	e8 fe 1e 00 00       	call   801054d1 <release>
801035d3:	83 c4 10             	add    $0x10,%esp
      break;
801035d6:	90                   	nop
    }
  }
}
801035d7:	90                   	nop
801035d8:	c9                   	leave  
801035d9:	c3                   	ret    

801035da <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035da:	55                   	push   %ebp
801035db:	89 e5                	mov    %esp,%ebp
801035dd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035e7:	83 ec 0c             	sub    $0xc,%esp
801035ea:	68 60 32 11 80       	push   $0x80113260
801035ef:	e8 76 1e 00 00       	call   8010546a <acquire>
801035f4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035f7:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801035fc:	83 e8 01             	sub    $0x1,%eax
801035ff:	a3 9c 32 11 80       	mov    %eax,0x8011329c
  if(log.committing)
80103604:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103609:	85 c0                	test   %eax,%eax
8010360b:	74 0d                	je     8010361a <end_op+0x40>
    panic("log.committing");
8010360d:	83 ec 0c             	sub    $0xc,%esp
80103610:	68 10 8c 10 80       	push   $0x80108c10
80103615:	e8 4c cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
8010361a:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010361f:	85 c0                	test   %eax,%eax
80103621:	75 13                	jne    80103636 <end_op+0x5c>
    do_commit = 1;
80103623:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010362a:	c7 05 a0 32 11 80 01 	movl   $0x1,0x801132a0
80103631:	00 00 00 
80103634:	eb 10                	jmp    80103646 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103636:	83 ec 0c             	sub    $0xc,%esp
80103639:	68 60 32 11 80       	push   $0x80113260
8010363e:	e8 aa 1a 00 00       	call   801050ed <wakeup>
80103643:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103646:	83 ec 0c             	sub    $0xc,%esp
80103649:	68 60 32 11 80       	push   $0x80113260
8010364e:	e8 7e 1e 00 00       	call   801054d1 <release>
80103653:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103656:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010365a:	74 3f                	je     8010369b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010365c:	e8 f5 00 00 00       	call   80103756 <commit>
    acquire(&log.lock);
80103661:	83 ec 0c             	sub    $0xc,%esp
80103664:	68 60 32 11 80       	push   $0x80113260
80103669:	e8 fc 1d 00 00       	call   8010546a <acquire>
8010366e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103671:	c7 05 a0 32 11 80 00 	movl   $0x0,0x801132a0
80103678:	00 00 00 
    wakeup(&log);
8010367b:	83 ec 0c             	sub    $0xc,%esp
8010367e:	68 60 32 11 80       	push   $0x80113260
80103683:	e8 65 1a 00 00       	call   801050ed <wakeup>
80103688:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010368b:	83 ec 0c             	sub    $0xc,%esp
8010368e:	68 60 32 11 80       	push   $0x80113260
80103693:	e8 39 1e 00 00       	call   801054d1 <release>
80103698:	83 c4 10             	add    $0x10,%esp
  }
}
8010369b:	90                   	nop
8010369c:	c9                   	leave  
8010369d:	c3                   	ret    

8010369e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010369e:	55                   	push   %ebp
8010369f:	89 e5                	mov    %esp,%ebp
801036a1:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036ab:	e9 95 00 00 00       	jmp    80103745 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036b0:	8b 15 94 32 11 80    	mov    0x80113294,%edx
801036b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b9:	01 d0                	add    %edx,%eax
801036bb:	83 c0 01             	add    $0x1,%eax
801036be:	89 c2                	mov    %eax,%edx
801036c0:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801036c5:	83 ec 08             	sub    $0x8,%esp
801036c8:	52                   	push   %edx
801036c9:	50                   	push   %eax
801036ca:	e8 e7 ca ff ff       	call   801001b6 <bread>
801036cf:	83 c4 10             	add    $0x10,%esp
801036d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d8:	83 c0 10             	add    $0x10,%eax
801036db:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
801036e2:	89 c2                	mov    %eax,%edx
801036e4:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801036e9:	83 ec 08             	sub    $0x8,%esp
801036ec:	52                   	push   %edx
801036ed:	50                   	push   %eax
801036ee:	e8 c3 ca ff ff       	call   801001b6 <bread>
801036f3:	83 c4 10             	add    $0x10,%esp
801036f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fc:	8d 50 18             	lea    0x18(%eax),%edx
801036ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103702:	83 c0 18             	add    $0x18,%eax
80103705:	83 ec 04             	sub    $0x4,%esp
80103708:	68 00 02 00 00       	push   $0x200
8010370d:	52                   	push   %edx
8010370e:	50                   	push   %eax
8010370f:	e8 78 20 00 00       	call   8010578c <memmove>
80103714:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	ff 75 f0             	pushl  -0x10(%ebp)
8010371d:	e8 cd ca ff ff       	call   801001ef <bwrite>
80103722:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103725:	83 ec 0c             	sub    $0xc,%esp
80103728:	ff 75 ec             	pushl  -0x14(%ebp)
8010372b:	e8 fe ca ff ff       	call   8010022e <brelse>
80103730:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103733:	83 ec 0c             	sub    $0xc,%esp
80103736:	ff 75 f0             	pushl  -0x10(%ebp)
80103739:	e8 f0 ca ff ff       	call   8010022e <brelse>
8010373e:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103741:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103745:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010374a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010374d:	0f 8f 5d ff ff ff    	jg     801036b0 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103753:	90                   	nop
80103754:	c9                   	leave  
80103755:	c3                   	ret    

80103756 <commit>:

static void
commit()
{
80103756:	55                   	push   %ebp
80103757:	89 e5                	mov    %esp,%ebp
80103759:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010375c:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103761:	85 c0                	test   %eax,%eax
80103763:	7e 1e                	jle    80103783 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103765:	e8 34 ff ff ff       	call   8010369e <write_log>
    write_head();    // Write header to disk -- the real commit
8010376a:	e8 3a fd ff ff       	call   801034a9 <write_head>
    install_trans(); // Now install writes to home locations
8010376f:	e8 09 fc ff ff       	call   8010337d <install_trans>
    log.lh.n = 0; 
80103774:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
8010377b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010377e:	e8 26 fd ff ff       	call   801034a9 <write_head>
  }
}
80103783:	90                   	nop
80103784:	c9                   	leave  
80103785:	c3                   	ret    

80103786 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103786:	55                   	push   %ebp
80103787:	89 e5                	mov    %esp,%ebp
80103789:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010378c:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103791:	83 f8 1d             	cmp    $0x1d,%eax
80103794:	7f 12                	jg     801037a8 <log_write+0x22>
80103796:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010379b:	8b 15 98 32 11 80    	mov    0x80113298,%edx
801037a1:	83 ea 01             	sub    $0x1,%edx
801037a4:	39 d0                	cmp    %edx,%eax
801037a6:	7c 0d                	jl     801037b5 <log_write+0x2f>
    panic("too big a transaction");
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	68 1f 8c 10 80       	push   $0x80108c1f
801037b0:	e8 b1 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
801037b5:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801037ba:	85 c0                	test   %eax,%eax
801037bc:	7f 0d                	jg     801037cb <log_write+0x45>
    panic("log_write outside of trans");
801037be:	83 ec 0c             	sub    $0xc,%esp
801037c1:	68 35 8c 10 80       	push   $0x80108c35
801037c6:	e8 9b cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801037cb:	83 ec 0c             	sub    $0xc,%esp
801037ce:	68 60 32 11 80       	push   $0x80113260
801037d3:	e8 92 1c 00 00       	call   8010546a <acquire>
801037d8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037e2:	eb 1d                	jmp    80103801 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e7:	83 c0 10             	add    $0x10,%eax
801037ea:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
801037f1:	89 c2                	mov    %eax,%edx
801037f3:	8b 45 08             	mov    0x8(%ebp),%eax
801037f6:	8b 40 08             	mov    0x8(%eax),%eax
801037f9:	39 c2                	cmp    %eax,%edx
801037fb:	74 10                	je     8010380d <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103801:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103806:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103809:	7f d9                	jg     801037e4 <log_write+0x5e>
8010380b:	eb 01                	jmp    8010380e <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
8010380d:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010380e:	8b 45 08             	mov    0x8(%ebp),%eax
80103811:	8b 40 08             	mov    0x8(%eax),%eax
80103814:	89 c2                	mov    %eax,%edx
80103816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103819:	83 c0 10             	add    $0x10,%eax
8010381c:	89 14 85 6c 32 11 80 	mov    %edx,-0x7feecd94(,%eax,4)
  if (i == log.lh.n)
80103823:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103828:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010382b:	75 0d                	jne    8010383a <log_write+0xb4>
    log.lh.n++;
8010382d:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103832:	83 c0 01             	add    $0x1,%eax
80103835:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  b->flags |= B_DIRTY; // prevent eviction
8010383a:	8b 45 08             	mov    0x8(%ebp),%eax
8010383d:	8b 00                	mov    (%eax),%eax
8010383f:	83 c8 04             	or     $0x4,%eax
80103842:	89 c2                	mov    %eax,%edx
80103844:	8b 45 08             	mov    0x8(%ebp),%eax
80103847:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	68 60 32 11 80       	push   $0x80113260
80103851:	e8 7b 1c 00 00       	call   801054d1 <release>
80103856:	83 c4 10             	add    $0x10,%esp
}
80103859:	90                   	nop
8010385a:	c9                   	leave  
8010385b:	c3                   	ret    

8010385c <v2p>:
8010385c:	55                   	push   %ebp
8010385d:	89 e5                	mov    %esp,%ebp
8010385f:	8b 45 08             	mov    0x8(%ebp),%eax
80103862:	05 00 00 00 80       	add    $0x80000000,%eax
80103867:	5d                   	pop    %ebp
80103868:	c3                   	ret    

80103869 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103869:	55                   	push   %ebp
8010386a:	89 e5                	mov    %esp,%ebp
8010386c:	8b 45 08             	mov    0x8(%ebp),%eax
8010386f:	05 00 00 00 80       	add    $0x80000000,%eax
80103874:	5d                   	pop    %ebp
80103875:	c3                   	ret    

80103876 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103876:	55                   	push   %ebp
80103877:	89 e5                	mov    %esp,%ebp
80103879:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010387c:	8b 55 08             	mov    0x8(%ebp),%edx
8010387f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103882:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103885:	f0 87 02             	lock xchg %eax,(%edx)
80103888:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010388b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010388e:	c9                   	leave  
8010388f:	c3                   	ret    

80103890 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103890:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103894:	83 e4 f0             	and    $0xfffffff0,%esp
80103897:	ff 71 fc             	pushl  -0x4(%ecx)
8010389a:	55                   	push   %ebp
8010389b:	89 e5                	mov    %esp,%ebp
8010389d:	51                   	push   %ecx
8010389e:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038a1:	83 ec 08             	sub    $0x8,%esp
801038a4:	68 00 00 40 80       	push   $0x80400000
801038a9:	68 3c 63 11 80       	push   $0x8011633c
801038ae:	e8 7d f2 ff ff       	call   80102b30 <kinit1>
801038b3:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038b6:	e8 65 49 00 00       	call   80108220 <kvmalloc>
  mpinit();        // collect info about this machine
801038bb:	e8 43 04 00 00       	call   80103d03 <mpinit>
  lapicinit();
801038c0:	e8 ea f5 ff ff       	call   80102eaf <lapicinit>
  seginit();       // set up segments
801038c5:	e8 ff 42 00 00       	call   80107bc9 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038d0:	0f b6 00             	movzbl (%eax),%eax
801038d3:	0f b6 c0             	movzbl %al,%eax
801038d6:	83 ec 08             	sub    $0x8,%esp
801038d9:	50                   	push   %eax
801038da:	68 50 8c 10 80       	push   $0x80108c50
801038df:	e8 e2 ca ff ff       	call   801003c6 <cprintf>
801038e4:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038e7:	e8 6d 06 00 00       	call   80103f59 <picinit>
  ioapicinit();    // another interrupt controller
801038ec:	e8 34 f1 ff ff       	call   80102a25 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038f1:	e8 23 d2 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
801038f6:	e8 2a 36 00 00       	call   80106f25 <uartinit>
  pinit();         // process table
801038fb:	e8 56 0b 00 00       	call   80104456 <pinit>
  tvinit();        // trap vectors
80103900:	e8 ea 31 00 00       	call   80106aef <tvinit>
  binit();         // buffer cache
80103905:	e8 2a c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010390a:	e8 67 d6 ff ff       	call   80100f76 <fileinit>
  ideinit();       // disk
8010390f:	e8 19 ed ff ff       	call   8010262d <ideinit>
  if(!ismp)
80103914:	a1 44 33 11 80       	mov    0x80113344,%eax
80103919:	85 c0                	test   %eax,%eax
8010391b:	75 05                	jne    80103922 <main+0x92>
    timerinit();   // uniprocessor timer
8010391d:	e8 2a 31 00 00       	call   80106a4c <timerinit>
  startothers();   // start other processors
80103922:	e8 7f 00 00 00       	call   801039a6 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103927:	83 ec 08             	sub    $0x8,%esp
8010392a:	68 00 00 00 8e       	push   $0x8e000000
8010392f:	68 00 00 40 80       	push   $0x80400000
80103934:	e8 30 f2 ff ff       	call   80102b69 <kinit2>
80103939:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010393c:	e8 5f 0c 00 00       	call   801045a0 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103941:	e8 1a 00 00 00       	call   80103960 <mpmain>

80103946 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103946:	55                   	push   %ebp
80103947:	89 e5                	mov    %esp,%ebp
80103949:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010394c:	e8 e7 48 00 00       	call   80108238 <switchkvm>
  seginit();
80103951:	e8 73 42 00 00       	call   80107bc9 <seginit>
  lapicinit();
80103956:	e8 54 f5 ff ff       	call   80102eaf <lapicinit>
  mpmain();
8010395b:	e8 00 00 00 00       	call   80103960 <mpmain>

80103960 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
80103963:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103966:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396c:	0f b6 00             	movzbl (%eax),%eax
8010396f:	0f b6 c0             	movzbl %al,%eax
80103972:	83 ec 08             	sub    $0x8,%esp
80103975:	50                   	push   %eax
80103976:	68 67 8c 10 80       	push   $0x80108c67
8010397b:	e8 46 ca ff ff       	call   801003c6 <cprintf>
80103980:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103983:	e8 dd 32 00 00       	call   80106c65 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103988:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010398e:	05 a8 00 00 00       	add    $0xa8,%eax
80103993:	83 ec 08             	sub    $0x8,%esp
80103996:	6a 01                	push   $0x1
80103998:	50                   	push   %eax
80103999:	e8 d8 fe ff ff       	call   80103876 <xchg>
8010399e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039a1:	e8 ab 11 00 00       	call   80104b51 <scheduler>

801039a6 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039a6:	55                   	push   %ebp
801039a7:	89 e5                	mov    %esp,%ebp
801039a9:	53                   	push   %ebx
801039aa:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039ad:	68 00 70 00 00       	push   $0x7000
801039b2:	e8 b2 fe ff ff       	call   80103869 <p2v>
801039b7:	83 c4 04             	add    $0x4,%esp
801039ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039bd:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039c2:	83 ec 04             	sub    $0x4,%esp
801039c5:	50                   	push   %eax
801039c6:	68 0c c5 10 80       	push   $0x8010c50c
801039cb:	ff 75 f0             	pushl  -0x10(%ebp)
801039ce:	e8 b9 1d 00 00       	call   8010578c <memmove>
801039d3:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039d6:	c7 45 f4 60 33 11 80 	movl   $0x80113360,-0xc(%ebp)
801039dd:	e9 90 00 00 00       	jmp    80103a72 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039e2:	e8 e6 f5 ff ff       	call   80102fcd <cpunum>
801039e7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039ed:	05 60 33 11 80       	add    $0x80113360,%eax
801039f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f5:	74 73                	je     80103a6a <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039f7:	e8 6b f2 ff ff       	call   80102c67 <kalloc>
801039fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a02:	83 e8 04             	sub    $0x4,%eax
80103a05:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a08:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a0e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a13:	83 e8 08             	sub    $0x8,%eax
80103a16:	c7 00 46 39 10 80    	movl   $0x80103946,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a22:	83 ec 0c             	sub    $0xc,%esp
80103a25:	68 00 b0 10 80       	push   $0x8010b000
80103a2a:	e8 2d fe ff ff       	call   8010385c <v2p>
80103a2f:	83 c4 10             	add    $0x10,%esp
80103a32:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a34:	83 ec 0c             	sub    $0xc,%esp
80103a37:	ff 75 f0             	pushl  -0x10(%ebp)
80103a3a:	e8 1d fe ff ff       	call   8010385c <v2p>
80103a3f:	83 c4 10             	add    $0x10,%esp
80103a42:	89 c2                	mov    %eax,%edx
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	0f b6 00             	movzbl (%eax),%eax
80103a4a:	0f b6 c0             	movzbl %al,%eax
80103a4d:	83 ec 08             	sub    $0x8,%esp
80103a50:	52                   	push   %edx
80103a51:	50                   	push   %eax
80103a52:	e8 f0 f5 ff ff       	call   80103047 <lapicstartap>
80103a57:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a5a:	90                   	nop
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a64:	85 c0                	test   %eax,%eax
80103a66:	74 f3                	je     80103a5b <startothers+0xb5>
80103a68:	eb 01                	jmp    80103a6b <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a6a:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a6b:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a72:	a1 40 39 11 80       	mov    0x80113940,%eax
80103a77:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a7d:	05 60 33 11 80       	add    $0x80113360,%eax
80103a82:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a85:	0f 87 57 ff ff ff    	ja     801039e2 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a8b:	90                   	nop
80103a8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a8f:	c9                   	leave  
80103a90:	c3                   	ret    

80103a91 <p2v>:
80103a91:	55                   	push   %ebp
80103a92:	89 e5                	mov    %esp,%ebp
80103a94:	8b 45 08             	mov    0x8(%ebp),%eax
80103a97:	05 00 00 00 80       	add    $0x80000000,%eax
80103a9c:	5d                   	pop    %ebp
80103a9d:	c3                   	ret    

80103a9e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a9e:	55                   	push   %ebp
80103a9f:	89 e5                	mov    %esp,%ebp
80103aa1:	83 ec 14             	sub    $0x14,%esp
80103aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aab:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103aaf:	89 c2                	mov    %eax,%edx
80103ab1:	ec                   	in     (%dx),%al
80103ab2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ab5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ab9:	c9                   	leave  
80103aba:	c3                   	ret    

80103abb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103abb:	55                   	push   %ebp
80103abc:	89 e5                	mov    %esp,%ebp
80103abe:	83 ec 08             	sub    $0x8,%esp
80103ac1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ac7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103acb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ace:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ad6:	ee                   	out    %al,(%dx)
}
80103ad7:	90                   	nop
80103ad8:	c9                   	leave  
80103ad9:	c3                   	ret    

80103ada <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ada:	55                   	push   %ebp
80103adb:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103add:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80103ae2:	89 c2                	mov    %eax,%edx
80103ae4:	b8 60 33 11 80       	mov    $0x80113360,%eax
80103ae9:	29 c2                	sub    %eax,%edx
80103aeb:	89 d0                	mov    %edx,%eax
80103aed:	c1 f8 02             	sar    $0x2,%eax
80103af0:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103af6:	5d                   	pop    %ebp
80103af7:	c3                   	ret    

80103af8 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103af8:	55                   	push   %ebp
80103af9:	89 e5                	mov    %esp,%ebp
80103afb:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103afe:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b05:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b0c:	eb 15                	jmp    80103b23 <sum+0x2b>
    sum += addr[i];
80103b0e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b11:	8b 45 08             	mov    0x8(%ebp),%eax
80103b14:	01 d0                	add    %edx,%eax
80103b16:	0f b6 00             	movzbl (%eax),%eax
80103b19:	0f b6 c0             	movzbl %al,%eax
80103b1c:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b1f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b26:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b29:	7c e3                	jl     80103b0e <sum+0x16>
    sum += addr[i];
  return sum;
80103b2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b2e:	c9                   	leave  
80103b2f:	c3                   	ret    

80103b30 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b30:	55                   	push   %ebp
80103b31:	89 e5                	mov    %esp,%ebp
80103b33:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b36:	ff 75 08             	pushl  0x8(%ebp)
80103b39:	e8 53 ff ff ff       	call   80103a91 <p2v>
80103b3e:	83 c4 04             	add    $0x4,%esp
80103b41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b44:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4a:	01 d0                	add    %edx,%eax
80103b4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b55:	eb 36                	jmp    80103b8d <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b57:	83 ec 04             	sub    $0x4,%esp
80103b5a:	6a 04                	push   $0x4
80103b5c:	68 78 8c 10 80       	push   $0x80108c78
80103b61:	ff 75 f4             	pushl  -0xc(%ebp)
80103b64:	e8 cb 1b 00 00       	call   80105734 <memcmp>
80103b69:	83 c4 10             	add    $0x10,%esp
80103b6c:	85 c0                	test   %eax,%eax
80103b6e:	75 19                	jne    80103b89 <mpsearch1+0x59>
80103b70:	83 ec 08             	sub    $0x8,%esp
80103b73:	6a 10                	push   $0x10
80103b75:	ff 75 f4             	pushl  -0xc(%ebp)
80103b78:	e8 7b ff ff ff       	call   80103af8 <sum>
80103b7d:	83 c4 10             	add    $0x10,%esp
80103b80:	84 c0                	test   %al,%al
80103b82:	75 05                	jne    80103b89 <mpsearch1+0x59>
      return (struct mp*)p;
80103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b87:	eb 11                	jmp    80103b9a <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b89:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b90:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b93:	72 c2                	jb     80103b57 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b9a:	c9                   	leave  
80103b9b:	c3                   	ret    

80103b9c <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b9c:	55                   	push   %ebp
80103b9d:	89 e5                	mov    %esp,%ebp
80103b9f:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ba2:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bac:	83 c0 0f             	add    $0xf,%eax
80103baf:	0f b6 00             	movzbl (%eax),%eax
80103bb2:	0f b6 c0             	movzbl %al,%eax
80103bb5:	c1 e0 08             	shl    $0x8,%eax
80103bb8:	89 c2                	mov    %eax,%edx
80103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbd:	83 c0 0e             	add    $0xe,%eax
80103bc0:	0f b6 00             	movzbl (%eax),%eax
80103bc3:	0f b6 c0             	movzbl %al,%eax
80103bc6:	09 d0                	or     %edx,%eax
80103bc8:	c1 e0 04             	shl    $0x4,%eax
80103bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bd2:	74 21                	je     80103bf5 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bd4:	83 ec 08             	sub    $0x8,%esp
80103bd7:	68 00 04 00 00       	push   $0x400
80103bdc:	ff 75 f0             	pushl  -0x10(%ebp)
80103bdf:	e8 4c ff ff ff       	call   80103b30 <mpsearch1>
80103be4:	83 c4 10             	add    $0x10,%esp
80103be7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bee:	74 51                	je     80103c41 <mpsearch+0xa5>
      return mp;
80103bf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf3:	eb 61                	jmp    80103c56 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf8:	83 c0 14             	add    $0x14,%eax
80103bfb:	0f b6 00             	movzbl (%eax),%eax
80103bfe:	0f b6 c0             	movzbl %al,%eax
80103c01:	c1 e0 08             	shl    $0x8,%eax
80103c04:	89 c2                	mov    %eax,%edx
80103c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c09:	83 c0 13             	add    $0x13,%eax
80103c0c:	0f b6 00             	movzbl (%eax),%eax
80103c0f:	0f b6 c0             	movzbl %al,%eax
80103c12:	09 d0                	or     %edx,%eax
80103c14:	c1 e0 0a             	shl    $0xa,%eax
80103c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1d:	2d 00 04 00 00       	sub    $0x400,%eax
80103c22:	83 ec 08             	sub    $0x8,%esp
80103c25:	68 00 04 00 00       	push   $0x400
80103c2a:	50                   	push   %eax
80103c2b:	e8 00 ff ff ff       	call   80103b30 <mpsearch1>
80103c30:	83 c4 10             	add    $0x10,%esp
80103c33:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c3a:	74 05                	je     80103c41 <mpsearch+0xa5>
      return mp;
80103c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3f:	eb 15                	jmp    80103c56 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c41:	83 ec 08             	sub    $0x8,%esp
80103c44:	68 00 00 01 00       	push   $0x10000
80103c49:	68 00 00 0f 00       	push   $0xf0000
80103c4e:	e8 dd fe ff ff       	call   80103b30 <mpsearch1>
80103c53:	83 c4 10             	add    $0x10,%esp
}
80103c56:	c9                   	leave  
80103c57:	c3                   	ret    

80103c58 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c58:	55                   	push   %ebp
80103c59:	89 e5                	mov    %esp,%ebp
80103c5b:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c5e:	e8 39 ff ff ff       	call   80103b9c <mpsearch>
80103c63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c6a:	74 0a                	je     80103c76 <mpconfig+0x1e>
80103c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6f:	8b 40 04             	mov    0x4(%eax),%eax
80103c72:	85 c0                	test   %eax,%eax
80103c74:	75 0a                	jne    80103c80 <mpconfig+0x28>
    return 0;
80103c76:	b8 00 00 00 00       	mov    $0x0,%eax
80103c7b:	e9 81 00 00 00       	jmp    80103d01 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c83:	8b 40 04             	mov    0x4(%eax),%eax
80103c86:	83 ec 0c             	sub    $0xc,%esp
80103c89:	50                   	push   %eax
80103c8a:	e8 02 fe ff ff       	call   80103a91 <p2v>
80103c8f:	83 c4 10             	add    $0x10,%esp
80103c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c95:	83 ec 04             	sub    $0x4,%esp
80103c98:	6a 04                	push   $0x4
80103c9a:	68 7d 8c 10 80       	push   $0x80108c7d
80103c9f:	ff 75 f0             	pushl  -0x10(%ebp)
80103ca2:	e8 8d 1a 00 00       	call   80105734 <memcmp>
80103ca7:	83 c4 10             	add    $0x10,%esp
80103caa:	85 c0                	test   %eax,%eax
80103cac:	74 07                	je     80103cb5 <mpconfig+0x5d>
    return 0;
80103cae:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb3:	eb 4c                	jmp    80103d01 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb8:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cbc:	3c 01                	cmp    $0x1,%al
80103cbe:	74 12                	je     80103cd2 <mpconfig+0x7a>
80103cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc3:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cc7:	3c 04                	cmp    $0x4,%al
80103cc9:	74 07                	je     80103cd2 <mpconfig+0x7a>
    return 0;
80103ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd0:	eb 2f                	jmp    80103d01 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd9:	0f b7 c0             	movzwl %ax,%eax
80103cdc:	83 ec 08             	sub    $0x8,%esp
80103cdf:	50                   	push   %eax
80103ce0:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce3:	e8 10 fe ff ff       	call   80103af8 <sum>
80103ce8:	83 c4 10             	add    $0x10,%esp
80103ceb:	84 c0                	test   %al,%al
80103ced:	74 07                	je     80103cf6 <mpconfig+0x9e>
    return 0;
80103cef:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf4:	eb 0b                	jmp    80103d01 <mpconfig+0xa9>
  *pmp = mp;
80103cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfc:	89 10                	mov    %edx,(%eax)
  return conf;
80103cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d01:	c9                   	leave  
80103d02:	c3                   	ret    

80103d03 <mpinit>:

void
mpinit(void)
{
80103d03:	55                   	push   %ebp
80103d04:	89 e5                	mov    %esp,%ebp
80103d06:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d09:	c7 05 44 c6 10 80 60 	movl   $0x80113360,0x8010c644
80103d10:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d13:	83 ec 0c             	sub    $0xc,%esp
80103d16:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d19:	50                   	push   %eax
80103d1a:	e8 39 ff ff ff       	call   80103c58 <mpconfig>
80103d1f:	83 c4 10             	add    $0x10,%esp
80103d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d29:	0f 84 96 01 00 00    	je     80103ec5 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d2f:	c7 05 44 33 11 80 01 	movl   $0x1,0x80113344
80103d36:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3c:	8b 40 24             	mov    0x24(%eax),%eax
80103d3f:	a3 5c 32 11 80       	mov    %eax,0x8011325c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d47:	83 c0 2c             	add    $0x2c,%eax
80103d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d50:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d54:	0f b7 d0             	movzwl %ax,%edx
80103d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5a:	01 d0                	add    %edx,%eax
80103d5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5f:	e9 f2 00 00 00       	jmp    80103e56 <mpinit+0x153>
    switch(*p){
80103d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d67:	0f b6 00             	movzbl (%eax),%eax
80103d6a:	0f b6 c0             	movzbl %al,%eax
80103d6d:	83 f8 04             	cmp    $0x4,%eax
80103d70:	0f 87 bc 00 00 00    	ja     80103e32 <mpinit+0x12f>
80103d76:	8b 04 85 c0 8c 10 80 	mov    -0x7fef7340(,%eax,4),%eax
80103d7d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d82:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d88:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d8c:	0f b6 d0             	movzbl %al,%edx
80103d8f:	a1 40 39 11 80       	mov    0x80113940,%eax
80103d94:	39 c2                	cmp    %eax,%edx
80103d96:	74 2b                	je     80103dc3 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d9b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d9f:	0f b6 d0             	movzbl %al,%edx
80103da2:	a1 40 39 11 80       	mov    0x80113940,%eax
80103da7:	83 ec 04             	sub    $0x4,%esp
80103daa:	52                   	push   %edx
80103dab:	50                   	push   %eax
80103dac:	68 82 8c 10 80       	push   $0x80108c82
80103db1:	e8 10 c6 ff ff       	call   801003c6 <cprintf>
80103db6:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103db9:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103dc0:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dc6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dca:	0f b6 c0             	movzbl %al,%eax
80103dcd:	83 e0 02             	and    $0x2,%eax
80103dd0:	85 c0                	test   %eax,%eax
80103dd2:	74 15                	je     80103de9 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103dd4:	a1 40 39 11 80       	mov    0x80113940,%eax
80103dd9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ddf:	05 60 33 11 80       	add    $0x80113360,%eax
80103de4:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103de9:	a1 40 39 11 80       	mov    0x80113940,%eax
80103dee:	8b 15 40 39 11 80    	mov    0x80113940,%edx
80103df4:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dfa:	05 60 33 11 80       	add    $0x80113360,%eax
80103dff:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e01:	a1 40 39 11 80       	mov    0x80113940,%eax
80103e06:	83 c0 01             	add    $0x1,%eax
80103e09:	a3 40 39 11 80       	mov    %eax,0x80113940
      p += sizeof(struct mpproc);
80103e0e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e12:	eb 42                	jmp    80103e56 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e1d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e21:	a2 40 33 11 80       	mov    %al,0x80113340
      p += sizeof(struct mpioapic);
80103e26:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e2a:	eb 2a                	jmp    80103e56 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e2c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e30:	eb 24                	jmp    80103e56 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e35:	0f b6 00             	movzbl (%eax),%eax
80103e38:	0f b6 c0             	movzbl %al,%eax
80103e3b:	83 ec 08             	sub    $0x8,%esp
80103e3e:	50                   	push   %eax
80103e3f:	68 a0 8c 10 80       	push   $0x80108ca0
80103e44:	e8 7d c5 ff ff       	call   801003c6 <cprintf>
80103e49:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e4c:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103e53:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e59:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e5c:	0f 82 02 ff ff ff    	jb     80103d64 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e62:	a1 44 33 11 80       	mov    0x80113344,%eax
80103e67:	85 c0                	test   %eax,%eax
80103e69:	75 1d                	jne    80103e88 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e6b:	c7 05 40 39 11 80 01 	movl   $0x1,0x80113940
80103e72:	00 00 00 
    lapic = 0;
80103e75:	c7 05 5c 32 11 80 00 	movl   $0x0,0x8011325c
80103e7c:	00 00 00 
    ioapicid = 0;
80103e7f:	c6 05 40 33 11 80 00 	movb   $0x0,0x80113340
    return;
80103e86:	eb 3e                	jmp    80103ec6 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e8f:	84 c0                	test   %al,%al
80103e91:	74 33                	je     80103ec6 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e93:	83 ec 08             	sub    $0x8,%esp
80103e96:	6a 70                	push   $0x70
80103e98:	6a 22                	push   $0x22
80103e9a:	e8 1c fc ff ff       	call   80103abb <outb>
80103e9f:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ea2:	83 ec 0c             	sub    $0xc,%esp
80103ea5:	6a 23                	push   $0x23
80103ea7:	e8 f2 fb ff ff       	call   80103a9e <inb>
80103eac:	83 c4 10             	add    $0x10,%esp
80103eaf:	83 c8 01             	or     $0x1,%eax
80103eb2:	0f b6 c0             	movzbl %al,%eax
80103eb5:	83 ec 08             	sub    $0x8,%esp
80103eb8:	50                   	push   %eax
80103eb9:	6a 23                	push   $0x23
80103ebb:	e8 fb fb ff ff       	call   80103abb <outb>
80103ec0:	83 c4 10             	add    $0x10,%esp
80103ec3:	eb 01                	jmp    80103ec6 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103ec5:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103ec6:	c9                   	leave  
80103ec7:	c3                   	ret    

80103ec8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ec8:	55                   	push   %ebp
80103ec9:	89 e5                	mov    %esp,%ebp
80103ecb:	83 ec 08             	sub    $0x8,%esp
80103ece:	8b 55 08             	mov    0x8(%ebp),%edx
80103ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ed8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103edb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103edf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ee3:	ee                   	out    %al,(%dx)
}
80103ee4:	90                   	nop
80103ee5:	c9                   	leave  
80103ee6:	c3                   	ret    

80103ee7 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ee7:	55                   	push   %ebp
80103ee8:	89 e5                	mov    %esp,%ebp
80103eea:	83 ec 04             	sub    $0x4,%esp
80103eed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ef4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ef8:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103efe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f02:	0f b6 c0             	movzbl %al,%eax
80103f05:	50                   	push   %eax
80103f06:	6a 21                	push   $0x21
80103f08:	e8 bb ff ff ff       	call   80103ec8 <outb>
80103f0d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f10:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f14:	66 c1 e8 08          	shr    $0x8,%ax
80103f18:	0f b6 c0             	movzbl %al,%eax
80103f1b:	50                   	push   %eax
80103f1c:	68 a1 00 00 00       	push   $0xa1
80103f21:	e8 a2 ff ff ff       	call   80103ec8 <outb>
80103f26:	83 c4 08             	add    $0x8,%esp
}
80103f29:	90                   	nop
80103f2a:	c9                   	leave  
80103f2b:	c3                   	ret    

80103f2c <picenable>:

void
picenable(int irq)
{
80103f2c:	55                   	push   %ebp
80103f2d:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	ba 01 00 00 00       	mov    $0x1,%edx
80103f37:	89 c1                	mov    %eax,%ecx
80103f39:	d3 e2                	shl    %cl,%edx
80103f3b:	89 d0                	mov    %edx,%eax
80103f3d:	f7 d0                	not    %eax
80103f3f:	89 c2                	mov    %eax,%edx
80103f41:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f48:	21 d0                	and    %edx,%eax
80103f4a:	0f b7 c0             	movzwl %ax,%eax
80103f4d:	50                   	push   %eax
80103f4e:	e8 94 ff ff ff       	call   80103ee7 <picsetmask>
80103f53:	83 c4 04             	add    $0x4,%esp
}
80103f56:	90                   	nop
80103f57:	c9                   	leave  
80103f58:	c3                   	ret    

80103f59 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f59:	55                   	push   %ebp
80103f5a:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f5c:	68 ff 00 00 00       	push   $0xff
80103f61:	6a 21                	push   $0x21
80103f63:	e8 60 ff ff ff       	call   80103ec8 <outb>
80103f68:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f6b:	68 ff 00 00 00       	push   $0xff
80103f70:	68 a1 00 00 00       	push   $0xa1
80103f75:	e8 4e ff ff ff       	call   80103ec8 <outb>
80103f7a:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f7d:	6a 11                	push   $0x11
80103f7f:	6a 20                	push   $0x20
80103f81:	e8 42 ff ff ff       	call   80103ec8 <outb>
80103f86:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f89:	6a 20                	push   $0x20
80103f8b:	6a 21                	push   $0x21
80103f8d:	e8 36 ff ff ff       	call   80103ec8 <outb>
80103f92:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f95:	6a 04                	push   $0x4
80103f97:	6a 21                	push   $0x21
80103f99:	e8 2a ff ff ff       	call   80103ec8 <outb>
80103f9e:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fa1:	6a 03                	push   $0x3
80103fa3:	6a 21                	push   $0x21
80103fa5:	e8 1e ff ff ff       	call   80103ec8 <outb>
80103faa:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fad:	6a 11                	push   $0x11
80103faf:	68 a0 00 00 00       	push   $0xa0
80103fb4:	e8 0f ff ff ff       	call   80103ec8 <outb>
80103fb9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fbc:	6a 28                	push   $0x28
80103fbe:	68 a1 00 00 00       	push   $0xa1
80103fc3:	e8 00 ff ff ff       	call   80103ec8 <outb>
80103fc8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103fcb:	6a 02                	push   $0x2
80103fcd:	68 a1 00 00 00       	push   $0xa1
80103fd2:	e8 f1 fe ff ff       	call   80103ec8 <outb>
80103fd7:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fda:	6a 03                	push   $0x3
80103fdc:	68 a1 00 00 00       	push   $0xa1
80103fe1:	e8 e2 fe ff ff       	call   80103ec8 <outb>
80103fe6:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fe9:	6a 68                	push   $0x68
80103feb:	6a 20                	push   $0x20
80103fed:	e8 d6 fe ff ff       	call   80103ec8 <outb>
80103ff2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ff5:	6a 0a                	push   $0xa
80103ff7:	6a 20                	push   $0x20
80103ff9:	e8 ca fe ff ff       	call   80103ec8 <outb>
80103ffe:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104001:	6a 68                	push   $0x68
80104003:	68 a0 00 00 00       	push   $0xa0
80104008:	e8 bb fe ff ff       	call   80103ec8 <outb>
8010400d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104010:	6a 0a                	push   $0xa
80104012:	68 a0 00 00 00       	push   $0xa0
80104017:	e8 ac fe ff ff       	call   80103ec8 <outb>
8010401c:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010401f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104026:	66 83 f8 ff          	cmp    $0xffff,%ax
8010402a:	74 13                	je     8010403f <picinit+0xe6>
    picsetmask(irqmask);
8010402c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104033:	0f b7 c0             	movzwl %ax,%eax
80104036:	50                   	push   %eax
80104037:	e8 ab fe ff ff       	call   80103ee7 <picsetmask>
8010403c:	83 c4 04             	add    $0x4,%esp
}
8010403f:	90                   	nop
80104040:	c9                   	leave  
80104041:	c3                   	ret    

80104042 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104042:	55                   	push   %ebp
80104043:	89 e5                	mov    %esp,%ebp
80104045:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104048:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010404f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104052:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104058:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405b:	8b 10                	mov    (%eax),%edx
8010405d:	8b 45 08             	mov    0x8(%ebp),%eax
80104060:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104062:	e8 2d cf ff ff       	call   80100f94 <filealloc>
80104067:	89 c2                	mov    %eax,%edx
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	89 10                	mov    %edx,(%eax)
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	8b 00                	mov    (%eax),%eax
80104073:	85 c0                	test   %eax,%eax
80104075:	0f 84 cb 00 00 00    	je     80104146 <pipealloc+0x104>
8010407b:	e8 14 cf ff ff       	call   80100f94 <filealloc>
80104080:	89 c2                	mov    %eax,%edx
80104082:	8b 45 0c             	mov    0xc(%ebp),%eax
80104085:	89 10                	mov    %edx,(%eax)
80104087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408a:	8b 00                	mov    (%eax),%eax
8010408c:	85 c0                	test   %eax,%eax
8010408e:	0f 84 b2 00 00 00    	je     80104146 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104094:	e8 ce eb ff ff       	call   80102c67 <kalloc>
80104099:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010409c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040a0:	0f 84 9f 00 00 00    	je     80104145 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801040a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a9:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040b0:	00 00 00 
  p->writeopen = 1;
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040bd:	00 00 00 
  p->nwrite = 0;
801040c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c3:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040ca:	00 00 00 
  p->nread = 0;
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040d7:	00 00 00 
  initlock(&p->lock, "pipe");
801040da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dd:	83 ec 08             	sub    $0x8,%esp
801040e0:	68 d4 8c 10 80       	push   $0x80108cd4
801040e5:	50                   	push   %eax
801040e6:	e8 5d 13 00 00       	call   80105448 <initlock>
801040eb:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040ee:	8b 45 08             	mov    0x8(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	8b 00                	mov    (%eax),%eax
801040fe:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104102:	8b 45 08             	mov    0x8(%ebp),%eax
80104105:	8b 00                	mov    (%eax),%eax
80104107:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 00                	mov    (%eax),%eax
80104110:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104113:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104116:	8b 45 0c             	mov    0xc(%ebp),%eax
80104119:	8b 00                	mov    (%eax),%eax
8010411b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104121:	8b 45 0c             	mov    0xc(%ebp),%eax
80104124:	8b 00                	mov    (%eax),%eax
80104126:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010412a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412d:	8b 00                	mov    (%eax),%eax
8010412f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104133:	8b 45 0c             	mov    0xc(%ebp),%eax
80104136:	8b 00                	mov    (%eax),%eax
80104138:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413b:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010413e:	b8 00 00 00 00       	mov    $0x0,%eax
80104143:	eb 4e                	jmp    80104193 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104145:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104146:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010414a:	74 0e                	je     8010415a <pipealloc+0x118>
    kfree((char*)p);
8010414c:	83 ec 0c             	sub    $0xc,%esp
8010414f:	ff 75 f4             	pushl  -0xc(%ebp)
80104152:	e8 73 ea ff ff       	call   80102bca <kfree>
80104157:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010415a:	8b 45 08             	mov    0x8(%ebp),%eax
8010415d:	8b 00                	mov    (%eax),%eax
8010415f:	85 c0                	test   %eax,%eax
80104161:	74 11                	je     80104174 <pipealloc+0x132>
    fileclose(*f0);
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	83 ec 0c             	sub    $0xc,%esp
8010416b:	50                   	push   %eax
8010416c:	e8 e1 ce ff ff       	call   80101052 <fileclose>
80104171:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104174:	8b 45 0c             	mov    0xc(%ebp),%eax
80104177:	8b 00                	mov    (%eax),%eax
80104179:	85 c0                	test   %eax,%eax
8010417b:	74 11                	je     8010418e <pipealloc+0x14c>
    fileclose(*f1);
8010417d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104180:	8b 00                	mov    (%eax),%eax
80104182:	83 ec 0c             	sub    $0xc,%esp
80104185:	50                   	push   %eax
80104186:	e8 c7 ce ff ff       	call   80101052 <fileclose>
8010418b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010418e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104193:	c9                   	leave  
80104194:	c3                   	ret    

80104195 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104195:	55                   	push   %ebp
80104196:	89 e5                	mov    %esp,%ebp
80104198:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010419b:	8b 45 08             	mov    0x8(%ebp),%eax
8010419e:	83 ec 0c             	sub    $0xc,%esp
801041a1:	50                   	push   %eax
801041a2:	e8 c3 12 00 00       	call   8010546a <acquire>
801041a7:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041ae:	74 23                	je     801041d3 <pipeclose+0x3e>
    p->writeopen = 0;
801041b0:	8b 45 08             	mov    0x8(%ebp),%eax
801041b3:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041ba:	00 00 00 
    wakeup(&p->nread);
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	05 34 02 00 00       	add    $0x234,%eax
801041c5:	83 ec 0c             	sub    $0xc,%esp
801041c8:	50                   	push   %eax
801041c9:	e8 1f 0f 00 00       	call   801050ed <wakeup>
801041ce:	83 c4 10             	add    $0x10,%esp
801041d1:	eb 21                	jmp    801041f4 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041dd:	00 00 00 
    wakeup(&p->nwrite);
801041e0:	8b 45 08             	mov    0x8(%ebp),%eax
801041e3:	05 38 02 00 00       	add    $0x238,%eax
801041e8:	83 ec 0c             	sub    $0xc,%esp
801041eb:	50                   	push   %eax
801041ec:	e8 fc 0e 00 00       	call   801050ed <wakeup>
801041f1:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041fd:	85 c0                	test   %eax,%eax
801041ff:	75 2c                	jne    8010422d <pipeclose+0x98>
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010420a:	85 c0                	test   %eax,%eax
8010420c:	75 1f                	jne    8010422d <pipeclose+0x98>
    release(&p->lock);
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	83 ec 0c             	sub    $0xc,%esp
80104214:	50                   	push   %eax
80104215:	e8 b7 12 00 00       	call   801054d1 <release>
8010421a:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010421d:	83 ec 0c             	sub    $0xc,%esp
80104220:	ff 75 08             	pushl  0x8(%ebp)
80104223:	e8 a2 e9 ff ff       	call   80102bca <kfree>
80104228:	83 c4 10             	add    $0x10,%esp
8010422b:	eb 0f                	jmp    8010423c <pipeclose+0xa7>
  } else
    release(&p->lock);
8010422d:	8b 45 08             	mov    0x8(%ebp),%eax
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	50                   	push   %eax
80104234:	e8 98 12 00 00       	call   801054d1 <release>
80104239:	83 c4 10             	add    $0x10,%esp
}
8010423c:	90                   	nop
8010423d:	c9                   	leave  
8010423e:	c3                   	ret    

8010423f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010423f:	55                   	push   %ebp
80104240:	89 e5                	mov    %esp,%ebp
80104242:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104245:	8b 45 08             	mov    0x8(%ebp),%eax
80104248:	83 ec 0c             	sub    $0xc,%esp
8010424b:	50                   	push   %eax
8010424c:	e8 19 12 00 00       	call   8010546a <acquire>
80104251:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104254:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010425b:	e9 ad 00 00 00       	jmp    8010430d <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104260:	8b 45 08             	mov    0x8(%ebp),%eax
80104263:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104269:	85 c0                	test   %eax,%eax
8010426b:	74 0d                	je     8010427a <pipewrite+0x3b>
8010426d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104273:	8b 40 2c             	mov    0x2c(%eax),%eax
80104276:	85 c0                	test   %eax,%eax
80104278:	74 19                	je     80104293 <pipewrite+0x54>
        release(&p->lock);
8010427a:	8b 45 08             	mov    0x8(%ebp),%eax
8010427d:	83 ec 0c             	sub    $0xc,%esp
80104280:	50                   	push   %eax
80104281:	e8 4b 12 00 00       	call   801054d1 <release>
80104286:	83 c4 10             	add    $0x10,%esp
        return -1;
80104289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428e:	e9 a8 00 00 00       	jmp    8010433b <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	05 34 02 00 00       	add    $0x234,%eax
8010429b:	83 ec 0c             	sub    $0xc,%esp
8010429e:	50                   	push   %eax
8010429f:	e8 49 0e 00 00       	call   801050ed <wakeup>
801042a4:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	8b 55 08             	mov    0x8(%ebp),%edx
801042ad:	81 c2 38 02 00 00    	add    $0x238,%edx
801042b3:	83 ec 08             	sub    $0x8,%esp
801042b6:	50                   	push   %eax
801042b7:	52                   	push   %edx
801042b8:	e8 42 0d 00 00       	call   80104fff <sleep>
801042bd:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042c0:	8b 45 08             	mov    0x8(%ebp),%eax
801042c3:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042c9:	8b 45 08             	mov    0x8(%ebp),%eax
801042cc:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042d2:	05 00 02 00 00       	add    $0x200,%eax
801042d7:	39 c2                	cmp    %eax,%edx
801042d9:	74 85                	je     80104260 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e4:	8d 48 01             	lea    0x1(%eax),%ecx
801042e7:	8b 55 08             	mov    0x8(%ebp),%edx
801042ea:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042f0:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f5:	89 c1                	mov    %eax,%ecx
801042f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fd:	01 d0                	add    %edx,%eax
801042ff:	0f b6 10             	movzbl (%eax),%edx
80104302:	8b 45 08             	mov    0x8(%ebp),%eax
80104305:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104309:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104310:	3b 45 10             	cmp    0x10(%ebp),%eax
80104313:	7c ab                	jl     801042c0 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	05 34 02 00 00       	add    $0x234,%eax
8010431d:	83 ec 0c             	sub    $0xc,%esp
80104320:	50                   	push   %eax
80104321:	e8 c7 0d 00 00       	call   801050ed <wakeup>
80104326:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104329:	8b 45 08             	mov    0x8(%ebp),%eax
8010432c:	83 ec 0c             	sub    $0xc,%esp
8010432f:	50                   	push   %eax
80104330:	e8 9c 11 00 00       	call   801054d1 <release>
80104335:	83 c4 10             	add    $0x10,%esp
  return n;
80104338:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010433b:	c9                   	leave  
8010433c:	c3                   	ret    

8010433d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010433d:	55                   	push   %ebp
8010433e:	89 e5                	mov    %esp,%ebp
80104340:	53                   	push   %ebx
80104341:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	83 ec 0c             	sub    $0xc,%esp
8010434a:	50                   	push   %eax
8010434b:	e8 1a 11 00 00       	call   8010546a <acquire>
80104350:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104353:	eb 3f                	jmp    80104394 <piperead+0x57>
    if(proc->killed){
80104355:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435b:	8b 40 2c             	mov    0x2c(%eax),%eax
8010435e:	85 c0                	test   %eax,%eax
80104360:	74 19                	je     8010437b <piperead+0x3e>
      release(&p->lock);
80104362:	8b 45 08             	mov    0x8(%ebp),%eax
80104365:	83 ec 0c             	sub    $0xc,%esp
80104368:	50                   	push   %eax
80104369:	e8 63 11 00 00       	call   801054d1 <release>
8010436e:	83 c4 10             	add    $0x10,%esp
      return -1;
80104371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104376:	e9 bf 00 00 00       	jmp    8010443a <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437b:	8b 45 08             	mov    0x8(%ebp),%eax
8010437e:	8b 55 08             	mov    0x8(%ebp),%edx
80104381:	81 c2 34 02 00 00    	add    $0x234,%edx
80104387:	83 ec 08             	sub    $0x8,%esp
8010438a:	50                   	push   %eax
8010438b:	52                   	push   %edx
8010438c:	e8 6e 0c 00 00       	call   80104fff <sleep>
80104391:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104394:	8b 45 08             	mov    0x8(%ebp),%eax
80104397:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439d:	8b 45 08             	mov    0x8(%ebp),%eax
801043a0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a6:	39 c2                	cmp    %eax,%edx
801043a8:	75 0d                	jne    801043b7 <piperead+0x7a>
801043aa:	8b 45 08             	mov    0x8(%ebp),%eax
801043ad:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b3:	85 c0                	test   %eax,%eax
801043b5:	75 9e                	jne    80104355 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043be:	eb 49                	jmp    80104409 <piperead+0xcc>
    if(p->nread == p->nwrite)
801043c0:	8b 45 08             	mov    0x8(%ebp),%eax
801043c3:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c9:	8b 45 08             	mov    0x8(%ebp),%eax
801043cc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d2:	39 c2                	cmp    %eax,%edx
801043d4:	74 3d                	je     80104413 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801043dc:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043df:	8b 45 08             	mov    0x8(%ebp),%eax
801043e2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043e8:	8d 48 01             	lea    0x1(%eax),%ecx
801043eb:	8b 55 08             	mov    0x8(%ebp),%edx
801043ee:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f4:	25 ff 01 00 00       	and    $0x1ff,%eax
801043f9:	89 c2                	mov    %eax,%edx
801043fb:	8b 45 08             	mov    0x8(%ebp),%eax
801043fe:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104403:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104405:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010440f:	7c af                	jl     801043c0 <piperead+0x83>
80104411:	eb 01                	jmp    80104414 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104413:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104414:	8b 45 08             	mov    0x8(%ebp),%eax
80104417:	05 38 02 00 00       	add    $0x238,%eax
8010441c:	83 ec 0c             	sub    $0xc,%esp
8010441f:	50                   	push   %eax
80104420:	e8 c8 0c 00 00       	call   801050ed <wakeup>
80104425:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104428:	8b 45 08             	mov    0x8(%ebp),%eax
8010442b:	83 ec 0c             	sub    $0xc,%esp
8010442e:	50                   	push   %eax
8010442f:	e8 9d 10 00 00       	call   801054d1 <release>
80104434:	83 c4 10             	add    $0x10,%esp
  return i;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010443a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010443d:	c9                   	leave  
8010443e:	c3                   	ret    

8010443f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010443f:	55                   	push   %ebp
80104440:	89 e5                	mov    %esp,%ebp
80104442:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104445:	9c                   	pushf  
80104446:	58                   	pop    %eax
80104447:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010444a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010444d:	c9                   	leave  
8010444e:	c3                   	ret    

8010444f <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010444f:	55                   	push   %ebp
80104450:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104452:	fb                   	sti    
}
80104453:	90                   	nop
80104454:	5d                   	pop    %ebp
80104455:	c3                   	ret    

80104456 <pinit>:
extern void trapret(void);

static void wakeup1(void* chan);

void pinit(void)
{
80104456:	55                   	push   %ebp
80104457:	89 e5                	mov    %esp,%ebp
80104459:	83 ec 08             	sub    $0x8,%esp
     initlock(&ptable.lock, "ptable");
8010445c:	83 ec 08             	sub    $0x8,%esp
8010445f:	68 dc 8c 10 80       	push   $0x80108cdc
80104464:	68 60 39 11 80       	push   $0x80113960
80104469:	e8 da 0f 00 00       	call   80105448 <initlock>
8010446e:	83 c4 10             	add    $0x10,%esp
}
80104471:	90                   	nop
80104472:	c9                   	leave  
80104473:	c3                   	ret    

80104474 <allocproc>:
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc*
allocproc(void)
{
80104474:	55                   	push   %ebp
80104475:	89 e5                	mov    %esp,%ebp
80104477:	83 ec 18             	sub    $0x18,%esp
     struct proc* p;
     char* sp;

     acquire(&ptable.lock);
8010447a:	83 ec 0c             	sub    $0xc,%esp
8010447d:	68 60 39 11 80       	push   $0x80113960
80104482:	e8 e3 0f 00 00       	call   8010546a <acquire>
80104487:	83 c4 10             	add    $0x10,%esp
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010448a:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80104491:	eb 11                	jmp    801044a4 <allocproc+0x30>
          if (p->state == UNUSED)
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	8b 40 14             	mov    0x14(%eax),%eax
80104499:	85 c0                	test   %eax,%eax
8010449b:	74 2a                	je     801044c7 <allocproc+0x53>
{
     struct proc* p;
     char* sp;

     acquire(&ptable.lock);
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010449d:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801044a4:	81 7d f4 94 5a 11 80 	cmpl   $0x80115a94,-0xc(%ebp)
801044ab:	72 e6                	jb     80104493 <allocproc+0x1f>
          if (p->state == UNUSED)
               goto found;
     release(&ptable.lock);
801044ad:	83 ec 0c             	sub    $0xc,%esp
801044b0:	68 60 39 11 80       	push   $0x80113960
801044b5:	e8 17 10 00 00       	call   801054d1 <release>
801044ba:	83 c4 10             	add    $0x10,%esp
     return 0;
801044bd:	b8 00 00 00 00       	mov    $0x0,%eax
801044c2:	e9 d7 00 00 00       	jmp    8010459e <allocproc+0x12a>
     char* sp;

     acquire(&ptable.lock);
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
          if (p->state == UNUSED)
               goto found;
801044c7:	90                   	nop
     release(&ptable.lock);
     return 0;

found:
     p->state = EMBRYO;
801044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cb:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
     p->pid = nextpid++;
801044d2:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801044d7:	8d 50 01             	lea    0x1(%eax),%edx
801044da:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801044e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e3:	89 42 18             	mov    %eax,0x18(%edx)
     p->queueName = 1;
801044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e9:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
     p->quantumSize = 10;
801044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f3:	c7 00 0a 00 00 00    	movl   $0xa,(%eax)
     release(&ptable.lock);
801044f9:	83 ec 0c             	sub    $0xc,%esp
801044fc:	68 60 39 11 80       	push   $0x80113960
80104501:	e8 cb 0f 00 00       	call   801054d1 <release>
80104506:	83 c4 10             	add    $0x10,%esp

     // Allocate kernel stack.
     if ((p->kstack = kalloc()) == 0)
80104509:	e8 59 e7 ff ff       	call   80102c67 <kalloc>
8010450e:	89 c2                	mov    %eax,%edx
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	89 50 10             	mov    %edx,0x10(%eax)
80104516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104519:	8b 40 10             	mov    0x10(%eax),%eax
8010451c:	85 c0                	test   %eax,%eax
8010451e:	75 11                	jne    80104531 <allocproc+0xbd>
     {
          p->state = UNUSED;
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
          return 0;
8010452a:	b8 00 00 00 00       	mov    $0x0,%eax
8010452f:	eb 6d                	jmp    8010459e <allocproc+0x12a>
     }
     sp = p->kstack + KSTACKSIZE;
80104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104534:	8b 40 10             	mov    0x10(%eax),%eax
80104537:	05 00 10 00 00       	add    $0x1000,%eax
8010453c:	89 45 f0             	mov    %eax,-0x10(%ebp)

     // Leave room for trap frame.
     sp -= sizeof * p->tf;
8010453f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
     p->tf = (struct trapframe*)sp;
80104543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104546:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104549:	89 50 20             	mov    %edx,0x20(%eax)

     // Set up new context to start executing at forkret,
     // which returns to trapret.
     sp -= 4;
8010454c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
     *(uint*)sp = (uint)trapret;
80104550:	ba a9 6a 10 80       	mov    $0x80106aa9,%edx
80104555:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104558:	89 10                	mov    %edx,(%eax)

     sp -= sizeof * p->context;
8010455a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
     p->context = (struct context*)sp;
8010455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104561:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104564:	89 50 24             	mov    %edx,0x24(%eax)
     memset(p->context, 0, sizeof * p->context);
80104567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456a:	8b 40 24             	mov    0x24(%eax),%eax
8010456d:	83 ec 04             	sub    $0x4,%esp
80104570:	6a 14                	push   $0x14
80104572:	6a 00                	push   $0x0
80104574:	50                   	push   %eax
80104575:	e8 53 11 00 00       	call   801056cd <memset>
8010457a:	83 c4 10             	add    $0x10,%esp
     p->context->eip = (uint)forkret;
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	8b 40 24             	mov    0x24(%eax),%eax
80104583:	ba b9 4f 10 80       	mov    $0x80104fb9,%edx
80104588:	89 50 10             	mov    %edx,0x10(%eax)

     append(p, 1);
8010458b:	83 ec 08             	sub    $0x8,%esp
8010458e:	6a 01                	push   $0x1
80104590:	ff 75 f4             	pushl  -0xc(%ebp)
80104593:	e8 0f 0d 00 00       	call   801052a7 <append>
80104598:	83 c4 10             	add    $0x10,%esp
     return p;
8010459b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010459e:	c9                   	leave  
8010459f:	c3                   	ret    

801045a0 <userinit>:

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
801045a0:	55                   	push   %ebp
801045a1:	89 e5                	mov    %esp,%ebp
801045a3:	83 ec 18             	sub    $0x18,%esp
     struct proc* p;
     extern char _binary_initcode_start[], _binary_initcode_size[];

     p = allocproc();
801045a6:	e8 c9 fe ff ff       	call   80104474 <allocproc>
801045ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
     initproc = p;
801045ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b1:	a3 54 c6 10 80       	mov    %eax,0x8010c654
     if ((p->pgdir = setupkvm()) == 0)
801045b6:	e8 b3 3b 00 00       	call   8010816e <setupkvm>
801045bb:	89 c2                	mov    %eax,%edx
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	89 50 0c             	mov    %edx,0xc(%eax)
801045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c6:	8b 40 0c             	mov    0xc(%eax),%eax
801045c9:	85 c0                	test   %eax,%eax
801045cb:	75 0d                	jne    801045da <userinit+0x3a>
          panic("userinit: out of memory?");
801045cd:	83 ec 0c             	sub    $0xc,%esp
801045d0:	68 e3 8c 10 80       	push   $0x80108ce3
801045d5:	e8 8c bf ff ff       	call   80100566 <panic>
     inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045da:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e2:	8b 40 0c             	mov    0xc(%eax),%eax
801045e5:	83 ec 04             	sub    $0x4,%esp
801045e8:	52                   	push   %edx
801045e9:	68 e0 c4 10 80       	push   $0x8010c4e0
801045ee:	50                   	push   %eax
801045ef:	e8 d4 3d 00 00       	call   801083c8 <inituvm>
801045f4:	83 c4 10             	add    $0x10,%esp
     p->sz = PGSIZE;
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fa:	c7 40 08 00 10 00 00 	movl   $0x1000,0x8(%eax)
     memset(p->tf, 0, sizeof(*p->tf));
80104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104604:	8b 40 20             	mov    0x20(%eax),%eax
80104607:	83 ec 04             	sub    $0x4,%esp
8010460a:	6a 4c                	push   $0x4c
8010460c:	6a 00                	push   $0x0
8010460e:	50                   	push   %eax
8010460f:	e8 b9 10 00 00       	call   801056cd <memset>
80104614:	83 c4 10             	add    $0x10,%esp
     p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461a:	8b 40 20             	mov    0x20(%eax),%eax
8010461d:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
     p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104626:	8b 40 20             	mov    0x20(%eax),%eax
80104629:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
     p->tf->es = p->tf->ds;
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 40 20             	mov    0x20(%eax),%eax
80104635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104638:	8b 52 20             	mov    0x20(%edx),%edx
8010463b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010463f:	66 89 50 28          	mov    %dx,0x28(%eax)
     p->tf->ss = p->tf->ds;
80104643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104646:	8b 40 20             	mov    0x20(%eax),%eax
80104649:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464c:	8b 52 20             	mov    0x20(%edx),%edx
8010464f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104653:	66 89 50 48          	mov    %dx,0x48(%eax)
     p->tf->eflags = FL_IF;
80104657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465a:	8b 40 20             	mov    0x20(%eax),%eax
8010465d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
     p->tf->esp = PGSIZE;
80104664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104667:	8b 40 20             	mov    0x20(%eax),%eax
8010466a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
     p->tf->eip = 0; // beginning of initcode.S
80104671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104674:	8b 40 20             	mov    0x20(%eax),%eax
80104677:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

     safestrcpy(p->name, "initcode", sizeof(p->name));
8010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104681:	83 c0 74             	add    $0x74,%eax
80104684:	83 ec 04             	sub    $0x4,%esp
80104687:	6a 10                	push   $0x10
80104689:	68 fc 8c 10 80       	push   $0x80108cfc
8010468e:	50                   	push   %eax
8010468f:	e8 3c 12 00 00       	call   801058d0 <safestrcpy>
80104694:	83 c4 10             	add    $0x10,%esp
     p->cwd = namei("/");
80104697:	83 ec 0c             	sub    $0xc,%esp
8010469a:	68 05 8d 10 80       	push   $0x80108d05
8010469f:	e8 85 de ff ff       	call   80102529 <namei>
801046a4:	83 c4 10             	add    $0x10,%esp
801046a7:	89 c2                	mov    %eax,%edx
801046a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ac:	89 50 70             	mov    %edx,0x70(%eax)

     p->state = RUNNABLE;
801046af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b2:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
}
801046b9:	90                   	nop
801046ba:	c9                   	leave  
801046bb:	c3                   	ret    

801046bc <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	83 ec 18             	sub    $0x18,%esp
     uint sz;

     sz = proc->sz;
801046c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c8:	8b 40 08             	mov    0x8(%eax),%eax
801046cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     if (n > 0)
801046ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046d2:	7e 31                	jle    80104705 <growproc+0x49>
     {
          if ((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046d4:	8b 55 08             	mov    0x8(%ebp),%edx
801046d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046da:	01 c2                	add    %eax,%edx
801046dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e2:	8b 40 0c             	mov    0xc(%eax),%eax
801046e5:	83 ec 04             	sub    $0x4,%esp
801046e8:	52                   	push   %edx
801046e9:	ff 75 f4             	pushl  -0xc(%ebp)
801046ec:	50                   	push   %eax
801046ed:	e8 23 3e 00 00       	call   80108515 <allocuvm>
801046f2:	83 c4 10             	add    $0x10,%esp
801046f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046fc:	75 3e                	jne    8010473c <growproc+0x80>
               return -1;
801046fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104703:	eb 5a                	jmp    8010475f <growproc+0xa3>
     }
     else if (n < 0)
80104705:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104709:	79 31                	jns    8010473c <growproc+0x80>
     {
          if ((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010470b:	8b 55 08             	mov    0x8(%ebp),%edx
8010470e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104711:	01 c2                	add    %eax,%edx
80104713:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104719:	8b 40 0c             	mov    0xc(%eax),%eax
8010471c:	83 ec 04             	sub    $0x4,%esp
8010471f:	52                   	push   %edx
80104720:	ff 75 f4             	pushl  -0xc(%ebp)
80104723:	50                   	push   %eax
80104724:	e8 b5 3e 00 00       	call   801085de <deallocuvm>
80104729:	83 c4 10             	add    $0x10,%esp
8010472c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010472f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104733:	75 07                	jne    8010473c <growproc+0x80>
               return -1;
80104735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010473a:	eb 23                	jmp    8010475f <growproc+0xa3>
     }
     proc->sz = sz;
8010473c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104745:	89 50 08             	mov    %edx,0x8(%eax)
     switchuvm(proc);
80104748:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010474e:	83 ec 0c             	sub    $0xc,%esp
80104751:	50                   	push   %eax
80104752:	e8 fe 3a 00 00       	call   80108255 <switchuvm>
80104757:	83 c4 10             	add    $0x10,%esp
     return 0;
8010475a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010475f:	c9                   	leave  
80104760:	c3                   	ret    

80104761 <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
80104761:	55                   	push   %ebp
80104762:	89 e5                	mov    %esp,%ebp
80104764:	57                   	push   %edi
80104765:	56                   	push   %esi
80104766:	53                   	push   %ebx
80104767:	83 ec 1c             	sub    $0x1c,%esp
     int i, pid;
     struct proc* np;

     // Allocate process.
     if ((np = allocproc()) == 0)
8010476a:	e8 05 fd ff ff       	call   80104474 <allocproc>
8010476f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104772:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104776:	75 0a                	jne    80104782 <fork+0x21>
          return -1;
80104778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010477d:	e9 68 01 00 00       	jmp    801048ea <fork+0x189>

     // Copy process state from p.
     if ((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0)
80104782:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104788:	8b 50 08             	mov    0x8(%eax),%edx
8010478b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104791:	8b 40 0c             	mov    0xc(%eax),%eax
80104794:	83 ec 08             	sub    $0x8,%esp
80104797:	52                   	push   %edx
80104798:	50                   	push   %eax
80104799:	e8 de 3f 00 00       	call   8010877c <copyuvm>
8010479e:	83 c4 10             	add    $0x10,%esp
801047a1:	89 c2                	mov    %eax,%edx
801047a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a6:	89 50 0c             	mov    %edx,0xc(%eax)
801047a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ac:	8b 40 0c             	mov    0xc(%eax),%eax
801047af:	85 c0                	test   %eax,%eax
801047b1:	75 30                	jne    801047e3 <fork+0x82>
     {
          kfree(np->kstack);
801047b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b6:	8b 40 10             	mov    0x10(%eax),%eax
801047b9:	83 ec 0c             	sub    $0xc,%esp
801047bc:	50                   	push   %eax
801047bd:	e8 08 e4 ff ff       	call   80102bca <kfree>
801047c2:	83 c4 10             	add    $0x10,%esp
          np->kstack = 0;
801047c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
          np->state = UNUSED;
801047cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
          return -1;
801047d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047de:	e9 07 01 00 00       	jmp    801048ea <fork+0x189>
     }
     np->sz = proc->sz;
801047e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e9:	8b 50 08             	mov    0x8(%eax),%edx
801047ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ef:	89 50 08             	mov    %edx,0x8(%eax)
     np->parent = proc;
801047f2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fc:	89 50 1c             	mov    %edx,0x1c(%eax)
     *np->tf = *proc->tf;
801047ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104802:	8b 50 20             	mov    0x20(%eax),%edx
80104805:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480b:	8b 40 20             	mov    0x20(%eax),%eax
8010480e:	89 c3                	mov    %eax,%ebx
80104810:	b8 13 00 00 00       	mov    $0x13,%eax
80104815:	89 d7                	mov    %edx,%edi
80104817:	89 de                	mov    %ebx,%esi
80104819:	89 c1                	mov    %eax,%ecx
8010481b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

     // Clear %eax so that fork returns 0 in the child.
     np->tf->eax = 0;
8010481d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104820:	8b 40 20             	mov    0x20(%eax),%eax
80104823:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

     for (i = 0; i < NOFILE; i++)
8010482a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104831:	eb 40                	jmp    80104873 <fork+0x112>
          if (proc->ofile[i])
80104833:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104839:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010483c:	83 c2 0c             	add    $0xc,%edx
8010483f:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104842:	85 c0                	test   %eax,%eax
80104844:	74 29                	je     8010486f <fork+0x10e>
               np->ofile[i] = filedup(proc->ofile[i]);
80104846:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010484f:	83 c2 0c             	add    $0xc,%edx
80104852:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104855:	83 ec 0c             	sub    $0xc,%esp
80104858:	50                   	push   %eax
80104859:	e8 a3 c7 ff ff       	call   80101001 <filedup>
8010485e:	83 c4 10             	add    $0x10,%esp
80104861:	89 c1                	mov    %eax,%ecx
80104863:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104866:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104869:	83 c2 0c             	add    $0xc,%edx
8010486c:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
     *np->tf = *proc->tf;

     // Clear %eax so that fork returns 0 in the child.
     np->tf->eax = 0;

     for (i = 0; i < NOFILE; i++)
8010486f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104873:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104877:	7e ba                	jle    80104833 <fork+0xd2>
          if (proc->ofile[i])
               np->ofile[i] = filedup(proc->ofile[i]);
     np->cwd = idup(proc->cwd);
80104879:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487f:	8b 40 70             	mov    0x70(%eax),%eax
80104882:	83 ec 0c             	sub    $0xc,%esp
80104885:	50                   	push   %eax
80104886:	e8 a6 d0 ff ff       	call   80101931 <idup>
8010488b:	83 c4 10             	add    $0x10,%esp
8010488e:	89 c2                	mov    %eax,%edx
80104890:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104893:	89 50 70             	mov    %edx,0x70(%eax)

     safestrcpy(np->name, proc->name, sizeof(proc->name));
80104896:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489c:	8d 50 74             	lea    0x74(%eax),%edx
8010489f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a2:	83 c0 74             	add    $0x74,%eax
801048a5:	83 ec 04             	sub    $0x4,%esp
801048a8:	6a 10                	push   $0x10
801048aa:	52                   	push   %edx
801048ab:	50                   	push   %eax
801048ac:	e8 1f 10 00 00       	call   801058d0 <safestrcpy>
801048b1:	83 c4 10             	add    $0x10,%esp

     pid = np->pid;
801048b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b7:	8b 40 18             	mov    0x18(%eax),%eax
801048ba:	89 45 dc             	mov    %eax,-0x24(%ebp)

     // lock to force the compiler to emit the np->state write last.
     acquire(&ptable.lock);
801048bd:	83 ec 0c             	sub    $0xc,%esp
801048c0:	68 60 39 11 80       	push   $0x80113960
801048c5:	e8 a0 0b 00 00       	call   8010546a <acquire>
801048ca:	83 c4 10             	add    $0x10,%esp
     np->state = RUNNABLE;
801048cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d0:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
     release(&ptable.lock);
801048d7:	83 ec 0c             	sub    $0xc,%esp
801048da:	68 60 39 11 80       	push   $0x80113960
801048df:	e8 ed 0b 00 00       	call   801054d1 <release>
801048e4:	83 c4 10             	add    $0x10,%esp

     return pid;
801048e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048ed:	5b                   	pop    %ebx
801048ee:	5e                   	pop    %esi
801048ef:	5f                   	pop    %edi
801048f0:	5d                   	pop    %ebp
801048f1:	c3                   	ret    

801048f2 <exit>:

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
801048f2:	55                   	push   %ebp
801048f3:	89 e5                	mov    %esp,%ebp
801048f5:	83 ec 18             	sub    $0x18,%esp
     struct proc* p;
     int fd;

     if (proc == initproc)
801048f8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048ff:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80104904:	39 c2                	cmp    %eax,%edx
80104906:	75 0d                	jne    80104915 <exit+0x23>
          panic("init exiting");
80104908:	83 ec 0c             	sub    $0xc,%esp
8010490b:	68 07 8d 10 80       	push   $0x80108d07
80104910:	e8 51 bc ff ff       	call   80100566 <panic>

     // Close all open files.
     for (fd = 0; fd < NOFILE; fd++)
80104915:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010491c:	eb 45                	jmp    80104963 <exit+0x71>
     {
          if (proc->ofile[fd])
8010491e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104924:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104927:	83 c2 0c             	add    $0xc,%edx
8010492a:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010492d:	85 c0                	test   %eax,%eax
8010492f:	74 2e                	je     8010495f <exit+0x6d>
          {
               fileclose(proc->ofile[fd]);
80104931:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104937:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010493a:	83 c2 0c             	add    $0xc,%edx
8010493d:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104940:	83 ec 0c             	sub    $0xc,%esp
80104943:	50                   	push   %eax
80104944:	e8 09 c7 ff ff       	call   80101052 <fileclose>
80104949:	83 c4 10             	add    $0x10,%esp
               proc->ofile[fd] = 0;
8010494c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104952:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104955:	83 c2 0c             	add    $0xc,%edx
80104958:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

     if (proc == initproc)
          panic("init exiting");

     // Close all open files.
     for (fd = 0; fd < NOFILE; fd++)
8010495f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104963:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104967:	7e b5                	jle    8010491e <exit+0x2c>
               fileclose(proc->ofile[fd]);
               proc->ofile[fd] = 0;
          }
     }

     begin_op();
80104969:	e8 e0 eb ff ff       	call   8010354e <begin_op>
     iput(proc->cwd);
8010496e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104974:	8b 40 70             	mov    0x70(%eax),%eax
80104977:	83 ec 0c             	sub    $0xc,%esp
8010497a:	50                   	push   %eax
8010497b:	e8 bb d1 ff ff       	call   80101b3b <iput>
80104980:	83 c4 10             	add    $0x10,%esp
     end_op();
80104983:	e8 52 ec ff ff       	call   801035da <end_op>
     proc->cwd = 0;
80104988:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498e:	c7 40 70 00 00 00 00 	movl   $0x0,0x70(%eax)

     acquire(&ptable.lock);
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	68 60 39 11 80       	push   $0x80113960
8010499d:	e8 c8 0a 00 00       	call   8010546a <acquire>
801049a2:	83 c4 10             	add    $0x10,%esp

     // Parent might be sleeping in wait().
     wakeup1(proc->parent);
801049a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ab:	8b 40 1c             	mov    0x1c(%eax),%eax
801049ae:	83 ec 0c             	sub    $0xc,%esp
801049b1:	50                   	push   %eax
801049b2:	e8 f4 06 00 00       	call   801050ab <wakeup1>
801049b7:	83 c4 10             	add    $0x10,%esp

     // Pass abandoned children to init.
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801049ba:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
801049c1:	eb 3f                	jmp    80104a02 <exit+0x110>
     {
          if (p->parent == proc)
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	8b 50 1c             	mov    0x1c(%eax),%edx
801049c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cf:	39 c2                	cmp    %eax,%edx
801049d1:	75 28                	jne    801049fb <exit+0x109>
          {
               p->parent = initproc;
801049d3:	8b 15 54 c6 10 80    	mov    0x8010c654,%edx
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	89 50 1c             	mov    %edx,0x1c(%eax)
               if (p->state == ZOMBIE)
801049df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e2:	8b 40 14             	mov    0x14(%eax),%eax
801049e5:	83 f8 05             	cmp    $0x5,%eax
801049e8:	75 11                	jne    801049fb <exit+0x109>
                    wakeup1(initproc);
801049ea:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801049ef:	83 ec 0c             	sub    $0xc,%esp
801049f2:	50                   	push   %eax
801049f3:	e8 b3 06 00 00       	call   801050ab <wakeup1>
801049f8:	83 c4 10             	add    $0x10,%esp

     // Parent might be sleeping in wait().
     wakeup1(proc->parent);

     // Pass abandoned children to init.
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801049fb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a02:	81 7d f4 94 5a 11 80 	cmpl   $0x80115a94,-0xc(%ebp)
80104a09:	72 b8                	jb     801049c3 <exit+0xd1>
                    wakeup1(initproc);
          }
     }

     // Jump into the scheduler, never to return.
     proc->state = ZOMBIE;
80104a0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a11:	c7 40 14 05 00 00 00 	movl   $0x5,0x14(%eax)
     sched();
80104a18:	e8 a5 04 00 00       	call   80104ec2 <sched>
     panic("zombie exit");
80104a1d:	83 ec 0c             	sub    $0xc,%esp
80104a20:	68 14 8d 10 80       	push   $0x80108d14
80104a25:	e8 3c bb ff ff       	call   80100566 <panic>

80104a2a <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
80104a2a:	55                   	push   %ebp
80104a2b:	89 e5                	mov    %esp,%ebp
80104a2d:	83 ec 18             	sub    $0x18,%esp
     struct proc* p;
     int havekids, pid;

     acquire(&ptable.lock);
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	68 60 39 11 80       	push   $0x80113960
80104a38:	e8 2d 0a 00 00       	call   8010546a <acquire>
80104a3d:	83 c4 10             	add    $0x10,%esp
     for (;;)
     {
          // Scan through table looking for zombie children.
          havekids = 0;
80104a40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
          for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a47:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80104a4e:	e9 a9 00 00 00       	jmp    80104afc <wait+0xd2>
          {
               if (p->parent != proc)
80104a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a56:	8b 50 1c             	mov    0x1c(%eax),%edx
80104a59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5f:	39 c2                	cmp    %eax,%edx
80104a61:	0f 85 8d 00 00 00    	jne    80104af4 <wait+0xca>
                    continue;
               havekids = 1;
80104a67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
               if (p->state == ZOMBIE)
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	8b 40 14             	mov    0x14(%eax),%eax
80104a74:	83 f8 05             	cmp    $0x5,%eax
80104a77:	75 7c                	jne    80104af5 <wait+0xcb>
               {
                    // Found one.
                    pid = p->pid;
80104a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7c:	8b 40 18             	mov    0x18(%eax),%eax
80104a7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
                    kfree(p->kstack);
80104a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a85:	8b 40 10             	mov    0x10(%eax),%eax
80104a88:	83 ec 0c             	sub    $0xc,%esp
80104a8b:	50                   	push   %eax
80104a8c:	e8 39 e1 ff ff       	call   80102bca <kfree>
80104a91:	83 c4 10             	add    $0x10,%esp
                    p->kstack = 0;
80104a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a97:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
                    freevm(p->pgdir);
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104aa4:	83 ec 0c             	sub    $0xc,%esp
80104aa7:	50                   	push   %eax
80104aa8:	e8 ee 3b 00 00       	call   8010869b <freevm>
80104aad:	83 c4 10             	add    $0x10,%esp
                    p->state = UNUSED;
80104ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
                    p->pid = 0;
80104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abd:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
                    p->parent = 0;
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
                    p->name[0] = 0;
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	c6 40 74 00          	movb   $0x0,0x74(%eax)
                    p->killed = 0;
80104ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad8:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%eax)
                    release(&ptable.lock);
80104adf:	83 ec 0c             	sub    $0xc,%esp
80104ae2:	68 60 39 11 80       	push   $0x80113960
80104ae7:	e8 e5 09 00 00       	call   801054d1 <release>
80104aec:	83 c4 10             	add    $0x10,%esp
                    return pid;
80104aef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104af2:	eb 5b                	jmp    80104b4f <wait+0x125>
          // Scan through table looking for zombie children.
          havekids = 0;
          for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
          {
               if (p->parent != proc)
                    continue;
80104af4:	90                   	nop
     acquire(&ptable.lock);
     for (;;)
     {
          // Scan through table looking for zombie children.
          havekids = 0;
          for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104af5:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104afc:	81 7d f4 94 5a 11 80 	cmpl   $0x80115a94,-0xc(%ebp)
80104b03:	0f 82 4a ff ff ff    	jb     80104a53 <wait+0x29>
                    return pid;
               }
          }

          // No point waiting if we don't have any children.
          if (!havekids || proc->killed)
80104b09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b0d:	74 0d                	je     80104b1c <wait+0xf2>
80104b0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b15:	8b 40 2c             	mov    0x2c(%eax),%eax
80104b18:	85 c0                	test   %eax,%eax
80104b1a:	74 17                	je     80104b33 <wait+0x109>
          {
               release(&ptable.lock);
80104b1c:	83 ec 0c             	sub    $0xc,%esp
80104b1f:	68 60 39 11 80       	push   $0x80113960
80104b24:	e8 a8 09 00 00       	call   801054d1 <release>
80104b29:	83 c4 10             	add    $0x10,%esp
               return -1;
80104b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b31:	eb 1c                	jmp    80104b4f <wait+0x125>
          }

          // Wait for children to exit.  (See wakeup1 call in proc_exit.)
          sleep(proc, &ptable.lock); // DOC: wait-sleep
80104b33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b39:	83 ec 08             	sub    $0x8,%esp
80104b3c:	68 60 39 11 80       	push   $0x80113960
80104b41:	50                   	push   %eax
80104b42:	e8 b8 04 00 00       	call   80104fff <sleep>
80104b47:	83 c4 10             	add    $0x10,%esp
     }
80104b4a:	e9 f1 fe ff ff       	jmp    80104a40 <wait+0x16>
}
80104b4f:	c9                   	leave  
80104b50:	c3                   	ret    

80104b51 <scheduler>:
//   - choose a process to run
//   - swtch to start running that process
//   - eventually that process transfers control
//       via swtch back to the scheduler.
void scheduler(void)
{
80104b51:	55                   	push   %ebp
80104b52:	89 e5                	mov    %esp,%ebp
80104b54:	83 ec 18             	sub    $0x18,%esp
     //struct proc *p;
     for (;;)
     {
          // Enable interrupts on this processor.
          sti();
80104b57:	e8 f3 f8 ff ff       	call   8010444f <sti>

          // Loop over process table looking for process to run.
          acquire(&ptable.lock);
80104b5c:	83 ec 0c             	sub    $0xc,%esp
80104b5f:	68 60 39 11 80       	push   $0x80113960
80104b64:	e8 01 09 00 00       	call   8010546a <acquire>
80104b69:	83 c4 10             	add    $0x10,%esp
          int pri;

          while (Queue1 != 0) {
80104b6c:	e9 df 00 00 00       	jmp    80104c50 <scheduler+0xff>
               if (Queue1->data->state != RUNNABLE)
80104b71:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104b76:	8b 00                	mov    (%eax),%eax
80104b78:	8b 40 14             	mov    0x14(%eax),%eax
80104b7b:	83 f8 03             	cmp    $0x3,%eax
80104b7e:	74 05                	je     80104b85 <scheduler+0x34>
                    continue;
80104b80:	e9 cb 00 00 00       	jmp    80104c50 <scheduler+0xff>

               // Switch to chosen process.  It is the process's job
               // to release ptable.lock and then reacquire it
               // before jumping back to us.
               proc = Queue1->data;
80104b85:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104b8a:	8b 00                	mov    (%eax),%eax
80104b8c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
               switchuvm(Queue1->data);
80104b92:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104b97:	8b 00                	mov    (%eax),%eax
80104b99:	83 ec 0c             	sub    $0xc,%esp
80104b9c:	50                   	push   %eax
80104b9d:	e8 b3 36 00 00       	call   80108255 <switchuvm>
80104ba2:	83 c4 10             	add    $0x10,%esp
               Queue1->data->state = RUNNING;
80104ba5:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104baa:	8b 00                	mov    (%eax),%eax
80104bac:	c7 40 14 04 00 00 00 	movl   $0x4,0x14(%eax)

               if (strncmp(proc->name, "spin", 4) == 0)
80104bb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb9:	83 c0 74             	add    $0x74,%eax
80104bbc:	83 ec 04             	sub    $0x4,%esp
80104bbf:	6a 04                	push   $0x4
80104bc1:	68 20 8d 10 80       	push   $0x80108d20
80104bc6:	50                   	push   %eax
80104bc7:	e8 56 0c 00 00       	call   80105822 <strncmp>
80104bcc:	83 c4 10             	add    $0x10,%esp
80104bcf:	85 c0                	test   %eax,%eax
80104bd1:	75 2b                	jne    80104bfe <scheduler+0xad>
                    cprintf("Process %s %d has consumed %d ms in Queue1\n", proc->name, proc->pid, proc->quantumSize);
80104bd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd9:	8b 10                	mov    (%eax),%edx
80104bdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be1:	8b 40 18             	mov    0x18(%eax),%eax
80104be4:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104beb:	83 c1 74             	add    $0x74,%ecx
80104bee:	52                   	push   %edx
80104bef:	50                   	push   %eax
80104bf0:	51                   	push   %ecx
80104bf1:	68 28 8d 10 80       	push   $0x80108d28
80104bf6:	e8 cb b7 ff ff       	call   801003c6 <cprintf>
80104bfb:	83 c4 10             	add    $0x10,%esp

               swtch(&cpu->scheduler, proc->context);
80104bfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c04:	8b 40 24             	mov    0x24(%eax),%eax
80104c07:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c0e:	83 c2 04             	add    $0x4,%edx
80104c11:	83 ec 08             	sub    $0x8,%esp
80104c14:	50                   	push   %eax
80104c15:	52                   	push   %edx
80104c16:	e8 26 0d 00 00       	call   80105941 <swtch>
80104c1b:	83 c4 10             	add    $0x10,%esp
               switchkvm();
80104c1e:	e8 15 36 00 00       	call   80108238 <switchkvm>

               // Process is done running for now.
               // It should have changed its p->state before coming back.
               proc = 0;
80104c23:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c2a:	00 00 00 00 
               append(Queue1->data, 2);
80104c2e:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104c33:	8b 00                	mov    (%eax),%eax
80104c35:	83 ec 08             	sub    $0x8,%esp
80104c38:	6a 02                	push   $0x2
80104c3a:	50                   	push   %eax
80104c3b:	e8 67 06 00 00       	call   801052a7 <append>
80104c40:	83 c4 10             	add    $0x10,%esp
               deleteFirstNode(1);
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	6a 01                	push   $0x1
80104c48:	e8 61 07 00 00       	call   801053ae <deleteFirstNode>
80104c4d:	83 c4 10             	add    $0x10,%esp

          // Loop over process table looking for process to run.
          acquire(&ptable.lock);
          int pri;

          while (Queue1 != 0) {
80104c50:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104c55:	85 c0                	test   %eax,%eax
80104c57:	0f 85 14 ff ff ff    	jne    80104b71 <scheduler+0x20>
               // It should have changed its p->state before coming back.
               proc = 0;
               append(Queue1->data, 2);
               deleteFirstNode(1);
          }
          while (Queue2 != 0)
80104c5d:	e9 f9 00 00 00       	jmp    80104d5b <scheduler+0x20a>
          {
               if (Queue2->data->state != RUNNABLE)
80104c62:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80104c67:	8b 00                	mov    (%eax),%eax
80104c69:	8b 40 14             	mov    0x14(%eax),%eax
80104c6c:	83 f8 03             	cmp    $0x3,%eax
80104c6f:	74 05                	je     80104c76 <scheduler+0x125>
                    continue;
80104c71:	e9 e5 00 00 00       	jmp    80104d5b <scheduler+0x20a>

               for (pri = 0; pri < 3; pri++) {
80104c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c7d:	e9 a2 00 00 00       	jmp    80104d24 <scheduler+0x1d3>
                    // Switch to chosen process.  It is the process's job
                    // to release ptable.lock and then reacquire it
                    // before jumping back to us.
                    proc = Queue2->data;
80104c82:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80104c87:	8b 00                	mov    (%eax),%eax
80104c89:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
                    switchuvm(Queue2->data);
80104c8f:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80104c94:	8b 00                	mov    (%eax),%eax
80104c96:	83 ec 0c             	sub    $0xc,%esp
80104c99:	50                   	push   %eax
80104c9a:	e8 b6 35 00 00       	call   80108255 <switchuvm>
80104c9f:	83 c4 10             	add    $0x10,%esp
                    Queue2->data->state = RUNNING;
80104ca2:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80104ca7:	8b 00                	mov    (%eax),%eax
80104ca9:	c7 40 14 04 00 00 00 	movl   $0x4,0x14(%eax)

                    if (strncmp(proc->name, "spin", 4) == 0)
80104cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb6:	83 c0 74             	add    $0x74,%eax
80104cb9:	83 ec 04             	sub    $0x4,%esp
80104cbc:	6a 04                	push   $0x4
80104cbe:	68 20 8d 10 80       	push   $0x80108d20
80104cc3:	50                   	push   %eax
80104cc4:	e8 59 0b 00 00       	call   80105822 <strncmp>
80104cc9:	83 c4 10             	add    $0x10,%esp
80104ccc:	85 c0                	test   %eax,%eax
80104cce:	75 2b                	jne    80104cfb <scheduler+0x1aa>
                         cprintf("Process %s %d has consumed %d ms in Queue2\n", proc->name, proc->pid, proc->quantumSize);
80104cd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd6:	8b 10                	mov    (%eax),%edx
80104cd8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cde:	8b 40 18             	mov    0x18(%eax),%eax
80104ce1:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104ce8:	83 c1 74             	add    $0x74,%ecx
80104ceb:	52                   	push   %edx
80104cec:	50                   	push   %eax
80104ced:	51                   	push   %ecx
80104cee:	68 54 8d 10 80       	push   $0x80108d54
80104cf3:	e8 ce b6 ff ff       	call   801003c6 <cprintf>
80104cf8:	83 c4 10             	add    $0x10,%esp

                    swtch(&cpu->scheduler, proc->context);
80104cfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d01:	8b 40 24             	mov    0x24(%eax),%eax
80104d04:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d0b:	83 c2 04             	add    $0x4,%edx
80104d0e:	83 ec 08             	sub    $0x8,%esp
80104d11:	50                   	push   %eax
80104d12:	52                   	push   %edx
80104d13:	e8 29 0c 00 00       	call   80105941 <swtch>
80104d18:	83 c4 10             	add    $0x10,%esp
                    switchkvm();
80104d1b:	e8 18 35 00 00       	call   80108238 <switchkvm>
          while (Queue2 != 0)
          {
               if (Queue2->data->state != RUNNABLE)
                    continue;

               for (pri = 0; pri < 3; pri++) {
80104d20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d24:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
80104d28:	0f 8e 54 ff ff ff    	jle    80104c82 <scheduler+0x131>
                    switchkvm();
               }

               // Process is done running for now.
               // It should have changed its p->state before coming back.
               proc = 0;
80104d2e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d35:	00 00 00 00 
               append(Queue2->data, 3);
80104d39:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80104d3e:	8b 00                	mov    (%eax),%eax
80104d40:	83 ec 08             	sub    $0x8,%esp
80104d43:	6a 03                	push   $0x3
80104d45:	50                   	push   %eax
80104d46:	e8 5c 05 00 00       	call   801052a7 <append>
80104d4b:	83 c4 10             	add    $0x10,%esp
               deleteFirstNode(2);
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	6a 02                	push   $0x2
80104d53:	e8 56 06 00 00       	call   801053ae <deleteFirstNode>
80104d58:	83 c4 10             	add    $0x10,%esp
               // It should have changed its p->state before coming back.
               proc = 0;
               append(Queue1->data, 2);
               deleteFirstNode(1);
          }
          while (Queue2 != 0)
80104d5b:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80104d60:	85 c0                	test   %eax,%eax
80104d62:	0f 85 fa fe ff ff    	jne    80104c62 <scheduler+0x111>
               // It should have changed its p->state before coming back.
               proc = 0;
               append(Queue2->data, 3);
               deleteFirstNode(2);
          }
          while (Queue3 != 0)
80104d68:	e9 43 01 00 00       	jmp    80104eb0 <scheduler+0x35f>
          {
               if (Queue3->data->state != RUNNABLE)
80104d6d:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104d72:	8b 00                	mov    (%eax),%eax
80104d74:	8b 40 14             	mov    0x14(%eax),%eax
80104d77:	83 f8 03             	cmp    $0x3,%eax
80104d7a:	74 05                	je     80104d81 <scheduler+0x230>
                    continue;
80104d7c:	e9 2f 01 00 00       	jmp    80104eb0 <scheduler+0x35f>

               for (pri = 0; pri < 9; pri++)
80104d81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d88:	e9 a2 00 00 00       	jmp    80104e2f <scheduler+0x2de>
               {
                    // Switch to chosen process.  It is the process's job
                    // to release ptable.lock and then reacquire it
                    // before jumping back to us.
                    proc = Queue3->data;
80104d8d:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104d92:	8b 00                	mov    (%eax),%eax
80104d94:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
                    switchuvm(Queue3->data);
80104d9a:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104d9f:	8b 00                	mov    (%eax),%eax
80104da1:	83 ec 0c             	sub    $0xc,%esp
80104da4:	50                   	push   %eax
80104da5:	e8 ab 34 00 00       	call   80108255 <switchuvm>
80104daa:	83 c4 10             	add    $0x10,%esp
                    Queue3->data->state = RUNNING;
80104dad:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104db2:	8b 00                	mov    (%eax),%eax
80104db4:	c7 40 14 04 00 00 00 	movl   $0x4,0x14(%eax)

                    if (strncmp(proc->name, "spin", 4) == 0)
80104dbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc1:	83 c0 74             	add    $0x74,%eax
80104dc4:	83 ec 04             	sub    $0x4,%esp
80104dc7:	6a 04                	push   $0x4
80104dc9:	68 20 8d 10 80       	push   $0x80108d20
80104dce:	50                   	push   %eax
80104dcf:	e8 4e 0a 00 00       	call   80105822 <strncmp>
80104dd4:	83 c4 10             	add    $0x10,%esp
80104dd7:	85 c0                	test   %eax,%eax
80104dd9:	75 2b                	jne    80104e06 <scheduler+0x2b5>
                         cprintf("Process %s %d has consumed %d ms in Queue3\n", proc->name, proc->pid, proc->quantumSize);
80104ddb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de1:	8b 10                	mov    (%eax),%edx
80104de3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de9:	8b 40 18             	mov    0x18(%eax),%eax
80104dec:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104df3:	83 c1 74             	add    $0x74,%ecx
80104df6:	52                   	push   %edx
80104df7:	50                   	push   %eax
80104df8:	51                   	push   %ecx
80104df9:	68 80 8d 10 80       	push   $0x80108d80
80104dfe:	e8 c3 b5 ff ff       	call   801003c6 <cprintf>
80104e03:	83 c4 10             	add    $0x10,%esp

                    swtch(&cpu->scheduler, proc->context);
80104e06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e0c:	8b 40 24             	mov    0x24(%eax),%eax
80104e0f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e16:	83 c2 04             	add    $0x4,%edx
80104e19:	83 ec 08             	sub    $0x8,%esp
80104e1c:	50                   	push   %eax
80104e1d:	52                   	push   %edx
80104e1e:	e8 1e 0b 00 00       	call   80105941 <swtch>
80104e23:	83 c4 10             	add    $0x10,%esp
                    switchkvm();
80104e26:	e8 0d 34 00 00       	call   80108238 <switchkvm>
          while (Queue3 != 0)
          {
               if (Queue3->data->state != RUNNABLE)
                    continue;

               for (pri = 0; pri < 9; pri++)
80104e2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e2f:	83 7d f4 08          	cmpl   $0x8,-0xc(%ebp)
80104e33:	0f 8e 54 ff ff ff    	jle    80104d8d <scheduler+0x23c>
                    switchkvm();
               }

               // Process is done running for now.
               // It should have changed its p->state before coming back.
               proc = 0;
80104e39:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104e40:	00 00 00 00 
               if (Queue3->boostCounter > 0)
80104e44:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104e49:	8b 40 04             	mov    0x4(%eax),%eax
80104e4c:	85 c0                	test   %eax,%eax
80104e4e:	7e 32                	jle    80104e82 <scheduler+0x331>
               {
                    append(Queue3->data, 3);
80104e50:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104e55:	8b 00                	mov    (%eax),%eax
80104e57:	83 ec 08             	sub    $0x8,%esp
80104e5a:	6a 03                	push   $0x3
80104e5c:	50                   	push   %eax
80104e5d:	e8 45 04 00 00       	call   801052a7 <append>
80104e62:	83 c4 10             	add    $0x10,%esp
                    deleteFirstNode(3);
80104e65:	83 ec 0c             	sub    $0xc,%esp
80104e68:	6a 03                	push   $0x3
80104e6a:	e8 3f 05 00 00       	call   801053ae <deleteFirstNode>
80104e6f:	83 c4 10             	add    $0x10,%esp
                    Queue3->boostCounter--;
80104e72:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104e77:	8b 50 04             	mov    0x4(%eax),%edx
80104e7a:	83 ea 01             	sub    $0x1,%edx
80104e7d:	89 50 04             	mov    %edx,0x4(%eax)
80104e80:	eb 2e                	jmp    80104eb0 <scheduler+0x35f>
               }
               else
               {
                    Queue3->boostCounter = 3;
80104e82:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104e87:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
                    append(Queue3->data, 1);
80104e8e:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104e93:	8b 00                	mov    (%eax),%eax
80104e95:	83 ec 08             	sub    $0x8,%esp
80104e98:	6a 01                	push   $0x1
80104e9a:	50                   	push   %eax
80104e9b:	e8 07 04 00 00       	call   801052a7 <append>
80104ea0:	83 c4 10             	add    $0x10,%esp
                    deleteFirstNode(3);
80104ea3:	83 ec 0c             	sub    $0xc,%esp
80104ea6:	6a 03                	push   $0x3
80104ea8:	e8 01 05 00 00       	call   801053ae <deleteFirstNode>
80104ead:	83 c4 10             	add    $0x10,%esp
               // It should have changed its p->state before coming back.
               proc = 0;
               append(Queue2->data, 3);
               deleteFirstNode(2);
          }
          while (Queue3 != 0)
80104eb0:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80104eb5:	85 c0                	test   %eax,%eax
80104eb7:	0f 85 b0 fe ff ff    	jne    80104d6d <scheduler+0x21c>
                    Queue3->boostCounter = 3;
                    append(Queue3->data, 1);
                    deleteFirstNode(3);
               }
          }
     }
80104ebd:	e9 95 fc ff ff       	jmp    80104b57 <scheduler+0x6>

80104ec2 <sched>:
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void sched(void)
{
80104ec2:	55                   	push   %ebp
80104ec3:	89 e5                	mov    %esp,%ebp
80104ec5:	83 ec 18             	sub    $0x18,%esp
     int intena;

     if (!holding(&ptable.lock))
80104ec8:	83 ec 0c             	sub    $0xc,%esp
80104ecb:	68 60 39 11 80       	push   $0x80113960
80104ed0:	e8 c8 06 00 00       	call   8010559d <holding>
80104ed5:	83 c4 10             	add    $0x10,%esp
80104ed8:	85 c0                	test   %eax,%eax
80104eda:	75 0d                	jne    80104ee9 <sched+0x27>
          panic("sched ptable.lock");
80104edc:	83 ec 0c             	sub    $0xc,%esp
80104edf:	68 ac 8d 10 80       	push   $0x80108dac
80104ee4:	e8 7d b6 ff ff       	call   80100566 <panic>
     if (cpu->ncli != 1)
80104ee9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104eef:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ef5:	83 f8 01             	cmp    $0x1,%eax
80104ef8:	74 0d                	je     80104f07 <sched+0x45>
          panic("sched locks");
80104efa:	83 ec 0c             	sub    $0xc,%esp
80104efd:	68 be 8d 10 80       	push   $0x80108dbe
80104f02:	e8 5f b6 ff ff       	call   80100566 <panic>
     if (proc->state == RUNNING)
80104f07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f0d:	8b 40 14             	mov    0x14(%eax),%eax
80104f10:	83 f8 04             	cmp    $0x4,%eax
80104f13:	75 0d                	jne    80104f22 <sched+0x60>
          panic("sched running");
80104f15:	83 ec 0c             	sub    $0xc,%esp
80104f18:	68 ca 8d 10 80       	push   $0x80108dca
80104f1d:	e8 44 b6 ff ff       	call   80100566 <panic>
     if (readeflags() & FL_IF)
80104f22:	e8 18 f5 ff ff       	call   8010443f <readeflags>
80104f27:	25 00 02 00 00       	and    $0x200,%eax
80104f2c:	85 c0                	test   %eax,%eax
80104f2e:	74 0d                	je     80104f3d <sched+0x7b>
          panic("sched interruptible");
80104f30:	83 ec 0c             	sub    $0xc,%esp
80104f33:	68 d8 8d 10 80       	push   $0x80108dd8
80104f38:	e8 29 b6 ff ff       	call   80100566 <panic>
     intena = cpu->intena;
80104f3d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f43:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f49:	89 45 f4             	mov    %eax,-0xc(%ebp)
     swtch(&proc->context, cpu->scheduler);
80104f4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f52:	8b 40 04             	mov    0x4(%eax),%eax
80104f55:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f5c:	83 c2 24             	add    $0x24,%edx
80104f5f:	83 ec 08             	sub    $0x8,%esp
80104f62:	50                   	push   %eax
80104f63:	52                   	push   %edx
80104f64:	e8 d8 09 00 00       	call   80105941 <swtch>
80104f69:	83 c4 10             	add    $0x10,%esp
     cpu->intena = intena;
80104f6c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f75:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104f7b:	90                   	nop
80104f7c:	c9                   	leave  
80104f7d:	c3                   	ret    

80104f7e <yield>:

// Give up the CPU for one scheduling round.
void yield(void)
{
80104f7e:	55                   	push   %ebp
80104f7f:	89 e5                	mov    %esp,%ebp
80104f81:	83 ec 08             	sub    $0x8,%esp
     acquire(&ptable.lock); // DOC: yieldlock
80104f84:	83 ec 0c             	sub    $0xc,%esp
80104f87:	68 60 39 11 80       	push   $0x80113960
80104f8c:	e8 d9 04 00 00       	call   8010546a <acquire>
80104f91:	83 c4 10             	add    $0x10,%esp
     proc->state = RUNNABLE;
80104f94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9a:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
     sched();
80104fa1:	e8 1c ff ff ff       	call   80104ec2 <sched>
     release(&ptable.lock);
80104fa6:	83 ec 0c             	sub    $0xc,%esp
80104fa9:	68 60 39 11 80       	push   $0x80113960
80104fae:	e8 1e 05 00 00       	call   801054d1 <release>
80104fb3:	83 c4 10             	add    $0x10,%esp
}
80104fb6:	90                   	nop
80104fb7:	c9                   	leave  
80104fb8:	c3                   	ret    

80104fb9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
80104fb9:	55                   	push   %ebp
80104fba:	89 e5                	mov    %esp,%ebp
80104fbc:	83 ec 08             	sub    $0x8,%esp
     static int first = 1;
     // Still holding ptable.lock from scheduler.
     release(&ptable.lock);
80104fbf:	83 ec 0c             	sub    $0xc,%esp
80104fc2:	68 60 39 11 80       	push   $0x80113960
80104fc7:	e8 05 05 00 00       	call   801054d1 <release>
80104fcc:	83 c4 10             	add    $0x10,%esp

     if (first)
80104fcf:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104fd4:	85 c0                	test   %eax,%eax
80104fd6:	74 24                	je     80104ffc <forkret+0x43>
     {
          // Some initialization functions must be run in the context
          // of a regular process (e.g., they call sleep), and thus cannot
          // be run from main().
          first = 0;
80104fd8:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104fdf:	00 00 00 
          iinit(ROOTDEV);
80104fe2:	83 ec 0c             	sub    $0xc,%esp
80104fe5:	6a 01                	push   $0x1
80104fe7:	e8 53 c6 ff ff       	call   8010163f <iinit>
80104fec:	83 c4 10             	add    $0x10,%esp
          initlog(ROOTDEV);
80104fef:	83 ec 0c             	sub    $0xc,%esp
80104ff2:	6a 01                	push   $0x1
80104ff4:	e8 37 e3 ff ff       	call   80103330 <initlog>
80104ff9:	83 c4 10             	add    $0x10,%esp
     }

     // Return to "caller", actually trapret (see allocproc).
}
80104ffc:	90                   	nop
80104ffd:	c9                   	leave  
80104ffe:	c3                   	ret    

80104fff <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void* chan, struct spinlock* lk)
{
80104fff:	55                   	push   %ebp
80105000:	89 e5                	mov    %esp,%ebp
80105002:	83 ec 08             	sub    $0x8,%esp
     if (proc == 0)
80105005:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010500b:	85 c0                	test   %eax,%eax
8010500d:	75 0d                	jne    8010501c <sleep+0x1d>
          panic("sleep");
8010500f:	83 ec 0c             	sub    $0xc,%esp
80105012:	68 ec 8d 10 80       	push   $0x80108dec
80105017:	e8 4a b5 ff ff       	call   80100566 <panic>

     if (lk == 0)
8010501c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105020:	75 0d                	jne    8010502f <sleep+0x30>
          panic("sleep without lk");
80105022:	83 ec 0c             	sub    $0xc,%esp
80105025:	68 f2 8d 10 80       	push   $0x80108df2
8010502a:	e8 37 b5 ff ff       	call   80100566 <panic>
     // change p->state and then call sched.
     // Once we hold ptable.lock, we can be
     // guaranteed that we won't miss any wakeup
     // (wakeup runs with ptable.lock locked),
     // so it's okay to release lk.
     if (lk != &ptable.lock)
8010502f:	81 7d 0c 60 39 11 80 	cmpl   $0x80113960,0xc(%ebp)
80105036:	74 1e                	je     80105056 <sleep+0x57>
     {                        // DOC: sleeplock0
          acquire(&ptable.lock); // DOC: sleeplock1
80105038:	83 ec 0c             	sub    $0xc,%esp
8010503b:	68 60 39 11 80       	push   $0x80113960
80105040:	e8 25 04 00 00       	call   8010546a <acquire>
80105045:	83 c4 10             	add    $0x10,%esp
          release(lk);
80105048:	83 ec 0c             	sub    $0xc,%esp
8010504b:	ff 75 0c             	pushl  0xc(%ebp)
8010504e:	e8 7e 04 00 00       	call   801054d1 <release>
80105053:	83 c4 10             	add    $0x10,%esp
     }

     // Go to sleep.
     proc->chan = chan;
80105056:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505c:	8b 55 08             	mov    0x8(%ebp),%edx
8010505f:	89 50 28             	mov    %edx,0x28(%eax)
     proc->state = SLEEPING;
80105062:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105068:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
     sched();
8010506f:	e8 4e fe ff ff       	call   80104ec2 <sched>

     // Tidy up.
     proc->chan = 0;
80105074:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010507a:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

     // Reacquire original lock.
     if (lk != &ptable.lock)
80105081:	81 7d 0c 60 39 11 80 	cmpl   $0x80113960,0xc(%ebp)
80105088:	74 1e                	je     801050a8 <sleep+0xa9>
     { // DOC: sleeplock2
          release(&ptable.lock);
8010508a:	83 ec 0c             	sub    $0xc,%esp
8010508d:	68 60 39 11 80       	push   $0x80113960
80105092:	e8 3a 04 00 00       	call   801054d1 <release>
80105097:	83 c4 10             	add    $0x10,%esp
          acquire(lk);
8010509a:	83 ec 0c             	sub    $0xc,%esp
8010509d:	ff 75 0c             	pushl  0xc(%ebp)
801050a0:	e8 c5 03 00 00       	call   8010546a <acquire>
801050a5:	83 c4 10             	add    $0x10,%esp
     }
}
801050a8:	90                   	nop
801050a9:	c9                   	leave  
801050aa:	c3                   	ret    

801050ab <wakeup1>:
// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void* chan)
{
801050ab:	55                   	push   %ebp
801050ac:	89 e5                	mov    %esp,%ebp
801050ae:	83 ec 10             	sub    $0x10,%esp
     struct proc* p;

     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050b1:	c7 45 fc 94 39 11 80 	movl   $0x80113994,-0x4(%ebp)
801050b8:	eb 27                	jmp    801050e1 <wakeup1+0x36>
          if (p->state == SLEEPING && p->chan == chan)
801050ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050bd:	8b 40 14             	mov    0x14(%eax),%eax
801050c0:	83 f8 02             	cmp    $0x2,%eax
801050c3:	75 15                	jne    801050da <wakeup1+0x2f>
801050c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050c8:	8b 40 28             	mov    0x28(%eax),%eax
801050cb:	3b 45 08             	cmp    0x8(%ebp),%eax
801050ce:	75 0a                	jne    801050da <wakeup1+0x2f>
               p->state = RUNNABLE;
801050d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050d3:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
static void
wakeup1(void* chan)
{
     struct proc* p;

     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050da:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801050e1:	81 7d fc 94 5a 11 80 	cmpl   $0x80115a94,-0x4(%ebp)
801050e8:	72 d0                	jb     801050ba <wakeup1+0xf>
          if (p->state == SLEEPING && p->chan == chan)
               p->state = RUNNABLE;
}
801050ea:	90                   	nop
801050eb:	c9                   	leave  
801050ec:	c3                   	ret    

801050ed <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void* chan)
{
801050ed:	55                   	push   %ebp
801050ee:	89 e5                	mov    %esp,%ebp
801050f0:	83 ec 08             	sub    $0x8,%esp
     acquire(&ptable.lock);
801050f3:	83 ec 0c             	sub    $0xc,%esp
801050f6:	68 60 39 11 80       	push   $0x80113960
801050fb:	e8 6a 03 00 00       	call   8010546a <acquire>
80105100:	83 c4 10             	add    $0x10,%esp
     wakeup1(chan);
80105103:	83 ec 0c             	sub    $0xc,%esp
80105106:	ff 75 08             	pushl  0x8(%ebp)
80105109:	e8 9d ff ff ff       	call   801050ab <wakeup1>
8010510e:	83 c4 10             	add    $0x10,%esp
     release(&ptable.lock);
80105111:	83 ec 0c             	sub    $0xc,%esp
80105114:	68 60 39 11 80       	push   $0x80113960
80105119:	e8 b3 03 00 00       	call   801054d1 <release>
8010511e:	83 c4 10             	add    $0x10,%esp
}
80105121:	90                   	nop
80105122:	c9                   	leave  
80105123:	c3                   	ret    

80105124 <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
80105124:	55                   	push   %ebp
80105125:	89 e5                	mov    %esp,%ebp
80105127:	83 ec 18             	sub    $0x18,%esp
     struct proc* p;

     acquire(&ptable.lock);
8010512a:	83 ec 0c             	sub    $0xc,%esp
8010512d:	68 60 39 11 80       	push   $0x80113960
80105132:	e8 33 03 00 00       	call   8010546a <acquire>
80105137:	83 c4 10             	add    $0x10,%esp
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010513a:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80105141:	eb 48                	jmp    8010518b <kill+0x67>
     {
          if (p->pid == pid)
80105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105146:	8b 40 18             	mov    0x18(%eax),%eax
80105149:	3b 45 08             	cmp    0x8(%ebp),%eax
8010514c:	75 36                	jne    80105184 <kill+0x60>
          {
               p->killed = 1;
8010514e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105151:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
               // Wake process from sleep if necessary.
               if (p->state == SLEEPING)
80105158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515b:	8b 40 14             	mov    0x14(%eax),%eax
8010515e:	83 f8 02             	cmp    $0x2,%eax
80105161:	75 0a                	jne    8010516d <kill+0x49>
                    p->state = RUNNABLE;
80105163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105166:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
               release(&ptable.lock);
8010516d:	83 ec 0c             	sub    $0xc,%esp
80105170:	68 60 39 11 80       	push   $0x80113960
80105175:	e8 57 03 00 00       	call   801054d1 <release>
8010517a:	83 c4 10             	add    $0x10,%esp
               return 0;
8010517d:	b8 00 00 00 00       	mov    $0x0,%eax
80105182:	eb 25                	jmp    801051a9 <kill+0x85>
int kill(int pid)
{
     struct proc* p;

     acquire(&ptable.lock);
     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105184:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010518b:	81 7d f4 94 5a 11 80 	cmpl   $0x80115a94,-0xc(%ebp)
80105192:	72 af                	jb     80105143 <kill+0x1f>
                    p->state = RUNNABLE;
               release(&ptable.lock);
               return 0;
          }
     }
     release(&ptable.lock);
80105194:	83 ec 0c             	sub    $0xc,%esp
80105197:	68 60 39 11 80       	push   $0x80113960
8010519c:	e8 30 03 00 00       	call   801054d1 <release>
801051a1:	83 c4 10             	add    $0x10,%esp
     return -1;
801051a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051a9:	c9                   	leave  
801051aa:	c3                   	ret    

801051ab <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
801051ab:	55                   	push   %ebp
801051ac:	89 e5                	mov    %esp,%ebp
801051ae:	83 ec 48             	sub    $0x48,%esp
     int i;
     struct proc* p;
     char* state;
     uint pc[10];

     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801051b1:	c7 45 f0 94 39 11 80 	movl   $0x80113994,-0x10(%ebp)
801051b8:	e9 da 00 00 00       	jmp    80105297 <procdump+0xec>
     {
          if (p->state == UNUSED)
801051bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c0:	8b 40 14             	mov    0x14(%eax),%eax
801051c3:	85 c0                	test   %eax,%eax
801051c5:	0f 84 c4 00 00 00    	je     8010528f <procdump+0xe4>
               continue;
          if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ce:	8b 40 14             	mov    0x14(%eax),%eax
801051d1:	83 f8 05             	cmp    $0x5,%eax
801051d4:	77 23                	ja     801051f9 <procdump+0x4e>
801051d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d9:	8b 40 14             	mov    0x14(%eax),%eax
801051dc:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801051e3:	85 c0                	test   %eax,%eax
801051e5:	74 12                	je     801051f9 <procdump+0x4e>
               state = states[p->state];
801051e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ea:	8b 40 14             	mov    0x14(%eax),%eax
801051ed:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801051f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051f7:	eb 07                	jmp    80105200 <procdump+0x55>
          else
               state = "???";
801051f9:	c7 45 ec 03 8e 10 80 	movl   $0x80108e03,-0x14(%ebp)
          cprintf("%d %s %s", p->pid, state, p->name);
80105200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105203:	8d 50 74             	lea    0x74(%eax),%edx
80105206:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105209:	8b 40 18             	mov    0x18(%eax),%eax
8010520c:	52                   	push   %edx
8010520d:	ff 75 ec             	pushl  -0x14(%ebp)
80105210:	50                   	push   %eax
80105211:	68 07 8e 10 80       	push   $0x80108e07
80105216:	e8 ab b1 ff ff       	call   801003c6 <cprintf>
8010521b:	83 c4 10             	add    $0x10,%esp
          if (p->state == SLEEPING)
8010521e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105221:	8b 40 14             	mov    0x14(%eax),%eax
80105224:	83 f8 02             	cmp    $0x2,%eax
80105227:	75 54                	jne    8010527d <procdump+0xd2>
          {
               getcallerpcs((uint*)p->context->ebp + 2, pc);
80105229:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522c:	8b 40 24             	mov    0x24(%eax),%eax
8010522f:	8b 40 0c             	mov    0xc(%eax),%eax
80105232:	83 c0 08             	add    $0x8,%eax
80105235:	89 c2                	mov    %eax,%edx
80105237:	83 ec 08             	sub    $0x8,%esp
8010523a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010523d:	50                   	push   %eax
8010523e:	52                   	push   %edx
8010523f:	e8 df 02 00 00       	call   80105523 <getcallerpcs>
80105244:	83 c4 10             	add    $0x10,%esp
               for (i = 0; i < 10 && pc[i] != 0; i++)
80105247:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010524e:	eb 1c                	jmp    8010526c <procdump+0xc1>
                    cprintf(" %p", pc[i]);
80105250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105253:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105257:	83 ec 08             	sub    $0x8,%esp
8010525a:	50                   	push   %eax
8010525b:	68 10 8e 10 80       	push   $0x80108e10
80105260:	e8 61 b1 ff ff       	call   801003c6 <cprintf>
80105265:	83 c4 10             	add    $0x10,%esp
               state = "???";
          cprintf("%d %s %s", p->pid, state, p->name);
          if (p->state == SLEEPING)
          {
               getcallerpcs((uint*)p->context->ebp + 2, pc);
               for (i = 0; i < 10 && pc[i] != 0; i++)
80105268:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010526c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105270:	7f 0b                	jg     8010527d <procdump+0xd2>
80105272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105275:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105279:	85 c0                	test   %eax,%eax
8010527b:	75 d3                	jne    80105250 <procdump+0xa5>
                    cprintf(" %p", pc[i]);
          }
          cprintf("\n");
8010527d:	83 ec 0c             	sub    $0xc,%esp
80105280:	68 14 8e 10 80       	push   $0x80108e14
80105285:	e8 3c b1 ff ff       	call   801003c6 <cprintf>
8010528a:	83 c4 10             	add    $0x10,%esp
8010528d:	eb 01                	jmp    80105290 <procdump+0xe5>
     uint pc[10];

     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
     {
          if (p->state == UNUSED)
               continue;
8010528f:	90                   	nop
     int i;
     struct proc* p;
     char* state;
     uint pc[10];

     for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105290:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105297:	81 7d f0 94 5a 11 80 	cmpl   $0x80115a94,-0x10(%ebp)
8010529e:	0f 82 19 ff ff ff    	jb     801051bd <procdump+0x12>
               for (i = 0; i < 10 && pc[i] != 0; i++)
                    cprintf(" %p", pc[i]);
          }
          cprintf("\n");
     }
}
801052a4:	90                   	nop
801052a5:	c9                   	leave  
801052a6:	c3                   	ret    

801052a7 <append>:

void append(struct proc* new_data, int priority)
{
801052a7:	55                   	push   %ebp
801052a8:	89 e5                	mov    %esp,%ebp
801052aa:	83 ec 10             	sub    $0x10,%esp
     struct QueueNode* newNode = 0; //= malloc(sizeof(struct QueueNode));
801052ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     newNode->data = new_data;
801052b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b7:	8b 55 08             	mov    0x8(%ebp),%edx
801052ba:	89 10                	mov    %edx,(%eax)
     newNode->boostCounter = 3;
801052bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052bf:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
     newNode->next = 0;
801052c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

     if (priority == 1)
801052d0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
801052d4:	75 43                	jne    80105319 <append+0x72>
     {
          newNode->quantumCounter = 1;
801052d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052d9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

          if (Queue1 == 0)
801052e0:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801052e5:	85 c0                	test   %eax,%eax
801052e7:	75 0a                	jne    801052f3 <append+0x4c>
               Queue1 = newNode;
801052e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ec:	a3 48 c6 10 80       	mov    %eax,0x8010c648
801052f1:	eb 26                	jmp    80105319 <append+0x72>

          else
          {
               struct QueueNode* p = Queue1;
801052f3:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801052f8:	89 45 fc             	mov    %eax,-0x4(%ebp)

               while (p->next != 0)
801052fb:	eb 09                	jmp    80105306 <append+0x5f>
               {
                    p = p->next;
801052fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105300:	8b 40 0c             	mov    0xc(%eax),%eax
80105303:	89 45 fc             	mov    %eax,-0x4(%ebp)

          else
          {
               struct QueueNode* p = Queue1;

               while (p->next != 0)
80105306:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105309:	8b 40 0c             	mov    0xc(%eax),%eax
8010530c:	85 c0                	test   %eax,%eax
8010530e:	75 ed                	jne    801052fd <append+0x56>
               {
                    p = p->next;
               }

               p->next = newNode;
80105310:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105313:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105316:	89 50 0c             	mov    %edx,0xc(%eax)
          }
     }
     if (priority == 2)
80105319:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
8010531d:	75 43                	jne    80105362 <append+0xbb>
     {
          newNode->quantumCounter = 3;
8010531f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105322:	c7 40 08 03 00 00 00 	movl   $0x3,0x8(%eax)

          if (Queue2 == 0)
80105329:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
8010532e:	85 c0                	test   %eax,%eax
80105330:	75 0a                	jne    8010533c <append+0x95>
               Queue2 = newNode;
80105332:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105335:	a3 4c c6 10 80       	mov    %eax,0x8010c64c
8010533a:	eb 26                	jmp    80105362 <append+0xbb>

          else
          {
               struct QueueNode* p = Queue2;
8010533c:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80105341:	89 45 f8             	mov    %eax,-0x8(%ebp)

               while (p->next != 0)
80105344:	eb 09                	jmp    8010534f <append+0xa8>
               {
                    p = p->next;
80105346:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105349:	8b 40 0c             	mov    0xc(%eax),%eax
8010534c:	89 45 f8             	mov    %eax,-0x8(%ebp)

          else
          {
               struct QueueNode* p = Queue2;

               while (p->next != 0)
8010534f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105352:	8b 40 0c             	mov    0xc(%eax),%eax
80105355:	85 c0                	test   %eax,%eax
80105357:	75 ed                	jne    80105346 <append+0x9f>
               {
                    p = p->next;
               }

               p->next = newNode;
80105359:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010535f:	89 50 0c             	mov    %edx,0xc(%eax)
          }
     }
     if (priority == 3)
80105362:	83 7d 0c 03          	cmpl   $0x3,0xc(%ebp)
80105366:	75 43                	jne    801053ab <append+0x104>
     {
          newNode->quantumCounter = 9;
80105368:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010536b:	c7 40 08 09 00 00 00 	movl   $0x9,0x8(%eax)

          if (Queue3 == 0)
80105372:	a1 50 c6 10 80       	mov    0x8010c650,%eax
80105377:	85 c0                	test   %eax,%eax
80105379:	75 0a                	jne    80105385 <append+0xde>
               Queue3 = newNode;
8010537b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537e:	a3 50 c6 10 80       	mov    %eax,0x8010c650
               }

               p->next = newNode;
          }
     }
}
80105383:	eb 26                	jmp    801053ab <append+0x104>
          if (Queue3 == 0)
               Queue3 = newNode;

          else
          {
               struct QueueNode* p = Queue3;
80105385:	a1 50 c6 10 80       	mov    0x8010c650,%eax
8010538a:	89 45 f4             	mov    %eax,-0xc(%ebp)

               while (p->next != 0)
8010538d:	eb 09                	jmp    80105398 <append+0xf1>
               {
                    p = p->next;
8010538f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105392:	8b 40 0c             	mov    0xc(%eax),%eax
80105395:	89 45 f4             	mov    %eax,-0xc(%ebp)

          else
          {
               struct QueueNode* p = Queue3;

               while (p->next != 0)
80105398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539b:	8b 40 0c             	mov    0xc(%eax),%eax
8010539e:	85 c0                	test   %eax,%eax
801053a0:	75 ed                	jne    8010538f <append+0xe8>
               {
                    p = p->next;
               }

               p->next = newNode;
801053a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053a8:	89 50 0c             	mov    %edx,0xc(%eax)
          }
     }
}
801053ab:	90                   	nop
801053ac:	c9                   	leave  
801053ad:	c3                   	ret    

801053ae <deleteFirstNode>:

void deleteFirstNode(int priority)
{
801053ae:	55                   	push   %ebp
801053af:	89 e5                	mov    %esp,%ebp

     if (priority == 1) {
801053b1:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
801053b5:	75 16                	jne    801053cd <deleteFirstNode+0x1f>
          if (Queue1 == 0)
801053b7:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801053bc:	85 c0                	test   %eax,%eax
801053be:	74 47                	je     80105407 <deleteFirstNode+0x59>
               return;

          Queue1 = Queue1->next;
801053c0:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801053c5:	8b 40 0c             	mov    0xc(%eax),%eax
801053c8:	a3 48 c6 10 80       	mov    %eax,0x8010c648
     }
     if (priority == 2)
801053cd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
801053d1:	75 16                	jne    801053e9 <deleteFirstNode+0x3b>
     {
          if (Queue2 == 0)
801053d3:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801053d8:	85 c0                	test   %eax,%eax
801053da:	74 2e                	je     8010540a <deleteFirstNode+0x5c>
               return;

          Queue2 = Queue2->next;
801053dc:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801053e1:	8b 40 0c             	mov    0xc(%eax),%eax
801053e4:	a3 4c c6 10 80       	mov    %eax,0x8010c64c
     }
     if (priority == 3)
801053e9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
801053ed:	75 1f                	jne    8010540e <deleteFirstNode+0x60>
     {
          if (Queue3 == 0)
801053ef:	a1 50 c6 10 80       	mov    0x8010c650,%eax
801053f4:	85 c0                	test   %eax,%eax
801053f6:	74 15                	je     8010540d <deleteFirstNode+0x5f>
               return;

          Queue3 = Queue3->next;
801053f8:	a1 50 c6 10 80       	mov    0x8010c650,%eax
801053fd:	8b 40 0c             	mov    0xc(%eax),%eax
80105400:	a3 50 c6 10 80       	mov    %eax,0x8010c650
80105405:	eb 07                	jmp    8010540e <deleteFirstNode+0x60>
void deleteFirstNode(int priority)
{

     if (priority == 1) {
          if (Queue1 == 0)
               return;
80105407:	90                   	nop
80105408:	eb 04                	jmp    8010540e <deleteFirstNode+0x60>
          Queue1 = Queue1->next;
     }
     if (priority == 2)
     {
          if (Queue2 == 0)
               return;
8010540a:	90                   	nop
8010540b:	eb 01                	jmp    8010540e <deleteFirstNode+0x60>
          Queue2 = Queue2->next;
     }
     if (priority == 3)
     {
          if (Queue3 == 0)
               return;
8010540d:	90                   	nop

          Queue3 = Queue3->next;
     }
}
8010540e:	5d                   	pop    %ebp
8010540f:	c3                   	ret    

80105410 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105416:	9c                   	pushf  
80105417:	58                   	pop    %eax
80105418:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010541b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010541e:	c9                   	leave  
8010541f:	c3                   	ret    

80105420 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105420:	55                   	push   %ebp
80105421:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105423:	fa                   	cli    
}
80105424:	90                   	nop
80105425:	5d                   	pop    %ebp
80105426:	c3                   	ret    

80105427 <sti>:

static inline void
sti(void)
{
80105427:	55                   	push   %ebp
80105428:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010542a:	fb                   	sti    
}
8010542b:	90                   	nop
8010542c:	5d                   	pop    %ebp
8010542d:	c3                   	ret    

8010542e <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010542e:	55                   	push   %ebp
8010542f:	89 e5                	mov    %esp,%ebp
80105431:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105434:	8b 55 08             	mov    0x8(%ebp),%edx
80105437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010543d:	f0 87 02             	lock xchg %eax,(%edx)
80105440:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105443:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105446:	c9                   	leave  
80105447:	c3                   	ret    

80105448 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105448:	55                   	push   %ebp
80105449:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105451:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105454:	8b 45 08             	mov    0x8(%ebp),%eax
80105457:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010545d:	8b 45 08             	mov    0x8(%ebp),%eax
80105460:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105467:	90                   	nop
80105468:	5d                   	pop    %ebp
80105469:	c3                   	ret    

8010546a <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010546a:	55                   	push   %ebp
8010546b:	89 e5                	mov    %esp,%ebp
8010546d:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105470:	e8 52 01 00 00       	call   801055c7 <pushcli>
  if(holding(lk))
80105475:	8b 45 08             	mov    0x8(%ebp),%eax
80105478:	83 ec 0c             	sub    $0xc,%esp
8010547b:	50                   	push   %eax
8010547c:	e8 1c 01 00 00       	call   8010559d <holding>
80105481:	83 c4 10             	add    $0x10,%esp
80105484:	85 c0                	test   %eax,%eax
80105486:	74 0d                	je     80105495 <acquire+0x2b>
    panic("acquire");
80105488:	83 ec 0c             	sub    $0xc,%esp
8010548b:	68 40 8e 10 80       	push   $0x80108e40
80105490:	e8 d1 b0 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105495:	90                   	nop
80105496:	8b 45 08             	mov    0x8(%ebp),%eax
80105499:	83 ec 08             	sub    $0x8,%esp
8010549c:	6a 01                	push   $0x1
8010549e:	50                   	push   %eax
8010549f:	e8 8a ff ff ff       	call   8010542e <xchg>
801054a4:	83 c4 10             	add    $0x10,%esp
801054a7:	85 c0                	test   %eax,%eax
801054a9:	75 eb                	jne    80105496 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801054ab:	8b 45 08             	mov    0x8(%ebp),%eax
801054ae:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801054b5:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801054b8:	8b 45 08             	mov    0x8(%ebp),%eax
801054bb:	83 c0 0c             	add    $0xc,%eax
801054be:	83 ec 08             	sub    $0x8,%esp
801054c1:	50                   	push   %eax
801054c2:	8d 45 08             	lea    0x8(%ebp),%eax
801054c5:	50                   	push   %eax
801054c6:	e8 58 00 00 00       	call   80105523 <getcallerpcs>
801054cb:	83 c4 10             	add    $0x10,%esp
}
801054ce:	90                   	nop
801054cf:	c9                   	leave  
801054d0:	c3                   	ret    

801054d1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801054d1:	55                   	push   %ebp
801054d2:	89 e5                	mov    %esp,%ebp
801054d4:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801054d7:	83 ec 0c             	sub    $0xc,%esp
801054da:	ff 75 08             	pushl  0x8(%ebp)
801054dd:	e8 bb 00 00 00       	call   8010559d <holding>
801054e2:	83 c4 10             	add    $0x10,%esp
801054e5:	85 c0                	test   %eax,%eax
801054e7:	75 0d                	jne    801054f6 <release+0x25>
    panic("release");
801054e9:	83 ec 0c             	sub    $0xc,%esp
801054ec:	68 48 8e 10 80       	push   $0x80108e48
801054f1:	e8 70 b0 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801054f6:	8b 45 08             	mov    0x8(%ebp),%eax
801054f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105500:	8b 45 08             	mov    0x8(%ebp),%eax
80105503:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010550a:	8b 45 08             	mov    0x8(%ebp),%eax
8010550d:	83 ec 08             	sub    $0x8,%esp
80105510:	6a 00                	push   $0x0
80105512:	50                   	push   %eax
80105513:	e8 16 ff ff ff       	call   8010542e <xchg>
80105518:	83 c4 10             	add    $0x10,%esp

  popcli();
8010551b:	e8 ec 00 00 00       	call   8010560c <popcli>
}
80105520:	90                   	nop
80105521:	c9                   	leave  
80105522:	c3                   	ret    

80105523 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105523:	55                   	push   %ebp
80105524:	89 e5                	mov    %esp,%ebp
80105526:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105529:	8b 45 08             	mov    0x8(%ebp),%eax
8010552c:	83 e8 08             	sub    $0x8,%eax
8010552f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105532:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105539:	eb 38                	jmp    80105573 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010553b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010553f:	74 53                	je     80105594 <getcallerpcs+0x71>
80105541:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105548:	76 4a                	jbe    80105594 <getcallerpcs+0x71>
8010554a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010554e:	74 44                	je     80105594 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105550:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105553:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010555a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555d:	01 c2                	add    %eax,%edx
8010555f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105562:	8b 40 04             	mov    0x4(%eax),%eax
80105565:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010556a:	8b 00                	mov    (%eax),%eax
8010556c:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010556f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105573:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105577:	7e c2                	jle    8010553b <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105579:	eb 19                	jmp    80105594 <getcallerpcs+0x71>
    pcs[i] = 0;
8010557b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010557e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105585:	8b 45 0c             	mov    0xc(%ebp),%eax
80105588:	01 d0                	add    %edx,%eax
8010558a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105590:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105594:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105598:	7e e1                	jle    8010557b <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010559a:	90                   	nop
8010559b:	c9                   	leave  
8010559c:	c3                   	ret    

8010559d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010559d:	55                   	push   %ebp
8010559e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801055a0:	8b 45 08             	mov    0x8(%ebp),%eax
801055a3:	8b 00                	mov    (%eax),%eax
801055a5:	85 c0                	test   %eax,%eax
801055a7:	74 17                	je     801055c0 <holding+0x23>
801055a9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ac:	8b 50 08             	mov    0x8(%eax),%edx
801055af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055b5:	39 c2                	cmp    %eax,%edx
801055b7:	75 07                	jne    801055c0 <holding+0x23>
801055b9:	b8 01 00 00 00       	mov    $0x1,%eax
801055be:	eb 05                	jmp    801055c5 <holding+0x28>
801055c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055c5:	5d                   	pop    %ebp
801055c6:	c3                   	ret    

801055c7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801055c7:	55                   	push   %ebp
801055c8:	89 e5                	mov    %esp,%ebp
801055ca:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801055cd:	e8 3e fe ff ff       	call   80105410 <readeflags>
801055d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801055d5:	e8 46 fe ff ff       	call   80105420 <cli>
  if(cpu->ncli++ == 0)
801055da:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801055e1:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801055e7:	8d 48 01             	lea    0x1(%eax),%ecx
801055ea:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801055f0:	85 c0                	test   %eax,%eax
801055f2:	75 15                	jne    80105609 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801055f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055fd:	81 e2 00 02 00 00    	and    $0x200,%edx
80105603:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105609:	90                   	nop
8010560a:	c9                   	leave  
8010560b:	c3                   	ret    

8010560c <popcli>:

void
popcli(void)
{
8010560c:	55                   	push   %ebp
8010560d:	89 e5                	mov    %esp,%ebp
8010560f:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105612:	e8 f9 fd ff ff       	call   80105410 <readeflags>
80105617:	25 00 02 00 00       	and    $0x200,%eax
8010561c:	85 c0                	test   %eax,%eax
8010561e:	74 0d                	je     8010562d <popcli+0x21>
    panic("popcli - interruptible");
80105620:	83 ec 0c             	sub    $0xc,%esp
80105623:	68 50 8e 10 80       	push   $0x80108e50
80105628:	e8 39 af ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010562d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105633:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105639:	83 ea 01             	sub    $0x1,%edx
8010563c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105642:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105648:	85 c0                	test   %eax,%eax
8010564a:	79 0d                	jns    80105659 <popcli+0x4d>
    panic("popcli");
8010564c:	83 ec 0c             	sub    $0xc,%esp
8010564f:	68 67 8e 10 80       	push   $0x80108e67
80105654:	e8 0d af ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105659:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010565f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105665:	85 c0                	test   %eax,%eax
80105667:	75 15                	jne    8010567e <popcli+0x72>
80105669:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010566f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105675:	85 c0                	test   %eax,%eax
80105677:	74 05                	je     8010567e <popcli+0x72>
    sti();
80105679:	e8 a9 fd ff ff       	call   80105427 <sti>
}
8010567e:	90                   	nop
8010567f:	c9                   	leave  
80105680:	c3                   	ret    

80105681 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105681:	55                   	push   %ebp
80105682:	89 e5                	mov    %esp,%ebp
80105684:	57                   	push   %edi
80105685:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105686:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105689:	8b 55 10             	mov    0x10(%ebp),%edx
8010568c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568f:	89 cb                	mov    %ecx,%ebx
80105691:	89 df                	mov    %ebx,%edi
80105693:	89 d1                	mov    %edx,%ecx
80105695:	fc                   	cld    
80105696:	f3 aa                	rep stos %al,%es:(%edi)
80105698:	89 ca                	mov    %ecx,%edx
8010569a:	89 fb                	mov    %edi,%ebx
8010569c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010569f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801056a2:	90                   	nop
801056a3:	5b                   	pop    %ebx
801056a4:	5f                   	pop    %edi
801056a5:	5d                   	pop    %ebp
801056a6:	c3                   	ret    

801056a7 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801056a7:	55                   	push   %ebp
801056a8:	89 e5                	mov    %esp,%ebp
801056aa:	57                   	push   %edi
801056ab:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801056ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
801056af:	8b 55 10             	mov    0x10(%ebp),%edx
801056b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b5:	89 cb                	mov    %ecx,%ebx
801056b7:	89 df                	mov    %ebx,%edi
801056b9:	89 d1                	mov    %edx,%ecx
801056bb:	fc                   	cld    
801056bc:	f3 ab                	rep stos %eax,%es:(%edi)
801056be:	89 ca                	mov    %ecx,%edx
801056c0:	89 fb                	mov    %edi,%ebx
801056c2:	89 5d 08             	mov    %ebx,0x8(%ebp)
801056c5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801056c8:	90                   	nop
801056c9:	5b                   	pop    %ebx
801056ca:	5f                   	pop    %edi
801056cb:	5d                   	pop    %ebp
801056cc:	c3                   	ret    

801056cd <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801056cd:	55                   	push   %ebp
801056ce:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801056d0:	8b 45 08             	mov    0x8(%ebp),%eax
801056d3:	83 e0 03             	and    $0x3,%eax
801056d6:	85 c0                	test   %eax,%eax
801056d8:	75 43                	jne    8010571d <memset+0x50>
801056da:	8b 45 10             	mov    0x10(%ebp),%eax
801056dd:	83 e0 03             	and    $0x3,%eax
801056e0:	85 c0                	test   %eax,%eax
801056e2:	75 39                	jne    8010571d <memset+0x50>
    c &= 0xFF;
801056e4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801056eb:	8b 45 10             	mov    0x10(%ebp),%eax
801056ee:	c1 e8 02             	shr    $0x2,%eax
801056f1:	89 c1                	mov    %eax,%ecx
801056f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f6:	c1 e0 18             	shl    $0x18,%eax
801056f9:	89 c2                	mov    %eax,%edx
801056fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801056fe:	c1 e0 10             	shl    $0x10,%eax
80105701:	09 c2                	or     %eax,%edx
80105703:	8b 45 0c             	mov    0xc(%ebp),%eax
80105706:	c1 e0 08             	shl    $0x8,%eax
80105709:	09 d0                	or     %edx,%eax
8010570b:	0b 45 0c             	or     0xc(%ebp),%eax
8010570e:	51                   	push   %ecx
8010570f:	50                   	push   %eax
80105710:	ff 75 08             	pushl  0x8(%ebp)
80105713:	e8 8f ff ff ff       	call   801056a7 <stosl>
80105718:	83 c4 0c             	add    $0xc,%esp
8010571b:	eb 12                	jmp    8010572f <memset+0x62>
  } else
    stosb(dst, c, n);
8010571d:	8b 45 10             	mov    0x10(%ebp),%eax
80105720:	50                   	push   %eax
80105721:	ff 75 0c             	pushl  0xc(%ebp)
80105724:	ff 75 08             	pushl  0x8(%ebp)
80105727:	e8 55 ff ff ff       	call   80105681 <stosb>
8010572c:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010572f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105732:	c9                   	leave  
80105733:	c3                   	ret    

80105734 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105734:	55                   	push   %ebp
80105735:	89 e5                	mov    %esp,%ebp
80105737:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010573a:	8b 45 08             	mov    0x8(%ebp),%eax
8010573d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105740:	8b 45 0c             	mov    0xc(%ebp),%eax
80105743:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105746:	eb 30                	jmp    80105778 <memcmp+0x44>
    if(*s1 != *s2)
80105748:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010574b:	0f b6 10             	movzbl (%eax),%edx
8010574e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105751:	0f b6 00             	movzbl (%eax),%eax
80105754:	38 c2                	cmp    %al,%dl
80105756:	74 18                	je     80105770 <memcmp+0x3c>
      return *s1 - *s2;
80105758:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010575b:	0f b6 00             	movzbl (%eax),%eax
8010575e:	0f b6 d0             	movzbl %al,%edx
80105761:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105764:	0f b6 00             	movzbl (%eax),%eax
80105767:	0f b6 c0             	movzbl %al,%eax
8010576a:	29 c2                	sub    %eax,%edx
8010576c:	89 d0                	mov    %edx,%eax
8010576e:	eb 1a                	jmp    8010578a <memcmp+0x56>
    s1++, s2++;
80105770:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105774:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105778:	8b 45 10             	mov    0x10(%ebp),%eax
8010577b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010577e:	89 55 10             	mov    %edx,0x10(%ebp)
80105781:	85 c0                	test   %eax,%eax
80105783:	75 c3                	jne    80105748 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105785:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010578a:	c9                   	leave  
8010578b:	c3                   	ret    

8010578c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010578c:	55                   	push   %ebp
8010578d:	89 e5                	mov    %esp,%ebp
8010578f:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105792:	8b 45 0c             	mov    0xc(%ebp),%eax
80105795:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105798:	8b 45 08             	mov    0x8(%ebp),%eax
8010579b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010579e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057a4:	73 54                	jae    801057fa <memmove+0x6e>
801057a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057a9:	8b 45 10             	mov    0x10(%ebp),%eax
801057ac:	01 d0                	add    %edx,%eax
801057ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057b1:	76 47                	jbe    801057fa <memmove+0x6e>
    s += n;
801057b3:	8b 45 10             	mov    0x10(%ebp),%eax
801057b6:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801057b9:	8b 45 10             	mov    0x10(%ebp),%eax
801057bc:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801057bf:	eb 13                	jmp    801057d4 <memmove+0x48>
      *--d = *--s;
801057c1:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801057c5:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801057c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057cc:	0f b6 10             	movzbl (%eax),%edx
801057cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057d2:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801057d4:	8b 45 10             	mov    0x10(%ebp),%eax
801057d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801057da:	89 55 10             	mov    %edx,0x10(%ebp)
801057dd:	85 c0                	test   %eax,%eax
801057df:	75 e0                	jne    801057c1 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801057e1:	eb 24                	jmp    80105807 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801057e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057e6:	8d 50 01             	lea    0x1(%eax),%edx
801057e9:	89 55 f8             	mov    %edx,-0x8(%ebp)
801057ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057ef:	8d 4a 01             	lea    0x1(%edx),%ecx
801057f2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801057f5:	0f b6 12             	movzbl (%edx),%edx
801057f8:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801057fa:	8b 45 10             	mov    0x10(%ebp),%eax
801057fd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105800:	89 55 10             	mov    %edx,0x10(%ebp)
80105803:	85 c0                	test   %eax,%eax
80105805:	75 dc                	jne    801057e3 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105807:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010580a:	c9                   	leave  
8010580b:	c3                   	ret    

8010580c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010580c:	55                   	push   %ebp
8010580d:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010580f:	ff 75 10             	pushl  0x10(%ebp)
80105812:	ff 75 0c             	pushl  0xc(%ebp)
80105815:	ff 75 08             	pushl  0x8(%ebp)
80105818:	e8 6f ff ff ff       	call   8010578c <memmove>
8010581d:	83 c4 0c             	add    $0xc,%esp
}
80105820:	c9                   	leave  
80105821:	c3                   	ret    

80105822 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105822:	55                   	push   %ebp
80105823:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105825:	eb 0c                	jmp    80105833 <strncmp+0x11>
    n--, p++, q++;
80105827:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010582b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010582f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105833:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105837:	74 1a                	je     80105853 <strncmp+0x31>
80105839:	8b 45 08             	mov    0x8(%ebp),%eax
8010583c:	0f b6 00             	movzbl (%eax),%eax
8010583f:	84 c0                	test   %al,%al
80105841:	74 10                	je     80105853 <strncmp+0x31>
80105843:	8b 45 08             	mov    0x8(%ebp),%eax
80105846:	0f b6 10             	movzbl (%eax),%edx
80105849:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584c:	0f b6 00             	movzbl (%eax),%eax
8010584f:	38 c2                	cmp    %al,%dl
80105851:	74 d4                	je     80105827 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105853:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105857:	75 07                	jne    80105860 <strncmp+0x3e>
    return 0;
80105859:	b8 00 00 00 00       	mov    $0x0,%eax
8010585e:	eb 16                	jmp    80105876 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105860:	8b 45 08             	mov    0x8(%ebp),%eax
80105863:	0f b6 00             	movzbl (%eax),%eax
80105866:	0f b6 d0             	movzbl %al,%edx
80105869:	8b 45 0c             	mov    0xc(%ebp),%eax
8010586c:	0f b6 00             	movzbl (%eax),%eax
8010586f:	0f b6 c0             	movzbl %al,%eax
80105872:	29 c2                	sub    %eax,%edx
80105874:	89 d0                	mov    %edx,%eax
}
80105876:	5d                   	pop    %ebp
80105877:	c3                   	ret    

80105878 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105878:	55                   	push   %ebp
80105879:	89 e5                	mov    %esp,%ebp
8010587b:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010587e:	8b 45 08             	mov    0x8(%ebp),%eax
80105881:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105884:	90                   	nop
80105885:	8b 45 10             	mov    0x10(%ebp),%eax
80105888:	8d 50 ff             	lea    -0x1(%eax),%edx
8010588b:	89 55 10             	mov    %edx,0x10(%ebp)
8010588e:	85 c0                	test   %eax,%eax
80105890:	7e 2c                	jle    801058be <strncpy+0x46>
80105892:	8b 45 08             	mov    0x8(%ebp),%eax
80105895:	8d 50 01             	lea    0x1(%eax),%edx
80105898:	89 55 08             	mov    %edx,0x8(%ebp)
8010589b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010589e:	8d 4a 01             	lea    0x1(%edx),%ecx
801058a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801058a4:	0f b6 12             	movzbl (%edx),%edx
801058a7:	88 10                	mov    %dl,(%eax)
801058a9:	0f b6 00             	movzbl (%eax),%eax
801058ac:	84 c0                	test   %al,%al
801058ae:	75 d5                	jne    80105885 <strncpy+0xd>
    ;
  while(n-- > 0)
801058b0:	eb 0c                	jmp    801058be <strncpy+0x46>
    *s++ = 0;
801058b2:	8b 45 08             	mov    0x8(%ebp),%eax
801058b5:	8d 50 01             	lea    0x1(%eax),%edx
801058b8:	89 55 08             	mov    %edx,0x8(%ebp)
801058bb:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801058be:	8b 45 10             	mov    0x10(%ebp),%eax
801058c1:	8d 50 ff             	lea    -0x1(%eax),%edx
801058c4:	89 55 10             	mov    %edx,0x10(%ebp)
801058c7:	85 c0                	test   %eax,%eax
801058c9:	7f e7                	jg     801058b2 <strncpy+0x3a>
    *s++ = 0;
  return os;
801058cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058ce:	c9                   	leave  
801058cf:	c3                   	ret    

801058d0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801058d0:	55                   	push   %ebp
801058d1:	89 e5                	mov    %esp,%ebp
801058d3:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801058d6:	8b 45 08             	mov    0x8(%ebp),%eax
801058d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801058dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058e0:	7f 05                	jg     801058e7 <safestrcpy+0x17>
    return os;
801058e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058e5:	eb 31                	jmp    80105918 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801058e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058ef:	7e 1e                	jle    8010590f <safestrcpy+0x3f>
801058f1:	8b 45 08             	mov    0x8(%ebp),%eax
801058f4:	8d 50 01             	lea    0x1(%eax),%edx
801058f7:	89 55 08             	mov    %edx,0x8(%ebp)
801058fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801058fd:	8d 4a 01             	lea    0x1(%edx),%ecx
80105900:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105903:	0f b6 12             	movzbl (%edx),%edx
80105906:	88 10                	mov    %dl,(%eax)
80105908:	0f b6 00             	movzbl (%eax),%eax
8010590b:	84 c0                	test   %al,%al
8010590d:	75 d8                	jne    801058e7 <safestrcpy+0x17>
    ;
  *s = 0;
8010590f:	8b 45 08             	mov    0x8(%ebp),%eax
80105912:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105915:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105918:	c9                   	leave  
80105919:	c3                   	ret    

8010591a <strlen>:

int
strlen(const char *s)
{
8010591a:	55                   	push   %ebp
8010591b:	89 e5                	mov    %esp,%ebp
8010591d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105920:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105927:	eb 04                	jmp    8010592d <strlen+0x13>
80105929:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010592d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105930:	8b 45 08             	mov    0x8(%ebp),%eax
80105933:	01 d0                	add    %edx,%eax
80105935:	0f b6 00             	movzbl (%eax),%eax
80105938:	84 c0                	test   %al,%al
8010593a:	75 ed                	jne    80105929 <strlen+0xf>
    ;
  return n;
8010593c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010593f:	c9                   	leave  
80105940:	c3                   	ret    

80105941 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105941:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105945:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105949:	55                   	push   %ebp
  pushl %ebx
8010594a:	53                   	push   %ebx
  pushl %esi
8010594b:	56                   	push   %esi
  pushl %edi
8010594c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010594d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010594f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105951:	5f                   	pop    %edi
  popl %esi
80105952:	5e                   	pop    %esi
  popl %ebx
80105953:	5b                   	pop    %ebx
  popl %ebp
80105954:	5d                   	pop    %ebp
  ret
80105955:	c3                   	ret    

80105956 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105956:	55                   	push   %ebp
80105957:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105959:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010595f:	8b 40 08             	mov    0x8(%eax),%eax
80105962:	3b 45 08             	cmp    0x8(%ebp),%eax
80105965:	76 13                	jbe    8010597a <fetchint+0x24>
80105967:	8b 45 08             	mov    0x8(%ebp),%eax
8010596a:	8d 50 04             	lea    0x4(%eax),%edx
8010596d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105973:	8b 40 08             	mov    0x8(%eax),%eax
80105976:	39 c2                	cmp    %eax,%edx
80105978:	76 07                	jbe    80105981 <fetchint+0x2b>
    return -1;
8010597a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597f:	eb 0f                	jmp    80105990 <fetchint+0x3a>
  *ip = *(int*)(addr);
80105981:	8b 45 08             	mov    0x8(%ebp),%eax
80105984:	8b 10                	mov    (%eax),%edx
80105986:	8b 45 0c             	mov    0xc(%ebp),%eax
80105989:	89 10                	mov    %edx,(%eax)
  return 0;
8010598b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105990:	5d                   	pop    %ebp
80105991:	c3                   	ret    

80105992 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105992:	55                   	push   %ebp
80105993:	89 e5                	mov    %esp,%ebp
80105995:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105998:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599e:	8b 40 08             	mov    0x8(%eax),%eax
801059a1:	3b 45 08             	cmp    0x8(%ebp),%eax
801059a4:	77 07                	ja     801059ad <fetchstr+0x1b>
    return -1;
801059a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ab:	eb 47                	jmp    801059f4 <fetchstr+0x62>
  *pp = (char*)addr;
801059ad:	8b 55 08             	mov    0x8(%ebp),%edx
801059b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801059b3:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801059b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059bb:	8b 40 08             	mov    0x8(%eax),%eax
801059be:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801059c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801059c4:	8b 00                	mov    (%eax),%eax
801059c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
801059c9:	eb 1c                	jmp    801059e7 <fetchstr+0x55>
    if(*s == 0)
801059cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ce:	0f b6 00             	movzbl (%eax),%eax
801059d1:	84 c0                	test   %al,%al
801059d3:	75 0e                	jne    801059e3 <fetchstr+0x51>
      return s - *pp;
801059d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801059db:	8b 00                	mov    (%eax),%eax
801059dd:	29 c2                	sub    %eax,%edx
801059df:	89 d0                	mov    %edx,%eax
801059e1:	eb 11                	jmp    801059f4 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801059e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059ed:	72 dc                	jb     801059cb <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  return -1;
801059ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059f4:	c9                   	leave  
801059f5:	c3                   	ret    

801059f6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801059f6:	55                   	push   %ebp
801059f7:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801059f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ff:	8b 40 20             	mov    0x20(%eax),%eax
80105a02:	8b 40 44             	mov    0x44(%eax),%eax
80105a05:	8b 55 08             	mov    0x8(%ebp),%edx
80105a08:	c1 e2 02             	shl    $0x2,%edx
80105a0b:	01 d0                	add    %edx,%eax
80105a0d:	83 c0 04             	add    $0x4,%eax
80105a10:	ff 75 0c             	pushl  0xc(%ebp)
80105a13:	50                   	push   %eax
80105a14:	e8 3d ff ff ff       	call   80105956 <fetchint>
80105a19:	83 c4 08             	add    $0x8,%esp
}
80105a1c:	c9                   	leave  
80105a1d:	c3                   	ret    

80105a1e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105a1e:	55                   	push   %ebp
80105a1f:	89 e5                	mov    %esp,%ebp
80105a21:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105a24:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a27:	50                   	push   %eax
80105a28:	ff 75 08             	pushl  0x8(%ebp)
80105a2b:	e8 c6 ff ff ff       	call   801059f6 <argint>
80105a30:	83 c4 08             	add    $0x8,%esp
80105a33:	85 c0                	test   %eax,%eax
80105a35:	79 07                	jns    80105a3e <argptr+0x20>
    return -1;
80105a37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3c:	eb 3d                	jmp    80105a7b <argptr+0x5d>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105a3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a44:	8b 40 08             	mov    0x8(%eax),%eax
80105a47:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a4a:	39 d0                	cmp    %edx,%eax
80105a4c:	76 17                	jbe    80105a65 <argptr+0x47>
80105a4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a51:	89 c2                	mov    %eax,%edx
80105a53:	8b 45 10             	mov    0x10(%ebp),%eax
80105a56:	01 c2                	add    %eax,%edx
80105a58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a5e:	8b 40 08             	mov    0x8(%eax),%eax
80105a61:	39 c2                	cmp    %eax,%edx
80105a63:	76 07                	jbe    80105a6c <argptr+0x4e>
    return -1;
80105a65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6a:	eb 0f                	jmp    80105a7b <argptr+0x5d>
  *pp = (char*)i;
80105a6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a6f:	89 c2                	mov    %eax,%edx
80105a71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a74:	89 10                	mov    %edx,(%eax)
  return 0;
80105a76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a7b:	c9                   	leave  
80105a7c:	c3                   	ret    

80105a7d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a7d:	55                   	push   %ebp
80105a7e:	89 e5                	mov    %esp,%ebp
80105a80:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a83:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a86:	50                   	push   %eax
80105a87:	ff 75 08             	pushl  0x8(%ebp)
80105a8a:	e8 67 ff ff ff       	call   801059f6 <argint>
80105a8f:	83 c4 08             	add    $0x8,%esp
80105a92:	85 c0                	test   %eax,%eax
80105a94:	79 07                	jns    80105a9d <argstr+0x20>
    return -1;
80105a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9b:	eb 0f                	jmp    80105aac <argstr+0x2f>
  return fetchstr(addr, pp);
80105a9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aa0:	ff 75 0c             	pushl  0xc(%ebp)
80105aa3:	50                   	push   %eax
80105aa4:	e8 e9 fe ff ff       	call   80105992 <fetchstr>
80105aa9:	83 c4 08             	add    $0x8,%esp
}
80105aac:	c9                   	leave  
80105aad:	c3                   	ret    

80105aae <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105aae:	55                   	push   %ebp
80105aaf:	89 e5                	mov    %esp,%ebp
80105ab1:	53                   	push   %ebx
80105ab2:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105abb:	8b 40 20             	mov    0x20(%eax),%eax
80105abe:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ac1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105ac4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac8:	7e 30                	jle    80105afa <syscall+0x4c>
80105aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acd:	83 f8 15             	cmp    $0x15,%eax
80105ad0:	77 28                	ja     80105afa <syscall+0x4c>
80105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad5:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105adc:	85 c0                	test   %eax,%eax
80105ade:	74 1a                	je     80105afa <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105ae0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ae6:	8b 58 20             	mov    0x20(%eax),%ebx
80105ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aec:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105af3:	ff d0                	call   *%eax
80105af5:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105af8:	eb 34                	jmp    80105b2e <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105afa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b00:	8d 50 74             	lea    0x74(%eax),%edx
80105b03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105b09:	8b 40 18             	mov    0x18(%eax),%eax
80105b0c:	ff 75 f4             	pushl  -0xc(%ebp)
80105b0f:	52                   	push   %edx
80105b10:	50                   	push   %eax
80105b11:	68 6e 8e 10 80       	push   $0x80108e6e
80105b16:	e8 ab a8 ff ff       	call   801003c6 <cprintf>
80105b1b:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105b1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b24:	8b 40 20             	mov    0x20(%eax),%eax
80105b27:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105b2e:	90                   	nop
80105b2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b32:	c9                   	leave  
80105b33:	c3                   	ret    

80105b34 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105b34:	55                   	push   %ebp
80105b35:	89 e5                	mov    %esp,%ebp
80105b37:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105b3a:	83 ec 08             	sub    $0x8,%esp
80105b3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b40:	50                   	push   %eax
80105b41:	ff 75 08             	pushl  0x8(%ebp)
80105b44:	e8 ad fe ff ff       	call   801059f6 <argint>
80105b49:	83 c4 10             	add    $0x10,%esp
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	79 07                	jns    80105b57 <argfd+0x23>
    return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b55:	eb 4f                	jmp    80105ba6 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5a:	85 c0                	test   %eax,%eax
80105b5c:	78 20                	js     80105b7e <argfd+0x4a>
80105b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b61:	83 f8 0f             	cmp    $0xf,%eax
80105b64:	7f 18                	jg     80105b7e <argfd+0x4a>
80105b66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b6f:	83 c2 0c             	add    $0xc,%edx
80105b72:	8b 04 90             	mov    (%eax,%edx,4),%eax
80105b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b7c:	75 07                	jne    80105b85 <argfd+0x51>
    return -1;
80105b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b83:	eb 21                	jmp    80105ba6 <argfd+0x72>
  if(pfd)
80105b85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b89:	74 08                	je     80105b93 <argfd+0x5f>
    *pfd = fd;
80105b8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b91:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b97:	74 08                	je     80105ba1 <argfd+0x6d>
    *pf = f;
80105b99:	8b 45 10             	mov    0x10(%ebp),%eax
80105b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b9f:	89 10                	mov    %edx,(%eax)
  return 0;
80105ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba6:	c9                   	leave  
80105ba7:	c3                   	ret    

80105ba8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ba8:	55                   	push   %ebp
80105ba9:	89 e5                	mov    %esp,%ebp
80105bab:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105bae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105bb5:	eb 2e                	jmp    80105be5 <fdalloc+0x3d>
    if(proc->ofile[fd] == 0){
80105bb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bbd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bc0:	83 c2 0c             	add    $0xc,%edx
80105bc3:	8b 04 90             	mov    (%eax,%edx,4),%eax
80105bc6:	85 c0                	test   %eax,%eax
80105bc8:	75 17                	jne    80105be1 <fdalloc+0x39>
      proc->ofile[fd] = f;
80105bca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bd0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bd3:	8d 4a 0c             	lea    0xc(%edx),%ecx
80105bd6:	8b 55 08             	mov    0x8(%ebp),%edx
80105bd9:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      return fd;
80105bdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bdf:	eb 0f                	jmp    80105bf0 <fdalloc+0x48>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105be1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105be5:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105be9:	7e cc                	jle    80105bb7 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bf0:	c9                   	leave  
80105bf1:	c3                   	ret    

80105bf2 <sys_dup>:

int
sys_dup(void)
{
80105bf2:	55                   	push   %ebp
80105bf3:	89 e5                	mov    %esp,%ebp
80105bf5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105bf8:	83 ec 04             	sub    $0x4,%esp
80105bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bfe:	50                   	push   %eax
80105bff:	6a 00                	push   $0x0
80105c01:	6a 00                	push   $0x0
80105c03:	e8 2c ff ff ff       	call   80105b34 <argfd>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	85 c0                	test   %eax,%eax
80105c0d:	79 07                	jns    80105c16 <sys_dup+0x24>
    return -1;
80105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c14:	eb 31                	jmp    80105c47 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c19:	83 ec 0c             	sub    $0xc,%esp
80105c1c:	50                   	push   %eax
80105c1d:	e8 86 ff ff ff       	call   80105ba8 <fdalloc>
80105c22:	83 c4 10             	add    $0x10,%esp
80105c25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c2c:	79 07                	jns    80105c35 <sys_dup+0x43>
    return -1;
80105c2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c33:	eb 12                	jmp    80105c47 <sys_dup+0x55>
  filedup(f);
80105c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c38:	83 ec 0c             	sub    $0xc,%esp
80105c3b:	50                   	push   %eax
80105c3c:	e8 c0 b3 ff ff       	call   80101001 <filedup>
80105c41:	83 c4 10             	add    $0x10,%esp
  return fd;
80105c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c47:	c9                   	leave  
80105c48:	c3                   	ret    

80105c49 <sys_read>:

int
sys_read(void)
{
80105c49:	55                   	push   %ebp
80105c4a:	89 e5                	mov    %esp,%ebp
80105c4c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c4f:	83 ec 04             	sub    $0x4,%esp
80105c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c55:	50                   	push   %eax
80105c56:	6a 00                	push   $0x0
80105c58:	6a 00                	push   $0x0
80105c5a:	e8 d5 fe ff ff       	call   80105b34 <argfd>
80105c5f:	83 c4 10             	add    $0x10,%esp
80105c62:	85 c0                	test   %eax,%eax
80105c64:	78 2e                	js     80105c94 <sys_read+0x4b>
80105c66:	83 ec 08             	sub    $0x8,%esp
80105c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6c:	50                   	push   %eax
80105c6d:	6a 02                	push   $0x2
80105c6f:	e8 82 fd ff ff       	call   801059f6 <argint>
80105c74:	83 c4 10             	add    $0x10,%esp
80105c77:	85 c0                	test   %eax,%eax
80105c79:	78 19                	js     80105c94 <sys_read+0x4b>
80105c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7e:	83 ec 04             	sub    $0x4,%esp
80105c81:	50                   	push   %eax
80105c82:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c85:	50                   	push   %eax
80105c86:	6a 01                	push   $0x1
80105c88:	e8 91 fd ff ff       	call   80105a1e <argptr>
80105c8d:	83 c4 10             	add    $0x10,%esp
80105c90:	85 c0                	test   %eax,%eax
80105c92:	79 07                	jns    80105c9b <sys_read+0x52>
    return -1;
80105c94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c99:	eb 17                	jmp    80105cb2 <sys_read+0x69>
  return fileread(f, p, n);
80105c9b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c9e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca4:	83 ec 04             	sub    $0x4,%esp
80105ca7:	51                   	push   %ecx
80105ca8:	52                   	push   %edx
80105ca9:	50                   	push   %eax
80105caa:	e8 e2 b4 ff ff       	call   80101191 <fileread>
80105caf:	83 c4 10             	add    $0x10,%esp
}
80105cb2:	c9                   	leave  
80105cb3:	c3                   	ret    

80105cb4 <sys_write>:

int
sys_write(void)
{
80105cb4:	55                   	push   %ebp
80105cb5:	89 e5                	mov    %esp,%ebp
80105cb7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105cba:	83 ec 04             	sub    $0x4,%esp
80105cbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cc0:	50                   	push   %eax
80105cc1:	6a 00                	push   $0x0
80105cc3:	6a 00                	push   $0x0
80105cc5:	e8 6a fe ff ff       	call   80105b34 <argfd>
80105cca:	83 c4 10             	add    $0x10,%esp
80105ccd:	85 c0                	test   %eax,%eax
80105ccf:	78 2e                	js     80105cff <sys_write+0x4b>
80105cd1:	83 ec 08             	sub    $0x8,%esp
80105cd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cd7:	50                   	push   %eax
80105cd8:	6a 02                	push   $0x2
80105cda:	e8 17 fd ff ff       	call   801059f6 <argint>
80105cdf:	83 c4 10             	add    $0x10,%esp
80105ce2:	85 c0                	test   %eax,%eax
80105ce4:	78 19                	js     80105cff <sys_write+0x4b>
80105ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce9:	83 ec 04             	sub    $0x4,%esp
80105cec:	50                   	push   %eax
80105ced:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cf0:	50                   	push   %eax
80105cf1:	6a 01                	push   $0x1
80105cf3:	e8 26 fd ff ff       	call   80105a1e <argptr>
80105cf8:	83 c4 10             	add    $0x10,%esp
80105cfb:	85 c0                	test   %eax,%eax
80105cfd:	79 07                	jns    80105d06 <sys_write+0x52>
    return -1;
80105cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d04:	eb 17                	jmp    80105d1d <sys_write+0x69>
  return filewrite(f, p, n);
80105d06:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d09:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0f:	83 ec 04             	sub    $0x4,%esp
80105d12:	51                   	push   %ecx
80105d13:	52                   	push   %edx
80105d14:	50                   	push   %eax
80105d15:	e8 2f b5 ff ff       	call   80101249 <filewrite>
80105d1a:	83 c4 10             	add    $0x10,%esp
}
80105d1d:	c9                   	leave  
80105d1e:	c3                   	ret    

80105d1f <sys_close>:

int
sys_close(void)
{
80105d1f:	55                   	push   %ebp
80105d20:	89 e5                	mov    %esp,%ebp
80105d22:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105d25:	83 ec 04             	sub    $0x4,%esp
80105d28:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d2b:	50                   	push   %eax
80105d2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d2f:	50                   	push   %eax
80105d30:	6a 00                	push   $0x0
80105d32:	e8 fd fd ff ff       	call   80105b34 <argfd>
80105d37:	83 c4 10             	add    $0x10,%esp
80105d3a:	85 c0                	test   %eax,%eax
80105d3c:	79 07                	jns    80105d45 <sys_close+0x26>
    return -1;
80105d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d43:	eb 27                	jmp    80105d6c <sys_close+0x4d>
  proc->ofile[fd] = 0;
80105d45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d4e:	83 c2 0c             	add    $0xc,%edx
80105d51:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  fileclose(f);
80105d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5b:	83 ec 0c             	sub    $0xc,%esp
80105d5e:	50                   	push   %eax
80105d5f:	e8 ee b2 ff ff       	call   80101052 <fileclose>
80105d64:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d6c:	c9                   	leave  
80105d6d:	c3                   	ret    

80105d6e <sys_fstat>:

int
sys_fstat(void)
{
80105d6e:	55                   	push   %ebp
80105d6f:	89 e5                	mov    %esp,%ebp
80105d71:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d74:	83 ec 04             	sub    $0x4,%esp
80105d77:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d7a:	50                   	push   %eax
80105d7b:	6a 00                	push   $0x0
80105d7d:	6a 00                	push   $0x0
80105d7f:	e8 b0 fd ff ff       	call   80105b34 <argfd>
80105d84:	83 c4 10             	add    $0x10,%esp
80105d87:	85 c0                	test   %eax,%eax
80105d89:	78 17                	js     80105da2 <sys_fstat+0x34>
80105d8b:	83 ec 04             	sub    $0x4,%esp
80105d8e:	6a 14                	push   $0x14
80105d90:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d93:	50                   	push   %eax
80105d94:	6a 01                	push   $0x1
80105d96:	e8 83 fc ff ff       	call   80105a1e <argptr>
80105d9b:	83 c4 10             	add    $0x10,%esp
80105d9e:	85 c0                	test   %eax,%eax
80105da0:	79 07                	jns    80105da9 <sys_fstat+0x3b>
    return -1;
80105da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da7:	eb 13                	jmp    80105dbc <sys_fstat+0x4e>
  return filestat(f, st);
80105da9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daf:	83 ec 08             	sub    $0x8,%esp
80105db2:	52                   	push   %edx
80105db3:	50                   	push   %eax
80105db4:	e8 81 b3 ff ff       	call   8010113a <filestat>
80105db9:	83 c4 10             	add    $0x10,%esp
}
80105dbc:	c9                   	leave  
80105dbd:	c3                   	ret    

80105dbe <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105dbe:	55                   	push   %ebp
80105dbf:	89 e5                	mov    %esp,%ebp
80105dc1:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105dc4:	83 ec 08             	sub    $0x8,%esp
80105dc7:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105dca:	50                   	push   %eax
80105dcb:	6a 00                	push   $0x0
80105dcd:	e8 ab fc ff ff       	call   80105a7d <argstr>
80105dd2:	83 c4 10             	add    $0x10,%esp
80105dd5:	85 c0                	test   %eax,%eax
80105dd7:	78 15                	js     80105dee <sys_link+0x30>
80105dd9:	83 ec 08             	sub    $0x8,%esp
80105ddc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ddf:	50                   	push   %eax
80105de0:	6a 01                	push   $0x1
80105de2:	e8 96 fc ff ff       	call   80105a7d <argstr>
80105de7:	83 c4 10             	add    $0x10,%esp
80105dea:	85 c0                	test   %eax,%eax
80105dec:	79 0a                	jns    80105df8 <sys_link+0x3a>
    return -1;
80105dee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df3:	e9 68 01 00 00       	jmp    80105f60 <sys_link+0x1a2>

  begin_op();
80105df8:	e8 51 d7 ff ff       	call   8010354e <begin_op>
  if((ip = namei(old)) == 0){
80105dfd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105e00:	83 ec 0c             	sub    $0xc,%esp
80105e03:	50                   	push   %eax
80105e04:	e8 20 c7 ff ff       	call   80102529 <namei>
80105e09:	83 c4 10             	add    $0x10,%esp
80105e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e13:	75 0f                	jne    80105e24 <sys_link+0x66>
    end_op();
80105e15:	e8 c0 d7 ff ff       	call   801035da <end_op>
    return -1;
80105e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1f:	e9 3c 01 00 00       	jmp    80105f60 <sys_link+0x1a2>
  }

  ilock(ip);
80105e24:	83 ec 0c             	sub    $0xc,%esp
80105e27:	ff 75 f4             	pushl  -0xc(%ebp)
80105e2a:	e8 3c bb ff ff       	call   8010196b <ilock>
80105e2f:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e35:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e39:	66 83 f8 01          	cmp    $0x1,%ax
80105e3d:	75 1d                	jne    80105e5c <sys_link+0x9e>
    iunlockput(ip);
80105e3f:	83 ec 0c             	sub    $0xc,%esp
80105e42:	ff 75 f4             	pushl  -0xc(%ebp)
80105e45:	e8 e1 bd ff ff       	call   80101c2b <iunlockput>
80105e4a:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e4d:	e8 88 d7 ff ff       	call   801035da <end_op>
    return -1;
80105e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e57:	e9 04 01 00 00       	jmp    80105f60 <sys_link+0x1a2>
  }

  ip->nlink++;
80105e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e63:	83 c0 01             	add    $0x1,%eax
80105e66:	89 c2                	mov    %eax,%edx
80105e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e6f:	83 ec 0c             	sub    $0xc,%esp
80105e72:	ff 75 f4             	pushl  -0xc(%ebp)
80105e75:	e8 17 b9 ff ff       	call   80101791 <iupdate>
80105e7a:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105e7d:	83 ec 0c             	sub    $0xc,%esp
80105e80:	ff 75 f4             	pushl  -0xc(%ebp)
80105e83:	e8 41 bc ff ff       	call   80101ac9 <iunlock>
80105e88:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105e8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e8e:	83 ec 08             	sub    $0x8,%esp
80105e91:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e94:	52                   	push   %edx
80105e95:	50                   	push   %eax
80105e96:	e8 aa c6 ff ff       	call   80102545 <nameiparent>
80105e9b:	83 c4 10             	add    $0x10,%esp
80105e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ea1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ea5:	74 71                	je     80105f18 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105ea7:	83 ec 0c             	sub    $0xc,%esp
80105eaa:	ff 75 f0             	pushl  -0x10(%ebp)
80105ead:	e8 b9 ba ff ff       	call   8010196b <ilock>
80105eb2:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	8b 10                	mov    (%eax),%edx
80105eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebd:	8b 00                	mov    (%eax),%eax
80105ebf:	39 c2                	cmp    %eax,%edx
80105ec1:	75 1d                	jne    80105ee0 <sys_link+0x122>
80105ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec6:	8b 40 04             	mov    0x4(%eax),%eax
80105ec9:	83 ec 04             	sub    $0x4,%esp
80105ecc:	50                   	push   %eax
80105ecd:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ed0:	50                   	push   %eax
80105ed1:	ff 75 f0             	pushl  -0x10(%ebp)
80105ed4:	e8 b4 c3 ff ff       	call   8010228d <dirlink>
80105ed9:	83 c4 10             	add    $0x10,%esp
80105edc:	85 c0                	test   %eax,%eax
80105ede:	79 10                	jns    80105ef0 <sys_link+0x132>
    iunlockput(dp);
80105ee0:	83 ec 0c             	sub    $0xc,%esp
80105ee3:	ff 75 f0             	pushl  -0x10(%ebp)
80105ee6:	e8 40 bd ff ff       	call   80101c2b <iunlockput>
80105eeb:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105eee:	eb 29                	jmp    80105f19 <sys_link+0x15b>
  }
  iunlockput(dp);
80105ef0:	83 ec 0c             	sub    $0xc,%esp
80105ef3:	ff 75 f0             	pushl  -0x10(%ebp)
80105ef6:	e8 30 bd ff ff       	call   80101c2b <iunlockput>
80105efb:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105efe:	83 ec 0c             	sub    $0xc,%esp
80105f01:	ff 75 f4             	pushl  -0xc(%ebp)
80105f04:	e8 32 bc ff ff       	call   80101b3b <iput>
80105f09:	83 c4 10             	add    $0x10,%esp

  end_op();
80105f0c:	e8 c9 d6 ff ff       	call   801035da <end_op>

  return 0;
80105f11:	b8 00 00 00 00       	mov    $0x0,%eax
80105f16:	eb 48                	jmp    80105f60 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105f18:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105f19:	83 ec 0c             	sub    $0xc,%esp
80105f1c:	ff 75 f4             	pushl  -0xc(%ebp)
80105f1f:	e8 47 ba ff ff       	call   8010196b <ilock>
80105f24:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f2e:	83 e8 01             	sub    $0x1,%eax
80105f31:	89 c2                	mov    %eax,%edx
80105f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f36:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f3a:	83 ec 0c             	sub    $0xc,%esp
80105f3d:	ff 75 f4             	pushl  -0xc(%ebp)
80105f40:	e8 4c b8 ff ff       	call   80101791 <iupdate>
80105f45:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105f48:	83 ec 0c             	sub    $0xc,%esp
80105f4b:	ff 75 f4             	pushl  -0xc(%ebp)
80105f4e:	e8 d8 bc ff ff       	call   80101c2b <iunlockput>
80105f53:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f56:	e8 7f d6 ff ff       	call   801035da <end_op>
  return -1;
80105f5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f60:	c9                   	leave  
80105f61:	c3                   	ret    

80105f62 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f62:	55                   	push   %ebp
80105f63:	89 e5                	mov    %esp,%ebp
80105f65:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f68:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f6f:	eb 40                	jmp    80105fb1 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f74:	6a 10                	push   $0x10
80105f76:	50                   	push   %eax
80105f77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f7a:	50                   	push   %eax
80105f7b:	ff 75 08             	pushl  0x8(%ebp)
80105f7e:	e8 56 bf ff ff       	call   80101ed9 <readi>
80105f83:	83 c4 10             	add    $0x10,%esp
80105f86:	83 f8 10             	cmp    $0x10,%eax
80105f89:	74 0d                	je     80105f98 <isdirempty+0x36>
      panic("isdirempty: readi");
80105f8b:	83 ec 0c             	sub    $0xc,%esp
80105f8e:	68 8a 8e 10 80       	push   $0x80108e8a
80105f93:	e8 ce a5 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105f98:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f9c:	66 85 c0             	test   %ax,%ax
80105f9f:	74 07                	je     80105fa8 <isdirempty+0x46>
      return 0;
80105fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80105fa6:	eb 1b                	jmp    80105fc3 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fab:	83 c0 10             	add    $0x10,%eax
80105fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb4:	8b 50 18             	mov    0x18(%eax),%edx
80105fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fba:	39 c2                	cmp    %eax,%edx
80105fbc:	77 b3                	ja     80105f71 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105fbe:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105fc3:	c9                   	leave  
80105fc4:	c3                   	ret    

80105fc5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105fc5:	55                   	push   %ebp
80105fc6:	89 e5                	mov    %esp,%ebp
80105fc8:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105fcb:	83 ec 08             	sub    $0x8,%esp
80105fce:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105fd1:	50                   	push   %eax
80105fd2:	6a 00                	push   $0x0
80105fd4:	e8 a4 fa ff ff       	call   80105a7d <argstr>
80105fd9:	83 c4 10             	add    $0x10,%esp
80105fdc:	85 c0                	test   %eax,%eax
80105fde:	79 0a                	jns    80105fea <sys_unlink+0x25>
    return -1;
80105fe0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe5:	e9 bc 01 00 00       	jmp    801061a6 <sys_unlink+0x1e1>

  begin_op();
80105fea:	e8 5f d5 ff ff       	call   8010354e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105fef:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ff2:	83 ec 08             	sub    $0x8,%esp
80105ff5:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ff8:	52                   	push   %edx
80105ff9:	50                   	push   %eax
80105ffa:	e8 46 c5 ff ff       	call   80102545 <nameiparent>
80105fff:	83 c4 10             	add    $0x10,%esp
80106002:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106005:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106009:	75 0f                	jne    8010601a <sys_unlink+0x55>
    end_op();
8010600b:	e8 ca d5 ff ff       	call   801035da <end_op>
    return -1;
80106010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106015:	e9 8c 01 00 00       	jmp    801061a6 <sys_unlink+0x1e1>
  }

  ilock(dp);
8010601a:	83 ec 0c             	sub    $0xc,%esp
8010601d:	ff 75 f4             	pushl  -0xc(%ebp)
80106020:	e8 46 b9 ff ff       	call   8010196b <ilock>
80106025:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106028:	83 ec 08             	sub    $0x8,%esp
8010602b:	68 9c 8e 10 80       	push   $0x80108e9c
80106030:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106033:	50                   	push   %eax
80106034:	e8 7f c1 ff ff       	call   801021b8 <namecmp>
80106039:	83 c4 10             	add    $0x10,%esp
8010603c:	85 c0                	test   %eax,%eax
8010603e:	0f 84 4a 01 00 00    	je     8010618e <sys_unlink+0x1c9>
80106044:	83 ec 08             	sub    $0x8,%esp
80106047:	68 9e 8e 10 80       	push   $0x80108e9e
8010604c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010604f:	50                   	push   %eax
80106050:	e8 63 c1 ff ff       	call   801021b8 <namecmp>
80106055:	83 c4 10             	add    $0x10,%esp
80106058:	85 c0                	test   %eax,%eax
8010605a:	0f 84 2e 01 00 00    	je     8010618e <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106060:	83 ec 04             	sub    $0x4,%esp
80106063:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106066:	50                   	push   %eax
80106067:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010606a:	50                   	push   %eax
8010606b:	ff 75 f4             	pushl  -0xc(%ebp)
8010606e:	e8 60 c1 ff ff       	call   801021d3 <dirlookup>
80106073:	83 c4 10             	add    $0x10,%esp
80106076:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106079:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607d:	0f 84 0a 01 00 00    	je     8010618d <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106083:	83 ec 0c             	sub    $0xc,%esp
80106086:	ff 75 f0             	pushl  -0x10(%ebp)
80106089:	e8 dd b8 ff ff       	call   8010196b <ilock>
8010608e:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106091:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106094:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106098:	66 85 c0             	test   %ax,%ax
8010609b:	7f 0d                	jg     801060aa <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010609d:	83 ec 0c             	sub    $0xc,%esp
801060a0:	68 a1 8e 10 80       	push   $0x80108ea1
801060a5:	e8 bc a4 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801060aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ad:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060b1:	66 83 f8 01          	cmp    $0x1,%ax
801060b5:	75 25                	jne    801060dc <sys_unlink+0x117>
801060b7:	83 ec 0c             	sub    $0xc,%esp
801060ba:	ff 75 f0             	pushl  -0x10(%ebp)
801060bd:	e8 a0 fe ff ff       	call   80105f62 <isdirempty>
801060c2:	83 c4 10             	add    $0x10,%esp
801060c5:	85 c0                	test   %eax,%eax
801060c7:	75 13                	jne    801060dc <sys_unlink+0x117>
    iunlockput(ip);
801060c9:	83 ec 0c             	sub    $0xc,%esp
801060cc:	ff 75 f0             	pushl  -0x10(%ebp)
801060cf:	e8 57 bb ff ff       	call   80101c2b <iunlockput>
801060d4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801060d7:	e9 b2 00 00 00       	jmp    8010618e <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801060dc:	83 ec 04             	sub    $0x4,%esp
801060df:	6a 10                	push   $0x10
801060e1:	6a 00                	push   $0x0
801060e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060e6:	50                   	push   %eax
801060e7:	e8 e1 f5 ff ff       	call   801056cd <memset>
801060ec:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060ef:	8b 45 c8             	mov    -0x38(%ebp),%eax
801060f2:	6a 10                	push   $0x10
801060f4:	50                   	push   %eax
801060f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060f8:	50                   	push   %eax
801060f9:	ff 75 f4             	pushl  -0xc(%ebp)
801060fc:	e8 2f bf ff ff       	call   80102030 <writei>
80106101:	83 c4 10             	add    $0x10,%esp
80106104:	83 f8 10             	cmp    $0x10,%eax
80106107:	74 0d                	je     80106116 <sys_unlink+0x151>
    panic("unlink: writei");
80106109:	83 ec 0c             	sub    $0xc,%esp
8010610c:	68 b3 8e 10 80       	push   $0x80108eb3
80106111:	e8 50 a4 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106119:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010611d:	66 83 f8 01          	cmp    $0x1,%ax
80106121:	75 21                	jne    80106144 <sys_unlink+0x17f>
    dp->nlink--;
80106123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106126:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010612a:	83 e8 01             	sub    $0x1,%eax
8010612d:	89 c2                	mov    %eax,%edx
8010612f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106132:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106136:	83 ec 0c             	sub    $0xc,%esp
80106139:	ff 75 f4             	pushl  -0xc(%ebp)
8010613c:	e8 50 b6 ff ff       	call   80101791 <iupdate>
80106141:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106144:	83 ec 0c             	sub    $0xc,%esp
80106147:	ff 75 f4             	pushl  -0xc(%ebp)
8010614a:	e8 dc ba ff ff       	call   80101c2b <iunlockput>
8010614f:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106155:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106159:	83 e8 01             	sub    $0x1,%eax
8010615c:	89 c2                	mov    %eax,%edx
8010615e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106161:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106165:	83 ec 0c             	sub    $0xc,%esp
80106168:	ff 75 f0             	pushl  -0x10(%ebp)
8010616b:	e8 21 b6 ff ff       	call   80101791 <iupdate>
80106170:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106173:	83 ec 0c             	sub    $0xc,%esp
80106176:	ff 75 f0             	pushl  -0x10(%ebp)
80106179:	e8 ad ba ff ff       	call   80101c2b <iunlockput>
8010617e:	83 c4 10             	add    $0x10,%esp

  end_op();
80106181:	e8 54 d4 ff ff       	call   801035da <end_op>

  return 0;
80106186:	b8 00 00 00 00       	mov    $0x0,%eax
8010618b:	eb 19                	jmp    801061a6 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010618d:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010618e:	83 ec 0c             	sub    $0xc,%esp
80106191:	ff 75 f4             	pushl  -0xc(%ebp)
80106194:	e8 92 ba ff ff       	call   80101c2b <iunlockput>
80106199:	83 c4 10             	add    $0x10,%esp
  end_op();
8010619c:	e8 39 d4 ff ff       	call   801035da <end_op>
  return -1;
801061a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061a6:	c9                   	leave  
801061a7:	c3                   	ret    

801061a8 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801061a8:	55                   	push   %ebp
801061a9:	89 e5                	mov    %esp,%ebp
801061ab:	83 ec 38             	sub    $0x38,%esp
801061ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801061b1:	8b 55 10             	mov    0x10(%ebp),%edx
801061b4:	8b 45 14             	mov    0x14(%ebp),%eax
801061b7:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801061bb:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801061bf:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801061c3:	83 ec 08             	sub    $0x8,%esp
801061c6:	8d 45 de             	lea    -0x22(%ebp),%eax
801061c9:	50                   	push   %eax
801061ca:	ff 75 08             	pushl  0x8(%ebp)
801061cd:	e8 73 c3 ff ff       	call   80102545 <nameiparent>
801061d2:	83 c4 10             	add    $0x10,%esp
801061d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061dc:	75 0a                	jne    801061e8 <create+0x40>
    return 0;
801061de:	b8 00 00 00 00       	mov    $0x0,%eax
801061e3:	e9 90 01 00 00       	jmp    80106378 <create+0x1d0>
  ilock(dp);
801061e8:	83 ec 0c             	sub    $0xc,%esp
801061eb:	ff 75 f4             	pushl  -0xc(%ebp)
801061ee:	e8 78 b7 ff ff       	call   8010196b <ilock>
801061f3:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801061f6:	83 ec 04             	sub    $0x4,%esp
801061f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061fc:	50                   	push   %eax
801061fd:	8d 45 de             	lea    -0x22(%ebp),%eax
80106200:	50                   	push   %eax
80106201:	ff 75 f4             	pushl  -0xc(%ebp)
80106204:	e8 ca bf ff ff       	call   801021d3 <dirlookup>
80106209:	83 c4 10             	add    $0x10,%esp
8010620c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010620f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106213:	74 50                	je     80106265 <create+0xbd>
    iunlockput(dp);
80106215:	83 ec 0c             	sub    $0xc,%esp
80106218:	ff 75 f4             	pushl  -0xc(%ebp)
8010621b:	e8 0b ba ff ff       	call   80101c2b <iunlockput>
80106220:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106223:	83 ec 0c             	sub    $0xc,%esp
80106226:	ff 75 f0             	pushl  -0x10(%ebp)
80106229:	e8 3d b7 ff ff       	call   8010196b <ilock>
8010622e:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106231:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106236:	75 15                	jne    8010624d <create+0xa5>
80106238:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010623f:	66 83 f8 02          	cmp    $0x2,%ax
80106243:	75 08                	jne    8010624d <create+0xa5>
      return ip;
80106245:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106248:	e9 2b 01 00 00       	jmp    80106378 <create+0x1d0>
    iunlockput(ip);
8010624d:	83 ec 0c             	sub    $0xc,%esp
80106250:	ff 75 f0             	pushl  -0x10(%ebp)
80106253:	e8 d3 b9 ff ff       	call   80101c2b <iunlockput>
80106258:	83 c4 10             	add    $0x10,%esp
    return 0;
8010625b:	b8 00 00 00 00       	mov    $0x0,%eax
80106260:	e9 13 01 00 00       	jmp    80106378 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106265:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626c:	8b 00                	mov    (%eax),%eax
8010626e:	83 ec 08             	sub    $0x8,%esp
80106271:	52                   	push   %edx
80106272:	50                   	push   %eax
80106273:	e8 42 b4 ff ff       	call   801016ba <ialloc>
80106278:	83 c4 10             	add    $0x10,%esp
8010627b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010627e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106282:	75 0d                	jne    80106291 <create+0xe9>
    panic("create: ialloc");
80106284:	83 ec 0c             	sub    $0xc,%esp
80106287:	68 c2 8e 10 80       	push   $0x80108ec2
8010628c:	e8 d5 a2 ff ff       	call   80100566 <panic>

  ilock(ip);
80106291:	83 ec 0c             	sub    $0xc,%esp
80106294:	ff 75 f0             	pushl  -0x10(%ebp)
80106297:	e8 cf b6 ff ff       	call   8010196b <ilock>
8010629c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010629f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a2:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801062a6:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801062aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ad:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801062b1:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801062b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b8:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801062be:	83 ec 0c             	sub    $0xc,%esp
801062c1:	ff 75 f0             	pushl  -0x10(%ebp)
801062c4:	e8 c8 b4 ff ff       	call   80101791 <iupdate>
801062c9:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801062cc:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801062d1:	75 6a                	jne    8010633d <create+0x195>
    dp->nlink++;  // for ".."
801062d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062da:	83 c0 01             	add    $0x1,%eax
801062dd:	89 c2                	mov    %eax,%edx
801062df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	ff 75 f4             	pushl  -0xc(%ebp)
801062ec:	e8 a0 b4 ff ff       	call   80101791 <iupdate>
801062f1:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f7:	8b 40 04             	mov    0x4(%eax),%eax
801062fa:	83 ec 04             	sub    $0x4,%esp
801062fd:	50                   	push   %eax
801062fe:	68 9c 8e 10 80       	push   $0x80108e9c
80106303:	ff 75 f0             	pushl  -0x10(%ebp)
80106306:	e8 82 bf ff ff       	call   8010228d <dirlink>
8010630b:	83 c4 10             	add    $0x10,%esp
8010630e:	85 c0                	test   %eax,%eax
80106310:	78 1e                	js     80106330 <create+0x188>
80106312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106315:	8b 40 04             	mov    0x4(%eax),%eax
80106318:	83 ec 04             	sub    $0x4,%esp
8010631b:	50                   	push   %eax
8010631c:	68 9e 8e 10 80       	push   $0x80108e9e
80106321:	ff 75 f0             	pushl  -0x10(%ebp)
80106324:	e8 64 bf ff ff       	call   8010228d <dirlink>
80106329:	83 c4 10             	add    $0x10,%esp
8010632c:	85 c0                	test   %eax,%eax
8010632e:	79 0d                	jns    8010633d <create+0x195>
      panic("create dots");
80106330:	83 ec 0c             	sub    $0xc,%esp
80106333:	68 d1 8e 10 80       	push   $0x80108ed1
80106338:	e8 29 a2 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010633d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106340:	8b 40 04             	mov    0x4(%eax),%eax
80106343:	83 ec 04             	sub    $0x4,%esp
80106346:	50                   	push   %eax
80106347:	8d 45 de             	lea    -0x22(%ebp),%eax
8010634a:	50                   	push   %eax
8010634b:	ff 75 f4             	pushl  -0xc(%ebp)
8010634e:	e8 3a bf ff ff       	call   8010228d <dirlink>
80106353:	83 c4 10             	add    $0x10,%esp
80106356:	85 c0                	test   %eax,%eax
80106358:	79 0d                	jns    80106367 <create+0x1bf>
    panic("create: dirlink");
8010635a:	83 ec 0c             	sub    $0xc,%esp
8010635d:	68 dd 8e 10 80       	push   $0x80108edd
80106362:	e8 ff a1 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106367:	83 ec 0c             	sub    $0xc,%esp
8010636a:	ff 75 f4             	pushl  -0xc(%ebp)
8010636d:	e8 b9 b8 ff ff       	call   80101c2b <iunlockput>
80106372:	83 c4 10             	add    $0x10,%esp

  return ip;
80106375:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106378:	c9                   	leave  
80106379:	c3                   	ret    

8010637a <sys_open>:

int
sys_open(void)
{
8010637a:	55                   	push   %ebp
8010637b:	89 e5                	mov    %esp,%ebp
8010637d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106380:	83 ec 08             	sub    $0x8,%esp
80106383:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106386:	50                   	push   %eax
80106387:	6a 00                	push   $0x0
80106389:	e8 ef f6 ff ff       	call   80105a7d <argstr>
8010638e:	83 c4 10             	add    $0x10,%esp
80106391:	85 c0                	test   %eax,%eax
80106393:	78 15                	js     801063aa <sys_open+0x30>
80106395:	83 ec 08             	sub    $0x8,%esp
80106398:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010639b:	50                   	push   %eax
8010639c:	6a 01                	push   $0x1
8010639e:	e8 53 f6 ff ff       	call   801059f6 <argint>
801063a3:	83 c4 10             	add    $0x10,%esp
801063a6:	85 c0                	test   %eax,%eax
801063a8:	79 0a                	jns    801063b4 <sys_open+0x3a>
    return -1;
801063aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063af:	e9 61 01 00 00       	jmp    80106515 <sys_open+0x19b>

  begin_op();
801063b4:	e8 95 d1 ff ff       	call   8010354e <begin_op>

  if(omode & O_CREATE){
801063b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063bc:	25 00 02 00 00       	and    $0x200,%eax
801063c1:	85 c0                	test   %eax,%eax
801063c3:	74 2a                	je     801063ef <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801063c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063c8:	6a 00                	push   $0x0
801063ca:	6a 00                	push   $0x0
801063cc:	6a 02                	push   $0x2
801063ce:	50                   	push   %eax
801063cf:	e8 d4 fd ff ff       	call   801061a8 <create>
801063d4:	83 c4 10             	add    $0x10,%esp
801063d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801063da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063de:	75 75                	jne    80106455 <sys_open+0xdb>
      end_op();
801063e0:	e8 f5 d1 ff ff       	call   801035da <end_op>
      return -1;
801063e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ea:	e9 26 01 00 00       	jmp    80106515 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801063ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063f2:	83 ec 0c             	sub    $0xc,%esp
801063f5:	50                   	push   %eax
801063f6:	e8 2e c1 ff ff       	call   80102529 <namei>
801063fb:	83 c4 10             	add    $0x10,%esp
801063fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106401:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106405:	75 0f                	jne    80106416 <sys_open+0x9c>
      end_op();
80106407:	e8 ce d1 ff ff       	call   801035da <end_op>
      return -1;
8010640c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106411:	e9 ff 00 00 00       	jmp    80106515 <sys_open+0x19b>
    }
    ilock(ip);
80106416:	83 ec 0c             	sub    $0xc,%esp
80106419:	ff 75 f4             	pushl  -0xc(%ebp)
8010641c:	e8 4a b5 ff ff       	call   8010196b <ilock>
80106421:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106427:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010642b:	66 83 f8 01          	cmp    $0x1,%ax
8010642f:	75 24                	jne    80106455 <sys_open+0xdb>
80106431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106434:	85 c0                	test   %eax,%eax
80106436:	74 1d                	je     80106455 <sys_open+0xdb>
      iunlockput(ip);
80106438:	83 ec 0c             	sub    $0xc,%esp
8010643b:	ff 75 f4             	pushl  -0xc(%ebp)
8010643e:	e8 e8 b7 ff ff       	call   80101c2b <iunlockput>
80106443:	83 c4 10             	add    $0x10,%esp
      end_op();
80106446:	e8 8f d1 ff ff       	call   801035da <end_op>
      return -1;
8010644b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106450:	e9 c0 00 00 00       	jmp    80106515 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106455:	e8 3a ab ff ff       	call   80100f94 <filealloc>
8010645a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010645d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106461:	74 17                	je     8010647a <sys_open+0x100>
80106463:	83 ec 0c             	sub    $0xc,%esp
80106466:	ff 75 f0             	pushl  -0x10(%ebp)
80106469:	e8 3a f7 ff ff       	call   80105ba8 <fdalloc>
8010646e:	83 c4 10             	add    $0x10,%esp
80106471:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106474:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106478:	79 2e                	jns    801064a8 <sys_open+0x12e>
    if(f)
8010647a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010647e:	74 0e                	je     8010648e <sys_open+0x114>
      fileclose(f);
80106480:	83 ec 0c             	sub    $0xc,%esp
80106483:	ff 75 f0             	pushl  -0x10(%ebp)
80106486:	e8 c7 ab ff ff       	call   80101052 <fileclose>
8010648b:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010648e:	83 ec 0c             	sub    $0xc,%esp
80106491:	ff 75 f4             	pushl  -0xc(%ebp)
80106494:	e8 92 b7 ff ff       	call   80101c2b <iunlockput>
80106499:	83 c4 10             	add    $0x10,%esp
    end_op();
8010649c:	e8 39 d1 ff ff       	call   801035da <end_op>
    return -1;
801064a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a6:	eb 6d                	jmp    80106515 <sys_open+0x19b>
  }
  iunlock(ip);
801064a8:	83 ec 0c             	sub    $0xc,%esp
801064ab:	ff 75 f4             	pushl  -0xc(%ebp)
801064ae:	e8 16 b6 ff ff       	call   80101ac9 <iunlock>
801064b3:	83 c4 10             	add    $0x10,%esp
  end_op();
801064b6:	e8 1f d1 ff ff       	call   801035da <end_op>

  f->type = FD_INODE;
801064bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064be:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801064c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ca:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801064cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801064d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064da:	83 e0 01             	and    $0x1,%eax
801064dd:	85 c0                	test   %eax,%eax
801064df:	0f 94 c0             	sete   %al
801064e2:	89 c2                	mov    %eax,%edx
801064e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064e7:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ed:	83 e0 01             	and    $0x1,%eax
801064f0:	85 c0                	test   %eax,%eax
801064f2:	75 0a                	jne    801064fe <sys_open+0x184>
801064f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064f7:	83 e0 02             	and    $0x2,%eax
801064fa:	85 c0                	test   %eax,%eax
801064fc:	74 07                	je     80106505 <sys_open+0x18b>
801064fe:	b8 01 00 00 00       	mov    $0x1,%eax
80106503:	eb 05                	jmp    8010650a <sys_open+0x190>
80106505:	b8 00 00 00 00       	mov    $0x0,%eax
8010650a:	89 c2                	mov    %eax,%edx
8010650c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106512:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106515:	c9                   	leave  
80106516:	c3                   	ret    

80106517 <sys_mkdir>:

int
sys_mkdir(void)
{
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010651d:	e8 2c d0 ff ff       	call   8010354e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106522:	83 ec 08             	sub    $0x8,%esp
80106525:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106528:	50                   	push   %eax
80106529:	6a 00                	push   $0x0
8010652b:	e8 4d f5 ff ff       	call   80105a7d <argstr>
80106530:	83 c4 10             	add    $0x10,%esp
80106533:	85 c0                	test   %eax,%eax
80106535:	78 1b                	js     80106552 <sys_mkdir+0x3b>
80106537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653a:	6a 00                	push   $0x0
8010653c:	6a 00                	push   $0x0
8010653e:	6a 01                	push   $0x1
80106540:	50                   	push   %eax
80106541:	e8 62 fc ff ff       	call   801061a8 <create>
80106546:	83 c4 10             	add    $0x10,%esp
80106549:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010654c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106550:	75 0c                	jne    8010655e <sys_mkdir+0x47>
    end_op();
80106552:	e8 83 d0 ff ff       	call   801035da <end_op>
    return -1;
80106557:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655c:	eb 18                	jmp    80106576 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010655e:	83 ec 0c             	sub    $0xc,%esp
80106561:	ff 75 f4             	pushl  -0xc(%ebp)
80106564:	e8 c2 b6 ff ff       	call   80101c2b <iunlockput>
80106569:	83 c4 10             	add    $0x10,%esp
  end_op();
8010656c:	e8 69 d0 ff ff       	call   801035da <end_op>
  return 0;
80106571:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106576:	c9                   	leave  
80106577:	c3                   	ret    

80106578 <sys_mknod>:

int
sys_mknod(void)
{
80106578:	55                   	push   %ebp
80106579:	89 e5                	mov    %esp,%ebp
8010657b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010657e:	e8 cb cf ff ff       	call   8010354e <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106583:	83 ec 08             	sub    $0x8,%esp
80106586:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106589:	50                   	push   %eax
8010658a:	6a 00                	push   $0x0
8010658c:	e8 ec f4 ff ff       	call   80105a7d <argstr>
80106591:	83 c4 10             	add    $0x10,%esp
80106594:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106597:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010659b:	78 4f                	js     801065ec <sys_mknod+0x74>
     argint(1, &major) < 0 ||
8010659d:	83 ec 08             	sub    $0x8,%esp
801065a0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065a3:	50                   	push   %eax
801065a4:	6a 01                	push   $0x1
801065a6:	e8 4b f4 ff ff       	call   801059f6 <argint>
801065ab:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801065ae:	85 c0                	test   %eax,%eax
801065b0:	78 3a                	js     801065ec <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065b2:	83 ec 08             	sub    $0x8,%esp
801065b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065b8:	50                   	push   %eax
801065b9:	6a 02                	push   $0x2
801065bb:	e8 36 f4 ff ff       	call   801059f6 <argint>
801065c0:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801065c3:	85 c0                	test   %eax,%eax
801065c5:	78 25                	js     801065ec <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801065c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ca:	0f bf c8             	movswl %ax,%ecx
801065cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065d0:	0f bf d0             	movswl %ax,%edx
801065d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065d6:	51                   	push   %ecx
801065d7:	52                   	push   %edx
801065d8:	6a 03                	push   $0x3
801065da:	50                   	push   %eax
801065db:	e8 c8 fb ff ff       	call   801061a8 <create>
801065e0:	83 c4 10             	add    $0x10,%esp
801065e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ea:	75 0c                	jne    801065f8 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801065ec:	e8 e9 cf ff ff       	call   801035da <end_op>
    return -1;
801065f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f6:	eb 18                	jmp    80106610 <sys_mknod+0x98>
  }
  iunlockput(ip);
801065f8:	83 ec 0c             	sub    $0xc,%esp
801065fb:	ff 75 f0             	pushl  -0x10(%ebp)
801065fe:	e8 28 b6 ff ff       	call   80101c2b <iunlockput>
80106603:	83 c4 10             	add    $0x10,%esp
  end_op();
80106606:	e8 cf cf ff ff       	call   801035da <end_op>
  return 0;
8010660b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106610:	c9                   	leave  
80106611:	c3                   	ret    

80106612 <sys_chdir>:

int
sys_chdir(void)
{
80106612:	55                   	push   %ebp
80106613:	89 e5                	mov    %esp,%ebp
80106615:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106618:	e8 31 cf ff ff       	call   8010354e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010661d:	83 ec 08             	sub    $0x8,%esp
80106620:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106623:	50                   	push   %eax
80106624:	6a 00                	push   $0x0
80106626:	e8 52 f4 ff ff       	call   80105a7d <argstr>
8010662b:	83 c4 10             	add    $0x10,%esp
8010662e:	85 c0                	test   %eax,%eax
80106630:	78 18                	js     8010664a <sys_chdir+0x38>
80106632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106635:	83 ec 0c             	sub    $0xc,%esp
80106638:	50                   	push   %eax
80106639:	e8 eb be ff ff       	call   80102529 <namei>
8010663e:	83 c4 10             	add    $0x10,%esp
80106641:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106644:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106648:	75 0c                	jne    80106656 <sys_chdir+0x44>
    end_op();
8010664a:	e8 8b cf ff ff       	call   801035da <end_op>
    return -1;
8010664f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106654:	eb 6e                	jmp    801066c4 <sys_chdir+0xb2>
  }
  ilock(ip);
80106656:	83 ec 0c             	sub    $0xc,%esp
80106659:	ff 75 f4             	pushl  -0xc(%ebp)
8010665c:	e8 0a b3 ff ff       	call   8010196b <ilock>
80106661:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106667:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010666b:	66 83 f8 01          	cmp    $0x1,%ax
8010666f:	74 1a                	je     8010668b <sys_chdir+0x79>
    iunlockput(ip);
80106671:	83 ec 0c             	sub    $0xc,%esp
80106674:	ff 75 f4             	pushl  -0xc(%ebp)
80106677:	e8 af b5 ff ff       	call   80101c2b <iunlockput>
8010667c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010667f:	e8 56 cf ff ff       	call   801035da <end_op>
    return -1;
80106684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106689:	eb 39                	jmp    801066c4 <sys_chdir+0xb2>
  }
  iunlock(ip);
8010668b:	83 ec 0c             	sub    $0xc,%esp
8010668e:	ff 75 f4             	pushl  -0xc(%ebp)
80106691:	e8 33 b4 ff ff       	call   80101ac9 <iunlock>
80106696:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106699:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010669f:	8b 40 70             	mov    0x70(%eax),%eax
801066a2:	83 ec 0c             	sub    $0xc,%esp
801066a5:	50                   	push   %eax
801066a6:	e8 90 b4 ff ff       	call   80101b3b <iput>
801066ab:	83 c4 10             	add    $0x10,%esp
  end_op();
801066ae:	e8 27 cf ff ff       	call   801035da <end_op>
  proc->cwd = ip;
801066b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066bc:	89 50 70             	mov    %edx,0x70(%eax)
  return 0;
801066bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066c4:	c9                   	leave  
801066c5:	c3                   	ret    

801066c6 <sys_exec>:

int
sys_exec(void)
{
801066c6:	55                   	push   %ebp
801066c7:	89 e5                	mov    %esp,%ebp
801066c9:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801066cf:	83 ec 08             	sub    $0x8,%esp
801066d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066d5:	50                   	push   %eax
801066d6:	6a 00                	push   $0x0
801066d8:	e8 a0 f3 ff ff       	call   80105a7d <argstr>
801066dd:	83 c4 10             	add    $0x10,%esp
801066e0:	85 c0                	test   %eax,%eax
801066e2:	78 18                	js     801066fc <sys_exec+0x36>
801066e4:	83 ec 08             	sub    $0x8,%esp
801066e7:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066ed:	50                   	push   %eax
801066ee:	6a 01                	push   $0x1
801066f0:	e8 01 f3 ff ff       	call   801059f6 <argint>
801066f5:	83 c4 10             	add    $0x10,%esp
801066f8:	85 c0                	test   %eax,%eax
801066fa:	79 0a                	jns    80106706 <sys_exec+0x40>
    return -1;
801066fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106701:	e9 c6 00 00 00       	jmp    801067cc <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106706:	83 ec 04             	sub    $0x4,%esp
80106709:	68 80 00 00 00       	push   $0x80
8010670e:	6a 00                	push   $0x0
80106710:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106716:	50                   	push   %eax
80106717:	e8 b1 ef ff ff       	call   801056cd <memset>
8010671c:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010671f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106729:	83 f8 1f             	cmp    $0x1f,%eax
8010672c:	76 0a                	jbe    80106738 <sys_exec+0x72>
      return -1;
8010672e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106733:	e9 94 00 00 00       	jmp    801067cc <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673b:	c1 e0 02             	shl    $0x2,%eax
8010673e:	89 c2                	mov    %eax,%edx
80106740:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106746:	01 c2                	add    %eax,%edx
80106748:	83 ec 08             	sub    $0x8,%esp
8010674b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106751:	50                   	push   %eax
80106752:	52                   	push   %edx
80106753:	e8 fe f1 ff ff       	call   80105956 <fetchint>
80106758:	83 c4 10             	add    $0x10,%esp
8010675b:	85 c0                	test   %eax,%eax
8010675d:	79 07                	jns    80106766 <sys_exec+0xa0>
      return -1;
8010675f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106764:	eb 66                	jmp    801067cc <sys_exec+0x106>
    if(uarg == 0){
80106766:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010676c:	85 c0                	test   %eax,%eax
8010676e:	75 27                	jne    80106797 <sys_exec+0xd1>
      argv[i] = 0;
80106770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106773:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010677a:	00 00 00 00 
      break;
8010677e:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010677f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106782:	83 ec 08             	sub    $0x8,%esp
80106785:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010678b:	52                   	push   %edx
8010678c:	50                   	push   %eax
8010678d:	e8 df a3 ff ff       	call   80100b71 <exec>
80106792:	83 c4 10             	add    $0x10,%esp
80106795:	eb 35                	jmp    801067cc <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106797:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010679d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067a0:	c1 e2 02             	shl    $0x2,%edx
801067a3:	01 c2                	add    %eax,%edx
801067a5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801067ab:	83 ec 08             	sub    $0x8,%esp
801067ae:	52                   	push   %edx
801067af:	50                   	push   %eax
801067b0:	e8 dd f1 ff ff       	call   80105992 <fetchstr>
801067b5:	83 c4 10             	add    $0x10,%esp
801067b8:	85 c0                	test   %eax,%eax
801067ba:	79 07                	jns    801067c3 <sys_exec+0xfd>
      return -1;
801067bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c1:	eb 09                	jmp    801067cc <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801067c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801067c7:	e9 5a ff ff ff       	jmp    80106726 <sys_exec+0x60>
  return exec(path, argv);
}
801067cc:	c9                   	leave  
801067cd:	c3                   	ret    

801067ce <sys_pipe>:

int
sys_pipe(void)
{
801067ce:	55                   	push   %ebp
801067cf:	89 e5                	mov    %esp,%ebp
801067d1:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801067d4:	83 ec 04             	sub    $0x4,%esp
801067d7:	6a 08                	push   $0x8
801067d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067dc:	50                   	push   %eax
801067dd:	6a 00                	push   $0x0
801067df:	e8 3a f2 ff ff       	call   80105a1e <argptr>
801067e4:	83 c4 10             	add    $0x10,%esp
801067e7:	85 c0                	test   %eax,%eax
801067e9:	79 0a                	jns    801067f5 <sys_pipe+0x27>
    return -1;
801067eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f0:	e9 ae 00 00 00       	jmp    801068a3 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801067f5:	83 ec 08             	sub    $0x8,%esp
801067f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067fb:	50                   	push   %eax
801067fc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801067ff:	50                   	push   %eax
80106800:	e8 3d d8 ff ff       	call   80104042 <pipealloc>
80106805:	83 c4 10             	add    $0x10,%esp
80106808:	85 c0                	test   %eax,%eax
8010680a:	79 0a                	jns    80106816 <sys_pipe+0x48>
    return -1;
8010680c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106811:	e9 8d 00 00 00       	jmp    801068a3 <sys_pipe+0xd5>
  fd0 = -1;
80106816:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010681d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106820:	83 ec 0c             	sub    $0xc,%esp
80106823:	50                   	push   %eax
80106824:	e8 7f f3 ff ff       	call   80105ba8 <fdalloc>
80106829:	83 c4 10             	add    $0x10,%esp
8010682c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010682f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106833:	78 18                	js     8010684d <sys_pipe+0x7f>
80106835:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106838:	83 ec 0c             	sub    $0xc,%esp
8010683b:	50                   	push   %eax
8010683c:	e8 67 f3 ff ff       	call   80105ba8 <fdalloc>
80106841:	83 c4 10             	add    $0x10,%esp
80106844:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106847:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010684b:	79 3e                	jns    8010688b <sys_pipe+0xbd>
    if(fd0 >= 0)
8010684d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106851:	78 13                	js     80106866 <sys_pipe+0x98>
      proc->ofile[fd0] = 0;
80106853:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106859:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010685c:	83 c2 0c             	add    $0xc,%edx
8010685f:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    fileclose(rf);
80106866:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106869:	83 ec 0c             	sub    $0xc,%esp
8010686c:	50                   	push   %eax
8010686d:	e8 e0 a7 ff ff       	call   80101052 <fileclose>
80106872:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106875:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106878:	83 ec 0c             	sub    $0xc,%esp
8010687b:	50                   	push   %eax
8010687c:	e8 d1 a7 ff ff       	call   80101052 <fileclose>
80106881:	83 c4 10             	add    $0x10,%esp
    return -1;
80106884:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106889:	eb 18                	jmp    801068a3 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010688b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010688e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106891:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106893:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106896:	8d 50 04             	lea    0x4(%eax),%edx
80106899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010689c:	89 02                	mov    %eax,(%edx)
  return 0;
8010689e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068a3:	c9                   	leave  
801068a4:	c3                   	ret    

801068a5 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801068a5:	55                   	push   %ebp
801068a6:	89 e5                	mov    %esp,%ebp
801068a8:	83 ec 08             	sub    $0x8,%esp
  return fork();
801068ab:	e8 b1 de ff ff       	call   80104761 <fork>
}
801068b0:	c9                   	leave  
801068b1:	c3                   	ret    

801068b2 <sys_exit>:

int
sys_exit(void)
{
801068b2:	55                   	push   %ebp
801068b3:	89 e5                	mov    %esp,%ebp
801068b5:	83 ec 08             	sub    $0x8,%esp
  exit();
801068b8:	e8 35 e0 ff ff       	call   801048f2 <exit>
  return 0;  // not reached
801068bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068c2:	c9                   	leave  
801068c3:	c3                   	ret    

801068c4 <sys_wait>:

int
sys_wait(void)
{
801068c4:	55                   	push   %ebp
801068c5:	89 e5                	mov    %esp,%ebp
801068c7:	83 ec 08             	sub    $0x8,%esp
  return wait();
801068ca:	e8 5b e1 ff ff       	call   80104a2a <wait>
}
801068cf:	c9                   	leave  
801068d0:	c3                   	ret    

801068d1 <sys_kill>:

int
sys_kill(void)
{
801068d1:	55                   	push   %ebp
801068d2:	89 e5                	mov    %esp,%ebp
801068d4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801068d7:	83 ec 08             	sub    $0x8,%esp
801068da:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068dd:	50                   	push   %eax
801068de:	6a 00                	push   $0x0
801068e0:	e8 11 f1 ff ff       	call   801059f6 <argint>
801068e5:	83 c4 10             	add    $0x10,%esp
801068e8:	85 c0                	test   %eax,%eax
801068ea:	79 07                	jns    801068f3 <sys_kill+0x22>
    return -1;
801068ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f1:	eb 0f                	jmp    80106902 <sys_kill+0x31>
  return kill(pid);
801068f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f6:	83 ec 0c             	sub    $0xc,%esp
801068f9:	50                   	push   %eax
801068fa:	e8 25 e8 ff ff       	call   80105124 <kill>
801068ff:	83 c4 10             	add    $0x10,%esp
}
80106902:	c9                   	leave  
80106903:	c3                   	ret    

80106904 <sys_getpid>:

int
sys_getpid(void)
{
80106904:	55                   	push   %ebp
80106905:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106907:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010690d:	8b 40 18             	mov    0x18(%eax),%eax
}
80106910:	5d                   	pop    %ebp
80106911:	c3                   	ret    

80106912 <sys_sbrk>:

int
sys_sbrk(void)
{
80106912:	55                   	push   %ebp
80106913:	89 e5                	mov    %esp,%ebp
80106915:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106918:	83 ec 08             	sub    $0x8,%esp
8010691b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010691e:	50                   	push   %eax
8010691f:	6a 00                	push   $0x0
80106921:	e8 d0 f0 ff ff       	call   801059f6 <argint>
80106926:	83 c4 10             	add    $0x10,%esp
80106929:	85 c0                	test   %eax,%eax
8010692b:	79 07                	jns    80106934 <sys_sbrk+0x22>
    return -1;
8010692d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106932:	eb 29                	jmp    8010695d <sys_sbrk+0x4b>
  addr = proc->sz;
80106934:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010693a:	8b 40 08             	mov    0x8(%eax),%eax
8010693d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106943:	83 ec 0c             	sub    $0xc,%esp
80106946:	50                   	push   %eax
80106947:	e8 70 dd ff ff       	call   801046bc <growproc>
8010694c:	83 c4 10             	add    $0x10,%esp
8010694f:	85 c0                	test   %eax,%eax
80106951:	79 07                	jns    8010695a <sys_sbrk+0x48>
    return -1;
80106953:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106958:	eb 03                	jmp    8010695d <sys_sbrk+0x4b>
  return addr;
8010695a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010695d:	c9                   	leave  
8010695e:	c3                   	ret    

8010695f <sys_sleep>:

int
sys_sleep(void)
{
8010695f:	55                   	push   %ebp
80106960:	89 e5                	mov    %esp,%ebp
80106962:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106965:	83 ec 08             	sub    $0x8,%esp
80106968:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010696b:	50                   	push   %eax
8010696c:	6a 00                	push   $0x0
8010696e:	e8 83 f0 ff ff       	call   801059f6 <argint>
80106973:	83 c4 10             	add    $0x10,%esp
80106976:	85 c0                	test   %eax,%eax
80106978:	79 07                	jns    80106981 <sys_sleep+0x22>
    return -1;
8010697a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697f:	eb 77                	jmp    801069f8 <sys_sleep+0x99>
  acquire(&tickslock);
80106981:	83 ec 0c             	sub    $0xc,%esp
80106984:	68 a0 5a 11 80       	push   $0x80115aa0
80106989:	e8 dc ea ff ff       	call   8010546a <acquire>
8010698e:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106991:	a1 e0 62 11 80       	mov    0x801162e0,%eax
80106996:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106999:	eb 39                	jmp    801069d4 <sys_sleep+0x75>
    if(proc->killed){
8010699b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a1:	8b 40 2c             	mov    0x2c(%eax),%eax
801069a4:	85 c0                	test   %eax,%eax
801069a6:	74 17                	je     801069bf <sys_sleep+0x60>
      release(&tickslock);
801069a8:	83 ec 0c             	sub    $0xc,%esp
801069ab:	68 a0 5a 11 80       	push   $0x80115aa0
801069b0:	e8 1c eb ff ff       	call   801054d1 <release>
801069b5:	83 c4 10             	add    $0x10,%esp
      return -1;
801069b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bd:	eb 39                	jmp    801069f8 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801069bf:	83 ec 08             	sub    $0x8,%esp
801069c2:	68 a0 5a 11 80       	push   $0x80115aa0
801069c7:	68 e0 62 11 80       	push   $0x801162e0
801069cc:	e8 2e e6 ff ff       	call   80104fff <sleep>
801069d1:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801069d4:	a1 e0 62 11 80       	mov    0x801162e0,%eax
801069d9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801069dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069df:	39 d0                	cmp    %edx,%eax
801069e1:	72 b8                	jb     8010699b <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801069e3:	83 ec 0c             	sub    $0xc,%esp
801069e6:	68 a0 5a 11 80       	push   $0x80115aa0
801069eb:	e8 e1 ea ff ff       	call   801054d1 <release>
801069f0:	83 c4 10             	add    $0x10,%esp
  return 0;
801069f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069f8:	c9                   	leave  
801069f9:	c3                   	ret    

801069fa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801069fa:	55                   	push   %ebp
801069fb:	89 e5                	mov    %esp,%ebp
801069fd:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106a00:	83 ec 0c             	sub    $0xc,%esp
80106a03:	68 a0 5a 11 80       	push   $0x80115aa0
80106a08:	e8 5d ea ff ff       	call   8010546a <acquire>
80106a0d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106a10:	a1 e0 62 11 80       	mov    0x801162e0,%eax
80106a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106a18:	83 ec 0c             	sub    $0xc,%esp
80106a1b:	68 a0 5a 11 80       	push   $0x80115aa0
80106a20:	e8 ac ea ff ff       	call   801054d1 <release>
80106a25:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a2b:	c9                   	leave  
80106a2c:	c3                   	ret    

80106a2d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a2d:	55                   	push   %ebp
80106a2e:	89 e5                	mov    %esp,%ebp
80106a30:	83 ec 08             	sub    $0x8,%esp
80106a33:	8b 55 08             	mov    0x8(%ebp),%edx
80106a36:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a39:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a3d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a40:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a44:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a48:	ee                   	out    %al,(%dx)
}
80106a49:	90                   	nop
80106a4a:	c9                   	leave  
80106a4b:	c3                   	ret    

80106a4c <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106a4c:	55                   	push   %ebp
80106a4d:	89 e5                	mov    %esp,%ebp
80106a4f:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106a52:	6a 34                	push   $0x34
80106a54:	6a 43                	push   $0x43
80106a56:	e8 d2 ff ff ff       	call   80106a2d <outb>
80106a5b:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106a5e:	68 9c 00 00 00       	push   $0x9c
80106a63:	6a 40                	push   $0x40
80106a65:	e8 c3 ff ff ff       	call   80106a2d <outb>
80106a6a:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106a6d:	6a 2e                	push   $0x2e
80106a6f:	6a 40                	push   $0x40
80106a71:	e8 b7 ff ff ff       	call   80106a2d <outb>
80106a76:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106a79:	83 ec 0c             	sub    $0xc,%esp
80106a7c:	6a 00                	push   $0x0
80106a7e:	e8 a9 d4 ff ff       	call   80103f2c <picenable>
80106a83:	83 c4 10             	add    $0x10,%esp
}
80106a86:	90                   	nop
80106a87:	c9                   	leave  
80106a88:	c3                   	ret    

80106a89 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a89:	1e                   	push   %ds
  pushl %es
80106a8a:	06                   	push   %es
  pushl %fs
80106a8b:	0f a0                	push   %fs
  pushl %gs
80106a8d:	0f a8                	push   %gs
  pushal
80106a8f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106a90:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a94:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a96:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106a98:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106a9c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106a9e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106aa0:	54                   	push   %esp
  call trap
80106aa1:	e8 d7 01 00 00       	call   80106c7d <trap>
  addl $4, %esp
80106aa6:	83 c4 04             	add    $0x4,%esp

80106aa9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106aa9:	61                   	popa   
  popl %gs
80106aaa:	0f a9                	pop    %gs
  popl %fs
80106aac:	0f a1                	pop    %fs
  popl %es
80106aae:	07                   	pop    %es
  popl %ds
80106aaf:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ab0:	83 c4 08             	add    $0x8,%esp
  iret
80106ab3:	cf                   	iret   

80106ab4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106ab4:	55                   	push   %ebp
80106ab5:	89 e5                	mov    %esp,%ebp
80106ab7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106aba:	8b 45 0c             	mov    0xc(%ebp),%eax
80106abd:	83 e8 01             	sub    $0x1,%eax
80106ac0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106acb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ace:	c1 e8 10             	shr    $0x10,%eax
80106ad1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106ad5:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ad8:	0f 01 18             	lidtl  (%eax)
}
80106adb:	90                   	nop
80106adc:	c9                   	leave  
80106add:	c3                   	ret    

80106ade <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106ade:	55                   	push   %ebp
80106adf:	89 e5                	mov    %esp,%ebp
80106ae1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106ae4:	0f 20 d0             	mov    %cr2,%eax
80106ae7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106aea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106aed:	c9                   	leave  
80106aee:	c3                   	ret    

80106aef <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106aef:	55                   	push   %ebp
80106af0:	89 e5                	mov    %esp,%ebp
80106af2:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106afc:	e9 c3 00 00 00       	jmp    80106bc4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b04:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106b0b:	89 c2                	mov    %eax,%edx
80106b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b10:	66 89 14 c5 e0 5a 11 	mov    %dx,-0x7feea520(,%eax,8)
80106b17:	80 
80106b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1b:	66 c7 04 c5 e2 5a 11 	movw   $0x8,-0x7feea51e(,%eax,8)
80106b22:	80 08 00 
80106b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b28:	0f b6 14 c5 e4 5a 11 	movzbl -0x7feea51c(,%eax,8),%edx
80106b2f:	80 
80106b30:	83 e2 e0             	and    $0xffffffe0,%edx
80106b33:	88 14 c5 e4 5a 11 80 	mov    %dl,-0x7feea51c(,%eax,8)
80106b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3d:	0f b6 14 c5 e4 5a 11 	movzbl -0x7feea51c(,%eax,8),%edx
80106b44:	80 
80106b45:	83 e2 1f             	and    $0x1f,%edx
80106b48:	88 14 c5 e4 5a 11 80 	mov    %dl,-0x7feea51c(,%eax,8)
80106b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b52:	0f b6 14 c5 e5 5a 11 	movzbl -0x7feea51b(,%eax,8),%edx
80106b59:	80 
80106b5a:	83 e2 f0             	and    $0xfffffff0,%edx
80106b5d:	83 ca 0e             	or     $0xe,%edx
80106b60:	88 14 c5 e5 5a 11 80 	mov    %dl,-0x7feea51b(,%eax,8)
80106b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6a:	0f b6 14 c5 e5 5a 11 	movzbl -0x7feea51b(,%eax,8),%edx
80106b71:	80 
80106b72:	83 e2 ef             	and    $0xffffffef,%edx
80106b75:	88 14 c5 e5 5a 11 80 	mov    %dl,-0x7feea51b(,%eax,8)
80106b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7f:	0f b6 14 c5 e5 5a 11 	movzbl -0x7feea51b(,%eax,8),%edx
80106b86:	80 
80106b87:	83 e2 9f             	and    $0xffffff9f,%edx
80106b8a:	88 14 c5 e5 5a 11 80 	mov    %dl,-0x7feea51b(,%eax,8)
80106b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b94:	0f b6 14 c5 e5 5a 11 	movzbl -0x7feea51b(,%eax,8),%edx
80106b9b:	80 
80106b9c:	83 ca 80             	or     $0xffffff80,%edx
80106b9f:	88 14 c5 e5 5a 11 80 	mov    %dl,-0x7feea51b(,%eax,8)
80106ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba9:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106bb0:	c1 e8 10             	shr    $0x10,%eax
80106bb3:	89 c2                	mov    %eax,%edx
80106bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb8:	66 89 14 c5 e6 5a 11 	mov    %dx,-0x7feea51a(,%eax,8)
80106bbf:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106bc0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bc4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bcb:	0f 8e 30 ff ff ff    	jle    80106b01 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106bd1:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106bd6:	66 a3 e0 5c 11 80    	mov    %ax,0x80115ce0
80106bdc:	66 c7 05 e2 5c 11 80 	movw   $0x8,0x80115ce2
80106be3:	08 00 
80106be5:	0f b6 05 e4 5c 11 80 	movzbl 0x80115ce4,%eax
80106bec:	83 e0 e0             	and    $0xffffffe0,%eax
80106bef:	a2 e4 5c 11 80       	mov    %al,0x80115ce4
80106bf4:	0f b6 05 e4 5c 11 80 	movzbl 0x80115ce4,%eax
80106bfb:	83 e0 1f             	and    $0x1f,%eax
80106bfe:	a2 e4 5c 11 80       	mov    %al,0x80115ce4
80106c03:	0f b6 05 e5 5c 11 80 	movzbl 0x80115ce5,%eax
80106c0a:	83 c8 0f             	or     $0xf,%eax
80106c0d:	a2 e5 5c 11 80       	mov    %al,0x80115ce5
80106c12:	0f b6 05 e5 5c 11 80 	movzbl 0x80115ce5,%eax
80106c19:	83 e0 ef             	and    $0xffffffef,%eax
80106c1c:	a2 e5 5c 11 80       	mov    %al,0x80115ce5
80106c21:	0f b6 05 e5 5c 11 80 	movzbl 0x80115ce5,%eax
80106c28:	83 c8 60             	or     $0x60,%eax
80106c2b:	a2 e5 5c 11 80       	mov    %al,0x80115ce5
80106c30:	0f b6 05 e5 5c 11 80 	movzbl 0x80115ce5,%eax
80106c37:	83 c8 80             	or     $0xffffff80,%eax
80106c3a:	a2 e5 5c 11 80       	mov    %al,0x80115ce5
80106c3f:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106c44:	c1 e8 10             	shr    $0x10,%eax
80106c47:	66 a3 e6 5c 11 80    	mov    %ax,0x80115ce6
  
  initlock(&tickslock, "time");
80106c4d:	83 ec 08             	sub    $0x8,%esp
80106c50:	68 f0 8e 10 80       	push   $0x80108ef0
80106c55:	68 a0 5a 11 80       	push   $0x80115aa0
80106c5a:	e8 e9 e7 ff ff       	call   80105448 <initlock>
80106c5f:	83 c4 10             	add    $0x10,%esp
}
80106c62:	90                   	nop
80106c63:	c9                   	leave  
80106c64:	c3                   	ret    

80106c65 <idtinit>:

void
idtinit(void)
{
80106c65:	55                   	push   %ebp
80106c66:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c68:	68 00 08 00 00       	push   $0x800
80106c6d:	68 e0 5a 11 80       	push   $0x80115ae0
80106c72:	e8 3d fe ff ff       	call   80106ab4 <lidt>
80106c77:	83 c4 08             	add    $0x8,%esp
}
80106c7a:	90                   	nop
80106c7b:	c9                   	leave  
80106c7c:	c3                   	ret    

80106c7d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c7d:	55                   	push   %ebp
80106c7e:	89 e5                	mov    %esp,%ebp
80106c80:	57                   	push   %edi
80106c81:	56                   	push   %esi
80106c82:	53                   	push   %ebx
80106c83:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106c86:	8b 45 08             	mov    0x8(%ebp),%eax
80106c89:	8b 40 30             	mov    0x30(%eax),%eax
80106c8c:	83 f8 40             	cmp    $0x40,%eax
80106c8f:	75 3e                	jne    80106ccf <trap+0x52>
    if(proc->killed)
80106c91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c97:	8b 40 2c             	mov    0x2c(%eax),%eax
80106c9a:	85 c0                	test   %eax,%eax
80106c9c:	74 05                	je     80106ca3 <trap+0x26>
      exit();
80106c9e:	e8 4f dc ff ff       	call   801048f2 <exit>
    proc->tf = tf;
80106ca3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca9:	8b 55 08             	mov    0x8(%ebp),%edx
80106cac:	89 50 20             	mov    %edx,0x20(%eax)
    syscall();
80106caf:	e8 fa ed ff ff       	call   80105aae <syscall>
    if(proc->killed)
80106cb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cba:	8b 40 2c             	mov    0x2c(%eax),%eax
80106cbd:	85 c0                	test   %eax,%eax
80106cbf:	0f 84 1b 02 00 00    	je     80106ee0 <trap+0x263>
      exit();
80106cc5:	e8 28 dc ff ff       	call   801048f2 <exit>
    return;
80106cca:	e9 11 02 00 00       	jmp    80106ee0 <trap+0x263>
  }

  switch(tf->trapno){
80106ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd2:	8b 40 30             	mov    0x30(%eax),%eax
80106cd5:	83 e8 20             	sub    $0x20,%eax
80106cd8:	83 f8 1f             	cmp    $0x1f,%eax
80106cdb:	0f 87 c0 00 00 00    	ja     80106da1 <trap+0x124>
80106ce1:	8b 04 85 98 8f 10 80 	mov    -0x7fef7068(,%eax,4),%eax
80106ce8:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106cea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106cf0:	0f b6 00             	movzbl (%eax),%eax
80106cf3:	84 c0                	test   %al,%al
80106cf5:	75 3d                	jne    80106d34 <trap+0xb7>
      acquire(&tickslock);
80106cf7:	83 ec 0c             	sub    $0xc,%esp
80106cfa:	68 a0 5a 11 80       	push   $0x80115aa0
80106cff:	e8 66 e7 ff ff       	call   8010546a <acquire>
80106d04:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d07:	a1 e0 62 11 80       	mov    0x801162e0,%eax
80106d0c:	83 c0 01             	add    $0x1,%eax
80106d0f:	a3 e0 62 11 80       	mov    %eax,0x801162e0
      wakeup(&ticks);
80106d14:	83 ec 0c             	sub    $0xc,%esp
80106d17:	68 e0 62 11 80       	push   $0x801162e0
80106d1c:	e8 cc e3 ff ff       	call   801050ed <wakeup>
80106d21:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d24:	83 ec 0c             	sub    $0xc,%esp
80106d27:	68 a0 5a 11 80       	push   $0x80115aa0
80106d2c:	e8 a0 e7 ff ff       	call   801054d1 <release>
80106d31:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d34:	e8 ed c2 ff ff       	call   80103026 <lapiceoi>
    break;
80106d39:	e9 1c 01 00 00       	jmp    80106e5a <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d3e:	e8 f6 ba ff ff       	call   80102839 <ideintr>
    lapiceoi();
80106d43:	e8 de c2 ff ff       	call   80103026 <lapiceoi>
    break;
80106d48:	e9 0d 01 00 00       	jmp    80106e5a <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d4d:	e8 d6 c0 ff ff       	call   80102e28 <kbdintr>
    lapiceoi();
80106d52:	e8 cf c2 ff ff       	call   80103026 <lapiceoi>
    break;
80106d57:	e9 fe 00 00 00       	jmp    80106e5a <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d5c:	e8 60 03 00 00       	call   801070c1 <uartintr>
    lapiceoi();
80106d61:	e8 c0 c2 ff ff       	call   80103026 <lapiceoi>
    break;
80106d66:	e9 ef 00 00 00       	jmp    80106e5a <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d6e:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106d71:	8b 45 08             	mov    0x8(%ebp),%eax
80106d74:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d78:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106d7b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d81:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d84:	0f b6 c0             	movzbl %al,%eax
80106d87:	51                   	push   %ecx
80106d88:	52                   	push   %edx
80106d89:	50                   	push   %eax
80106d8a:	68 f8 8e 10 80       	push   $0x80108ef8
80106d8f:	e8 32 96 ff ff       	call   801003c6 <cprintf>
80106d94:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106d97:	e8 8a c2 ff ff       	call   80103026 <lapiceoi>
    break;
80106d9c:	e9 b9 00 00 00       	jmp    80106e5a <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106da1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106da7:	85 c0                	test   %eax,%eax
80106da9:	74 11                	je     80106dbc <trap+0x13f>
80106dab:	8b 45 08             	mov    0x8(%ebp),%eax
80106dae:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106db2:	0f b7 c0             	movzwl %ax,%eax
80106db5:	83 e0 03             	and    $0x3,%eax
80106db8:	85 c0                	test   %eax,%eax
80106dba:	75 40                	jne    80106dfc <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dbc:	e8 1d fd ff ff       	call   80106ade <rcr2>
80106dc1:	89 c3                	mov    %eax,%ebx
80106dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc6:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106dc9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106dcf:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dd2:	0f b6 d0             	movzbl %al,%edx
80106dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd8:	8b 40 30             	mov    0x30(%eax),%eax
80106ddb:	83 ec 0c             	sub    $0xc,%esp
80106dde:	53                   	push   %ebx
80106ddf:	51                   	push   %ecx
80106de0:	52                   	push   %edx
80106de1:	50                   	push   %eax
80106de2:	68 1c 8f 10 80       	push   $0x80108f1c
80106de7:	e8 da 95 ff ff       	call   801003c6 <cprintf>
80106dec:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106def:	83 ec 0c             	sub    $0xc,%esp
80106df2:	68 4e 8f 10 80       	push   $0x80108f4e
80106df7:	e8 6a 97 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106dfc:	e8 dd fc ff ff       	call   80106ade <rcr2>
80106e01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e04:	8b 45 08             	mov    0x8(%ebp),%eax
80106e07:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e0a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e10:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e13:	0f b6 d8             	movzbl %al,%ebx
80106e16:	8b 45 08             	mov    0x8(%ebp),%eax
80106e19:	8b 48 34             	mov    0x34(%eax),%ecx
80106e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1f:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e28:	8d 78 74             	lea    0x74(%eax),%edi
80106e2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e31:	8b 40 18             	mov    0x18(%eax),%eax
80106e34:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e37:	56                   	push   %esi
80106e38:	53                   	push   %ebx
80106e39:	51                   	push   %ecx
80106e3a:	52                   	push   %edx
80106e3b:	57                   	push   %edi
80106e3c:	50                   	push   %eax
80106e3d:	68 54 8f 10 80       	push   $0x80108f54
80106e42:	e8 7f 95 ff ff       	call   801003c6 <cprintf>
80106e47:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106e4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e50:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
80106e57:	eb 01                	jmp    80106e5a <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106e59:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106e5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e60:	85 c0                	test   %eax,%eax
80106e62:	74 24                	je     80106e88 <trap+0x20b>
80106e64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e6a:	8b 40 2c             	mov    0x2c(%eax),%eax
80106e6d:	85 c0                	test   %eax,%eax
80106e6f:	74 17                	je     80106e88 <trap+0x20b>
80106e71:	8b 45 08             	mov    0x8(%ebp),%eax
80106e74:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e78:	0f b7 c0             	movzwl %ax,%eax
80106e7b:	83 e0 03             	and    $0x3,%eax
80106e7e:	83 f8 03             	cmp    $0x3,%eax
80106e81:	75 05                	jne    80106e88 <trap+0x20b>
    exit();
80106e83:	e8 6a da ff ff       	call   801048f2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e8e:	85 c0                	test   %eax,%eax
80106e90:	74 1e                	je     80106eb0 <trap+0x233>
80106e92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e98:	8b 40 14             	mov    0x14(%eax),%eax
80106e9b:	83 f8 04             	cmp    $0x4,%eax
80106e9e:	75 10                	jne    80106eb0 <trap+0x233>
80106ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea3:	8b 40 30             	mov    0x30(%eax),%eax
80106ea6:	83 f8 20             	cmp    $0x20,%eax
80106ea9:	75 05                	jne    80106eb0 <trap+0x233>
    yield();
80106eab:	e8 ce e0 ff ff       	call   80104f7e <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eb6:	85 c0                	test   %eax,%eax
80106eb8:	74 27                	je     80106ee1 <trap+0x264>
80106eba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec0:	8b 40 2c             	mov    0x2c(%eax),%eax
80106ec3:	85 c0                	test   %eax,%eax
80106ec5:	74 1a                	je     80106ee1 <trap+0x264>
80106ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80106eca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ece:	0f b7 c0             	movzwl %ax,%eax
80106ed1:	83 e0 03             	and    $0x3,%eax
80106ed4:	83 f8 03             	cmp    $0x3,%eax
80106ed7:	75 08                	jne    80106ee1 <trap+0x264>
    exit();
80106ed9:	e8 14 da ff ff       	call   801048f2 <exit>
80106ede:	eb 01                	jmp    80106ee1 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106ee0:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ee4:	5b                   	pop    %ebx
80106ee5:	5e                   	pop    %esi
80106ee6:	5f                   	pop    %edi
80106ee7:	5d                   	pop    %ebp
80106ee8:	c3                   	ret    

80106ee9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106ee9:	55                   	push   %ebp
80106eea:	89 e5                	mov    %esp,%ebp
80106eec:	83 ec 14             	sub    $0x14,%esp
80106eef:	8b 45 08             	mov    0x8(%ebp),%eax
80106ef2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106ef6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106efa:	89 c2                	mov    %eax,%edx
80106efc:	ec                   	in     (%dx),%al
80106efd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f00:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f04:	c9                   	leave  
80106f05:	c3                   	ret    

80106f06 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106f06:	55                   	push   %ebp
80106f07:	89 e5                	mov    %esp,%ebp
80106f09:	83 ec 08             	sub    $0x8,%esp
80106f0c:	8b 55 08             	mov    0x8(%ebp),%edx
80106f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f12:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106f16:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f19:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f1d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f21:	ee                   	out    %al,(%dx)
}
80106f22:	90                   	nop
80106f23:	c9                   	leave  
80106f24:	c3                   	ret    

80106f25 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f25:	55                   	push   %ebp
80106f26:	89 e5                	mov    %esp,%ebp
80106f28:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f2b:	6a 00                	push   $0x0
80106f2d:	68 fa 03 00 00       	push   $0x3fa
80106f32:	e8 cf ff ff ff       	call   80106f06 <outb>
80106f37:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f3a:	68 80 00 00 00       	push   $0x80
80106f3f:	68 fb 03 00 00       	push   $0x3fb
80106f44:	e8 bd ff ff ff       	call   80106f06 <outb>
80106f49:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f4c:	6a 0c                	push   $0xc
80106f4e:	68 f8 03 00 00       	push   $0x3f8
80106f53:	e8 ae ff ff ff       	call   80106f06 <outb>
80106f58:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106f5b:	6a 00                	push   $0x0
80106f5d:	68 f9 03 00 00       	push   $0x3f9
80106f62:	e8 9f ff ff ff       	call   80106f06 <outb>
80106f67:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106f6a:	6a 03                	push   $0x3
80106f6c:	68 fb 03 00 00       	push   $0x3fb
80106f71:	e8 90 ff ff ff       	call   80106f06 <outb>
80106f76:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106f79:	6a 00                	push   $0x0
80106f7b:	68 fc 03 00 00       	push   $0x3fc
80106f80:	e8 81 ff ff ff       	call   80106f06 <outb>
80106f85:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106f88:	6a 01                	push   $0x1
80106f8a:	68 f9 03 00 00       	push   $0x3f9
80106f8f:	e8 72 ff ff ff       	call   80106f06 <outb>
80106f94:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106f97:	68 fd 03 00 00       	push   $0x3fd
80106f9c:	e8 48 ff ff ff       	call   80106ee9 <inb>
80106fa1:	83 c4 04             	add    $0x4,%esp
80106fa4:	3c ff                	cmp    $0xff,%al
80106fa6:	74 6e                	je     80107016 <uartinit+0xf1>
    return;
  uart = 1;
80106fa8:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80106faf:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106fb2:	68 fa 03 00 00       	push   $0x3fa
80106fb7:	e8 2d ff ff ff       	call   80106ee9 <inb>
80106fbc:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106fbf:	68 f8 03 00 00       	push   $0x3f8
80106fc4:	e8 20 ff ff ff       	call   80106ee9 <inb>
80106fc9:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106fcc:	83 ec 0c             	sub    $0xc,%esp
80106fcf:	6a 04                	push   $0x4
80106fd1:	e8 56 cf ff ff       	call   80103f2c <picenable>
80106fd6:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106fd9:	83 ec 08             	sub    $0x8,%esp
80106fdc:	6a 00                	push   $0x0
80106fde:	6a 04                	push   $0x4
80106fe0:	e8 f6 ba ff ff       	call   80102adb <ioapicenable>
80106fe5:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106fe8:	c7 45 f4 18 90 10 80 	movl   $0x80109018,-0xc(%ebp)
80106fef:	eb 19                	jmp    8010700a <uartinit+0xe5>
    uartputc(*p);
80106ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff4:	0f b6 00             	movzbl (%eax),%eax
80106ff7:	0f be c0             	movsbl %al,%eax
80106ffa:	83 ec 0c             	sub    $0xc,%esp
80106ffd:	50                   	push   %eax
80106ffe:	e8 16 00 00 00       	call   80107019 <uartputc>
80107003:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107006:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010700a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700d:	0f b6 00             	movzbl (%eax),%eax
80107010:	84 c0                	test   %al,%al
80107012:	75 dd                	jne    80106ff1 <uartinit+0xcc>
80107014:	eb 01                	jmp    80107017 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107016:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107017:	c9                   	leave  
80107018:	c3                   	ret    

80107019 <uartputc>:

void
uartputc(int c)
{
80107019:	55                   	push   %ebp
8010701a:	89 e5                	mov    %esp,%ebp
8010701c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010701f:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80107024:	85 c0                	test   %eax,%eax
80107026:	74 53                	je     8010707b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107028:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010702f:	eb 11                	jmp    80107042 <uartputc+0x29>
    microdelay(10);
80107031:	83 ec 0c             	sub    $0xc,%esp
80107034:	6a 0a                	push   $0xa
80107036:	e8 06 c0 ff ff       	call   80103041 <microdelay>
8010703b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010703e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107042:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107046:	7f 1a                	jg     80107062 <uartputc+0x49>
80107048:	83 ec 0c             	sub    $0xc,%esp
8010704b:	68 fd 03 00 00       	push   $0x3fd
80107050:	e8 94 fe ff ff       	call   80106ee9 <inb>
80107055:	83 c4 10             	add    $0x10,%esp
80107058:	0f b6 c0             	movzbl %al,%eax
8010705b:	83 e0 20             	and    $0x20,%eax
8010705e:	85 c0                	test   %eax,%eax
80107060:	74 cf                	je     80107031 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107062:	8b 45 08             	mov    0x8(%ebp),%eax
80107065:	0f b6 c0             	movzbl %al,%eax
80107068:	83 ec 08             	sub    $0x8,%esp
8010706b:	50                   	push   %eax
8010706c:	68 f8 03 00 00       	push   $0x3f8
80107071:	e8 90 fe ff ff       	call   80106f06 <outb>
80107076:	83 c4 10             	add    $0x10,%esp
80107079:	eb 01                	jmp    8010707c <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010707b:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010707c:	c9                   	leave  
8010707d:	c3                   	ret    

8010707e <uartgetc>:

static int
uartgetc(void)
{
8010707e:	55                   	push   %ebp
8010707f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107081:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80107086:	85 c0                	test   %eax,%eax
80107088:	75 07                	jne    80107091 <uartgetc+0x13>
    return -1;
8010708a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010708f:	eb 2e                	jmp    801070bf <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107091:	68 fd 03 00 00       	push   $0x3fd
80107096:	e8 4e fe ff ff       	call   80106ee9 <inb>
8010709b:	83 c4 04             	add    $0x4,%esp
8010709e:	0f b6 c0             	movzbl %al,%eax
801070a1:	83 e0 01             	and    $0x1,%eax
801070a4:	85 c0                	test   %eax,%eax
801070a6:	75 07                	jne    801070af <uartgetc+0x31>
    return -1;
801070a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ad:	eb 10                	jmp    801070bf <uartgetc+0x41>
  return inb(COM1+0);
801070af:	68 f8 03 00 00       	push   $0x3f8
801070b4:	e8 30 fe ff ff       	call   80106ee9 <inb>
801070b9:	83 c4 04             	add    $0x4,%esp
801070bc:	0f b6 c0             	movzbl %al,%eax
}
801070bf:	c9                   	leave  
801070c0:	c3                   	ret    

801070c1 <uartintr>:

void
uartintr(void)
{
801070c1:	55                   	push   %ebp
801070c2:	89 e5                	mov    %esp,%ebp
801070c4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801070c7:	83 ec 0c             	sub    $0xc,%esp
801070ca:	68 7e 70 10 80       	push   $0x8010707e
801070cf:	e8 25 97 ff ff       	call   801007f9 <consoleintr>
801070d4:	83 c4 10             	add    $0x10,%esp
}
801070d7:	90                   	nop
801070d8:	c9                   	leave  
801070d9:	c3                   	ret    

801070da <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $0
801070dc:	6a 00                	push   $0x0
  jmp alltraps
801070de:	e9 a6 f9 ff ff       	jmp    80106a89 <alltraps>

801070e3 <vector1>:
.globl vector1
vector1:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $1
801070e5:	6a 01                	push   $0x1
  jmp alltraps
801070e7:	e9 9d f9 ff ff       	jmp    80106a89 <alltraps>

801070ec <vector2>:
.globl vector2
vector2:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $2
801070ee:	6a 02                	push   $0x2
  jmp alltraps
801070f0:	e9 94 f9 ff ff       	jmp    80106a89 <alltraps>

801070f5 <vector3>:
.globl vector3
vector3:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $3
801070f7:	6a 03                	push   $0x3
  jmp alltraps
801070f9:	e9 8b f9 ff ff       	jmp    80106a89 <alltraps>

801070fe <vector4>:
.globl vector4
vector4:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $4
80107100:	6a 04                	push   $0x4
  jmp alltraps
80107102:	e9 82 f9 ff ff       	jmp    80106a89 <alltraps>

80107107 <vector5>:
.globl vector5
vector5:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $5
80107109:	6a 05                	push   $0x5
  jmp alltraps
8010710b:	e9 79 f9 ff ff       	jmp    80106a89 <alltraps>

80107110 <vector6>:
.globl vector6
vector6:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $6
80107112:	6a 06                	push   $0x6
  jmp alltraps
80107114:	e9 70 f9 ff ff       	jmp    80106a89 <alltraps>

80107119 <vector7>:
.globl vector7
vector7:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $7
8010711b:	6a 07                	push   $0x7
  jmp alltraps
8010711d:	e9 67 f9 ff ff       	jmp    80106a89 <alltraps>

80107122 <vector8>:
.globl vector8
vector8:
  pushl $8
80107122:	6a 08                	push   $0x8
  jmp alltraps
80107124:	e9 60 f9 ff ff       	jmp    80106a89 <alltraps>

80107129 <vector9>:
.globl vector9
vector9:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $9
8010712b:	6a 09                	push   $0x9
  jmp alltraps
8010712d:	e9 57 f9 ff ff       	jmp    80106a89 <alltraps>

80107132 <vector10>:
.globl vector10
vector10:
  pushl $10
80107132:	6a 0a                	push   $0xa
  jmp alltraps
80107134:	e9 50 f9 ff ff       	jmp    80106a89 <alltraps>

80107139 <vector11>:
.globl vector11
vector11:
  pushl $11
80107139:	6a 0b                	push   $0xb
  jmp alltraps
8010713b:	e9 49 f9 ff ff       	jmp    80106a89 <alltraps>

80107140 <vector12>:
.globl vector12
vector12:
  pushl $12
80107140:	6a 0c                	push   $0xc
  jmp alltraps
80107142:	e9 42 f9 ff ff       	jmp    80106a89 <alltraps>

80107147 <vector13>:
.globl vector13
vector13:
  pushl $13
80107147:	6a 0d                	push   $0xd
  jmp alltraps
80107149:	e9 3b f9 ff ff       	jmp    80106a89 <alltraps>

8010714e <vector14>:
.globl vector14
vector14:
  pushl $14
8010714e:	6a 0e                	push   $0xe
  jmp alltraps
80107150:	e9 34 f9 ff ff       	jmp    80106a89 <alltraps>

80107155 <vector15>:
.globl vector15
vector15:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $15
80107157:	6a 0f                	push   $0xf
  jmp alltraps
80107159:	e9 2b f9 ff ff       	jmp    80106a89 <alltraps>

8010715e <vector16>:
.globl vector16
vector16:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $16
80107160:	6a 10                	push   $0x10
  jmp alltraps
80107162:	e9 22 f9 ff ff       	jmp    80106a89 <alltraps>

80107167 <vector17>:
.globl vector17
vector17:
  pushl $17
80107167:	6a 11                	push   $0x11
  jmp alltraps
80107169:	e9 1b f9 ff ff       	jmp    80106a89 <alltraps>

8010716e <vector18>:
.globl vector18
vector18:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $18
80107170:	6a 12                	push   $0x12
  jmp alltraps
80107172:	e9 12 f9 ff ff       	jmp    80106a89 <alltraps>

80107177 <vector19>:
.globl vector19
vector19:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $19
80107179:	6a 13                	push   $0x13
  jmp alltraps
8010717b:	e9 09 f9 ff ff       	jmp    80106a89 <alltraps>

80107180 <vector20>:
.globl vector20
vector20:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $20
80107182:	6a 14                	push   $0x14
  jmp alltraps
80107184:	e9 00 f9 ff ff       	jmp    80106a89 <alltraps>

80107189 <vector21>:
.globl vector21
vector21:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $21
8010718b:	6a 15                	push   $0x15
  jmp alltraps
8010718d:	e9 f7 f8 ff ff       	jmp    80106a89 <alltraps>

80107192 <vector22>:
.globl vector22
vector22:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $22
80107194:	6a 16                	push   $0x16
  jmp alltraps
80107196:	e9 ee f8 ff ff       	jmp    80106a89 <alltraps>

8010719b <vector23>:
.globl vector23
vector23:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $23
8010719d:	6a 17                	push   $0x17
  jmp alltraps
8010719f:	e9 e5 f8 ff ff       	jmp    80106a89 <alltraps>

801071a4 <vector24>:
.globl vector24
vector24:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $24
801071a6:	6a 18                	push   $0x18
  jmp alltraps
801071a8:	e9 dc f8 ff ff       	jmp    80106a89 <alltraps>

801071ad <vector25>:
.globl vector25
vector25:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $25
801071af:	6a 19                	push   $0x19
  jmp alltraps
801071b1:	e9 d3 f8 ff ff       	jmp    80106a89 <alltraps>

801071b6 <vector26>:
.globl vector26
vector26:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $26
801071b8:	6a 1a                	push   $0x1a
  jmp alltraps
801071ba:	e9 ca f8 ff ff       	jmp    80106a89 <alltraps>

801071bf <vector27>:
.globl vector27
vector27:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $27
801071c1:	6a 1b                	push   $0x1b
  jmp alltraps
801071c3:	e9 c1 f8 ff ff       	jmp    80106a89 <alltraps>

801071c8 <vector28>:
.globl vector28
vector28:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $28
801071ca:	6a 1c                	push   $0x1c
  jmp alltraps
801071cc:	e9 b8 f8 ff ff       	jmp    80106a89 <alltraps>

801071d1 <vector29>:
.globl vector29
vector29:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $29
801071d3:	6a 1d                	push   $0x1d
  jmp alltraps
801071d5:	e9 af f8 ff ff       	jmp    80106a89 <alltraps>

801071da <vector30>:
.globl vector30
vector30:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $30
801071dc:	6a 1e                	push   $0x1e
  jmp alltraps
801071de:	e9 a6 f8 ff ff       	jmp    80106a89 <alltraps>

801071e3 <vector31>:
.globl vector31
vector31:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $31
801071e5:	6a 1f                	push   $0x1f
  jmp alltraps
801071e7:	e9 9d f8 ff ff       	jmp    80106a89 <alltraps>

801071ec <vector32>:
.globl vector32
vector32:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $32
801071ee:	6a 20                	push   $0x20
  jmp alltraps
801071f0:	e9 94 f8 ff ff       	jmp    80106a89 <alltraps>

801071f5 <vector33>:
.globl vector33
vector33:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $33
801071f7:	6a 21                	push   $0x21
  jmp alltraps
801071f9:	e9 8b f8 ff ff       	jmp    80106a89 <alltraps>

801071fe <vector34>:
.globl vector34
vector34:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $34
80107200:	6a 22                	push   $0x22
  jmp alltraps
80107202:	e9 82 f8 ff ff       	jmp    80106a89 <alltraps>

80107207 <vector35>:
.globl vector35
vector35:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $35
80107209:	6a 23                	push   $0x23
  jmp alltraps
8010720b:	e9 79 f8 ff ff       	jmp    80106a89 <alltraps>

80107210 <vector36>:
.globl vector36
vector36:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $36
80107212:	6a 24                	push   $0x24
  jmp alltraps
80107214:	e9 70 f8 ff ff       	jmp    80106a89 <alltraps>

80107219 <vector37>:
.globl vector37
vector37:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $37
8010721b:	6a 25                	push   $0x25
  jmp alltraps
8010721d:	e9 67 f8 ff ff       	jmp    80106a89 <alltraps>

80107222 <vector38>:
.globl vector38
vector38:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $38
80107224:	6a 26                	push   $0x26
  jmp alltraps
80107226:	e9 5e f8 ff ff       	jmp    80106a89 <alltraps>

8010722b <vector39>:
.globl vector39
vector39:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $39
8010722d:	6a 27                	push   $0x27
  jmp alltraps
8010722f:	e9 55 f8 ff ff       	jmp    80106a89 <alltraps>

80107234 <vector40>:
.globl vector40
vector40:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $40
80107236:	6a 28                	push   $0x28
  jmp alltraps
80107238:	e9 4c f8 ff ff       	jmp    80106a89 <alltraps>

8010723d <vector41>:
.globl vector41
vector41:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $41
8010723f:	6a 29                	push   $0x29
  jmp alltraps
80107241:	e9 43 f8 ff ff       	jmp    80106a89 <alltraps>

80107246 <vector42>:
.globl vector42
vector42:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $42
80107248:	6a 2a                	push   $0x2a
  jmp alltraps
8010724a:	e9 3a f8 ff ff       	jmp    80106a89 <alltraps>

8010724f <vector43>:
.globl vector43
vector43:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $43
80107251:	6a 2b                	push   $0x2b
  jmp alltraps
80107253:	e9 31 f8 ff ff       	jmp    80106a89 <alltraps>

80107258 <vector44>:
.globl vector44
vector44:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $44
8010725a:	6a 2c                	push   $0x2c
  jmp alltraps
8010725c:	e9 28 f8 ff ff       	jmp    80106a89 <alltraps>

80107261 <vector45>:
.globl vector45
vector45:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $45
80107263:	6a 2d                	push   $0x2d
  jmp alltraps
80107265:	e9 1f f8 ff ff       	jmp    80106a89 <alltraps>

8010726a <vector46>:
.globl vector46
vector46:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $46
8010726c:	6a 2e                	push   $0x2e
  jmp alltraps
8010726e:	e9 16 f8 ff ff       	jmp    80106a89 <alltraps>

80107273 <vector47>:
.globl vector47
vector47:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $47
80107275:	6a 2f                	push   $0x2f
  jmp alltraps
80107277:	e9 0d f8 ff ff       	jmp    80106a89 <alltraps>

8010727c <vector48>:
.globl vector48
vector48:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $48
8010727e:	6a 30                	push   $0x30
  jmp alltraps
80107280:	e9 04 f8 ff ff       	jmp    80106a89 <alltraps>

80107285 <vector49>:
.globl vector49
vector49:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $49
80107287:	6a 31                	push   $0x31
  jmp alltraps
80107289:	e9 fb f7 ff ff       	jmp    80106a89 <alltraps>

8010728e <vector50>:
.globl vector50
vector50:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $50
80107290:	6a 32                	push   $0x32
  jmp alltraps
80107292:	e9 f2 f7 ff ff       	jmp    80106a89 <alltraps>

80107297 <vector51>:
.globl vector51
vector51:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $51
80107299:	6a 33                	push   $0x33
  jmp alltraps
8010729b:	e9 e9 f7 ff ff       	jmp    80106a89 <alltraps>

801072a0 <vector52>:
.globl vector52
vector52:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $52
801072a2:	6a 34                	push   $0x34
  jmp alltraps
801072a4:	e9 e0 f7 ff ff       	jmp    80106a89 <alltraps>

801072a9 <vector53>:
.globl vector53
vector53:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $53
801072ab:	6a 35                	push   $0x35
  jmp alltraps
801072ad:	e9 d7 f7 ff ff       	jmp    80106a89 <alltraps>

801072b2 <vector54>:
.globl vector54
vector54:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $54
801072b4:	6a 36                	push   $0x36
  jmp alltraps
801072b6:	e9 ce f7 ff ff       	jmp    80106a89 <alltraps>

801072bb <vector55>:
.globl vector55
vector55:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $55
801072bd:	6a 37                	push   $0x37
  jmp alltraps
801072bf:	e9 c5 f7 ff ff       	jmp    80106a89 <alltraps>

801072c4 <vector56>:
.globl vector56
vector56:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $56
801072c6:	6a 38                	push   $0x38
  jmp alltraps
801072c8:	e9 bc f7 ff ff       	jmp    80106a89 <alltraps>

801072cd <vector57>:
.globl vector57
vector57:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $57
801072cf:	6a 39                	push   $0x39
  jmp alltraps
801072d1:	e9 b3 f7 ff ff       	jmp    80106a89 <alltraps>

801072d6 <vector58>:
.globl vector58
vector58:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $58
801072d8:	6a 3a                	push   $0x3a
  jmp alltraps
801072da:	e9 aa f7 ff ff       	jmp    80106a89 <alltraps>

801072df <vector59>:
.globl vector59
vector59:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $59
801072e1:	6a 3b                	push   $0x3b
  jmp alltraps
801072e3:	e9 a1 f7 ff ff       	jmp    80106a89 <alltraps>

801072e8 <vector60>:
.globl vector60
vector60:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $60
801072ea:	6a 3c                	push   $0x3c
  jmp alltraps
801072ec:	e9 98 f7 ff ff       	jmp    80106a89 <alltraps>

801072f1 <vector61>:
.globl vector61
vector61:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $61
801072f3:	6a 3d                	push   $0x3d
  jmp alltraps
801072f5:	e9 8f f7 ff ff       	jmp    80106a89 <alltraps>

801072fa <vector62>:
.globl vector62
vector62:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $62
801072fc:	6a 3e                	push   $0x3e
  jmp alltraps
801072fe:	e9 86 f7 ff ff       	jmp    80106a89 <alltraps>

80107303 <vector63>:
.globl vector63
vector63:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $63
80107305:	6a 3f                	push   $0x3f
  jmp alltraps
80107307:	e9 7d f7 ff ff       	jmp    80106a89 <alltraps>

8010730c <vector64>:
.globl vector64
vector64:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $64
8010730e:	6a 40                	push   $0x40
  jmp alltraps
80107310:	e9 74 f7 ff ff       	jmp    80106a89 <alltraps>

80107315 <vector65>:
.globl vector65
vector65:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $65
80107317:	6a 41                	push   $0x41
  jmp alltraps
80107319:	e9 6b f7 ff ff       	jmp    80106a89 <alltraps>

8010731e <vector66>:
.globl vector66
vector66:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $66
80107320:	6a 42                	push   $0x42
  jmp alltraps
80107322:	e9 62 f7 ff ff       	jmp    80106a89 <alltraps>

80107327 <vector67>:
.globl vector67
vector67:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $67
80107329:	6a 43                	push   $0x43
  jmp alltraps
8010732b:	e9 59 f7 ff ff       	jmp    80106a89 <alltraps>

80107330 <vector68>:
.globl vector68
vector68:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $68
80107332:	6a 44                	push   $0x44
  jmp alltraps
80107334:	e9 50 f7 ff ff       	jmp    80106a89 <alltraps>

80107339 <vector69>:
.globl vector69
vector69:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $69
8010733b:	6a 45                	push   $0x45
  jmp alltraps
8010733d:	e9 47 f7 ff ff       	jmp    80106a89 <alltraps>

80107342 <vector70>:
.globl vector70
vector70:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $70
80107344:	6a 46                	push   $0x46
  jmp alltraps
80107346:	e9 3e f7 ff ff       	jmp    80106a89 <alltraps>

8010734b <vector71>:
.globl vector71
vector71:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $71
8010734d:	6a 47                	push   $0x47
  jmp alltraps
8010734f:	e9 35 f7 ff ff       	jmp    80106a89 <alltraps>

80107354 <vector72>:
.globl vector72
vector72:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $72
80107356:	6a 48                	push   $0x48
  jmp alltraps
80107358:	e9 2c f7 ff ff       	jmp    80106a89 <alltraps>

8010735d <vector73>:
.globl vector73
vector73:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $73
8010735f:	6a 49                	push   $0x49
  jmp alltraps
80107361:	e9 23 f7 ff ff       	jmp    80106a89 <alltraps>

80107366 <vector74>:
.globl vector74
vector74:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $74
80107368:	6a 4a                	push   $0x4a
  jmp alltraps
8010736a:	e9 1a f7 ff ff       	jmp    80106a89 <alltraps>

8010736f <vector75>:
.globl vector75
vector75:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $75
80107371:	6a 4b                	push   $0x4b
  jmp alltraps
80107373:	e9 11 f7 ff ff       	jmp    80106a89 <alltraps>

80107378 <vector76>:
.globl vector76
vector76:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $76
8010737a:	6a 4c                	push   $0x4c
  jmp alltraps
8010737c:	e9 08 f7 ff ff       	jmp    80106a89 <alltraps>

80107381 <vector77>:
.globl vector77
vector77:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $77
80107383:	6a 4d                	push   $0x4d
  jmp alltraps
80107385:	e9 ff f6 ff ff       	jmp    80106a89 <alltraps>

8010738a <vector78>:
.globl vector78
vector78:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $78
8010738c:	6a 4e                	push   $0x4e
  jmp alltraps
8010738e:	e9 f6 f6 ff ff       	jmp    80106a89 <alltraps>

80107393 <vector79>:
.globl vector79
vector79:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $79
80107395:	6a 4f                	push   $0x4f
  jmp alltraps
80107397:	e9 ed f6 ff ff       	jmp    80106a89 <alltraps>

8010739c <vector80>:
.globl vector80
vector80:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $80
8010739e:	6a 50                	push   $0x50
  jmp alltraps
801073a0:	e9 e4 f6 ff ff       	jmp    80106a89 <alltraps>

801073a5 <vector81>:
.globl vector81
vector81:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $81
801073a7:	6a 51                	push   $0x51
  jmp alltraps
801073a9:	e9 db f6 ff ff       	jmp    80106a89 <alltraps>

801073ae <vector82>:
.globl vector82
vector82:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $82
801073b0:	6a 52                	push   $0x52
  jmp alltraps
801073b2:	e9 d2 f6 ff ff       	jmp    80106a89 <alltraps>

801073b7 <vector83>:
.globl vector83
vector83:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $83
801073b9:	6a 53                	push   $0x53
  jmp alltraps
801073bb:	e9 c9 f6 ff ff       	jmp    80106a89 <alltraps>

801073c0 <vector84>:
.globl vector84
vector84:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $84
801073c2:	6a 54                	push   $0x54
  jmp alltraps
801073c4:	e9 c0 f6 ff ff       	jmp    80106a89 <alltraps>

801073c9 <vector85>:
.globl vector85
vector85:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $85
801073cb:	6a 55                	push   $0x55
  jmp alltraps
801073cd:	e9 b7 f6 ff ff       	jmp    80106a89 <alltraps>

801073d2 <vector86>:
.globl vector86
vector86:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $86
801073d4:	6a 56                	push   $0x56
  jmp alltraps
801073d6:	e9 ae f6 ff ff       	jmp    80106a89 <alltraps>

801073db <vector87>:
.globl vector87
vector87:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $87
801073dd:	6a 57                	push   $0x57
  jmp alltraps
801073df:	e9 a5 f6 ff ff       	jmp    80106a89 <alltraps>

801073e4 <vector88>:
.globl vector88
vector88:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $88
801073e6:	6a 58                	push   $0x58
  jmp alltraps
801073e8:	e9 9c f6 ff ff       	jmp    80106a89 <alltraps>

801073ed <vector89>:
.globl vector89
vector89:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $89
801073ef:	6a 59                	push   $0x59
  jmp alltraps
801073f1:	e9 93 f6 ff ff       	jmp    80106a89 <alltraps>

801073f6 <vector90>:
.globl vector90
vector90:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $90
801073f8:	6a 5a                	push   $0x5a
  jmp alltraps
801073fa:	e9 8a f6 ff ff       	jmp    80106a89 <alltraps>

801073ff <vector91>:
.globl vector91
vector91:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $91
80107401:	6a 5b                	push   $0x5b
  jmp alltraps
80107403:	e9 81 f6 ff ff       	jmp    80106a89 <alltraps>

80107408 <vector92>:
.globl vector92
vector92:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $92
8010740a:	6a 5c                	push   $0x5c
  jmp alltraps
8010740c:	e9 78 f6 ff ff       	jmp    80106a89 <alltraps>

80107411 <vector93>:
.globl vector93
vector93:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $93
80107413:	6a 5d                	push   $0x5d
  jmp alltraps
80107415:	e9 6f f6 ff ff       	jmp    80106a89 <alltraps>

8010741a <vector94>:
.globl vector94
vector94:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $94
8010741c:	6a 5e                	push   $0x5e
  jmp alltraps
8010741e:	e9 66 f6 ff ff       	jmp    80106a89 <alltraps>

80107423 <vector95>:
.globl vector95
vector95:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $95
80107425:	6a 5f                	push   $0x5f
  jmp alltraps
80107427:	e9 5d f6 ff ff       	jmp    80106a89 <alltraps>

8010742c <vector96>:
.globl vector96
vector96:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $96
8010742e:	6a 60                	push   $0x60
  jmp alltraps
80107430:	e9 54 f6 ff ff       	jmp    80106a89 <alltraps>

80107435 <vector97>:
.globl vector97
vector97:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $97
80107437:	6a 61                	push   $0x61
  jmp alltraps
80107439:	e9 4b f6 ff ff       	jmp    80106a89 <alltraps>

8010743e <vector98>:
.globl vector98
vector98:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $98
80107440:	6a 62                	push   $0x62
  jmp alltraps
80107442:	e9 42 f6 ff ff       	jmp    80106a89 <alltraps>

80107447 <vector99>:
.globl vector99
vector99:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $99
80107449:	6a 63                	push   $0x63
  jmp alltraps
8010744b:	e9 39 f6 ff ff       	jmp    80106a89 <alltraps>

80107450 <vector100>:
.globl vector100
vector100:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $100
80107452:	6a 64                	push   $0x64
  jmp alltraps
80107454:	e9 30 f6 ff ff       	jmp    80106a89 <alltraps>

80107459 <vector101>:
.globl vector101
vector101:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $101
8010745b:	6a 65                	push   $0x65
  jmp alltraps
8010745d:	e9 27 f6 ff ff       	jmp    80106a89 <alltraps>

80107462 <vector102>:
.globl vector102
vector102:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $102
80107464:	6a 66                	push   $0x66
  jmp alltraps
80107466:	e9 1e f6 ff ff       	jmp    80106a89 <alltraps>

8010746b <vector103>:
.globl vector103
vector103:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $103
8010746d:	6a 67                	push   $0x67
  jmp alltraps
8010746f:	e9 15 f6 ff ff       	jmp    80106a89 <alltraps>

80107474 <vector104>:
.globl vector104
vector104:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $104
80107476:	6a 68                	push   $0x68
  jmp alltraps
80107478:	e9 0c f6 ff ff       	jmp    80106a89 <alltraps>

8010747d <vector105>:
.globl vector105
vector105:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $105
8010747f:	6a 69                	push   $0x69
  jmp alltraps
80107481:	e9 03 f6 ff ff       	jmp    80106a89 <alltraps>

80107486 <vector106>:
.globl vector106
vector106:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $106
80107488:	6a 6a                	push   $0x6a
  jmp alltraps
8010748a:	e9 fa f5 ff ff       	jmp    80106a89 <alltraps>

8010748f <vector107>:
.globl vector107
vector107:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $107
80107491:	6a 6b                	push   $0x6b
  jmp alltraps
80107493:	e9 f1 f5 ff ff       	jmp    80106a89 <alltraps>

80107498 <vector108>:
.globl vector108
vector108:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $108
8010749a:	6a 6c                	push   $0x6c
  jmp alltraps
8010749c:	e9 e8 f5 ff ff       	jmp    80106a89 <alltraps>

801074a1 <vector109>:
.globl vector109
vector109:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $109
801074a3:	6a 6d                	push   $0x6d
  jmp alltraps
801074a5:	e9 df f5 ff ff       	jmp    80106a89 <alltraps>

801074aa <vector110>:
.globl vector110
vector110:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $110
801074ac:	6a 6e                	push   $0x6e
  jmp alltraps
801074ae:	e9 d6 f5 ff ff       	jmp    80106a89 <alltraps>

801074b3 <vector111>:
.globl vector111
vector111:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $111
801074b5:	6a 6f                	push   $0x6f
  jmp alltraps
801074b7:	e9 cd f5 ff ff       	jmp    80106a89 <alltraps>

801074bc <vector112>:
.globl vector112
vector112:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $112
801074be:	6a 70                	push   $0x70
  jmp alltraps
801074c0:	e9 c4 f5 ff ff       	jmp    80106a89 <alltraps>

801074c5 <vector113>:
.globl vector113
vector113:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $113
801074c7:	6a 71                	push   $0x71
  jmp alltraps
801074c9:	e9 bb f5 ff ff       	jmp    80106a89 <alltraps>

801074ce <vector114>:
.globl vector114
vector114:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $114
801074d0:	6a 72                	push   $0x72
  jmp alltraps
801074d2:	e9 b2 f5 ff ff       	jmp    80106a89 <alltraps>

801074d7 <vector115>:
.globl vector115
vector115:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $115
801074d9:	6a 73                	push   $0x73
  jmp alltraps
801074db:	e9 a9 f5 ff ff       	jmp    80106a89 <alltraps>

801074e0 <vector116>:
.globl vector116
vector116:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $116
801074e2:	6a 74                	push   $0x74
  jmp alltraps
801074e4:	e9 a0 f5 ff ff       	jmp    80106a89 <alltraps>

801074e9 <vector117>:
.globl vector117
vector117:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $117
801074eb:	6a 75                	push   $0x75
  jmp alltraps
801074ed:	e9 97 f5 ff ff       	jmp    80106a89 <alltraps>

801074f2 <vector118>:
.globl vector118
vector118:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $118
801074f4:	6a 76                	push   $0x76
  jmp alltraps
801074f6:	e9 8e f5 ff ff       	jmp    80106a89 <alltraps>

801074fb <vector119>:
.globl vector119
vector119:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $119
801074fd:	6a 77                	push   $0x77
  jmp alltraps
801074ff:	e9 85 f5 ff ff       	jmp    80106a89 <alltraps>

80107504 <vector120>:
.globl vector120
vector120:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $120
80107506:	6a 78                	push   $0x78
  jmp alltraps
80107508:	e9 7c f5 ff ff       	jmp    80106a89 <alltraps>

8010750d <vector121>:
.globl vector121
vector121:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $121
8010750f:	6a 79                	push   $0x79
  jmp alltraps
80107511:	e9 73 f5 ff ff       	jmp    80106a89 <alltraps>

80107516 <vector122>:
.globl vector122
vector122:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $122
80107518:	6a 7a                	push   $0x7a
  jmp alltraps
8010751a:	e9 6a f5 ff ff       	jmp    80106a89 <alltraps>

8010751f <vector123>:
.globl vector123
vector123:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $123
80107521:	6a 7b                	push   $0x7b
  jmp alltraps
80107523:	e9 61 f5 ff ff       	jmp    80106a89 <alltraps>

80107528 <vector124>:
.globl vector124
vector124:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $124
8010752a:	6a 7c                	push   $0x7c
  jmp alltraps
8010752c:	e9 58 f5 ff ff       	jmp    80106a89 <alltraps>

80107531 <vector125>:
.globl vector125
vector125:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $125
80107533:	6a 7d                	push   $0x7d
  jmp alltraps
80107535:	e9 4f f5 ff ff       	jmp    80106a89 <alltraps>

8010753a <vector126>:
.globl vector126
vector126:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $126
8010753c:	6a 7e                	push   $0x7e
  jmp alltraps
8010753e:	e9 46 f5 ff ff       	jmp    80106a89 <alltraps>

80107543 <vector127>:
.globl vector127
vector127:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $127
80107545:	6a 7f                	push   $0x7f
  jmp alltraps
80107547:	e9 3d f5 ff ff       	jmp    80106a89 <alltraps>

8010754c <vector128>:
.globl vector128
vector128:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $128
8010754e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107553:	e9 31 f5 ff ff       	jmp    80106a89 <alltraps>

80107558 <vector129>:
.globl vector129
vector129:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $129
8010755a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010755f:	e9 25 f5 ff ff       	jmp    80106a89 <alltraps>

80107564 <vector130>:
.globl vector130
vector130:
  pushl $0
80107564:	6a 00                	push   $0x0
  pushl $130
80107566:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010756b:	e9 19 f5 ff ff       	jmp    80106a89 <alltraps>

80107570 <vector131>:
.globl vector131
vector131:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $131
80107572:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107577:	e9 0d f5 ff ff       	jmp    80106a89 <alltraps>

8010757c <vector132>:
.globl vector132
vector132:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $132
8010757e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107583:	e9 01 f5 ff ff       	jmp    80106a89 <alltraps>

80107588 <vector133>:
.globl vector133
vector133:
  pushl $0
80107588:	6a 00                	push   $0x0
  pushl $133
8010758a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010758f:	e9 f5 f4 ff ff       	jmp    80106a89 <alltraps>

80107594 <vector134>:
.globl vector134
vector134:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $134
80107596:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010759b:	e9 e9 f4 ff ff       	jmp    80106a89 <alltraps>

801075a0 <vector135>:
.globl vector135
vector135:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $135
801075a2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075a7:	e9 dd f4 ff ff       	jmp    80106a89 <alltraps>

801075ac <vector136>:
.globl vector136
vector136:
  pushl $0
801075ac:	6a 00                	push   $0x0
  pushl $136
801075ae:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801075b3:	e9 d1 f4 ff ff       	jmp    80106a89 <alltraps>

801075b8 <vector137>:
.globl vector137
vector137:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $137
801075ba:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801075bf:	e9 c5 f4 ff ff       	jmp    80106a89 <alltraps>

801075c4 <vector138>:
.globl vector138
vector138:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $138
801075c6:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801075cb:	e9 b9 f4 ff ff       	jmp    80106a89 <alltraps>

801075d0 <vector139>:
.globl vector139
vector139:
  pushl $0
801075d0:	6a 00                	push   $0x0
  pushl $139
801075d2:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801075d7:	e9 ad f4 ff ff       	jmp    80106a89 <alltraps>

801075dc <vector140>:
.globl vector140
vector140:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $140
801075de:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801075e3:	e9 a1 f4 ff ff       	jmp    80106a89 <alltraps>

801075e8 <vector141>:
.globl vector141
vector141:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $141
801075ea:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801075ef:	e9 95 f4 ff ff       	jmp    80106a89 <alltraps>

801075f4 <vector142>:
.globl vector142
vector142:
  pushl $0
801075f4:	6a 00                	push   $0x0
  pushl $142
801075f6:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801075fb:	e9 89 f4 ff ff       	jmp    80106a89 <alltraps>

80107600 <vector143>:
.globl vector143
vector143:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $143
80107602:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107607:	e9 7d f4 ff ff       	jmp    80106a89 <alltraps>

8010760c <vector144>:
.globl vector144
vector144:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $144
8010760e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107613:	e9 71 f4 ff ff       	jmp    80106a89 <alltraps>

80107618 <vector145>:
.globl vector145
vector145:
  pushl $0
80107618:	6a 00                	push   $0x0
  pushl $145
8010761a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010761f:	e9 65 f4 ff ff       	jmp    80106a89 <alltraps>

80107624 <vector146>:
.globl vector146
vector146:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $146
80107626:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010762b:	e9 59 f4 ff ff       	jmp    80106a89 <alltraps>

80107630 <vector147>:
.globl vector147
vector147:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $147
80107632:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107637:	e9 4d f4 ff ff       	jmp    80106a89 <alltraps>

8010763c <vector148>:
.globl vector148
vector148:
  pushl $0
8010763c:	6a 00                	push   $0x0
  pushl $148
8010763e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107643:	e9 41 f4 ff ff       	jmp    80106a89 <alltraps>

80107648 <vector149>:
.globl vector149
vector149:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $149
8010764a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010764f:	e9 35 f4 ff ff       	jmp    80106a89 <alltraps>

80107654 <vector150>:
.globl vector150
vector150:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $150
80107656:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010765b:	e9 29 f4 ff ff       	jmp    80106a89 <alltraps>

80107660 <vector151>:
.globl vector151
vector151:
  pushl $0
80107660:	6a 00                	push   $0x0
  pushl $151
80107662:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107667:	e9 1d f4 ff ff       	jmp    80106a89 <alltraps>

8010766c <vector152>:
.globl vector152
vector152:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $152
8010766e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107673:	e9 11 f4 ff ff       	jmp    80106a89 <alltraps>

80107678 <vector153>:
.globl vector153
vector153:
  pushl $0
80107678:	6a 00                	push   $0x0
  pushl $153
8010767a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010767f:	e9 05 f4 ff ff       	jmp    80106a89 <alltraps>

80107684 <vector154>:
.globl vector154
vector154:
  pushl $0
80107684:	6a 00                	push   $0x0
  pushl $154
80107686:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010768b:	e9 f9 f3 ff ff       	jmp    80106a89 <alltraps>

80107690 <vector155>:
.globl vector155
vector155:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $155
80107692:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107697:	e9 ed f3 ff ff       	jmp    80106a89 <alltraps>

8010769c <vector156>:
.globl vector156
vector156:
  pushl $0
8010769c:	6a 00                	push   $0x0
  pushl $156
8010769e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076a3:	e9 e1 f3 ff ff       	jmp    80106a89 <alltraps>

801076a8 <vector157>:
.globl vector157
vector157:
  pushl $0
801076a8:	6a 00                	push   $0x0
  pushl $157
801076aa:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801076af:	e9 d5 f3 ff ff       	jmp    80106a89 <alltraps>

801076b4 <vector158>:
.globl vector158
vector158:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $158
801076b6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801076bb:	e9 c9 f3 ff ff       	jmp    80106a89 <alltraps>

801076c0 <vector159>:
.globl vector159
vector159:
  pushl $0
801076c0:	6a 00                	push   $0x0
  pushl $159
801076c2:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801076c7:	e9 bd f3 ff ff       	jmp    80106a89 <alltraps>

801076cc <vector160>:
.globl vector160
vector160:
  pushl $0
801076cc:	6a 00                	push   $0x0
  pushl $160
801076ce:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801076d3:	e9 b1 f3 ff ff       	jmp    80106a89 <alltraps>

801076d8 <vector161>:
.globl vector161
vector161:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $161
801076da:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801076df:	e9 a5 f3 ff ff       	jmp    80106a89 <alltraps>

801076e4 <vector162>:
.globl vector162
vector162:
  pushl $0
801076e4:	6a 00                	push   $0x0
  pushl $162
801076e6:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801076eb:	e9 99 f3 ff ff       	jmp    80106a89 <alltraps>

801076f0 <vector163>:
.globl vector163
vector163:
  pushl $0
801076f0:	6a 00                	push   $0x0
  pushl $163
801076f2:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801076f7:	e9 8d f3 ff ff       	jmp    80106a89 <alltraps>

801076fc <vector164>:
.globl vector164
vector164:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $164
801076fe:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107703:	e9 81 f3 ff ff       	jmp    80106a89 <alltraps>

80107708 <vector165>:
.globl vector165
vector165:
  pushl $0
80107708:	6a 00                	push   $0x0
  pushl $165
8010770a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010770f:	e9 75 f3 ff ff       	jmp    80106a89 <alltraps>

80107714 <vector166>:
.globl vector166
vector166:
  pushl $0
80107714:	6a 00                	push   $0x0
  pushl $166
80107716:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010771b:	e9 69 f3 ff ff       	jmp    80106a89 <alltraps>

80107720 <vector167>:
.globl vector167
vector167:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $167
80107722:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107727:	e9 5d f3 ff ff       	jmp    80106a89 <alltraps>

8010772c <vector168>:
.globl vector168
vector168:
  pushl $0
8010772c:	6a 00                	push   $0x0
  pushl $168
8010772e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107733:	e9 51 f3 ff ff       	jmp    80106a89 <alltraps>

80107738 <vector169>:
.globl vector169
vector169:
  pushl $0
80107738:	6a 00                	push   $0x0
  pushl $169
8010773a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010773f:	e9 45 f3 ff ff       	jmp    80106a89 <alltraps>

80107744 <vector170>:
.globl vector170
vector170:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $170
80107746:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010774b:	e9 39 f3 ff ff       	jmp    80106a89 <alltraps>

80107750 <vector171>:
.globl vector171
vector171:
  pushl $0
80107750:	6a 00                	push   $0x0
  pushl $171
80107752:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107757:	e9 2d f3 ff ff       	jmp    80106a89 <alltraps>

8010775c <vector172>:
.globl vector172
vector172:
  pushl $0
8010775c:	6a 00                	push   $0x0
  pushl $172
8010775e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107763:	e9 21 f3 ff ff       	jmp    80106a89 <alltraps>

80107768 <vector173>:
.globl vector173
vector173:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $173
8010776a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010776f:	e9 15 f3 ff ff       	jmp    80106a89 <alltraps>

80107774 <vector174>:
.globl vector174
vector174:
  pushl $0
80107774:	6a 00                	push   $0x0
  pushl $174
80107776:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010777b:	e9 09 f3 ff ff       	jmp    80106a89 <alltraps>

80107780 <vector175>:
.globl vector175
vector175:
  pushl $0
80107780:	6a 00                	push   $0x0
  pushl $175
80107782:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107787:	e9 fd f2 ff ff       	jmp    80106a89 <alltraps>

8010778c <vector176>:
.globl vector176
vector176:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $176
8010778e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107793:	e9 f1 f2 ff ff       	jmp    80106a89 <alltraps>

80107798 <vector177>:
.globl vector177
vector177:
  pushl $0
80107798:	6a 00                	push   $0x0
  pushl $177
8010779a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010779f:	e9 e5 f2 ff ff       	jmp    80106a89 <alltraps>

801077a4 <vector178>:
.globl vector178
vector178:
  pushl $0
801077a4:	6a 00                	push   $0x0
  pushl $178
801077a6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077ab:	e9 d9 f2 ff ff       	jmp    80106a89 <alltraps>

801077b0 <vector179>:
.globl vector179
vector179:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $179
801077b2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801077b7:	e9 cd f2 ff ff       	jmp    80106a89 <alltraps>

801077bc <vector180>:
.globl vector180
vector180:
  pushl $0
801077bc:	6a 00                	push   $0x0
  pushl $180
801077be:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801077c3:	e9 c1 f2 ff ff       	jmp    80106a89 <alltraps>

801077c8 <vector181>:
.globl vector181
vector181:
  pushl $0
801077c8:	6a 00                	push   $0x0
  pushl $181
801077ca:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801077cf:	e9 b5 f2 ff ff       	jmp    80106a89 <alltraps>

801077d4 <vector182>:
.globl vector182
vector182:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $182
801077d6:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801077db:	e9 a9 f2 ff ff       	jmp    80106a89 <alltraps>

801077e0 <vector183>:
.globl vector183
vector183:
  pushl $0
801077e0:	6a 00                	push   $0x0
  pushl $183
801077e2:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801077e7:	e9 9d f2 ff ff       	jmp    80106a89 <alltraps>

801077ec <vector184>:
.globl vector184
vector184:
  pushl $0
801077ec:	6a 00                	push   $0x0
  pushl $184
801077ee:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801077f3:	e9 91 f2 ff ff       	jmp    80106a89 <alltraps>

801077f8 <vector185>:
.globl vector185
vector185:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $185
801077fa:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801077ff:	e9 85 f2 ff ff       	jmp    80106a89 <alltraps>

80107804 <vector186>:
.globl vector186
vector186:
  pushl $0
80107804:	6a 00                	push   $0x0
  pushl $186
80107806:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010780b:	e9 79 f2 ff ff       	jmp    80106a89 <alltraps>

80107810 <vector187>:
.globl vector187
vector187:
  pushl $0
80107810:	6a 00                	push   $0x0
  pushl $187
80107812:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107817:	e9 6d f2 ff ff       	jmp    80106a89 <alltraps>

8010781c <vector188>:
.globl vector188
vector188:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $188
8010781e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107823:	e9 61 f2 ff ff       	jmp    80106a89 <alltraps>

80107828 <vector189>:
.globl vector189
vector189:
  pushl $0
80107828:	6a 00                	push   $0x0
  pushl $189
8010782a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010782f:	e9 55 f2 ff ff       	jmp    80106a89 <alltraps>

80107834 <vector190>:
.globl vector190
vector190:
  pushl $0
80107834:	6a 00                	push   $0x0
  pushl $190
80107836:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010783b:	e9 49 f2 ff ff       	jmp    80106a89 <alltraps>

80107840 <vector191>:
.globl vector191
vector191:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $191
80107842:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107847:	e9 3d f2 ff ff       	jmp    80106a89 <alltraps>

8010784c <vector192>:
.globl vector192
vector192:
  pushl $0
8010784c:	6a 00                	push   $0x0
  pushl $192
8010784e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107853:	e9 31 f2 ff ff       	jmp    80106a89 <alltraps>

80107858 <vector193>:
.globl vector193
vector193:
  pushl $0
80107858:	6a 00                	push   $0x0
  pushl $193
8010785a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010785f:	e9 25 f2 ff ff       	jmp    80106a89 <alltraps>

80107864 <vector194>:
.globl vector194
vector194:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $194
80107866:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010786b:	e9 19 f2 ff ff       	jmp    80106a89 <alltraps>

80107870 <vector195>:
.globl vector195
vector195:
  pushl $0
80107870:	6a 00                	push   $0x0
  pushl $195
80107872:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107877:	e9 0d f2 ff ff       	jmp    80106a89 <alltraps>

8010787c <vector196>:
.globl vector196
vector196:
  pushl $0
8010787c:	6a 00                	push   $0x0
  pushl $196
8010787e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107883:	e9 01 f2 ff ff       	jmp    80106a89 <alltraps>

80107888 <vector197>:
.globl vector197
vector197:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $197
8010788a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010788f:	e9 f5 f1 ff ff       	jmp    80106a89 <alltraps>

80107894 <vector198>:
.globl vector198
vector198:
  pushl $0
80107894:	6a 00                	push   $0x0
  pushl $198
80107896:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010789b:	e9 e9 f1 ff ff       	jmp    80106a89 <alltraps>

801078a0 <vector199>:
.globl vector199
vector199:
  pushl $0
801078a0:	6a 00                	push   $0x0
  pushl $199
801078a2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078a7:	e9 dd f1 ff ff       	jmp    80106a89 <alltraps>

801078ac <vector200>:
.globl vector200
vector200:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $200
801078ae:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801078b3:	e9 d1 f1 ff ff       	jmp    80106a89 <alltraps>

801078b8 <vector201>:
.globl vector201
vector201:
  pushl $0
801078b8:	6a 00                	push   $0x0
  pushl $201
801078ba:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801078bf:	e9 c5 f1 ff ff       	jmp    80106a89 <alltraps>

801078c4 <vector202>:
.globl vector202
vector202:
  pushl $0
801078c4:	6a 00                	push   $0x0
  pushl $202
801078c6:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801078cb:	e9 b9 f1 ff ff       	jmp    80106a89 <alltraps>

801078d0 <vector203>:
.globl vector203
vector203:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $203
801078d2:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801078d7:	e9 ad f1 ff ff       	jmp    80106a89 <alltraps>

801078dc <vector204>:
.globl vector204
vector204:
  pushl $0
801078dc:	6a 00                	push   $0x0
  pushl $204
801078de:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801078e3:	e9 a1 f1 ff ff       	jmp    80106a89 <alltraps>

801078e8 <vector205>:
.globl vector205
vector205:
  pushl $0
801078e8:	6a 00                	push   $0x0
  pushl $205
801078ea:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801078ef:	e9 95 f1 ff ff       	jmp    80106a89 <alltraps>

801078f4 <vector206>:
.globl vector206
vector206:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $206
801078f6:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801078fb:	e9 89 f1 ff ff       	jmp    80106a89 <alltraps>

80107900 <vector207>:
.globl vector207
vector207:
  pushl $0
80107900:	6a 00                	push   $0x0
  pushl $207
80107902:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107907:	e9 7d f1 ff ff       	jmp    80106a89 <alltraps>

8010790c <vector208>:
.globl vector208
vector208:
  pushl $0
8010790c:	6a 00                	push   $0x0
  pushl $208
8010790e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107913:	e9 71 f1 ff ff       	jmp    80106a89 <alltraps>

80107918 <vector209>:
.globl vector209
vector209:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $209
8010791a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010791f:	e9 65 f1 ff ff       	jmp    80106a89 <alltraps>

80107924 <vector210>:
.globl vector210
vector210:
  pushl $0
80107924:	6a 00                	push   $0x0
  pushl $210
80107926:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010792b:	e9 59 f1 ff ff       	jmp    80106a89 <alltraps>

80107930 <vector211>:
.globl vector211
vector211:
  pushl $0
80107930:	6a 00                	push   $0x0
  pushl $211
80107932:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107937:	e9 4d f1 ff ff       	jmp    80106a89 <alltraps>

8010793c <vector212>:
.globl vector212
vector212:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $212
8010793e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107943:	e9 41 f1 ff ff       	jmp    80106a89 <alltraps>

80107948 <vector213>:
.globl vector213
vector213:
  pushl $0
80107948:	6a 00                	push   $0x0
  pushl $213
8010794a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010794f:	e9 35 f1 ff ff       	jmp    80106a89 <alltraps>

80107954 <vector214>:
.globl vector214
vector214:
  pushl $0
80107954:	6a 00                	push   $0x0
  pushl $214
80107956:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010795b:	e9 29 f1 ff ff       	jmp    80106a89 <alltraps>

80107960 <vector215>:
.globl vector215
vector215:
  pushl $0
80107960:	6a 00                	push   $0x0
  pushl $215
80107962:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107967:	e9 1d f1 ff ff       	jmp    80106a89 <alltraps>

8010796c <vector216>:
.globl vector216
vector216:
  pushl $0
8010796c:	6a 00                	push   $0x0
  pushl $216
8010796e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107973:	e9 11 f1 ff ff       	jmp    80106a89 <alltraps>

80107978 <vector217>:
.globl vector217
vector217:
  pushl $0
80107978:	6a 00                	push   $0x0
  pushl $217
8010797a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010797f:	e9 05 f1 ff ff       	jmp    80106a89 <alltraps>

80107984 <vector218>:
.globl vector218
vector218:
  pushl $0
80107984:	6a 00                	push   $0x0
  pushl $218
80107986:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010798b:	e9 f9 f0 ff ff       	jmp    80106a89 <alltraps>

80107990 <vector219>:
.globl vector219
vector219:
  pushl $0
80107990:	6a 00                	push   $0x0
  pushl $219
80107992:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107997:	e9 ed f0 ff ff       	jmp    80106a89 <alltraps>

8010799c <vector220>:
.globl vector220
vector220:
  pushl $0
8010799c:	6a 00                	push   $0x0
  pushl $220
8010799e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079a3:	e9 e1 f0 ff ff       	jmp    80106a89 <alltraps>

801079a8 <vector221>:
.globl vector221
vector221:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $221
801079aa:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801079af:	e9 d5 f0 ff ff       	jmp    80106a89 <alltraps>

801079b4 <vector222>:
.globl vector222
vector222:
  pushl $0
801079b4:	6a 00                	push   $0x0
  pushl $222
801079b6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801079bb:	e9 c9 f0 ff ff       	jmp    80106a89 <alltraps>

801079c0 <vector223>:
.globl vector223
vector223:
  pushl $0
801079c0:	6a 00                	push   $0x0
  pushl $223
801079c2:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801079c7:	e9 bd f0 ff ff       	jmp    80106a89 <alltraps>

801079cc <vector224>:
.globl vector224
vector224:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $224
801079ce:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801079d3:	e9 b1 f0 ff ff       	jmp    80106a89 <alltraps>

801079d8 <vector225>:
.globl vector225
vector225:
  pushl $0
801079d8:	6a 00                	push   $0x0
  pushl $225
801079da:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801079df:	e9 a5 f0 ff ff       	jmp    80106a89 <alltraps>

801079e4 <vector226>:
.globl vector226
vector226:
  pushl $0
801079e4:	6a 00                	push   $0x0
  pushl $226
801079e6:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801079eb:	e9 99 f0 ff ff       	jmp    80106a89 <alltraps>

801079f0 <vector227>:
.globl vector227
vector227:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $227
801079f2:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801079f7:	e9 8d f0 ff ff       	jmp    80106a89 <alltraps>

801079fc <vector228>:
.globl vector228
vector228:
  pushl $0
801079fc:	6a 00                	push   $0x0
  pushl $228
801079fe:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a03:	e9 81 f0 ff ff       	jmp    80106a89 <alltraps>

80107a08 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a08:	6a 00                	push   $0x0
  pushl $229
80107a0a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a0f:	e9 75 f0 ff ff       	jmp    80106a89 <alltraps>

80107a14 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $230
80107a16:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a1b:	e9 69 f0 ff ff       	jmp    80106a89 <alltraps>

80107a20 <vector231>:
.globl vector231
vector231:
  pushl $0
80107a20:	6a 00                	push   $0x0
  pushl $231
80107a22:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a27:	e9 5d f0 ff ff       	jmp    80106a89 <alltraps>

80107a2c <vector232>:
.globl vector232
vector232:
  pushl $0
80107a2c:	6a 00                	push   $0x0
  pushl $232
80107a2e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a33:	e9 51 f0 ff ff       	jmp    80106a89 <alltraps>

80107a38 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $233
80107a3a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a3f:	e9 45 f0 ff ff       	jmp    80106a89 <alltraps>

80107a44 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a44:	6a 00                	push   $0x0
  pushl $234
80107a46:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a4b:	e9 39 f0 ff ff       	jmp    80106a89 <alltraps>

80107a50 <vector235>:
.globl vector235
vector235:
  pushl $0
80107a50:	6a 00                	push   $0x0
  pushl $235
80107a52:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107a57:	e9 2d f0 ff ff       	jmp    80106a89 <alltraps>

80107a5c <vector236>:
.globl vector236
vector236:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $236
80107a5e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107a63:	e9 21 f0 ff ff       	jmp    80106a89 <alltraps>

80107a68 <vector237>:
.globl vector237
vector237:
  pushl $0
80107a68:	6a 00                	push   $0x0
  pushl $237
80107a6a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107a6f:	e9 15 f0 ff ff       	jmp    80106a89 <alltraps>

80107a74 <vector238>:
.globl vector238
vector238:
  pushl $0
80107a74:	6a 00                	push   $0x0
  pushl $238
80107a76:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107a7b:	e9 09 f0 ff ff       	jmp    80106a89 <alltraps>

80107a80 <vector239>:
.globl vector239
vector239:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $239
80107a82:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107a87:	e9 fd ef ff ff       	jmp    80106a89 <alltraps>

80107a8c <vector240>:
.globl vector240
vector240:
  pushl $0
80107a8c:	6a 00                	push   $0x0
  pushl $240
80107a8e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107a93:	e9 f1 ef ff ff       	jmp    80106a89 <alltraps>

80107a98 <vector241>:
.globl vector241
vector241:
  pushl $0
80107a98:	6a 00                	push   $0x0
  pushl $241
80107a9a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107a9f:	e9 e5 ef ff ff       	jmp    80106a89 <alltraps>

80107aa4 <vector242>:
.globl vector242
vector242:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $242
80107aa6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107aab:	e9 d9 ef ff ff       	jmp    80106a89 <alltraps>

80107ab0 <vector243>:
.globl vector243
vector243:
  pushl $0
80107ab0:	6a 00                	push   $0x0
  pushl $243
80107ab2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107ab7:	e9 cd ef ff ff       	jmp    80106a89 <alltraps>

80107abc <vector244>:
.globl vector244
vector244:
  pushl $0
80107abc:	6a 00                	push   $0x0
  pushl $244
80107abe:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107ac3:	e9 c1 ef ff ff       	jmp    80106a89 <alltraps>

80107ac8 <vector245>:
.globl vector245
vector245:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $245
80107aca:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107acf:	e9 b5 ef ff ff       	jmp    80106a89 <alltraps>

80107ad4 <vector246>:
.globl vector246
vector246:
  pushl $0
80107ad4:	6a 00                	push   $0x0
  pushl $246
80107ad6:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107adb:	e9 a9 ef ff ff       	jmp    80106a89 <alltraps>

80107ae0 <vector247>:
.globl vector247
vector247:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $247
80107ae2:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107ae7:	e9 9d ef ff ff       	jmp    80106a89 <alltraps>

80107aec <vector248>:
.globl vector248
vector248:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $248
80107aee:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107af3:	e9 91 ef ff ff       	jmp    80106a89 <alltraps>

80107af8 <vector249>:
.globl vector249
vector249:
  pushl $0
80107af8:	6a 00                	push   $0x0
  pushl $249
80107afa:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107aff:	e9 85 ef ff ff       	jmp    80106a89 <alltraps>

80107b04 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $250
80107b06:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b0b:	e9 79 ef ff ff       	jmp    80106a89 <alltraps>

80107b10 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $251
80107b12:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b17:	e9 6d ef ff ff       	jmp    80106a89 <alltraps>

80107b1c <vector252>:
.globl vector252
vector252:
  pushl $0
80107b1c:	6a 00                	push   $0x0
  pushl $252
80107b1e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b23:	e9 61 ef ff ff       	jmp    80106a89 <alltraps>

80107b28 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $253
80107b2a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b2f:	e9 55 ef ff ff       	jmp    80106a89 <alltraps>

80107b34 <vector254>:
.globl vector254
vector254:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $254
80107b36:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b3b:	e9 49 ef ff ff       	jmp    80106a89 <alltraps>

80107b40 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b40:	6a 00                	push   $0x0
  pushl $255
80107b42:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b47:	e9 3d ef ff ff       	jmp    80106a89 <alltraps>

80107b4c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107b4c:	55                   	push   %ebp
80107b4d:	89 e5                	mov    %esp,%ebp
80107b4f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107b52:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b55:	83 e8 01             	sub    $0x1,%eax
80107b58:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b5f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107b63:	8b 45 08             	mov    0x8(%ebp),%eax
80107b66:	c1 e8 10             	shr    $0x10,%eax
80107b69:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107b6d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107b70:	0f 01 10             	lgdtl  (%eax)
}
80107b73:	90                   	nop
80107b74:	c9                   	leave  
80107b75:	c3                   	ret    

80107b76 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107b76:	55                   	push   %ebp
80107b77:	89 e5                	mov    %esp,%ebp
80107b79:	83 ec 04             	sub    $0x4,%esp
80107b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b7f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107b83:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107b87:	0f 00 d8             	ltr    %ax
}
80107b8a:	90                   	nop
80107b8b:	c9                   	leave  
80107b8c:	c3                   	ret    

80107b8d <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107b8d:	55                   	push   %ebp
80107b8e:	89 e5                	mov    %esp,%ebp
80107b90:	83 ec 04             	sub    $0x4,%esp
80107b93:	8b 45 08             	mov    0x8(%ebp),%eax
80107b96:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107b9a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107b9e:	8e e8                	mov    %eax,%gs
}
80107ba0:	90                   	nop
80107ba1:	c9                   	leave  
80107ba2:	c3                   	ret    

80107ba3 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107ba3:	55                   	push   %ebp
80107ba4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba9:	0f 22 d8             	mov    %eax,%cr3
}
80107bac:	90                   	nop
80107bad:	5d                   	pop    %ebp
80107bae:	c3                   	ret    

80107baf <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107baf:	55                   	push   %ebp
80107bb0:	89 e5                	mov    %esp,%ebp
80107bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb5:	05 00 00 00 80       	add    $0x80000000,%eax
80107bba:	5d                   	pop    %ebp
80107bbb:	c3                   	ret    

80107bbc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107bbc:	55                   	push   %ebp
80107bbd:	89 e5                	mov    %esp,%ebp
80107bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc2:	05 00 00 00 80       	add    $0x80000000,%eax
80107bc7:	5d                   	pop    %ebp
80107bc8:	c3                   	ret    

80107bc9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107bc9:	55                   	push   %ebp
80107bca:	89 e5                	mov    %esp,%ebp
80107bcc:	53                   	push   %ebx
80107bcd:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107bd0:	e8 f8 b3 ff ff       	call   80102fcd <cpunum>
80107bd5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107bdb:	05 60 33 11 80       	add    $0x80113360,%eax
80107be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bef:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c03:	83 e2 f0             	and    $0xfffffff0,%edx
80107c06:	83 ca 0a             	or     $0xa,%edx
80107c09:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c13:	83 ca 10             	or     $0x10,%edx
80107c16:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c20:	83 e2 9f             	and    $0xffffff9f,%edx
80107c23:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c29:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c2d:	83 ca 80             	or     $0xffffff80,%edx
80107c30:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c36:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c3a:	83 ca 0f             	or     $0xf,%edx
80107c3d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c43:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c47:	83 e2 ef             	and    $0xffffffef,%edx
80107c4a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c50:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c54:	83 e2 df             	and    $0xffffffdf,%edx
80107c57:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c61:	83 ca 40             	or     $0x40,%edx
80107c64:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c6e:	83 ca 80             	or     $0xffffff80,%edx
80107c71:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c77:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107c85:	ff ff 
80107c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107c91:	00 00 
80107c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c96:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ca7:	83 e2 f0             	and    $0xfffffff0,%edx
80107caa:	83 ca 02             	or     $0x2,%edx
80107cad:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cbd:	83 ca 10             	or     $0x10,%edx
80107cc0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cd0:	83 e2 9f             	and    $0xffffff9f,%edx
80107cd3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ce3:	83 ca 80             	or     $0xffffff80,%edx
80107ce6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cf6:	83 ca 0f             	or     $0xf,%edx
80107cf9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d09:	83 e2 ef             	and    $0xffffffef,%edx
80107d0c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d15:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d1c:	83 e2 df             	and    $0xffffffdf,%edx
80107d1f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d28:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d2f:	83 ca 40             	or     $0x40,%edx
80107d32:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d42:	83 ca 80             	or     $0xffffff80,%edx
80107d45:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d58:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d5f:	ff ff 
80107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d64:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d6b:	00 00 
80107d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d70:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d81:	83 e2 f0             	and    $0xfffffff0,%edx
80107d84:	83 ca 0a             	or     $0xa,%edx
80107d87:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d97:	83 ca 10             	or     $0x10,%edx
80107d9a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107daa:	83 ca 60             	or     $0x60,%edx
80107dad:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dbd:	83 ca 80             	or     $0xffffff80,%edx
80107dc0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107dd0:	83 ca 0f             	or     $0xf,%edx
80107dd3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107de3:	83 e2 ef             	and    $0xffffffef,%edx
80107de6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107def:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107df6:	83 e2 df             	and    $0xffffffdf,%edx
80107df9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e02:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e09:	83 ca 40             	or     $0x40,%edx
80107e0c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e15:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e1c:	83 ca 80             	or     $0xffffff80,%edx
80107e1f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e32:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107e39:	ff ff 
80107e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107e45:	00 00 
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e54:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e5b:	83 e2 f0             	and    $0xfffffff0,%edx
80107e5e:	83 ca 02             	or     $0x2,%edx
80107e61:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e71:	83 ca 10             	or     $0x10,%edx
80107e74:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e84:	83 ca 60             	or     $0x60,%edx
80107e87:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e90:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e97:	83 ca 80             	or     $0xffffff80,%edx
80107e9a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107eaa:	83 ca 0f             	or     $0xf,%edx
80107ead:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ebd:	83 e2 ef             	and    $0xffffffef,%edx
80107ec0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ed0:	83 e2 df             	and    $0xffffffdf,%edx
80107ed3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ee3:	83 ca 40             	or     $0x40,%edx
80107ee6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eef:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ef6:	83 ca 80             	or     $0xffffff80,%edx
80107ef9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0c:	05 b4 00 00 00       	add    $0xb4,%eax
80107f11:	89 c3                	mov    %eax,%ebx
80107f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f16:	05 b4 00 00 00       	add    $0xb4,%eax
80107f1b:	c1 e8 10             	shr    $0x10,%eax
80107f1e:	89 c2                	mov    %eax,%edx
80107f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f23:	05 b4 00 00 00       	add    $0xb4,%eax
80107f28:	c1 e8 18             	shr    $0x18,%eax
80107f2b:	89 c1                	mov    %eax,%ecx
80107f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f30:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107f37:	00 00 
80107f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f56:	83 e2 f0             	and    $0xfffffff0,%edx
80107f59:	83 ca 02             	or     $0x2,%edx
80107f5c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f65:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f6c:	83 ca 10             	or     $0x10,%edx
80107f6f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f78:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f7f:	83 e2 9f             	and    $0xffffff9f,%edx
80107f82:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f92:	83 ca 80             	or     $0xffffff80,%edx
80107f95:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107fa5:	83 e2 f0             	and    $0xfffffff0,%edx
80107fa8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107fb8:	83 e2 ef             	and    $0xffffffef,%edx
80107fbb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107fcb:	83 e2 df             	and    $0xffffffdf,%edx
80107fce:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107fde:	83 ca 40             	or     $0x40,%edx
80107fe1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fea:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ff1:	83 ca 80             	or     $0xffffff80,%edx
80107ff4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffd:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108006:	83 c0 70             	add    $0x70,%eax
80108009:	83 ec 08             	sub    $0x8,%esp
8010800c:	6a 38                	push   $0x38
8010800e:	50                   	push   %eax
8010800f:	e8 38 fb ff ff       	call   80107b4c <lgdt>
80108014:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108017:	83 ec 0c             	sub    $0xc,%esp
8010801a:	6a 18                	push   $0x18
8010801c:	e8 6c fb ff ff       	call   80107b8d <loadgs>
80108021:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108027:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010802d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108034:	00 00 00 00 
}
80108038:	90                   	nop
80108039:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010803c:	c9                   	leave  
8010803d:	c3                   	ret    

8010803e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010803e:	55                   	push   %ebp
8010803f:	89 e5                	mov    %esp,%ebp
80108041:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108044:	8b 45 0c             	mov    0xc(%ebp),%eax
80108047:	c1 e8 16             	shr    $0x16,%eax
8010804a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108051:	8b 45 08             	mov    0x8(%ebp),%eax
80108054:	01 d0                	add    %edx,%eax
80108056:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805c:	8b 00                	mov    (%eax),%eax
8010805e:	83 e0 01             	and    $0x1,%eax
80108061:	85 c0                	test   %eax,%eax
80108063:	74 18                	je     8010807d <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108065:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108068:	8b 00                	mov    (%eax),%eax
8010806a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010806f:	50                   	push   %eax
80108070:	e8 47 fb ff ff       	call   80107bbc <p2v>
80108075:	83 c4 04             	add    $0x4,%esp
80108078:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010807b:	eb 48                	jmp    801080c5 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010807d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108081:	74 0e                	je     80108091 <walkpgdir+0x53>
80108083:	e8 df ab ff ff       	call   80102c67 <kalloc>
80108088:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010808b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010808f:	75 07                	jne    80108098 <walkpgdir+0x5a>
      return 0;
80108091:	b8 00 00 00 00       	mov    $0x0,%eax
80108096:	eb 44                	jmp    801080dc <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108098:	83 ec 04             	sub    $0x4,%esp
8010809b:	68 00 10 00 00       	push   $0x1000
801080a0:	6a 00                	push   $0x0
801080a2:	ff 75 f4             	pushl  -0xc(%ebp)
801080a5:	e8 23 d6 ff ff       	call   801056cd <memset>
801080aa:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801080ad:	83 ec 0c             	sub    $0xc,%esp
801080b0:	ff 75 f4             	pushl  -0xc(%ebp)
801080b3:	e8 f7 fa ff ff       	call   80107baf <v2p>
801080b8:	83 c4 10             	add    $0x10,%esp
801080bb:	83 c8 07             	or     $0x7,%eax
801080be:	89 c2                	mov    %eax,%edx
801080c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c3:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801080c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801080c8:	c1 e8 0c             	shr    $0xc,%eax
801080cb:	25 ff 03 00 00       	and    $0x3ff,%eax
801080d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080da:	01 d0                	add    %edx,%eax
}
801080dc:	c9                   	leave  
801080dd:	c3                   	ret    

801080de <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080de:	55                   	push   %ebp
801080df:	89 e5                	mov    %esp,%ebp
801080e1:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801080e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801080e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801080ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801080f2:	8b 45 10             	mov    0x10(%ebp),%eax
801080f5:	01 d0                	add    %edx,%eax
801080f7:	83 e8 01             	sub    $0x1,%eax
801080fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108102:	83 ec 04             	sub    $0x4,%esp
80108105:	6a 01                	push   $0x1
80108107:	ff 75 f4             	pushl  -0xc(%ebp)
8010810a:	ff 75 08             	pushl  0x8(%ebp)
8010810d:	e8 2c ff ff ff       	call   8010803e <walkpgdir>
80108112:	83 c4 10             	add    $0x10,%esp
80108115:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108118:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010811c:	75 07                	jne    80108125 <mappages+0x47>
      return -1;
8010811e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108123:	eb 47                	jmp    8010816c <mappages+0x8e>
    if(*pte & PTE_P)
80108125:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108128:	8b 00                	mov    (%eax),%eax
8010812a:	83 e0 01             	and    $0x1,%eax
8010812d:	85 c0                	test   %eax,%eax
8010812f:	74 0d                	je     8010813e <mappages+0x60>
      panic("remap");
80108131:	83 ec 0c             	sub    $0xc,%esp
80108134:	68 20 90 10 80       	push   $0x80109020
80108139:	e8 28 84 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
8010813e:	8b 45 18             	mov    0x18(%ebp),%eax
80108141:	0b 45 14             	or     0x14(%ebp),%eax
80108144:	83 c8 01             	or     $0x1,%eax
80108147:	89 c2                	mov    %eax,%edx
80108149:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010814c:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010814e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108151:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108154:	74 10                	je     80108166 <mappages+0x88>
      break;
    a += PGSIZE;
80108156:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010815d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108164:	eb 9c                	jmp    80108102 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108166:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108167:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010816c:	c9                   	leave  
8010816d:	c3                   	ret    

8010816e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010816e:	55                   	push   %ebp
8010816f:	89 e5                	mov    %esp,%ebp
80108171:	53                   	push   %ebx
80108172:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108175:	e8 ed aa ff ff       	call   80102c67 <kalloc>
8010817a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010817d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108181:	75 0a                	jne    8010818d <setupkvm+0x1f>
    return 0;
80108183:	b8 00 00 00 00       	mov    $0x0,%eax
80108188:	e9 8e 00 00 00       	jmp    8010821b <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010818d:	83 ec 04             	sub    $0x4,%esp
80108190:	68 00 10 00 00       	push   $0x1000
80108195:	6a 00                	push   $0x0
80108197:	ff 75 f0             	pushl  -0x10(%ebp)
8010819a:	e8 2e d5 ff ff       	call   801056cd <memset>
8010819f:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801081a2:	83 ec 0c             	sub    $0xc,%esp
801081a5:	68 00 00 00 0e       	push   $0xe000000
801081aa:	e8 0d fa ff ff       	call   80107bbc <p2v>
801081af:	83 c4 10             	add    $0x10,%esp
801081b2:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801081b7:	76 0d                	jbe    801081c6 <setupkvm+0x58>
    panic("PHYSTOP too high");
801081b9:	83 ec 0c             	sub    $0xc,%esp
801081bc:	68 26 90 10 80       	push   $0x80109026
801081c1:	e8 a0 83 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801081c6:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801081cd:	eb 40                	jmp    8010820f <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801081cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801081d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d8:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801081db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081de:	8b 58 08             	mov    0x8(%eax),%ebx
801081e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e4:	8b 40 04             	mov    0x4(%eax),%eax
801081e7:	29 c3                	sub    %eax,%ebx
801081e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ec:	8b 00                	mov    (%eax),%eax
801081ee:	83 ec 0c             	sub    $0xc,%esp
801081f1:	51                   	push   %ecx
801081f2:	52                   	push   %edx
801081f3:	53                   	push   %ebx
801081f4:	50                   	push   %eax
801081f5:	ff 75 f0             	pushl  -0x10(%ebp)
801081f8:	e8 e1 fe ff ff       	call   801080de <mappages>
801081fd:	83 c4 20             	add    $0x20,%esp
80108200:	85 c0                	test   %eax,%eax
80108202:	79 07                	jns    8010820b <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108204:	b8 00 00 00 00       	mov    $0x0,%eax
80108209:	eb 10                	jmp    8010821b <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010820b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010820f:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108216:	72 b7                	jb     801081cf <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108218:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010821b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010821e:	c9                   	leave  
8010821f:	c3                   	ret    

80108220 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108220:	55                   	push   %ebp
80108221:	89 e5                	mov    %esp,%ebp
80108223:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108226:	e8 43 ff ff ff       	call   8010816e <setupkvm>
8010822b:	a3 38 63 11 80       	mov    %eax,0x80116338
  switchkvm();
80108230:	e8 03 00 00 00       	call   80108238 <switchkvm>
}
80108235:	90                   	nop
80108236:	c9                   	leave  
80108237:	c3                   	ret    

80108238 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108238:	55                   	push   %ebp
80108239:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010823b:	a1 38 63 11 80       	mov    0x80116338,%eax
80108240:	50                   	push   %eax
80108241:	e8 69 f9 ff ff       	call   80107baf <v2p>
80108246:	83 c4 04             	add    $0x4,%esp
80108249:	50                   	push   %eax
8010824a:	e8 54 f9 ff ff       	call   80107ba3 <lcr3>
8010824f:	83 c4 04             	add    $0x4,%esp
}
80108252:	90                   	nop
80108253:	c9                   	leave  
80108254:	c3                   	ret    

80108255 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108255:	55                   	push   %ebp
80108256:	89 e5                	mov    %esp,%ebp
80108258:	56                   	push   %esi
80108259:	53                   	push   %ebx
  pushcli();
8010825a:	e8 68 d3 ff ff       	call   801055c7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010825f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108265:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010826c:	83 c2 08             	add    $0x8,%edx
8010826f:	89 d6                	mov    %edx,%esi
80108271:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108278:	83 c2 08             	add    $0x8,%edx
8010827b:	c1 ea 10             	shr    $0x10,%edx
8010827e:	89 d3                	mov    %edx,%ebx
80108280:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108287:	83 c2 08             	add    $0x8,%edx
8010828a:	c1 ea 18             	shr    $0x18,%edx
8010828d:	89 d1                	mov    %edx,%ecx
8010828f:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108296:	67 00 
80108298:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
8010829f:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
801082a5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082ac:	83 e2 f0             	and    $0xfffffff0,%edx
801082af:	83 ca 09             	or     $0x9,%edx
801082b2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801082b8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082bf:	83 ca 10             	or     $0x10,%edx
801082c2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801082c8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082cf:	83 e2 9f             	and    $0xffffff9f,%edx
801082d2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801082d8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082df:	83 ca 80             	or     $0xffffff80,%edx
801082e2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801082e8:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801082ef:	83 e2 f0             	and    $0xfffffff0,%edx
801082f2:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801082f8:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801082ff:	83 e2 ef             	and    $0xffffffef,%edx
80108302:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108308:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010830f:	83 e2 df             	and    $0xffffffdf,%edx
80108312:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108318:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010831f:	83 ca 40             	or     $0x40,%edx
80108322:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108328:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010832f:	83 e2 7f             	and    $0x7f,%edx
80108332:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108338:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010833e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108344:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010834b:	83 e2 ef             	and    $0xffffffef,%edx
8010834e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108354:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010835a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108360:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108366:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010836d:	8b 52 10             	mov    0x10(%edx),%edx
80108370:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108376:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108379:	83 ec 0c             	sub    $0xc,%esp
8010837c:	6a 30                	push   $0x30
8010837e:	e8 f3 f7 ff ff       	call   80107b76 <ltr>
80108383:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108386:	8b 45 08             	mov    0x8(%ebp),%eax
80108389:	8b 40 0c             	mov    0xc(%eax),%eax
8010838c:	85 c0                	test   %eax,%eax
8010838e:	75 0d                	jne    8010839d <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108390:	83 ec 0c             	sub    $0xc,%esp
80108393:	68 37 90 10 80       	push   $0x80109037
80108398:	e8 c9 81 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010839d:	8b 45 08             	mov    0x8(%ebp),%eax
801083a0:	8b 40 0c             	mov    0xc(%eax),%eax
801083a3:	83 ec 0c             	sub    $0xc,%esp
801083a6:	50                   	push   %eax
801083a7:	e8 03 f8 ff ff       	call   80107baf <v2p>
801083ac:	83 c4 10             	add    $0x10,%esp
801083af:	83 ec 0c             	sub    $0xc,%esp
801083b2:	50                   	push   %eax
801083b3:	e8 eb f7 ff ff       	call   80107ba3 <lcr3>
801083b8:	83 c4 10             	add    $0x10,%esp
  popcli();
801083bb:	e8 4c d2 ff ff       	call   8010560c <popcli>
}
801083c0:	90                   	nop
801083c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801083c4:	5b                   	pop    %ebx
801083c5:	5e                   	pop    %esi
801083c6:	5d                   	pop    %ebp
801083c7:	c3                   	ret    

801083c8 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801083c8:	55                   	push   %ebp
801083c9:	89 e5                	mov    %esp,%ebp
801083cb:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801083ce:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801083d5:	76 0d                	jbe    801083e4 <inituvm+0x1c>
    panic("inituvm: more than a page");
801083d7:	83 ec 0c             	sub    $0xc,%esp
801083da:	68 4b 90 10 80       	push   $0x8010904b
801083df:	e8 82 81 ff ff       	call   80100566 <panic>
  mem = kalloc();
801083e4:	e8 7e a8 ff ff       	call   80102c67 <kalloc>
801083e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801083ec:	83 ec 04             	sub    $0x4,%esp
801083ef:	68 00 10 00 00       	push   $0x1000
801083f4:	6a 00                	push   $0x0
801083f6:	ff 75 f4             	pushl  -0xc(%ebp)
801083f9:	e8 cf d2 ff ff       	call   801056cd <memset>
801083fe:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108401:	83 ec 0c             	sub    $0xc,%esp
80108404:	ff 75 f4             	pushl  -0xc(%ebp)
80108407:	e8 a3 f7 ff ff       	call   80107baf <v2p>
8010840c:	83 c4 10             	add    $0x10,%esp
8010840f:	83 ec 0c             	sub    $0xc,%esp
80108412:	6a 06                	push   $0x6
80108414:	50                   	push   %eax
80108415:	68 00 10 00 00       	push   $0x1000
8010841a:	6a 00                	push   $0x0
8010841c:	ff 75 08             	pushl  0x8(%ebp)
8010841f:	e8 ba fc ff ff       	call   801080de <mappages>
80108424:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108427:	83 ec 04             	sub    $0x4,%esp
8010842a:	ff 75 10             	pushl  0x10(%ebp)
8010842d:	ff 75 0c             	pushl  0xc(%ebp)
80108430:	ff 75 f4             	pushl  -0xc(%ebp)
80108433:	e8 54 d3 ff ff       	call   8010578c <memmove>
80108438:	83 c4 10             	add    $0x10,%esp
}
8010843b:	90                   	nop
8010843c:	c9                   	leave  
8010843d:	c3                   	ret    

8010843e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010843e:	55                   	push   %ebp
8010843f:	89 e5                	mov    %esp,%ebp
80108441:	53                   	push   %ebx
80108442:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108445:	8b 45 0c             	mov    0xc(%ebp),%eax
80108448:	25 ff 0f 00 00       	and    $0xfff,%eax
8010844d:	85 c0                	test   %eax,%eax
8010844f:	74 0d                	je     8010845e <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108451:	83 ec 0c             	sub    $0xc,%esp
80108454:	68 68 90 10 80       	push   $0x80109068
80108459:	e8 08 81 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010845e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108465:	e9 95 00 00 00       	jmp    801084ff <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010846a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108470:	01 d0                	add    %edx,%eax
80108472:	83 ec 04             	sub    $0x4,%esp
80108475:	6a 00                	push   $0x0
80108477:	50                   	push   %eax
80108478:	ff 75 08             	pushl  0x8(%ebp)
8010847b:	e8 be fb ff ff       	call   8010803e <walkpgdir>
80108480:	83 c4 10             	add    $0x10,%esp
80108483:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108486:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010848a:	75 0d                	jne    80108499 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010848c:	83 ec 0c             	sub    $0xc,%esp
8010848f:	68 8b 90 10 80       	push   $0x8010908b
80108494:	e8 cd 80 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108499:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010849c:	8b 00                	mov    (%eax),%eax
8010849e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801084a6:	8b 45 18             	mov    0x18(%ebp),%eax
801084a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084ac:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801084b1:	77 0b                	ja     801084be <loaduvm+0x80>
      n = sz - i;
801084b3:	8b 45 18             	mov    0x18(%ebp),%eax
801084b6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084bc:	eb 07                	jmp    801084c5 <loaduvm+0x87>
    else
      n = PGSIZE;
801084be:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801084c5:	8b 55 14             	mov    0x14(%ebp),%edx
801084c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cb:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801084ce:	83 ec 0c             	sub    $0xc,%esp
801084d1:	ff 75 e8             	pushl  -0x18(%ebp)
801084d4:	e8 e3 f6 ff ff       	call   80107bbc <p2v>
801084d9:	83 c4 10             	add    $0x10,%esp
801084dc:	ff 75 f0             	pushl  -0x10(%ebp)
801084df:	53                   	push   %ebx
801084e0:	50                   	push   %eax
801084e1:	ff 75 10             	pushl  0x10(%ebp)
801084e4:	e8 f0 99 ff ff       	call   80101ed9 <readi>
801084e9:	83 c4 10             	add    $0x10,%esp
801084ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801084ef:	74 07                	je     801084f8 <loaduvm+0xba>
      return -1;
801084f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084f6:	eb 18                	jmp    80108510 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801084f8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108502:	3b 45 18             	cmp    0x18(%ebp),%eax
80108505:	0f 82 5f ff ff ff    	jb     8010846a <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010850b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108513:	c9                   	leave  
80108514:	c3                   	ret    

80108515 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108515:	55                   	push   %ebp
80108516:	89 e5                	mov    %esp,%ebp
80108518:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010851b:	8b 45 10             	mov    0x10(%ebp),%eax
8010851e:	85 c0                	test   %eax,%eax
80108520:	79 0a                	jns    8010852c <allocuvm+0x17>
    return 0;
80108522:	b8 00 00 00 00       	mov    $0x0,%eax
80108527:	e9 b0 00 00 00       	jmp    801085dc <allocuvm+0xc7>
  if(newsz < oldsz)
8010852c:	8b 45 10             	mov    0x10(%ebp),%eax
8010852f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108532:	73 08                	jae    8010853c <allocuvm+0x27>
    return oldsz;
80108534:	8b 45 0c             	mov    0xc(%ebp),%eax
80108537:	e9 a0 00 00 00       	jmp    801085dc <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010853c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010853f:	05 ff 0f 00 00       	add    $0xfff,%eax
80108544:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108549:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010854c:	eb 7f                	jmp    801085cd <allocuvm+0xb8>
    mem = kalloc();
8010854e:	e8 14 a7 ff ff       	call   80102c67 <kalloc>
80108553:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108556:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010855a:	75 2b                	jne    80108587 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
8010855c:	83 ec 0c             	sub    $0xc,%esp
8010855f:	68 a9 90 10 80       	push   $0x801090a9
80108564:	e8 5d 7e ff ff       	call   801003c6 <cprintf>
80108569:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010856c:	83 ec 04             	sub    $0x4,%esp
8010856f:	ff 75 0c             	pushl  0xc(%ebp)
80108572:	ff 75 10             	pushl  0x10(%ebp)
80108575:	ff 75 08             	pushl  0x8(%ebp)
80108578:	e8 61 00 00 00       	call   801085de <deallocuvm>
8010857d:	83 c4 10             	add    $0x10,%esp
      return 0;
80108580:	b8 00 00 00 00       	mov    $0x0,%eax
80108585:	eb 55                	jmp    801085dc <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108587:	83 ec 04             	sub    $0x4,%esp
8010858a:	68 00 10 00 00       	push   $0x1000
8010858f:	6a 00                	push   $0x0
80108591:	ff 75 f0             	pushl  -0x10(%ebp)
80108594:	e8 34 d1 ff ff       	call   801056cd <memset>
80108599:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010859c:	83 ec 0c             	sub    $0xc,%esp
8010859f:	ff 75 f0             	pushl  -0x10(%ebp)
801085a2:	e8 08 f6 ff ff       	call   80107baf <v2p>
801085a7:	83 c4 10             	add    $0x10,%esp
801085aa:	89 c2                	mov    %eax,%edx
801085ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085af:	83 ec 0c             	sub    $0xc,%esp
801085b2:	6a 06                	push   $0x6
801085b4:	52                   	push   %edx
801085b5:	68 00 10 00 00       	push   $0x1000
801085ba:	50                   	push   %eax
801085bb:	ff 75 08             	pushl  0x8(%ebp)
801085be:	e8 1b fb ff ff       	call   801080de <mappages>
801085c3:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801085c6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d0:	3b 45 10             	cmp    0x10(%ebp),%eax
801085d3:	0f 82 75 ff ff ff    	jb     8010854e <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801085d9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085dc:	c9                   	leave  
801085dd:	c3                   	ret    

801085de <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085de:	55                   	push   %ebp
801085df:	89 e5                	mov    %esp,%ebp
801085e1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801085e4:	8b 45 10             	mov    0x10(%ebp),%eax
801085e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085ea:	72 08                	jb     801085f4 <deallocuvm+0x16>
    return oldsz;
801085ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801085ef:	e9 a5 00 00 00       	jmp    80108699 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801085f4:	8b 45 10             	mov    0x10(%ebp),%eax
801085f7:	05 ff 0f 00 00       	add    $0xfff,%eax
801085fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108601:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108604:	e9 81 00 00 00       	jmp    8010868a <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860c:	83 ec 04             	sub    $0x4,%esp
8010860f:	6a 00                	push   $0x0
80108611:	50                   	push   %eax
80108612:	ff 75 08             	pushl  0x8(%ebp)
80108615:	e8 24 fa ff ff       	call   8010803e <walkpgdir>
8010861a:	83 c4 10             	add    $0x10,%esp
8010861d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108620:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108624:	75 09                	jne    8010862f <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108626:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010862d:	eb 54                	jmp    80108683 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010862f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108632:	8b 00                	mov    (%eax),%eax
80108634:	83 e0 01             	and    $0x1,%eax
80108637:	85 c0                	test   %eax,%eax
80108639:	74 48                	je     80108683 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010863b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863e:	8b 00                	mov    (%eax),%eax
80108640:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108645:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108648:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010864c:	75 0d                	jne    8010865b <deallocuvm+0x7d>
        panic("kfree");
8010864e:	83 ec 0c             	sub    $0xc,%esp
80108651:	68 c1 90 10 80       	push   $0x801090c1
80108656:	e8 0b 7f ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010865b:	83 ec 0c             	sub    $0xc,%esp
8010865e:	ff 75 ec             	pushl  -0x14(%ebp)
80108661:	e8 56 f5 ff ff       	call   80107bbc <p2v>
80108666:	83 c4 10             	add    $0x10,%esp
80108669:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010866c:	83 ec 0c             	sub    $0xc,%esp
8010866f:	ff 75 e8             	pushl  -0x18(%ebp)
80108672:	e8 53 a5 ff ff       	call   80102bca <kfree>
80108677:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010867a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108683:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010868a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108690:	0f 82 73 ff ff ff    	jb     80108609 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108696:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108699:	c9                   	leave  
8010869a:	c3                   	ret    

8010869b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010869b:	55                   	push   %ebp
8010869c:	89 e5                	mov    %esp,%ebp
8010869e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801086a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801086a5:	75 0d                	jne    801086b4 <freevm+0x19>
    panic("freevm: no pgdir");
801086a7:	83 ec 0c             	sub    $0xc,%esp
801086aa:	68 c7 90 10 80       	push   $0x801090c7
801086af:	e8 b2 7e ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801086b4:	83 ec 04             	sub    $0x4,%esp
801086b7:	6a 00                	push   $0x0
801086b9:	68 00 00 00 80       	push   $0x80000000
801086be:	ff 75 08             	pushl  0x8(%ebp)
801086c1:	e8 18 ff ff ff       	call   801085de <deallocuvm>
801086c6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086d0:	eb 4f                	jmp    80108721 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801086d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086dc:	8b 45 08             	mov    0x8(%ebp),%eax
801086df:	01 d0                	add    %edx,%eax
801086e1:	8b 00                	mov    (%eax),%eax
801086e3:	83 e0 01             	and    $0x1,%eax
801086e6:	85 c0                	test   %eax,%eax
801086e8:	74 33                	je     8010871d <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801086ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086f4:	8b 45 08             	mov    0x8(%ebp),%eax
801086f7:	01 d0                	add    %edx,%eax
801086f9:	8b 00                	mov    (%eax),%eax
801086fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108700:	83 ec 0c             	sub    $0xc,%esp
80108703:	50                   	push   %eax
80108704:	e8 b3 f4 ff ff       	call   80107bbc <p2v>
80108709:	83 c4 10             	add    $0x10,%esp
8010870c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010870f:	83 ec 0c             	sub    $0xc,%esp
80108712:	ff 75 f0             	pushl  -0x10(%ebp)
80108715:	e8 b0 a4 ff ff       	call   80102bca <kfree>
8010871a:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010871d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108721:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108728:	76 a8                	jbe    801086d2 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010872a:	83 ec 0c             	sub    $0xc,%esp
8010872d:	ff 75 08             	pushl  0x8(%ebp)
80108730:	e8 95 a4 ff ff       	call   80102bca <kfree>
80108735:	83 c4 10             	add    $0x10,%esp
}
80108738:	90                   	nop
80108739:	c9                   	leave  
8010873a:	c3                   	ret    

8010873b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010873b:	55                   	push   %ebp
8010873c:	89 e5                	mov    %esp,%ebp
8010873e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108741:	83 ec 04             	sub    $0x4,%esp
80108744:	6a 00                	push   $0x0
80108746:	ff 75 0c             	pushl  0xc(%ebp)
80108749:	ff 75 08             	pushl  0x8(%ebp)
8010874c:	e8 ed f8 ff ff       	call   8010803e <walkpgdir>
80108751:	83 c4 10             	add    $0x10,%esp
80108754:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108757:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010875b:	75 0d                	jne    8010876a <clearpteu+0x2f>
    panic("clearpteu");
8010875d:	83 ec 0c             	sub    $0xc,%esp
80108760:	68 d8 90 10 80       	push   $0x801090d8
80108765:	e8 fc 7d ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010876a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876d:	8b 00                	mov    (%eax),%eax
8010876f:	83 e0 fb             	and    $0xfffffffb,%eax
80108772:	89 c2                	mov    %eax,%edx
80108774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108777:	89 10                	mov    %edx,(%eax)
}
80108779:	90                   	nop
8010877a:	c9                   	leave  
8010877b:	c3                   	ret    

8010877c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010877c:	55                   	push   %ebp
8010877d:	89 e5                	mov    %esp,%ebp
8010877f:	53                   	push   %ebx
80108780:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108783:	e8 e6 f9 ff ff       	call   8010816e <setupkvm>
80108788:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010878b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010878f:	75 0a                	jne    8010879b <copyuvm+0x1f>
    return 0;
80108791:	b8 00 00 00 00       	mov    $0x0,%eax
80108796:	e9 f8 00 00 00       	jmp    80108893 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010879b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087a2:	e9 c4 00 00 00       	jmp    8010886b <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801087a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087aa:	83 ec 04             	sub    $0x4,%esp
801087ad:	6a 00                	push   $0x0
801087af:	50                   	push   %eax
801087b0:	ff 75 08             	pushl  0x8(%ebp)
801087b3:	e8 86 f8 ff ff       	call   8010803e <walkpgdir>
801087b8:	83 c4 10             	add    $0x10,%esp
801087bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087c2:	75 0d                	jne    801087d1 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801087c4:	83 ec 0c             	sub    $0xc,%esp
801087c7:	68 e2 90 10 80       	push   $0x801090e2
801087cc:	e8 95 7d ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801087d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087d4:	8b 00                	mov    (%eax),%eax
801087d6:	83 e0 01             	and    $0x1,%eax
801087d9:	85 c0                	test   %eax,%eax
801087db:	75 0d                	jne    801087ea <copyuvm+0x6e>
      panic("copyuvm: page not present");
801087dd:	83 ec 0c             	sub    $0xc,%esp
801087e0:	68 fc 90 10 80       	push   $0x801090fc
801087e5:	e8 7c 7d ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801087ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ed:	8b 00                	mov    (%eax),%eax
801087ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fa:	8b 00                	mov    (%eax),%eax
801087fc:	25 ff 0f 00 00       	and    $0xfff,%eax
80108801:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108804:	e8 5e a4 ff ff       	call   80102c67 <kalloc>
80108809:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010880c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108810:	74 6a                	je     8010887c <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108812:	83 ec 0c             	sub    $0xc,%esp
80108815:	ff 75 e8             	pushl  -0x18(%ebp)
80108818:	e8 9f f3 ff ff       	call   80107bbc <p2v>
8010881d:	83 c4 10             	add    $0x10,%esp
80108820:	83 ec 04             	sub    $0x4,%esp
80108823:	68 00 10 00 00       	push   $0x1000
80108828:	50                   	push   %eax
80108829:	ff 75 e0             	pushl  -0x20(%ebp)
8010882c:	e8 5b cf ff ff       	call   8010578c <memmove>
80108831:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108834:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108837:	83 ec 0c             	sub    $0xc,%esp
8010883a:	ff 75 e0             	pushl  -0x20(%ebp)
8010883d:	e8 6d f3 ff ff       	call   80107baf <v2p>
80108842:	83 c4 10             	add    $0x10,%esp
80108845:	89 c2                	mov    %eax,%edx
80108847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884a:	83 ec 0c             	sub    $0xc,%esp
8010884d:	53                   	push   %ebx
8010884e:	52                   	push   %edx
8010884f:	68 00 10 00 00       	push   $0x1000
80108854:	50                   	push   %eax
80108855:	ff 75 f0             	pushl  -0x10(%ebp)
80108858:	e8 81 f8 ff ff       	call   801080de <mappages>
8010885d:	83 c4 20             	add    $0x20,%esp
80108860:	85 c0                	test   %eax,%eax
80108862:	78 1b                	js     8010887f <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108864:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108871:	0f 82 30 ff ff ff    	jb     801087a7 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010887a:	eb 17                	jmp    80108893 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010887c:	90                   	nop
8010887d:	eb 01                	jmp    80108880 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010887f:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108880:	83 ec 0c             	sub    $0xc,%esp
80108883:	ff 75 f0             	pushl  -0x10(%ebp)
80108886:	e8 10 fe ff ff       	call   8010869b <freevm>
8010888b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010888e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108896:	c9                   	leave  
80108897:	c3                   	ret    

80108898 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108898:	55                   	push   %ebp
80108899:	89 e5                	mov    %esp,%ebp
8010889b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010889e:	83 ec 04             	sub    $0x4,%esp
801088a1:	6a 00                	push   $0x0
801088a3:	ff 75 0c             	pushl  0xc(%ebp)
801088a6:	ff 75 08             	pushl  0x8(%ebp)
801088a9:	e8 90 f7 ff ff       	call   8010803e <walkpgdir>
801088ae:	83 c4 10             	add    $0x10,%esp
801088b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	8b 00                	mov    (%eax),%eax
801088b9:	83 e0 01             	and    $0x1,%eax
801088bc:	85 c0                	test   %eax,%eax
801088be:	75 07                	jne    801088c7 <uva2ka+0x2f>
    return 0;
801088c0:	b8 00 00 00 00       	mov    $0x0,%eax
801088c5:	eb 29                	jmp    801088f0 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	8b 00                	mov    (%eax),%eax
801088cc:	83 e0 04             	and    $0x4,%eax
801088cf:	85 c0                	test   %eax,%eax
801088d1:	75 07                	jne    801088da <uva2ka+0x42>
    return 0;
801088d3:	b8 00 00 00 00       	mov    $0x0,%eax
801088d8:	eb 16                	jmp    801088f0 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801088da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dd:	8b 00                	mov    (%eax),%eax
801088df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088e4:	83 ec 0c             	sub    $0xc,%esp
801088e7:	50                   	push   %eax
801088e8:	e8 cf f2 ff ff       	call   80107bbc <p2v>
801088ed:	83 c4 10             	add    $0x10,%esp
}
801088f0:	c9                   	leave  
801088f1:	c3                   	ret    

801088f2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801088f2:	55                   	push   %ebp
801088f3:	89 e5                	mov    %esp,%ebp
801088f5:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088f8:	8b 45 10             	mov    0x10(%ebp),%eax
801088fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088fe:	eb 7f                	jmp    8010897f <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108900:	8b 45 0c             	mov    0xc(%ebp),%eax
80108903:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108908:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010890b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010890e:	83 ec 08             	sub    $0x8,%esp
80108911:	50                   	push   %eax
80108912:	ff 75 08             	pushl  0x8(%ebp)
80108915:	e8 7e ff ff ff       	call   80108898 <uva2ka>
8010891a:	83 c4 10             	add    $0x10,%esp
8010891d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108920:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108924:	75 07                	jne    8010892d <copyout+0x3b>
      return -1;
80108926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010892b:	eb 61                	jmp    8010898e <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010892d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108930:	2b 45 0c             	sub    0xc(%ebp),%eax
80108933:	05 00 10 00 00       	add    $0x1000,%eax
80108938:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010893b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010893e:	3b 45 14             	cmp    0x14(%ebp),%eax
80108941:	76 06                	jbe    80108949 <copyout+0x57>
      n = len;
80108943:	8b 45 14             	mov    0x14(%ebp),%eax
80108946:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108949:	8b 45 0c             	mov    0xc(%ebp),%eax
8010894c:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010894f:	89 c2                	mov    %eax,%edx
80108951:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108954:	01 d0                	add    %edx,%eax
80108956:	83 ec 04             	sub    $0x4,%esp
80108959:	ff 75 f0             	pushl  -0x10(%ebp)
8010895c:	ff 75 f4             	pushl  -0xc(%ebp)
8010895f:	50                   	push   %eax
80108960:	e8 27 ce ff ff       	call   8010578c <memmove>
80108965:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108968:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010896b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010896e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108971:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108974:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108977:	05 00 10 00 00       	add    $0x1000,%eax
8010897c:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010897f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108983:	0f 85 77 ff ff ff    	jne    80108900 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108989:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010898e:	c9                   	leave  
8010898f:	c3                   	ret    
