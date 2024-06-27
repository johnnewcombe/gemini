package cmd

import (
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

var interleavedCmd = &cobra.Command{
	Use:   "interleaved",
	Short: "Creates an interleaved image from a sequential one.",
	Long:  `Creates an interleaved image from a sequential one. Note that the reported track and sector numbers will always reflect the original disk layout.`,
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

		if outputDiskImage, err = cmd.Flags().GetString("output-file"); err != nil {
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

		dsk.Interleave()

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
