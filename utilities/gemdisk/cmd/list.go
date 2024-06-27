package cmd

import (
	"fmt"
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "List all files from all user areas on the disk.",
	Long:  `List all files from all user areas on the disk.`,
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

		fmt.Printf("\r\n\r\nDIRECTORY LISTING FOR %s.\r\n", inputDiskImage)
		fmt.Print(dsk.ListFiles())

		return nil
	},
}
