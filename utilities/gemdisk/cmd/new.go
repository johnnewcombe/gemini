package cmd

import (
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

// TODO Add DDDS Support

var newCmd = &cobra.Command{
	Use:   "new",
	Short: "Creates a new disk image.",
	Long:  `Creates a new disk image.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			outputDiskImage string
			dsk             disk.Disk
			data            []byte
			ddds            bool
			diskSize        int
			err             error
		)

		if outputDiskImage, err = cmd.Flags().GetString("output-file"); err != nil {
			return err
		}

		if ddds, err = cmd.Flags().GetBool("ddds"); err != nil {
			return err
		}

		if ddds {
			//data = make([]byte,disk.DDDSSize)
			diskSize = disk.DDDSSize
		} else {
			//data = make([]byte,disk.QDDSSize)
			diskSize = disk.QDDSSize
		}

		// format the disk
		for d := 0; d <diskSize;d++{
			data = append(data, 0xe5)
		}

		// load and initialise the disk
		if err = dsk.LoadDiskImage(data); err != nil {
			return err
		}



		// update disk image on the host
		if err := ioutil.WriteFile(outputDiskImage, dsk.ToBytes(), 0644); err != nil {
			return err
		}

		return nil
	},
}
