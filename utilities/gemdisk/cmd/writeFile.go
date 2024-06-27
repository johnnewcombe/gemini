package cmd

import (
	"gemdisk/disk"
	"gemdisk/logger"
	"github.com/spf13/cobra"
	"io/ioutil"
	"os"
	"strings"
)

var writeFileCmd = &cobra.Command{
	Use:   "write-file",
	Short: "Writes a file from the local file system to the disk image.",
	Long:  `Writes a file from the local file system to the disk image.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage  string
			outputDiskImage string
			fileName        string
			fn              disk.Filename
			dsk             disk.Disk
			textMode        bool
			bytes           []byte
			data            []byte
			err             error
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

		if fileName, err = cmd.Flags().GetString("filename"); err != nil {
			return err
		}

		if textMode, err = cmd.Flags().GetBool("text-mode"); err != nil {
			return err
		}

		if bytes, err = readFileFromHost(fileName, textMode); err != nil {
			logger.LogError.Printf("%v", err)
			os.Exit(1)
		}

		// convert back to CP/M filename
		fileName = strings.Replace(fileName, "__", "/", -1)
		fileName = strings.ToUpper(fileName)

		if fn, err = disk.ParseFilename(fileName); err != nil {
			logger.LogError.Printf("%v", err)
			os.Exit(1)
		}

		if err := dsk.WriteFile(fn, bytes); err != nil {
			return err
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
