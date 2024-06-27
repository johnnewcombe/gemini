## TODO

### Random Files

Consider how this program should handle random files e.g. where the allocation blocks are not written to in any kind of order. This is non-urgent as many CP/M programs don't always handle this.
  
### File Writes

Need to handle text files to ensure that they have Ctrl-Z at the end as they may have been trimmed by the download process.
(e.g. if file !contain CtrlZ then append one.)

Need to handle CR/LFs e.g. ???

Need to determine how many blocks in size etc. 

Delete the file if it exists and assemble list of free blocks placing the allocation units of the deleted file, if it exists, at the end so that they are used last, thereby allowing for undelete.

## Misc Notes:

Gemini skew the system tracks differently to the data tracks! Sector trackes are skewed 2 4 6 8 1 5 7 9, data tracks can be skewed by 0,1,2,3 as chosen by the user when formatting a disk.

SDDS uses 1k blocks
DDDS uses 2k blocks
QDSS and QDDS uses 4k blocks

CP/M 2.2 has 8Mb max disk size (65536 128 byte records) CP/m 1.4 and 3.0 are different.

    
    
    QDDS and DDDS
    128 32 byte directory entries
    
    QDDS Only
    6304 128byte Record Capacity
    788 Kilobyte Capacity
    512 records per extent
    32 records per block
    40 sectors per track
    2 reserved track
    
    DDDS Only
    2704 128byte Record Capacity
    338 Kilobyte Capacity
    256 records per extent
    16 records per block
    80 sectors per track
    1 reserved track



### DDDS

128 directory entries with 2K block size = 2 blocks for directory

Blocks on DDDS disk =  358400/2048 = 175
2 tracks (20 sects, equivalent to 5 blocks) used for OS therefore 168 blocks of data plus 2 blocks of directory.

__Note that the directory is same size for bothe QDDS and DDDS (i.e. 8 sectors)__

### QDDS

128 directory entries with 4k blocks, only one block (first data block) is used for the directory. 64 bytes per directory entry.

Blocks on QDDS disk =  819200/4096 = 200
2 tracks (20 sects, equivalent to 2.5 blocks) used for OS therefore 196.5 blocks? of data plus 1 block of directory.

__Note that the directory is same size for bothe QDDS and DDDS (i.e. 8 sectors)__

## Directory

byte 0	(UU)		User area in lower 4 bits, upper 4 bits not used on cp/m 2.2 but are on cp/m 3.0
					E5 in this position indicates a deleted file.

byte 1-8 (Fn1-8) 	eleven bytes for file name and size in 8.3 format see examples below.
byte 9-11 (T1-3) 	file type e.g. COM or TXT. The top bit of T1 (T1') sets the file Read Only the top bit of T2 (T2')
					indicates a system file.

byte 12 (EX)		Extent counter (low byte, value = 0-31), this shows the maximum extent that is used by the file. A single directory entry controls extents 0-3. TODO what does this meann

byte 13 (S1)		Not used, set to 0

byte 14 (S2)		Extent byte  (high byte)

byte 15 (RC)		Number of 128 byte records.

byte 16-31 (AL)		Allocation, each allocation is the number of the block on the disk. 8 bit block numbers if there
					are < 256 blocks on the disk and 16 bit block numbers where the disk > 255 blocks. Gemini QDDS
					uses 8 bit block numbers. Note that zeros in the directory entries can be used to signify that
					there are no more blocks allocated. this is safe as Block 0 will always contain directory
					information and never a file.
e.g

The CP/M 2.2 directory has only one type of entry:

UU F1 F2 F3 F4 F5 F6 F7 F8 T1 T2 T3 EX S1 S2 RC   .FILENAMETYP....
AL AL AL AL AL AL AL AL AL AL AL AL AL AL AL AL   ................

UU = User number. 0-15 (on some systems, 0-31). The user number allows multiple
    files of the same name to coexist on the disc.
     User number = 0E5h => File deleted
Fn - filename
Tn - filetype. The characters used for these are 7-bit ASCII.
       The top bit of T1 (often referred to as T1') is set if the file is
     read-only.
       T2' is set if the file is a system file (this corresponds to "hidden" on
     other systems).
EX = Extent counter, low byte - takes values from 0-31 making the max file size of 512K (each extent represents 4 blocks = 16K)
S2 = Extent counter, high byte. this number is incremented when the EXT > 31 and represents 512k bytes of the file.
		For QDDS there are 4 extents per directory area each representing four 4k blocks (16K).
		simply add 512k * S2 to get full file size

S1 - reserved, set to 0.
RC - Number of records (1 record=128 bytes) used in the last extent.

    If RC is 80h, this extent is full and there may be another one on the
    disc. File lengths are only saved to the nearest 128 bytes.

	To calculate file size simply multiply EX by extent size (e.g. 16384 for QDDS) and add RC * 128.
	FIXME this doesn't handle Random files and only works with multiple directory entries if we are looking
		at the last directory entry i.e. the one with the maximum EXT value.

AL - Allocation. Each AL is the number of a block on the disc. If an AL
    number is zero, that section of the file has no storage allocated to it
    (ie it does not exist). For example, a 3k file might have allocation
    5,6,8,0,0.... - the first 1k is in block 5, the second in block 6, the
    third in block 8.
     AL numbers can either be 8-bit (if there are fewer than 256 blocks on the
    disc) or 16-bit (stored low byte first).

Side: 0, Track: 2, Sector: 0, Physical Sector Number: 20
00000000  00 41 53 4d 20 20 20 20  20 43 4f 4d 00 00 00 40  |.ASM     COM...@|
00000010  01 02 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000020  00 42 49 4f 53 46 20 20  20 53 59 53 00 00 00 23  |.BIOSF   SYS...#|
00000030  03 04 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000040  00 43 42 49 4f 53 20 20  20 41 53 4d 00 00 00 45  |.CBIOS   ASM...E|
00000050  05 06 07 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000060  00 43 4f 4e 46 49 47 20  20 43 4f 4d 00 00 00 5c  |.CONFIG  COM...\|
00000070  08 09 0a 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000080  00 43 50 4d 20 20 20 20  20 53 59 53 00 00 00 34  |.CPM     SYS...4|
00000090  0b 0c 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000a0  00 44 44 54 20 20 20 20  20 43 4f 4d 00 00 00 26  |.DDT     COM...&|
000000b0  0d 0e 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000c0  00 44 45 42 4c 4f 43 4b  20 41 53 4d 00 00 00 50  |.DEBLOCK ASM...P|
000000d0  0f 10 11 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

// TODO: need to understand this one!
000000e0  00 44 45 4d 46 49 4c 45  20 53 56 43 03 00 00 80  |.DEMFILE SVC....|
000000f0  12 13 14 15 16 17 18 19  1a 1b 1c 1d 1e 1f 20 21  |.............. !|
00000100  00 44 45 4d 46 49 4c 45  20 53 56 43 04 00 00 80  |.DEMFILE SVC....|
00000110  22 23 24 25 00 00 00 00  00 00 00 00 00 00 00 00  |"#$%............|

00000120  00 44 49 52 53 54 41 54  20 43 4f 4d 00 00 00 1c  |.DIRSTAT COM....|
00000130  26 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |&...............|
00000140  00 44 49 53 4b 44 45 46  20 4c 49 42 00 00 00 31  |.DISKDEF LIB...1|
00000150  27 28 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |'(..............|
00000160  00 44 55 4d 50 20 20 20  20 41 53 4d 00 00 00 21  |.DUMP    ASM...!|
00000170  29 2a 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |)*..............|
00000180  00 44 55 4d 50 20 20 20  20 43 4f 4d 00 00 00 04  |.DUMP    COM....|
00000190  2b 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |+...............|
000001a0  00 45 44 20 20 20 20 20  20 43 4f 4d 00 00 00 34  |.ED      COM...4|
000001b0  2c 2d 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |,-..............|
000001c0  00 45 52 51 20 20 20 20  20 43 4f 4d 00 00 00 04  |.ERQ     COM....|
000001d0  2e 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001e0  00 46 4f 52 4d 41 54 20  20 43 4f 4d 00 00 00 5f  |.FORMAT  COM..._|
000001f0  2f 51 52 00 00 00 00 00  00 00 00 00 00 00 00 00  |/QR.............|
Side: 0, Track: 2, Sector: 1, Physical Sector Number: 21
00000000  00 47 45 4e 53 59 53 20  20 43 4f 4d 00 00 00 79  |.GENSYS  COM...y|
00000010  30 31 32 33 00 00 00 00  00 00 00 00 00 00 00 00  |0123............|
00000020  00 4b 45 59 43 48 41 49  4e 43 4f 4d 00 00 00 09  |.KEYCHAINCOM....|
00000030  34 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |4...............|
00000040  00 4b 45 59 43 48 41 49  4e 4d 41 43 00 00 00 36  |.KEYCHAINMAC...6|
00000050  35 36 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |56..............|
00000060  00 4c 4f 41 44 20 20 20  20 43 4f 4d 00 00 00 0e  |.LOAD    COM....|
00000070  37 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |7...............|
00000080  00 50 49 50 20 20 20 20  20 43 4f 4d 00 00 00 3a  |.PIP     COM...:|
00000090  38 39 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |89..............|
000000a0  00 52 45 41 44 43 41 53  20 43 4f 4d 00 00 00 09  |.READCAS COM....|
000000b0  3a 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |:...............|
000000c0  00 53 41 56 45 4b 45 59  53 43 4f 4d 00 00 00 07  |.SAVEKEYSCOM....|
000000d0  3b 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |;...............|
000000e0  00 53 41 56 45 4b 45 59  53 4d 41 43 00 00 00 22  |.SAVEKEYSMAC..."|
000000f0  3c 3d 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |<=..............|
00000100  00 53 54 41 54 20 20 20  20 43 4f 4d 00 00 00 29  |.STAT    COM...)|
00000110  3e 3f 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |>?..............|
00000120  00 53 55 42 4d 49 54 20  20 43 4f 4d 00 00 00 0a  |.SUBMIT  COM....|
00000130  40 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |@...............|
00000140  00 53 55 42 4d 49 54 4d  20 43 4f 4d 00 00 00 0a  |.SUBMITM COM....|
00000150  41 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |A...............|
00000160  00 53 56 43 44 45 4d 4f  20 43 4f 4d 01 00 00 79  |.SVCDEMO COM...y|
00000170  42 43 44 45 46 47 48 49  00 00 00 00 00 00 00 00  |BCDEFGHI........|
00000180  00 53 59 53 54 45 4d 20  20 43 46 47 00 00 00 0f  |.SYSTEM  CFG....|
00000190  4a 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |J...............|
000001a0  00 56 49 44 52 45 53 45  54 43 4f 4d 00 00 00 02  |.VIDRESETCOM....|
000001b0  4b 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |K...............|

000001c0  00 57 41 52 4d 20 20 20  20 43 4f 4d 00 00 00 00  |.WARM    COM....|
000001d0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

000001e0  00 57 48 49 47 20 20 20  20 43 4f 4d 00 00 00 2d  |.WHIG    COM...-|
000001f0  4c 4d 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |LM..............|
Side: 0, Track: 2, Sector: 2, Physical Sector Number: 22
00000000  00 57 52 49 54 43 41 53  20 43 4f 4d 00 00 00 07  |.WRITCAS COM....|
00000010  4e 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |N...............|
00000020  00 58 53 55 42 20 20 20  20 43 4f 4d 00 00 00 06  |.XSUB    COM....|
00000030  4f 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |O...............|
00000040  00 58 53 55 42 4d 20 20  20 43 4f 4d 00 00 00 06  |.XSUBM   COM....|
00000050  50 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |P...............|




