package cmd

import (
	"fmt"
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

var dumpCmd = &cobra.Command{
	Use:   "dump",
	Short: "Dump the disk image contents to the console in hex/ascii.",
	Long:  `Dump the disk image contents to the console in hex/ascii.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage string
			dsk            disk.Disk
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

		fmt.Print(dsk.Dump())

		return nil
	},
}
