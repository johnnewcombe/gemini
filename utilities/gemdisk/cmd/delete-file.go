package cmd

import (
	"gemdisk/disk"
	"gemdisk/logger"
	"github.com/spf13/cobra"
	"io/ioutil"
	"os"
	"strings"
)

var deleteFileCmd = &cobra.Command{
	Use:   "delete-file",
	Short: "Deletes a file from the disk image.",
	Long:  `Deletes a file from the disk image.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage string
			outputDiskImage     string
			filenameS      string
			fn             disk.Filename
			dsk            disk.Disk
			err            error
			data           []byte
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

		if filenameS, err = cmd.Flags().GetString("filename"); err != nil {
			return err
		}

		// convert back to CP/M filename
		filenameS = strings.Replace(filenameS, "__", "/", -1)
		filenameS = strings.ToUpper(filenameS)

		if fn, err = disk.ParseFilename(filenameS); err != nil {
			logger.LogError.Printf("%v", err)
			os.Exit(1)
		}

		for _, filename := range dsk.GetFilenames() {
			if fn.Name+fn.Extn == filename.Name+fn.Extn && fn.UserArea == filename.UserArea {
				dsk.DeleteFile(filename)
			}
		}

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
