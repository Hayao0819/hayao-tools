package gistrge

type GistrgeList []*Gistrge

func (list GistrgeList) Find(target string) (*Gistrge, error) {
	for _, item := range list {
		if *item.gist.ID == target || item.Description == target {
			return item, nil
		}

	}
	return nil, nil
}
