package cmd

import (
	"gemdisk/disk"
	"github.com/spf13/cobra"
	"io/ioutil"
)

var sysgenCmd = &cobra.Command{
	Use:   "sys-gen",
	Short: "Adds CP/M to the system tracks.",
	Long:  `Create a bootable image using Gemini CP/M (Bios 3.5). The system will be configured for three floppy drives QDDS,QDDS and DDDS.`,
	RunE: func(cmd *cobra.Command, args []string) error {

		var (
			inputDiskImage  string
			outputDiskImage string
			dsk             disk.Disk
			data            []byte
			systemSectors   [][]byte
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

		// Note that bios's recovered from QDDS disks(sequential) cant be used on DDDS disks
		// I can only assume that the code requests a certain side/sector combination before
		// CP/M is loaded.
		if dsk.Qdds {
			systemSectors = disk.GetChunks(BiosFW35_sys, 512)
		} else {
			systemSectors = disk.GetChunks(BiosF14_sys, 512)
		}
		for i := 0; i < disk.SectorsPerTrack*disk.SystemTracks; i++ {
			dsk.Sectors[i].Data = systemSectors[i]
		}

		// update disk image on the host
		if len(outputDiskImage) == 0 {
			outputDiskImage = inputDiskImage
		}
		if err := ioutil.WriteFile(outputDiskImage, dsk.ToBytes(), 0644); err != nil {
			return err
		}

		return nil
	},
}
