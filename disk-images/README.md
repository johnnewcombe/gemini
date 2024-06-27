## Introduction

The disk images here are either GEMDDDS or GEMQDDS format raw disk images and have been imaged using John B Hansons DISKED program running on a Gemini GM916 MFB2 (Bios 3.4) computer. As a result they are in raw binary form (see Disk Layout) below.

GEMQDDS disks are 819200 bytes in size and GEMDDDS disks are 358400 bytes in size.

Each disk is stored in its own directory (see list below) and where possible includes the individual files stored on the disk.

__Please note that this area, in particular disk numbering scheme, will be subject to change as the disks as investigated and sorted. Please link to this page rather than the disk image itself.__

## Disk Layout

The GEMDDDS disk type uses the following disk layout, in other words when reading or writing to a disk the sectors are accessed in the following order. This is referred to in this repository as track interleaved.

    Side 0, Track 0, Sect 0 to 9
    Side 1, Track 0, Sect 0 to 9
    Side 0, Track 1, Sect 0 to 9
    Side 1, Track 1, Sect 0 to 9
    Side 0, Track 2, Sect 0 to 9
    Side 1, Track 2, Sect 0 to 9
    
    etc...

The GEMQDDS disk type uses the following disk layout. All of side 1 is accessed followed by all of side 2. This is referred to as sequential format.

    Side 0, Track 0, Sect 0 to 9
    Side 0, Track 1, Sect 0 to 9
    Side 0, Track 2, Sect 0 to 9
    Side 0, Track 3, Sect 0 to 9

    etc... to track 79 then...

    Side 1, Track 0, Sect 0 to 9
    Side 1, Track 1, Sect 0 to 9
    Side 1, Track 2, Sect 0 to 9
    Side 1, Track 3, Sect 0 to 9

The disk images in this repository adhere to this specification.

__Notes:__

If the disk has a READ.ME file on it PLEASE READ IT!, it will often describe whats on the disk and how the CP/M USER areas are used. 

Multiformat Bios Disks (MFB) require the special Gemini MFB system to work, the MFB system uses a specially modified GM849 or GM849a disk controller card and a special MFB version of the Simon ROM.

## Using with a Gotek (Flash Floppy) Device

If using these images with a Gotek/FlashFloppy system use the following definition.

    # 'GEMDDDS' matches images of the form *.GEMDDDS.img and *.GEMDDDS.ima
    [GEMDDDS]
    file-layout = interleaved
    cyls  = 35
    heads = 2
    secs  = 10
    id = 0
    rate = 250
    bps = 512

    # 'GEMQDDS' matches images of the form *.GEMQDDS.img and *.GEMQDDS.ima
    [GEMQDDS]
    file-layout = sequential
    cyls  = 80
    heads = 2
    secs  = 10
    id = 0
    rate = 250
    bps = 512

## Using with XBeaver

A configuration example for the XBeaver emulator is shown below. This command shows a GEMQDDS disk as the first floppy and a GEMDDDS disk as the second floppy. Note the 'S' (sequential) parameter in front of the geometry definition in the case of GEMQDDS disk images.

    board 0xe0 gm849_floppy -geometry S80.2.10.0.512 Disk1.GEMQDDS.img -geometry 35.2.10.0.512 Disk2.GEMDDDS.img

## Using Greasweazle to Image Gemini Disks

_These examples assume an 96 TPI PC disk drive with straight cable is being used._


To convert a Gemini DDDS (interleaved) disk to .img.

    gw read --tracks="c=0-79:h=0-1" --drive=B --format ibm.scan mydisk.img

To convert a Gemini QDDS (sequential) disk to .img, the following commands can be used

    gw read --tracks="c=0-79:h=0" --drive=B --format ibm.scan mydisk-side-0.img
    gw read --tracks="c=0-79:h=1" --drive=B --format ibm.scan mydisk-side-1.img
    cat mydisk-side-0.img mydisk-side-1.img > mydisk.img


These images can be used in xBeaver, however, sequential disks e.g. QDDS require the 'S' # parameter specifying as part of the geometry e.g.

    ... -geometry S80.2.10.0.512 mydisk.img

## Disk Contents

Note that MFB-1 was designed to run with the GM829 controller. MFB-2 requires the GM849 controller specifically modified for the Multi Format Bios (MFB). In addition, the Simon 4.x (MFB only) ROM should be used. In order for the system to boot a Xebec controller needs to be connected to the GM849MFB controller. 

### 001-019 Original Gemini Disks

    001 - GM555 Bios 3.5 2-DM Serial 2-248-03060__
    002 - Gemini Bios 3's
    003 - GM860 EPROM Programmer Source Listings and Prigram Version 1.0 28/11/85__
    004 - Upgrade Software for MultiNet, MultiNet Version 2 29/09/85__
    005 - GM925 MFB 2 Master Disk Bios Vers 3.3 10W Release 1.3 Serial 2-248-02662__
    006 - MFB 2 Update, Update Release December 1985 Bios 3.4
    007 - GM142 Miniscribe Upgrade Software.
    008 - GM142N System Programs for 20Mb NEC Winchester Disk Drive.
    009 - MFB 1 Upgrade Software, Configuration Version 1.1, Serial 2-248-01722
    010 = MFB2 Update Release September 1986 Bios Version 3.4 Reg. No. 122 2272

All remaining disks are taken from user created disks, but in many cases maybe backups of originals.

### 020-229 User Contributed CP/M Versions

    020 - Gemini 96,96,8,8 Bios 5.03 CP/M3 Master

### 030-039 Applications

    030 = Gemini Turbo Pascal 3 Serial No. D3B1037179
    032 - Kenilworth Labeling System (5 disk set)

### 100-199 Miscellaneous Non-Original Disks (To be investigated and sorted)

These disks are 'user disks' and may or may not be bootable. Some may be copies of original Gemini disks, but most are likely to be a mismatch of programs and files. Many of these will be investigated further with appropriate comments being added. Duplicates of genuine disks will be deleted.

    100 - GM891 Test Software and Source (includes GemTerm)
    101 - GM925 MFB 2 Master Disk CP/M 2.2 Bios v3.3 20Mb Winchester
    103 - GM916 System Disk Backup Serial 01282 (Upgraded System)
    104 - MSUTIL, MSPAT, 
    105 - MSUTIL Release 19 Feb 1985
    106 - MFB 2 Update Serviuce (Supplied by Timeclaim Ltd) Update July 1985
    107 - MAP80 Systems, Assign Version 4.00 (some CRC issues noticed)
    108 - Gemini Programs [to be investigated] (see User Area 1, 2 and 3) (some CRC issues noticed)
    109 - Utility Programs Disc Master [to be investigated]
    110 - 
    111 - System Configurations [may be related to disk 113, to be investigated]
    112 - 
    113 - Special Boot Disk Boots with CON:=BAT:
    114 - Bios 3.6 (see user areas)
    115 - Gemini 142N System Programs for NEC 20Mb Winchester
    116 - MENU.COM with Pascal source (from HD B User 13)
    117 - Kenilworth Master Disk
    118 - Kenilworth Master Disk Gemini CP/M 2.2. Bios 3.2
    119 - Gemini System disk (some additional files)
    120 - Micropolis QMTEST.034
    121 - Gemini Wordstar
    122 - GM142n Miniscribe Update Software OK for ST20M
    123 - Gemin CP/M 2.2 Bios 3.4 Test
    124 - Gemini Bios'
    125 - CP/M 3
    126 - CP/M 3.2 Config'D
    127 - CP/M 3 Bios 5.03 96.96.48.8 Master
    128 - CP/M 3 Bios 4.00 Master
    129 - CP/M 3 Bios 5.0 Master
    130 - CP/M 3
    131 - CP/M 3 Bios V5.03 96,96,96,8
    132 - CP/M 3 Bios V5.03 96,96,48,8
    133 - AllDisk Version 1.2 Master (Translated for Gemini by David Searle 9 June 1989)
    134 - AllDisk Version 1.2 Master (Translated for Gemini by David Searle 9 June 1989)
    135 - CP/M 3 Bios V5.03 96,96,48,8
    136 - CP/M 3 Bios V5.03 96,96,48,8,8
    137 - CP/M 3 Bios V4.00 96,96,48,8
    138 - CP/M 3 Bios V4.00 96,96,48,8
    139 - CP/M 3 Bios 4.00 Master
    140 - CP/M 3 96,96,96, 8
    141 - CP/M 3 96,96,48, 8
    142 - Gemini CP/M 3 Bios 5.0
    
