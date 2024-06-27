package disk


type Filename struct {
	UserArea       byte
	Name           string
	Extn           string
}

func (f *Filename) FullName() string {
	return f.Name + "." + f.Extn
}

func (f *Filename) CompareTo(filename Filename) bool {
	return f.Name == filename.Name && f.Extn== filename.Extn && f.UserArea == filename.UserArea
}
