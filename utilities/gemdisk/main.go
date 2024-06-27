package main

import (
	_ "embed"
	"gemdisk/cmd"
	"os"
)




func main() {

	//fmt.Printf("%d\r\n",len(biosFW35_sys))
	//fmt.Printf("%d\r\n",len(format_com))


	cmd.Execute()
	os.Exit(0)
}

