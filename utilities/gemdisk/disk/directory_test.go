package disk

import "testing"

const (
	testErrorMessage = "Test Description: \"%s.\""
)

func Test_clear(t *testing.T) {

	var (
		input DirectoryEntry
	)

	// create a simple directory
	input = createDirectory(make([]byte, 16, 16))

	// clear the directory
	input.clear()

	// get the directory as bytes
	got := input.ToBytes()

	// check the length
	if len(got) != 32 {
		t.Errorf(testErrorMessage, "clear")
	}

	// ensure that all bytes are e5
	for _, b := range got {
		if b != 0xe5 {
			t.Errorf(testErrorMessage, "clear")
		}
	}
}

func Test_String(t *testing.T) {

}

func Test_SetAllocationBlock(t *testing.T) {

	type Test struct {
		description     string
		input           DirectoryEntry
		inputBlockIndex int
		inputBlock      byte
		want            byte
	}
	var tests = []Test{

		{"Allocation 8", DirectoryEntry{
			Filename:    Filename{UserArea: 0, Name: "MYFILE.COM", Extn: "COM"},
			EX:          2, // 3 extents e.g. 3*16K
			S1:          0,
			S2:          1, // Number of 512K blocks (i.e. multiples of 31 extents).
			RC:          2, // two records used in last extent
			Allocations: []byte{1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0}},
			8, 0x7f, 0x7f},
		{"Allocation 10", DirectoryEntry{
			Filename:    Filename{UserArea: 0, Name: "MYFILE.COM", Extn: "COM"},
			EX:          2, // 3 extents e.g. 3*16K
			S1:          0,
			S2:          0, // Number of 512K blocks (i.e. multiples of 31 extents).
			RC:          2, // two records used in last extent
			Allocations: []byte{1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0}},
			10, 0x00, 0x00},
	}
	for _, test := range tests {
		test.input.SetAllocationBlock(test.inputBlockIndex, test.inputBlock)
		if test.input.Allocations[test.inputBlockIndex] != test.want {
			t.Errorf(testErrorMessage, test.description)
		}

	}
}

func Test_SetNextEmptyAllocationBlock(t *testing.T) {

	type Test struct {
		description    string
		input          DirectoryEntry
		inputBlock     byte
		want           byte
		wantBlockIndex int
	}
	var tests = []Test{

		{"Allocation 8", DirectoryEntry{
			Filename:    Filename{UserArea: 0, Name: "MYFILE.COM", Extn: "COM"},
			EX:          2, // 3 extents e.g. 3*16K
			S1:          0,
			S2:          1, // Number of 512K blocks (i.e. multiples of 31 extents).
			RC:          2, // two records used in last extent
			Allocations: []byte{1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0}},
			0x7f, 0x7f, 8},
		{"Allocation 10", DirectoryEntry{
			Filename:    Filename{UserArea: 0, Name: "MYFILE.COM", Extn: "COM"},
			EX:          2, // 3 extents e.g. 3*16K
			S1:          0,
			S2:          0, // Number of 512K blocks (i.e. multiples of 31 extents).
			RC:          2, // two records used in last extent
			Allocations: []byte{1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0}},
			0x01, 0x01, 9},
	}
	for _, test := range tests {
		if got, err := test.input.SetNextEmptyAllocationBlock(test.inputBlock); got != test.wantBlockIndex ||
			test.input.Allocations[test.wantBlockIndex] != test.want ||
			err != nil {
			t.Errorf(testErrorMessage, test.description)

		}
	}
}

func createDirectory(allocations []byte) DirectoryEntry {

	return DirectoryEntry{
		Filename: Filename{
			UserArea: 0,
			Name:     "MYFILE.COM",
			Extn:     "COM"},
		EX:          2, // 3 extents e.g. 3*16K
		S1:          0,
		S2:          1, // Number of 512K blocks (i.e. multiples of 31 extents).
		RC:          2, // two records used in last extent
		Allocations: allocations}

}
