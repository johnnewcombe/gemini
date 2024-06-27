## GemDisk

__This is a work in progress... watch this space.__

This utility is designed to inspect and manipulate the contents of GEMQDDS and GEMDDDS raw disk image files. It is available in native compiled form in the bin directory for the following architectures.

```text
    MacOS (arm/amd64)
    Windows (386/amd64)
    Linux (amd64/arm64/arm)
```

To understand how these images can be used with a Gotek or the XBeaver emulator. See https://bitbucket.org/johnnewcombe/gemini/src/master/disk-images/

## GEMDDDS and GEMQDDS Disk Formats

The GEMDDDS disk type uses the following disk layout, in other words when reading or writing to a disk the sectors are accessed in the following order. This is referred to as track interleaved.

```text
    Side 0, Track 0, Sect 0 to 9
    Side 1, Track 0, Sect 0 to 9
    Side 0, Track 1, Sect 0 to 9
    Side 1, Track 1, Sect 0 to 9
    Side 0, Track 2, Sect 0 to 9
    Side 1, Track 2, Sect 0 to 9
    
    etc...
```

The GEMQDDS disk type uses the following disk layout. All of side 1 is accessed followed by all of side 2. This is referred to as sequential format.

```text
    Side 0, Track 0, Sect 0 to 9
    Side 0, Track 2, Sect 0 to 9
    Side 0, Track 3, Sect 0 to 9

    etc... to track 79 then

    Side 1, Track 0, Sect 0 to 9
    Side 1, Track 2, Sect 0 to 9
    Side 1, Track 3, Sect 0 to 9
```

CP/M see the disks as follows...
 
GEMQDDS Disks

```text
    6304 128byte Record Capacity
    128 32 byte directory entries
    788 Kilobyte Capacity
    512 records per extent
    32 records per block
    40 sectors per track
    2 reserved track
```

GEMDDDS Disks

```text
    2704 128byte Record Capacity
    128 32 byte directory entries
    338 Kilobyte Capacity
    256 records per extent
    16 records per block
    80 sectors per track
    1 reserved track
```

## Usage

For usage:

```text
    $ gemdisk -h
```

The following will be displayed...

```text
    Gemini QDDS and DDDS Disk Utility
    
    Usage:
      gemdisk [command]
    
    Available Commands:
      completion  Generate the autocompletion script for the specified shell
      delete-file Deletes a file from the disk image.
      dump        Dump the disk image contents to the console in hex/ascii.
      dump-file   Dump a file contents to the console in hex/ascii.
      help        Help about any command
      interleaved Creates an interleaved image from a sequential one.
      list        List all files from all user areas on the disk.
      new         Creates a new disk image.
      read-file   Reads a file from the disk image to the local file system.
      sequential  Creates a sequential image from an interleaved one.
      sys-gen     Adds CP/M to the system tracks.
      version     Displays the program version.
      write-file  Writes a file from the local file system to the disk image.
    
    Flags:
      -h, --help   help for gemdisk
    
    Use "gemdisk [command] --help" for more information about a command.

```

### Dumping a Disk

The ```dump``` command will dump the disk in hex/ascii format and will show track and sector information based on the assumption that GEMQDSS disk images are sequential images and GEMDDDS disk images are track interleaved disk images.

```text
    $ gemdisk dump -i "MYDISK.IMG"
```

e.g.

```text
    Side: 0, Track: 0, Sector: 0, Physical Sector Number: 0
    00000000  47 47 31 00 01 b7 20 01  3c 08 3e 0f d3 bc cd 1e  |GG1... .<.>.....|
    00000010  00 28 07 3e 03 d3 bc c3  00 f0 08 c3 00 f0 21 00  |.(.>..........!.|
    00000020  da 01 e4 01 1e 13 db e5  07 16 82 30 02 16 88 08  |...........0....|
    00000030  d3 e4 08 78 d3 e2 7a d3  e0 18 02 77 23 ed 78 28  |...x..z....w#.x(|
    00000040  fc db e3 fa 3b 00 db e0  e6 fc c0 04 78 d6 0a 20  |....;.......x.. |
    ...
```

### Dump the contents of a file

The ```dump-file``` will dump the contents of a file in hex/asci format.

```text
    $ gemdisk dump-file -i "MYDISK.IMG" -f "findbad.com"
```

e.g.

```text
    00000000  c3 05 01 00 ff 31 61 07  cd 67 01 0d 0a 46 49 4e  |.....1a..g...FIN|
    00000010  44 42 41 44 20 2d 20 76  65 72 20 35 2e 32 0d 0a  |DBAD - ver 5.2..|
    00000020  42 61 64 20 73 65 63 74  6f 72 20 6c 6f 63 6b 6f  |Bad sector locko|
    00000030  75 74 20 70 72 6f 67 72  61 6d 0d 0a 55 6e 69 76  |ut program..Univ|
    00000040  65 72 73 61 6c 20 76 65  72 73 69 6f 6e 0d 0a 0d  |ersal version...|
    00000050  0a 54 79 70 65 20 43 54  4c 2d 43 20 74 6f 20 61  |.Type CTL-C to a|
    00000060  62 6f 72 74 0d 0a 24 d1  0e 09 cd 05 00 cd a5 01  |bort..$.........|
    00000070  cd fd 05 cd 3f 02 ca 7c  01 cd 32 04 cd aa 05 3e  |....?..|..2....>|
    00000080  09 cd b1 05 11 e3 06 2a  fa 06 7c b5 ca 95 01 cd  |.......*..|.....|
    00000090  88 05 c3 9a 01 0e 09 cd  05 00 11 e6 06 0e 09 cd  |................|
    000000a0  05 00 c3 00 00 2a 01 00  11 18 00 19 22 0a 02 11  |.....*......"...|
    000000b0  03 00 19 22 76 03 11 03  00 19 22 6e 03 11 06 00  |..."v....."n....|
    000000c0  19 22 79 03 11 09 00 19  22 be 03 0e 0c cd 05 00  |."y.....".......|
    000000d0  7c b5 32 c1 06 c2 e4 01  11 0f 00 2a 06 00 2e 00  ||.2........*....|
    000000e0  19 22 be 03 3a 5c 00 4f  b7 c2 f3 01 0e 19 cd 05  |."..:\.O........|
    ...
```

### Listing Files

The ```list``` command will list files from all user areas.

```text
    $ gemdisk list -i="MYDISK.IMG"
```

e.g.

```text
     USER      NAME EXT    SIZE
        6     BIOSF.SYS    4608 bytes
        6    BIOSFW.SYS    4992 bytes
        5     BIOSN.SYS    4992 bytes
        6     BIOSW.SYS    4864 bytes
        2    SYSGEN.COM    1024 bytes
        2    FORMAT.COM    1536 bytes
        0      BOOT.COM     384 bytes
        0    CONFIG.COM   11776 bytes
        0   FINDBAD.COM    1664 bytes
        0   FWM3212.COM    2816 bytes
        0   FWM3425.COM    2816 bytes
        0     FWNEC.COM    2816 bytes
        0   FWRO201.COM    2816 bytes
        0   FWRO202.COM    2816 bytes
        0   FWRO203.COM    2816 bytes
        0   FWRO204.COM    2816 bytes
        0    GENSYS.COM   15616 bytes
        0  SCRUBDIR.COM    1152 bytes
        0   SYSTEMF.CFG    1792 bytes
        0  SYSTEMFW.CFG    2176 bytes
        0   SYSTEMW.CFG    2304 bytes
        0      WHIG.COM    5760 bytes
        0      PARK.COM    1408 bytes
        0   SIMON44.ROM    1920 bytes
        0   SIMON42.ROM    1920 bytes
        0      READ. ME    2304 bytes
        
        files:  26
        used:  62 blocks
        free: 134 blocks
```

## Copying Files from the Disk Image

Files can be copied from the disk image to the current working directory using the ```copy``` command e.g.

```text
    $ gemdisk read-file -i "MYDISK.IMG" -f "FINDBAD.COM"
```

The file will be copied to the local working directory, and the name is prepended with the user area in square brackets e.g.

```text
    -rw-r--r--  1 john  staff  1664 Sep 22 10:12 [00]FINDBAD.COM
```

To copy all the files in all user areas to the current working directory use the ```*``` wildcard e.g.

```text
    $ gemdisk read-file -i "MYDISK.IMG" -f "*"
```

To copy files from a specific user area, simply add the user area number to the filename in square brackets e.g.

```text
    $ gemdisk read-file -i "MYDISK.IMG" -f "[5]BIOSN.SYS"
```

Files will be stored in the local working directory prefixed by the user area they were located in e.g.

```text
    -rw-r--r--   2 john  staff     384 Sep 22 10:20 [00]BOOT.COM
    -rw-r--r--   2 john  staff   11776 Sep 22 10:20 [00]CONFIG.COM
    -rw-r--r--   1 john  staff    1664 Sep 22 10:20 [00]FINDBAD.COM
    -rw-r--r--   2 john  staff    4480 Sep 22 10:20 [05]BIOSF.SYS
    -rw-r--r--   2 john  staff    4864 Sep 22 10:20 [05]BIOSFW.SYS
    -rw-r--r--   2 john  staff    4992 Sep 22 10:20 [05]BIOSN.SYS
    -rw-r--r--   2 john  staff    4992 Sep 22 10:20 [05]BIOSW.SYS
    -rw-r--r--   2 john  staff    4608 Sep 22 10:20 [06]BIOSF.SYS
    -rw-r--r--   2 john  staff    4992 Sep 22 10:20 [06]BIOSFW.SYS
    -rw-r--r--   2 john  staff    4864 Sep 22 10:20 [06]BIOSW.SYS
    ...
```

The additional option ```-t``` (```--text-mode```) will cause files of type .TXT, .DOC, .LST, .MAC, .ASM, .SUB, .CFG to be truncated at the first Ctrl Z character.

## Copying Files to the Disk Image

```text
    $ gemdisk write-file -i "MYDISK.IMG" -f "[5]BIOSN.SYS"
```

The additional option ```-t``` (```--text-mode```) will cause files of type .TXT, .DOC, .LST, .MAC, .ASM, .SUB, .CFG to ensure a Ctrl Z character is present at the end and that line endings are CR/LF. This allows files to be edited on the local host and safely copied to the disk image.

## Creating a Blank Formatted Disk Image

To create a new blank disk, use the ```new``` command

```text
    gemdisk new -o MYDISK.IMG
```
The above command will create a blank formatted GEMQDDS disk image. to create a GEMDDDS disk image, simply add the ```--ddds``` option e.g.

```text
    gemdisk new -o MYDISK.IMG --ddds
```

## Creating a new Bootable Disk Image


To make the disk image bootable, use the ```sys-gen``` command e.g.

```text
    gemdisk sys-gen -i MYDISK.IMG
```

This will create a bootable disk configured with three floppy drives as follows A:=GEMQDDS, B:=GEMQDDS and C:=GEMDDDS. GEMQDDS images will be configured to boot to BIOS 3.5. GEMDDDS images will be configured to boot to BIOS 1.4. This is simply meant to be a 'get you started' disk.

### Converting from Track Interleaved to Sequential

Some GEMQDDS raw disk image files have been written to file as track interleaved images (see GEMDDDS and GEMQDDS Disk Formats above), GemDisk can convert these for example to convert a track interleaved image to a sequential image the following command can be used.

```text
    $ gemdisk sequential  -i "MYDISK.IMG" -o "MYDISK_S.IMG" -is
```

To convert it back...

```text
    $ gemdisk interleaved  -i "MYDISK_I.IMG" -o "MYDISK_S.IMG" -is
```

To understand how these images can be used with a Gotek or the XBeaver emulator. See https://bitbucket.org/johnnewcombe/gemini/src/master/disk-images/

### More ...

Features still to be added are:

```text
    copy-file:  where files can be copied within the disk image. This will support changes to user areas.
    blank_disk: ability to create blank formatted disk images
    sys-gen:    add further bios's e.g. 3.2, 3.3, 3.4, 3.4 MFB, 3.5, 3.6.
```

The aim is to have a utility that can fully manipulate GEMQDDS and GEMDDDS disk images. More features to be added soon, watch this space!

Enjoy!

John Newcombe (@GlassTTY)