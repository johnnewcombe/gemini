package disk

import (
	"errors"
	"path"
	"regexp"
	"strconv"
	"strings"
)

func GetChunks(data []byte, chunkSize int) [][]byte {

	var chunks [][]byte
	for i := 0; i < len(data); i += chunkSize {
		end := i + chunkSize

		// necessary check to avoid slicing beyond
		// slice capacity
		if end > len(data) {
			end = len(data)
		}

		chunks = append(chunks, data[i:end])
	}

	return chunks
}

func trim(s string) string {

	return asciiUpper(strings.Trim(s, " "))

}

func asciiUpper(s string) string {

	bytes := []byte(s)

	for i:=0;i<len(bytes);i++{
		if bytes[i] >96 && bytes[i] < 123 {
			bytes[i] -= 32
		}
	}

	return string(bytes)
}

func FileNameWithoutExtension(fileName string) string {

	if pos := strings.LastIndexByte(fileName, '.'); pos != -1 {
		fileName = fileName[:pos]
	}
	return TruncateText(fileName, 8)
}

func FileExtension(filename string) string {
	return TruncateText(strings.Trim(path.Ext(filename), "."), 3)
}

func IsTextFile(filename string) bool {

	extn := path.Ext(filename)

	// text files tend to end or be be padded with Ctrl Z char
	if extn == ".TXT" || extn == ".DOC" || extn == ".LST" || extn == ".MAC" ||
		extn == ".ASM" || extn == ".SUB" || extn == ".CFG" || extn == ".ME" || extn == ".PAS" {

		return true
	}

	return false
}

func TruncateText(s string, max int) string {
	if len(s) > max {
		return s[:max]
	} else {
		return s
	}
}


func ParseFilename(filename string) (Filename, error) {

	var (
		userArea int
		err      error
		result   Filename
	)

	// need to account for a full directory path!
	_, filename = path.Split(filename)
	filename = strings.TrimLeft(filename, "[")

	re := regexp.MustCompile("^[0-9]*.]\\S{1,8}?\\.?\\S{0,3}$")

	// check for [user area]Filename i.e. file on the disk with a user area specified
	if re.MatchString(filename) {
		fu := strings.Split(filename, "]")

		if userArea, err = strconv.Atoi(fu[0]); err != nil {
			return result, errors.New("unable to match Filename")
		}
		result.Extn = FileExtension(fu[1])
		result.Name = FileNameWithoutExtension(fu[1])
		result.UserArea = byte(userArea)

	} else {
		// check whether this ia a file without a user area
		re = regexp.MustCompile("^[0-9]*\\S{1,8}?\\.?\\S{0,3}$")
		if re.MatchString(filename) {
			result.Extn = FileExtension(filename)
			result.Name = FileNameWithoutExtension(filename)
			result.UserArea = 0
		} else {
			return result, errors.New("invalid Filename")
		}

	}

	/* we need to consider what to do with invalid chars e.g.
	  	"< > . , ; : = ? * [ ] % | ( ) / \"
		 note that other 'new' keyboard chars need to be considered e.g. the Euro symbol.
	*/
	re = regexp.MustCompile("[<>.,;:=?*[\\] ]")
	if re.MatchString(result.Name) || re.MatchString(result.Extn) {
		return result, errors.New("invalid Filename")
	}

	// ok so far but all chars need to be between 0x20 and 0x7f
	for _, r := range []rune(result.Name) {
		if r < 0x20 || r > 0x7f {
			return result, errors.New("invalid Filename")
		}
	}

	return result, nil

}
