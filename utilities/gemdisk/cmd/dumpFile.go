package cmd

import (
	"encoding/hex"
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

var dumpFileCmd = &cobra.Command{
	Use:   "dump-file",
	Short: "Dump a file contents to the console in hex/ascii.",
	Long:  `Dump a file contents to the console in hex/ascii.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage, fileName string
			fn                       disk.Filename
			dsk                      disk.Disk
			bytes                    []byte
			data                     []byte
			err                      error
		)

		if inputDiskImage, err = cmd.Flags().GetString("input-file"); err != nil {
			return err
		}

		if fileName, err = cmd.Flags().GetString("filename"); err != nil {
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

		if fn, err = disk.ParseFilename(fileName); err != nil {
			return err
		}

		if bytes, err = dsk.ReadFile(fn); err != nil {
			return err
		}

		print(hex.Dump(bytes))

		return nil
	},
}
