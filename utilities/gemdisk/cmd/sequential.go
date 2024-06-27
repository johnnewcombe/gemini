package cmd

import (
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

var sequentialCmd = &cobra.Command{
	Use:   "sequential",
	Short: "Creates a sequential image from an interleaved one.",
	Long:  `Creates a sequential image from an interleaved one. Note that the reported track and sector numbers will always reflect the original disk layout.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage, outputDiskImage string
			dsk                             disk.Disk
			data                            []byte
			err                             error
		)

		if inputDiskImage, err = cmd.Flags().GetString("input-file"); err != nil {
			return err
		}

		if outputDiskImage, err = cmd.Flags().GetString("input-file"); err != nil {
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

		dsk.Sequential()

		// update disk image on the host
		if len(outputDiskImage) ==0{
			outputDiskImage=inputDiskImage
		}
		if err := ioutil.WriteFile(outputDiskImage, dsk.ToBytes(), 0644); err != nil {
			return err
		}


		return nil
	},
}
