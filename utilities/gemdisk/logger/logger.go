package logger

import (
	"log"
	"os"
)

var (
	LogInfo  *log.Logger
	LogWarn  *log.Logger
	LogError *log.Logger
)

func init() {

	output := os.Stdout

	LogInfo = log.New(output, "INFO:    ", log.Ldate|log.Ltime)
	LogWarn = log.New(output, "WARNING: ", log.Ldate|log.Ltime)
	LogError = log.New(output, "ERROR:   ", log.Ldate|log.Ltime|log.Lshortfile)
}
