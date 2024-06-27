package cmd

import (
	"fmt"
	"gemdisk/disk"
	"gemdisk/logger"
	"github.com/spf13/cobra"
	"io/ioutil"
	"os"
	"strings"
)

var readFileCmd = &cobra.Command{
	Use:   "read-file",
	Short: "Reads a file from the disk image to the local file system.",
	Long:  `Reads a file from the disk image to the local file system. If an asterisk is used as the source filename then all files will be copied.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage string
			fileName       string
			dsk            disk.Disk
			textMode       bool
			data           []byte
			err            error
		)

		if inputDiskImage, err = cmd.Flags().GetString("input-file"); err != nil {
			return err
		}

		// open binary file
		if data, err = ioutil.ReadFile(inputDiskImage); err != nil {
			return err
		}

		// load and initialise the disk
		if err = dsk.LoadDiskImage(data); err != nil {
			return err
		}

		if fileName, err = cmd.Flags().GetString("filename"); err != nil {
			return err
		}

		if textMode, err = cmd.Flags().GetBool("text-mode"); err != nil {
			return err
		}

		if fileName == "*" {

			for _, filename := range dsk.GetFilenames() {
				readFile(dsk, filename.FullName(), textMode)
			}

		} else {

			readFile(dsk, fileName, textMode)
		}

		return nil
	},
}

func readFile(dsk disk.Disk, filename string, textMode bool) {

	var (
		bytes        []byte
		hostFilename string
		fn           disk.Filename
		err          error
	)

	if fn, err = disk.ParseFilename(filename); err != nil {
		logger.LogError.Printf("%v", err)
		os.Exit(1)
	}

	if bytes, err = dsk.ReadFile(fn); err != nil {
		logger.LogError.Printf("%v", err)
		os.Exit(1)
	}

	// tidy up the filename
	hostFilename = strings.ReplaceAll(fn.FullName(), "/", "__")
	hostFilename = strings.Trim(hostFilename, ".")
	hostFilename = strings.ToUpper(hostFilename)

	if err = writeFileToHost(fmt.Sprintf("[%02d]%s", fn.UserArea, hostFilename), bytes, textMode); err != nil {
		logger.LogError.Printf("%v", err)
		os.Exit(1)
	}
}
