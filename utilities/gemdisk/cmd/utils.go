package cmd

import (
	"bytes"
	"gemdisk/disk"
	"io/ioutil"
)


func writeFileToHost(filename string, data []byte, textMode bool) error {

	// text files tend to end or be be padded with Ctrl Z char
	if textMode && disk.IsTextFile(filename) {

		// only up to  CtrlZ (0x1f)
		index := bytes.IndexByte(data, 0x1a)
		data = data[:index]
	}

	if err := ioutil.WriteFile(filename, data, 0644); err != nil {
		return err
	}

	return nil
}

func readFileFromHost(filename string, textMode bool) ([]byte, error) {

	var (
		data []byte
		err  error
	)

	// FIXME Is this needed anymore?
	//if textMode && disk.IsTextFile(filename) {
	//} else {
	//}

	data, err = ioutil.ReadFile(filename)

	return data, err
}