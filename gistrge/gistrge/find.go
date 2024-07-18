package gistrge

func Find(list []*Gistrge, target string) (*Gistrge, error) {
	for _, item := range list {
		if *item.Gist.ID == target {
			return item, nil
		}

		if item.Description == target {
			return item, nil
		}
	}
	return nil, nil
}
