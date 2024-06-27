package disk

import (
	"io/ioutil"
	"testing"
)

func Test_ReadFile(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_WriteFile(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_DeleteFile(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_UnDeleteFile(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_ListFiles(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_Dump(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_Interleave(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_Sequential(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_ToBytes(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_FreeBlockCount(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_UsedBlockCount(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_GetDirectoryEntries(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_GetFileNames(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_GetFileSize(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_getSectorIndexForBlock(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests:=[]Test{
		{"",0,0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_createDirectoryEntries(t *testing.T) {
	/*
		file:= make([]byte,128,128)
		ioutil.WriteFile("1-BLK.BIN",file,fs.ModePerm)

		file= make([]byte,128*128,128*128)
		ioutil.WriteFile("128-BLK.BIN",file,fs.ModePerm)

		file= make([]byte,129*128,129*128)
		ioutil.WriteFile("129-BLK.BIN",file,fs.ModePerm)

		file= make([]byte,1222*128,1222*128)
		ioutil.WriteFile("1222-BLK.BIN",file,fs.ModePerm)


	*/

	const (
		filename = "MYTESTFILE"
		extn     = "TXT"
	)

	var (
		dsk    Disk
		err    error
		result []int
	)

	if dsk, err = loadDisk("../MYDISK.IMG"); err != nil {
		t.Errorf(testErrorMessage, "Disk load fail.")
	}

	type Test struct {
		description      string
		input            Filename
		inputRecordCount int
		want             []DirectoryEntry
		wantAllocated    int
	}
	tests := []Test{

		{"Record Count = 1", Filename{7, filename, extn}, 1,
			[]DirectoryEntry{
				{Filename{7, filename, extn}, 0, 0, 0, 1,
					[]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
			},1},
		// ------------------------------------------------------------
		// Result from actual directory entry 1-BLK.BIN on QDDS Disk
		// ------------------------------------------------------------
		// 00 31 2D 42 4C 4B 20 20 20 42 49 4E 00 00 00 01
		// nn 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		// ------------------------------------------------------------

		{"Record Count = 128", Filename{7, filename, extn}, 128,
			[]DirectoryEntry{
				{Filename{7, filename, extn}, 0, 0, 0, 0x80,
					[]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
			}, 4},
		// ------------------------------------------------------------
		// Result from actual directory entry 128-BLK.BIN on QDDS Disk
		// ------------------------------------------------------------
		// 00 31 32 38 2D 42 4C 4B 20 42 49 4E 00 00 00 80
		// nn nn nn nn 00 00 00 00 00 00 00 00 00 00 00 00
		// ------------------------------------------------------------

		{"Record Count = 129", Filename{7, filename, extn}, 129,
			[]DirectoryEntry{
				{Filename{7, filename, extn}, 1, 0, 0, 1,
					[]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
			},5},
		// ------------------------------------------------------------
		// Result from actual directory entry 129-BLK.BIN on QDDS Disk
		// ------------------------------------------------------------
		// 00 31 32 39 2D 42 4C 4B 20 42 49 4E 01 00 00 01
		// nn nn nn nn nn 00 00 00 00 00 00 00 00 00 00 00

		{"Record Count = 1222", Filename{7, filename, extn}, 1222,
			[]DirectoryEntry{
				{Filename{7, filename, extn}, 3, 0, 0, 0x80,
					[]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
				{Filename{7, filename, extn}, 7, 0, 0, 0x80,
					[]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
				{Filename{7, filename, extn}, 9, 0, 0, 0x46,
					[]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
			},39},
		// ------------------------------------------------------------
		// Result from actual directory entry 1222-BLK.BIN on QDDS Disk
		// ------------------------------------------------------------
		// 00 31 32 32 32 2D 42 4C 4B 42 49 4E 03 00 00 80
		// nn nn nn nn nn nn nn nn nn nn nn nn nn nn nn nn

		// 00 31 32 32 32 2D 42 4C 4B 42 49 4E 07 00 00 80
		// nn nn nn nn nn nn nn nn nn nn nn nn nn nn nn nn

		// 00 31 32 32 32 2D 42 4C 4B 42 49 4E 09 00 00 46
		// nn nn nn nn nn nn nn 00 00 00 00 00 00 00 00 00
		// ------------------------------------------------------------

	}

	for _, test := range tests {

		if result, err = dsk.createDirectoryEntries(test.input, test.inputRecordCount); err != nil {
			t.Errorf(testErrorMessage, test.description)
		}

		allocated:=0
		for i, r := range result {
			if !dsk.DirectoryEntries[r].CompareTo(test.want[i], true) {
				t.Errorf(testErrorMessage, test.description)
			}

			// check allocations determine how many are not 0
			for i := 0; i < 16; i++ {
				if dsk.DirectoryEntries[r].Allocations[i] != 0 {
					allocated++
				}
			}
		}
		if allocated != test.wantAllocated{
			t.Errorf(testErrorMessage, test.description)
		}
	}
}

func Test_clearDirectoryEntries(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_GetBlock(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_getDirectoriesNeeded(t *testing.T) {

	var (
		dsk Disk
		err error
	)

	if dsk, err = loadDisk("../MYDISK.IMG"); err != nil {
		t.Errorf(testErrorMessage, "Disk load fail.")
	}

	type Test struct {
		description      string
		inputRecordCount int
		wantDirCount     int
	}

	// 32k per dir entry for DDDS disks, 64k for QDDS disks
	// 32K = 256 records
	// 64K = 512 records

	tests := []Test{
		{"1 Directory", 1, 1},
		{"2 Directories", 129, 1},
		{"4 Directories", 513, 2},
	}

	for _, test := range tests {
		if got := dsk.getDirectoriesNeeded(test.inputRecordCount); got != test.wantDirCount {
			t.Errorf(testErrorMessage, test.description)
		}
	}
}

func Test_getBlocksNeeded(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_getNextFreeBlock(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_getDirectory(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func Test_getNextFreeDirectory(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests := []Test{
		{"", 0, 0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

func loadDisk(filename string) (Disk, error) {

	var (
		dsk  Disk
		data []byte
		err  error
	)

	// open binary file
	if data, err = ioutil.ReadFile(filename); err != nil {
		return dsk, err
	}

	// open binary file
	if err = dsk.LoadDiskImage(data); err != nil {
		return dsk, err
	}

	return dsk, nil
}

/*
func Test_ExampleTemplate(t *testing.T) {

	type Test struct {
		description string
		input       int
		want        int
	}
	tests:=[]Test{
		{"",0,0},
	}

	for _, test := range tests {
		t.Errorf(testErrorMessage, test.description)
	}
}

*/
