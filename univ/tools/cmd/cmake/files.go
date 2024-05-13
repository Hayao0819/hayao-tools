package cmake

import (
	"github.com/Hayao0819/nahi/flist"
)

func getCFiles(src string) (*[]string, error) {
	files, err := flist.Get(src, flist.WithFileOnly(), flist.WithExtOnly(".c"))
	if err != nil {
		return nil, err
	}

	return files, nil
}
