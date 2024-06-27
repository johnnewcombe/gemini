package disk

type Sector struct {
	SideNumber           int
	TrackNumber          int
	SectorNumber         int
	Data                 []byte
	PhysicalSectorNumber int
}

/*
// New returns a freshly formatted sector
func NewSector() Sector{
	var(
		result Sector
	)
	for i:=0;i<BytesPerSector;i++{
		result.Data=append(result.Data, 0xe5)
	}
	return result
}

*/