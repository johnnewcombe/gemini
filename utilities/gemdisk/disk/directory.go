package disk

import (
	"errors"
	"fmt"
)

/*
DDDS with 2K block size and 16 blocks per directory means that each directory represents 32K of file storage.
QDDS with 4K block size and 16 blocks per directory means that each directory represents 64K of file storage.
An extent is 16K (hangover from CP/M 1.4

	The CP/M 2.2 directory has only one type of entry:

	UU F1 F2 F3 F4 F5 F6 F7 F8 T1 T2 T3 EX S1 S2 RC   .FILENAMETYP....
	AL AL AL AL AL AL AL AL AL AL AL AL AL AL AL AL   ................

	UU = User number. 0-15 (on some systems, 0-31). The user number allows multiple
		files of the same name to coexist on the disc.
		 User number = 0E5h => File deleted
	Fn - Filename
	Tn - filetype. The characters used for these are 7-bit ASCII.
		   The top bit of T1 (often referred to as T1') is set if the file is
		 read-only.
		   T2' is set if the file is a system file (this corresponds to "hidden" on
		 other systems).
	EX = Extent counter, low byte - takes values from 0-31 making the max file size of 512K (each extent is 16K)
         it refers to that maximum extent number accessed by the directory entry. If a file used all of the blocks
         of two directory entries, EX would be 7.
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


*/

type DirectoryEntry struct {
	Filename    Filename
	EX          byte
	S1          byte
	S2          byte
	RC          byte // EX refers to that maximum extent number accessed by the directory entry.
	Allocations []byte
}

func (e *DirectoryEntry) String() string {
	return fmt.Sprintf("[%02b]%s.%s", e.Filename.UserArea, e.Filename.Name, e.Filename.Extn)
}

func (e *DirectoryEntry) ToBytes() []byte {

	var result []byte

	result = append(result, e.Filename.UserArea)
	// FIXME PAD to the end
	result = append(result, []byte(fmt.Sprintf("%-8s", e.Filename.Name)[:8])...)
	result = append(result, []byte(fmt.Sprintf("%-3s", e.Filename.Extn)[:3])...)
	result = append(result, e.EX)
	result = append(result, e.S1)
	result = append(result, e.S2)
	result = append(result, e.RC)
	result = append(result, e.Allocations...)

	return result
}

func (e *DirectoryEntry) SetAllocationBlock(blockIndex int, blockNumber byte) error {

	if blockIndex > 15 {
		return errors.New("GEMDDDS and GEMQDDS disks only support 16 blocks per directory")
	}

	e.Allocations[blockIndex] = blockNumber

	return nil
}

func (e *DirectoryEntry) SetNextEmptyAllocationBlock(blockNumber byte) (int, error) {

	for i, allocation := range e.Allocations {
		if allocation == 0 {
			e.Allocations[i] = blockNumber
			return i, nil
		}
	}
	return -1, errors.New("no empty allocation found")
}

func (e *DirectoryEntry) clear() {

	// TODO make this more elegant
	// clear the directory e
	e.Filename.UserArea = 0xe5
	e.Filename.Name = "\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5"
	e.Filename.Extn = "\xe5\xe5\xe5"
	e.EX = 0xe5
	e.RC = 0xe5
	e.S1 = 0xe5
	e.S2 = 0xe5
	for a := 0; a < 16; a++ {
		e.Allocations[a] = 0xe5
	}
}

func (d *DirectoryEntry) CompareTo(directory DirectoryEntry, ignoreAllocations bool) bool {

	if len(d.Allocations) != len(directory.Allocations) {
		return false
	}

	if !ignoreAllocations {
		for a := 0; a < 16; a++ {
			if d.Allocations[a] != directory.Allocations[a] {
				return false
			}
		}
	}

	if d.Filename.CompareTo(directory.Filename) &&
		d.EX == directory.EX &&
		d.S1 == directory.S1 &&
		d.S2 == directory.S2 &&
		d.RC == directory.RC {
		return true
	}
	return false
}

func NewDirectoryEntry() DirectoryEntry {
	var (
		result DirectoryEntry
	)

	result.clear()
	return result
}