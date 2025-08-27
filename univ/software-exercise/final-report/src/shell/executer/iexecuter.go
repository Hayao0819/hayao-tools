package executer

type Executer interface {
	Exec(argv []string, ioctx IOContext) (int, error)
}
