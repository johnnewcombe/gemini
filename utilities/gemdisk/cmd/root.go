package cmd

import (
	_ "embed"
	"fmt"
	"gemdisk/globals"
	"github.com/spf13/cobra"
	"os"
)

const (
	inputFile      = "Input disk image filename."
	outputFile     = "Output disk image filename."
	dumpFile       = "File on the disk image to dump."
	readFilename   = "File on the disk image to be copied to the local file system. If an asterisk is used as the source filename then all files will be copied."
	writeFilename  = "File on the local host to be copied to the disk image."
	deleteFilename = "File on the disk image to be deleted."
	readTextMode   = "Will cause files of type .TXT, .DOC, .LST, .MAC, .ASM, .SUB and .CFG to be truncated at the first Ctrl Z character."
	writeTextMode  = "Will ensure files of type .TXT, .DOC, .LST, .MAC, .ASM, .SUB and .CFG have a terminating Ctrl Z character and CP/M line endings."
	qdds           = "Gemini DDDS format. If this is not specified, Gemini QDDS format is assumed."
)

// Note that bios's recovered from QDDS disks(sequential)  cant be used on DDDS disks
// without first interleaving the system data.

// ******************************************************
// Bios 3.5
// ******************************************************
//go:embed "embedded/bios35.bin"
var BiosFW35_sys []byte

// ******************************************************
// Bios 1.4
// ******************************************************
//go:embed "embedded/bios14.bin"
var BiosF14_sys []byte

// ******************************************************
// FORMAT.COM
// ******************************************************
// This is the version that does all bios 3 formats and
// supersedes the one supplied with 3.2
//go:embed "embedded/FORMAT.COM"
var Format_com []byte

func init() {

	rootCmd.AddCommand(listCmd)
	rootCmd.AddCommand(dumpCmd)
	rootCmd.AddCommand(interleavedCmd)
	rootCmd.AddCommand(sequentialCmd)
	rootCmd.AddCommand(dumpFileCmd)
	rootCmd.AddCommand(readFileCmd)
	rootCmd.AddCommand(writeFileCmd)
	rootCmd.AddCommand(deleteFileCmd)
	rootCmd.AddCommand(sysgenCmd)
	rootCmd.AddCommand(newCmd)
	rootCmd.AddCommand(versionCmd)

	// list
	listCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	listCmd.MarkPersistentFlagRequired("input-file")

	// dump
	dumpCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	dumpCmd.MarkPersistentFlagRequired("input-file")

	// interleaved
	interleavedCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	interleavedCmd.MarkPersistentFlagRequired("input-file")
	interleavedCmd.PersistentFlags().StringP("output-file", "o", "", outputFile)
	interleavedCmd.MarkPersistentFlagRequired("output-file")

	// sequential
	sequentialCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	sequentialCmd.MarkPersistentFlagRequired("input-file")
	sequentialCmd.PersistentFlags().StringP("output-file", "o", "", outputFile)
	sequentialCmd.MarkPersistentFlagRequired("output-file")

	// dump-file
	dumpFileCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	dumpFileCmd.MarkPersistentFlagRequired("input-file")
	dumpFileCmd.PersistentFlags().StringP("filename", "f", "", dumpFile)
	dumpFileCmd.MarkPersistentFlagRequired("filename")

	// read-file
	readFileCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	readFileCmd.MarkPersistentFlagRequired("input-file")
	readFileCmd.PersistentFlags().StringP("filename", "f", "", readFilename)
	readFileCmd.MarkPersistentFlagRequired("filename")
	readFileCmd.PersistentFlags().BoolP("text-mode", "t", false, readTextMode)

	// write-file
	writeFileCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	writeFileCmd.MarkPersistentFlagRequired("input-file")
	writeFileCmd.PersistentFlags().StringP("output-file", "o", "", outputFile)
	writeFileCmd.PersistentFlags().StringP("filename", "f", "", writeFilename)
	writeFileCmd.MarkPersistentFlagRequired("filename")
	writeFileCmd.PersistentFlags().BoolP("text-mode", "t", false, writeTextMode)

	// delete-file
	deleteFileCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	deleteFileCmd.MarkPersistentFlagRequired("input-file")
	deleteFileCmd.PersistentFlags().StringP("output-file", "o", "", outputFile)
	deleteFileCmd.PersistentFlags().StringP("filename", "f", "", deleteFilename)
	deleteFileCmd.MarkPersistentFlagRequired("filename")

	// sysgen
	sysgenCmd.PersistentFlags().StringP("input-file", "i", "", inputFile)
	sysgenCmd.MarkPersistentFlagRequired("input-file")
	sysgenCmd.PersistentFlags().StringP("output-file", "o", "", outputFile)

	// new
	newCmd.PersistentFlags().BoolP("ddds", "", false, qdds)
	newCmd.PersistentFlags().StringP("output-file", "o", "", outputFile)
	newCmd.MarkPersistentFlagRequired("output-file")

}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		// TODO maybe sanitise the output unless the debug flag is set
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

var rootCmd = &cobra.Command{
	Use:   "gemdisk",
	Short: "Gemini QDDS and DDDS Disk Utility Version " + globals.Version,
	Long:  `Gemini QDDS and DDDS Disk Utility`,
}
