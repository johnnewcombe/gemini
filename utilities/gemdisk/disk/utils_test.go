package disk

import "testing"

func Test_asciiUpper(t *testing.T) {

	type Test struct {
		description string
		input       string
		want        string
	}

	tests:=[]Test{
		{"","hello world","HELLO WORLD"},
		{"","hello\xe5world","HELLO\xe5WORLD"},
	}

	for _, test := range tests {
		if got := asciiUpper(test.input); got != test.want {
			t.Errorf(testErrorMessage, test.description)
		}
	}
}


func Test_trim(t *testing.T) {

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