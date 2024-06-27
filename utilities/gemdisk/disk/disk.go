package disk

import (
	"bytes"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

const (
	Sides                   = 2
	Tracks                  = 80
	SystemTracks            = 2
	BytesPerSector          = 512
	BytesPerDirectory       = 32
	SectorsPerTrack         = 10
	ExtentBytes             = 16384
	RecordBytes             = 128
	DirectoryEntries        = 128
	QddsDataBlocks          = 197
	DddsDataBlocks          = 170
	QddsBlockSize           = 4096
	DddsBlockSize           = 2048
	BlocksPerDirectory      = 16
	RecordSize              = 128
	RecordsPerExtent        = 128
	QDDSSize                = 819200
	DDDSSize                = 358400
	textEof            byte = 0x1F
	deleteByte         byte = 0xE5
	allAreas                = 255
)

type Disk struct {
	Qdds                bool
	Sectors             []Sector
	DirectoryEntries    []DirectoryEntry
	blockMap            map[byte]bool // map of blocks, value is tru if block is used
	lastBlock           byte
	blockSize           int
	sectorsPerBlock     int
	recordsPerExtent    int
	recordsPerDirectory int
	extentsPerDirectory int
}

// LoadDiskImage Loads and initialises the disk object from the supplied data.
func (d *Disk) LoadDiskImage(data []byte) error {

	var (
		sectNum, trkNum, sideNum int
	)

	switch len(data) {
	case QDDSSize:
		d.Qdds = true
	case DDDSSize:
		d.Qdds = false
	default:
		return errors.New("the disk image file size is invalid")
	}

	d.initDisk()

	// this gives us 1600n sectors for qdds and 700 sectors for ddds
	sectors := GetChunks(data, BytesPerSector)

	for index, s := range sectors {

		sectNum = index % SectorsPerTrack

		if d.Qdds {
			// gemqdds (4k blocks)
			trkNum = index / SectorsPerTrack % Tracks
			sideNum = index / (SectorsPerTrack * Tracks)

		} else {
			// gemddds (2k blocks)
			trkNum = (index / SectorsPerTrack) / 2
			sideNum = (index / SectorsPerTrack % Tracks) % 2

		}

		d.Sectors = append(d.Sectors, Sector{sideNum, trkNum, sectNum, s, index})
	}

	// populate the directory
	dir := d.getDirectory()
	entries := GetChunks(dir, 32)

	for i := 0; i < DirectoryEntries; i++ {

		entry := entries[i]
		user := entry[0]

		// note that we include empty and deleted directories here

		//debug := []byte(e.Filename.Name)
		//print(len(debug))

		de := DirectoryEntry{
			Filename{user, trim(string(entry[1:9])), trim(string(entry[9:12]))},
			entry[12], entry[13], entry[14], entry[15],
			entry[16:]}

		// create the block Map so that we can find free blocks easily
		for _, alloc := range de.Allocations {
			d.blockMap[alloc] = true
		}

		d.DirectoryEntries = append(d.DirectoryEntries, de)
	}

	// cache the Filename for use when writing files etc.
	return nil
}

// ReadFile Returns a file from the disk image based on the record count.
func (d *Disk) ReadFile(filename Filename) ([]byte, error) {

	var (
		entry    DirectoryEntry
		result   []byte
		fileSize int
	)

	entries := d.GetDirectoryEntries(filename)
	if entries == nil {
		return []byte{}, fmt.Errorf("file '%s' not found in user area %d", filename.FullName(), filename.UserArea)
	}

	lastEntry := entries[len(entries)-1]

	// get file size (based on 128 byte records)
	fileSize = int(lastEntry.EX)*ExtentBytes + (int(lastEntry.RC) * RecordBytes)

	for _, entry = range entries {
		for _, allocation := range entry.Allocations {
			if allocation > 0 {
				//result = append(result, d.getBlock(int(allocation))...)
				block := d.getBlock(int(allocation))
				result = append(result, block...)
			}
		}
	}

	return result[:fileSize], nil
}

// WriteFile Writes a file to the disk image
func (d *Disk) WriteFile(filename Filename, data []byte) error {

	var (
		recordsNeeded    int
		firstSectorIndex int
		freeBlocks       int
		allocatedBlocks  []byte
		err              error
	)

	if IsTextFile(filename.FullName()) && !bytes.Contains(data, []byte{textEof}) {

		//ensure that text files have Ctrl-Z at the end as they may have been trimmed by the download process or external editing.
		data = append(data, textEof)

		// handle CR/LFs
		re := regexp.MustCompile(`\r?\n`) // using back tick means we don't need to escape the backslashes
		data = re.ReplaceAll(data, []byte{0x0d, 0x0a})
	}

	// Does file exist, if so delete file by setting user area to E5
	if d.FileExists(filename) {
		d.DeleteFile(filename)
	}

	// get the data as blocks
	blocks := GetChunks(data, d.blockSize)

	// work out how many records are to be written
	recordsNeeded = int(math.Ceil(float64(len(data)) / 128))

	// Get free blocks
	freeBlocks = d.FreeBlockCount()

	// check that there is some space
	if freeBlocks < len(blocks) {
		d.UnDeleteFile(filename)
		return errors.New("disk is full, not enough free blocks")
	}

	// create the directory entries
	if _, err = d.createDirectoryEntries(filename, recordsNeeded); err != nil {
		d.UnDeleteFile(filename)
		return err
	}

	// get the blocks that were allocated when we created the directories
	allocatedBlocks = d.GetBlocks(filename)

	//loop through each block updating the associated sectors
	for i, block := range blocks {

		// updates are done by updating the sectors that represent the blocks
		// to get the index of the sector simply find out how many sectors to
		// ignore in order to get to the block, however we need to ignore the
		// 2 system Tracks e.g. SectorsPerTrack * 2
		firstSectorIndex = d.getSectorIndexForBlock(allocatedBlocks[i])

		// last block could be less than full size depending upon the file and its source
		if len(block) < d.blockSize {
			for len(block) < d.blockSize {
				block = append(block, 0xe5)
			}
		}

		// loop through each sector that is in the block
		for sect := 0; sect < d.sectorsPerBlock; sect++ {
			// update the sector
			a := sect * BytesPerSector
			b := sect*BytesPerSector + BytesPerSector
			d.Sectors[sect+firstSectorIndex].Data = block[a:b]
			//d.Sectors[sect+firstSectorIndex].Data = block[sect*BytesPerSector : sect*BytesPerSector+BytesPerSector]
		}
	}

	return nil
}

func (d *Disk) DeleteFile(filename Filename) {

	// get directory entries for non-deleted files
	for index, entry := range d.DirectoryEntries {
		if entry.Filename.Name+entry.Filename.Extn == strings.ToUpper(filename.Name+filename.Extn) && (entry.Filename.UserArea == filename.UserArea && entry.Filename.UserArea != 0xE5) {
			d.DirectoryEntries[index].Filename.UserArea = deleteByte
		}
	}
	return

}

func (d *Disk) UnDeleteFile(filename Filename) error {

	// get directory entries for non-deleted files
	for index, entry := range d.DirectoryEntries {
		if entry.Filename.Name+entry.Filename.Extn == strings.ToUpper(filename.Name+filename.Extn) &&
			entry.Filename.UserArea == filename.UserArea &&
			entry.Filename.UserArea != 0xE5 {
			return errors.New("cannot un-delete file as a file with the same name already exists")
		}

		if entry.Filename.Name+entry.Filename.Extn == strings.ToUpper(filename.Name+filename.Extn) &&
			entry.Filename.UserArea == filename.UserArea &&
			entry.Filename.UserArea == 0xE5 {
			d.DirectoryEntries[index].Filename.UserArea = 0
		} else {
			return fmt.Errorf("file does not exist in user area %d", filename.UserArea)
		}
	}
	return nil

}

func (d *Disk) FileExists(filename Filename) bool {
	dirs := d.GetDirectoryEntries(filename)
	return len(dirs) != 0
}

// ListFiles List all files from all user areas. Excludes deleted files.
func (d *Disk) ListFiles() string {

	var (
		result    strings.Builder
		entry     DirectoryEntry
		byteCount int
	)
	// we need our list to be unique so we use a map of key/val bool to assist
	keys := make(map[string]bool)

	//. write the header
	result.WriteString("\r\nUSER      NAME EXT    SIZE\r\n")

	for _, entry = range d.DirectoryEntries {

		key:= string(entry.Filename.UserArea)+entry.Filename.Name+entry.Filename.Extn

		// if the value (bool) is false then the name is not already in the map
		if _, value := keys[key]; !value && entry.Filename.UserArea != deleteByte {

			// add the key to the map
			keys[key] = true

			// get all directories for this file and use the one with
			// the largest extent
			fn := Filename{UserArea: entry.Filename.UserArea, Name: entry.Filename.Name, Extn: entry.Filename.Extn}
			directories := d.GetDirectoryEntries(fn)
			last := directories[len(directories)-1:][0]
			result.WriteString(fmt.Sprintf("  %2d  %8s.%3s  %6d\r\n", last.Filename.UserArea, strings.Trim(last.Filename.Name, " "), last.Filename.Extn, d.GetFileSize(fn)))

			byteCount += d.GetFileSize(fn)
		}
	}

	result.WriteString(fmt.Sprintf("\r\nfiles: %3d\r\n", len(keys)))
	result.WriteString(fmt.Sprintf(" used: %3d blocks\r\n", d.UsedBlockCount()))
	result.WriteString(fmt.Sprintf(" free: %3d blocks\r\n", d.FreeBlockCount()))
	//	result.WriteString(fmt.Sprintf("bytes: %3d K\r\n\r\n",int(math.Ceil(float64(byteCount)/1024))))
	result.WriteString(fmt.Sprintf("bytes: %3d\r\n\r\n", byteCount))
	return result.String()
}

// Dump Dumps the disk image to the console.
func (d *Disk) Dump() string {

	var result strings.Builder

	for _, sector := range d.Sectors {
		result.WriteString(fmt.Sprintf("Side: %d, Track: %d, Sector: %d, Physical Sector Number: %d\r\n%s", sector.SideNumber, sector.TrackNumber, sector.SectorNumber, sector.PhysicalSectorNumber, hex.Dump(sector.Data)))
	}
	return result.String()
}

// Interleave Converts from Sequential to Interleaves by rearranging the Tracks.
func (d *Disk) Interleave() {

	/* The layout of a sequential disk is as follows

		    Side 0, Track 0, Sect 0 to 9
		    Side 0, Track 1, Sect 0 to 9
		    Side 0, Track 2, Sect 0 to 9
		    Side 0, Track 3, Sect 0 to 9

		    etc... to track 79 then

		    Side 1, Track 0, Sect 0 to 9
		    Side 1, Track 1, Sect 0 to 9
		    Side 1, Track 2, Sect 0 to 9
		    Side 1, Track 3, Sect 0 to 9

			etc... to track 79

		The layout of an interleaved disk is as follows

			Side 0, Track 0, Sect 0 to 9
			Side 1, Track 0, Sect 0 to 9
			Side 0, Track 1, Sect 0 to 9
			Side 1, Track 1, Sect 0 to 9
			Side 0, Track 2, Sect 0 to 9
			Side 1, Track 2, Sect 0 to 9

			etc...

	To convert sequential to interleaved, simply split the Tracks in half and add a track from
	the first half followed by a track from the second half.

	To convert interleaved to sequential simply separate odd Tracks and even Tracks and place all
	odd track after even Tracks.

	*/

	var result, side1, side0 []Sector

	// get the sectors count
	sectCount := len(d.Sectors)

	// split the disk in half the first half represents side 0 second represents side 1
	side0 = d.Sectors[:sectCount/2]
	side1 = d.Sectors[sectCount/2:]

	// loop through each track e.g. sectCount/2 % 10
	for sec := 0; sec < sectCount/2; sec += SectorsPerTrack {

		// get the Tracks from side 0 then side 1
		trackSide0 := side0[sec : sec+SectorsPerTrack]
		trackSide1 := side1[sec : sec+SectorsPerTrack]

		// add them to the result
		result = append(result, trackSide0...)
		result = append(result, trackSide1...)
	}

	// set the current disk with the result
	d.Sectors = result
}

// Sequential Converts from Interleaves to Sequential by rearranging the Tracks.
func (d *Disk) Sequential() {

	// To convert interleaved to sequential simply separate odd Tracks and even Tracks and ...

	var resultOdd, resultEven []Sector

	for _, sector := range d.Sectors {
		if sector.TrackNumber%2 == 0 {
			resultEven = append(resultEven, sector)
		} else {
			resultOdd = append(resultOdd, sector)
		}
	}
	result := append(resultEven, resultOdd...)
	d.Sectors = result
}

// ToBytes Returns the whole disk as a slice of bytes.
func (d *Disk) ToBytes() []byte {

	var (
		result []byte
	)

	// system is on first two Tracks
	systemSectors := SectorsPerTrack * SystemTracks
	// entries are 32 bytes, sectors are 512 bytes so 16 per sector * 128 directory entries so 8 sectors
	dirSectors := DirectoryEntries * BytesPerDirectory / BytesPerSector

	// the idea is to take the system Tracks followed by the directory then the remaining sectors
	// it has to be done like this rather than just taking all sectors as the directory may have changed
	// due to deletions, files added etc. These changes wont be reflected in the underlying sectors.

	// system Tracks
	for _, sector := range d.Sectors[:systemSectors] {
		result = append(result, sector.Data...)
	}

	// directories
	for _, dir := range d.DirectoryEntries {
		result = append(result, dir.ToBytes()...)
		//fmt.Printf("%d: %d, %d \r\n",i, len(result), len(dir.ToBytes()))
	}

	// remaining sectors
	for _, sector := range d.Sectors[systemSectors+dirSectors:] {
		result = append(result, sector.Data...)
	}
	return result
}

//FreeBlockCount Returns the number of free blocks.
func (d *Disk) FreeBlockCount() int {

	return int(d.lastBlock) - d.UsedBlockCount()
}

// UsedBlockCount Returns the number of used blocks.
func (d *Disk) UsedBlockCount() int {

	var i, usedBlockCount byte

	for i = 0; i < d.lastBlock; i++ {
		if d.blockMap[i] {
			usedBlockCount++
		}
	}

	return int(usedBlockCount)
}

// GetBlocks returns all blocks for the given Filename. Excludes deleted directories.
func (d *Disk) GetBlocks(filename Filename) []byte {

	var (
		directories []DirectoryEntry
		result      []byte
	)

	directories = d.GetDirectoryEntries(filename)

	// get directory entries for non-deleted files
	for _, entry := range directories {
		if entry.Filename.Name+entry.Filename.Extn == strings.ToUpper(filename.Name+filename.Extn) && (entry.Filename.UserArea == filename.UserArea || (filename.UserArea == allAreas && entry.Filename.UserArea != 0xE5)) {
			result = append(result, entry.Allocations...)
		}
	}

	return result
}

// GetDirectoryEntries returns all directory entries for the given Filename. Excludes deleted directories.
func (d *Disk) GetDirectoryEntries(filename Filename) []DirectoryEntry {

	var result []DirectoryEntry

	// get directory entries for non-deleted files
	for _, entry := range d.DirectoryEntries {
		if entry.Filename.Name+entry.Filename.Extn == strings.ToUpper(filename.Name+filename.Extn) && (entry.Filename.UserArea == filename.UserArea && entry.Filename.UserArea != 0xE5) {
			result = append(result, entry)
		}
	}

	// Result needs to be sorted by Extent number so that the allocation blocks
	// are in the correct order and it easier to calculate the file size
	sort.Slice(result, func(i, j int) bool {
		return result[i].EX < result[j].EX
	})

	return result
}

// GetFilenames returns a unique list of filenames
func (d *Disk) GetFilenames() []Filename {

	var (
		entry  DirectoryEntry
		result []Filename
	)

	keys := make(map[string]bool)

	for _, entry = range d.DirectoryEntries {

		if entry.Filename.UserArea == deleteByte {
			continue
		}

		key := strconv.Itoa(int(entry.Filename.UserArea)) + entry.Filename.Name + entry.Filename.Extn

		// if the value (bool) is false then the name is not already in the map
		if _, value := keys[key]; !value {

			// add the key to the map
			keys[key] = true

			// get all directories for this file and use the one with
			// the largest extent
			result = append(result, Filename{entry.Filename.UserArea, entry.Filename.Name, entry.Filename.Extn})
			//result = append(result, fmt.Sprintf("%s.%s.%02d", entry.UserArea, entry.Name, entry.Extn))
		}
	}
	return result
}

func (d *Disk) GetFileSize(filename Filename) int {

	entries := d.GetDirectoryEntries(filename)
	lastEntry := entries[len(entries)-1:][0]
	// each extent is 16K (zero based so a value of 0 represents only one extent
	// RC represents the number of 128 byte records used in the last extent
	// S2 indicates the number of extents*31 e.g. 512K chunks
	return int(lastEntry.EX)*ExtentBytes + (int(lastEntry.RC) * RecordBytes) + (int(lastEntry.S2) * 512 * 1024)
}

func (d *Disk) getSectorIndexForBlock(block byte) int {
	return int(block)*d.sectorsPerBlock + (SectorsPerTrack * 2)
}

// CreateDirectory this function will create all the directory entries required
// based on the record count. The directory will be populated with free blocks as
// appropriate. Returns a slice of integers representing the index of each directory
// entry created.
func (d *Disk) createDirectoryEntries(filename Filename, recordCount int) ([]int, error) {

	var (
		result      []int
		extent      int
		allocations int
	)

	// check that we have room for the directories
	dirEntriesNeeded := d.getDirectoriesNeeded(recordCount)

	if d.getUsedDirectoryCount()+dirEntriesNeeded > DirectoryEntries {
		return result, errors.New("disk is full, no directory space")
	}

	// clear all directory entries that may exist under the same name
	// not strictly necessary but keeps things simple
	d.clearDirectoryEntries(filename)

	// get the total extents for whole file
	extents := int(math.Ceil(float64(recordCount) / RecordsPerExtent))

	// for each dir needed, create the dir

	for entry := 0; entry < dirEntriesNeeded; entry++ {

		nextFreeIndex := d.getNextFreeDirectoryIndex()
		result = append(result, nextFreeIndex)

		// it is the sector data that is written back to the disk.
		dir := &d.DirectoryEntries[nextFreeIndex]

		// set values as appropriate
		dir.Filename = filename
		dir.S1 = 0 // not used
		dir.S2 = 0 // FIXME for files above 512K (based on dirEntriesNeeded maybe?)

		if extents > 4 {

			// more extents to follow
			dir.RC = RecordsPerExtent
			dir.EX = byte(d.extentsPerDirectory - 1 + (entry * 4))
			extent -= d.extentsPerDirectory
			allocations = BlocksPerDirectory

		} else if extents > 0 {

			// last extent
			rc := recordCount % RecordsPerExtent
			if rc == 0 {
				rc = 128
			}
			dir.RC = byte(rc)
			dir.EX = byte(extents - 1 + (entry * 4))
			allocations = d.getBlocksNeeded(recordCount) % BlocksPerDirectory

		} else {
			return result, errors.New("cannot create a file with zero records/extents")
		}

		// allocate the blocks
		dir.Allocations = make([]byte, 16, 16)
		for i := 0; i < allocations; i++ {
			freeBlock := d.getNextFreeBlock()
			dir.Allocations[i] = freeBlock
			d.blockMap[freeBlock] = true
		}

		extents -= d.extentsPerDirectory

	}

	return result, nil
}

func (d *Disk) clearDirectoryEntries(filename Filename) {

	// get directory entries for non-deleted files
	// need to get all non-deleted and all deleted
	for i, entry := range d.DirectoryEntries {
		if entry.Filename.Name+entry.Filename.Extn == strings.ToUpper(filename.Name+filename.Extn) &&
			(entry.Filename.UserArea == filename.UserArea || (filename.UserArea == allAreas)) {
			d.DirectoryEntries[i].clear()
		}
	}
}

// getBlock Returns a specific block
func (d *Disk) getBlock(blockNumber int) []byte {

	var (
		//sectorsPerBlock int
		result []byte
	)

	// blocks start at track 2 (third track) ao we need to work out where the sectors that form the block, start.
	// the first sector is
	startSector := (SectorsPerTrack * 2) + (blockNumber * d.sectorsPerBlock)

	block := d.Sectors[startSector : startSector+d.sectorsPerBlock]

	for _, sect := range block {
		result = append(result, sect.Data...)
	}

	return result
}

/*
func (d *Disk) setBlock(blockNumber int, data []byte) error {

	// TODO we need to work out the directory to update and update it asa appropriate

	if len(data) != d.sectorsPerBlock*BytesPerSector {
		return errors.New("data is not equal to the block size")
	}

	startSector := (SectorsPerTrack * 2) + (blockNumber * d.sectorsPerBlock)
	block := d.Sectors[startSector : startSector+d.sectorsPerBlock]

	print(len(block))

	// TODO: loop through bytes in associated sectors adding data ??

	return nil
}
*/

func (d *Disk) getDirectoriesNeeded(recordCount int) int {

	// 32k per dir entry for DDDS 64k for QDDS
	// 32K = 256 records
	// 64K = 512 records
	blocksNeeded := float64(d.getBlocksNeeded(recordCount))
	return int(math.Ceil(blocksNeeded / BlocksPerDirectory))
}

func (d *Disk) getBlocksNeeded(recordCount int) int {
	return int(math.Ceil(float64(recordCount*RecordSize) / float64(d.blockSize)))
}

func (d *Disk) getNextFreeDirectoryIndex() int {
	var result int
	for i, entry := range d.DirectoryEntries {
		if entry.Filename.UserArea == deleteByte {
			return i
		}
	}
	return result
}

func (d *Disk) getUsedDirectoryCount() int {

	var result int

	for _, entry := range d.DirectoryEntries {
		if entry.Filename.UserArea != deleteByte {
			result++
		}
	}
	return result
}

// getNextFreeBlock
func (d *Disk) getNextFreeBlock() byte {

	// get next free block
	var freeBlock byte

	// loop from 0 to final block on the disk
	for freeBlock = 0; freeBlock < d.lastBlock; freeBlock++ {

		// if not in the map then it's free!
		if !d.blockMap[freeBlock] {
			break
		}

	}

	// make sure we didn't reach the end of the loop without finding a free block
	if !d.blockMap[freeBlock] {
		return freeBlock
	} else {
		return 0
	}
}

func (d *Disk) getDirectory() []byte {

	var result []byte

	//directory is first 4k of data i.e. start of third track (2)
	sects := d.Sectors[20:28]

	// convert to a byte slice
	for _, s := range sects {
		result = append(result, s.Data...)
	}
	return result
}

func (d *Disk) initDisk() {

	if d.Qdds {
		// create the block Map and mark the directory block as used
		d.blockMap = make(map[byte]bool, QddsDataBlocks)
		d.blockMap[0] = true
		d.lastBlock = QddsDataBlocks - 1
		d.blockSize = QddsBlockSize
		d.sectorsPerBlock = 8

	} else {
		// create the block Map and mark the two directory blocks as used
		d.blockMap = make(map[byte]bool, DddsDataBlocks)
		d.blockMap[0] = true
		d.blockMap[1] = true
		d.lastBlock = DddsDataBlocks - 1
		d.blockSize = DddsBlockSize
		d.sectorsPerBlock = 4
	}

	d.recordsPerDirectory = d.blockSize * BlocksPerDirectory / 128
	d.extentsPerDirectory = d.recordsPerDirectory / RecordsPerExtent
}
