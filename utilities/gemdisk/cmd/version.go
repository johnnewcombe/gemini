package cmd

import (
	"fmt"
	"gemdisk/globals"
	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Displays the program version.",
	Long:  `Displays the program version.`,
	RunE: func(cmd *cobra.Command, args []string) error {

			fmt.Printf("\r\nGemDisk Disk Utility (c) John Newcombe 2022, Version %s.\r\n\r\n", globals.Version)
			return nil
	},
}

