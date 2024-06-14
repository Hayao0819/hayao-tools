package buildtools

import (
	"os"
	"path"

	"github.com/Hayao0819/nahi/futils"
	cp "github.com/otiai10/copy"
)

func Run(target string, out string) error {
	if target == "" {
		return nil
	}

	stat, err := os.Stat(target)
	if err != nil {
		return err
	}

	if stat.IsDir() {
		return runDir(target, out)
	} else {
		return runFile(target, out)
	}

}

func runDir(target string, out string) error {
	if futils.Exists(path.Join(target, "CMakeLists.txt")) {
		return buildCmake(target)
	}
	if futils.Exists(path.Join(target, "Makefile")) {
		return buildMake(target)
	}

	if futils.Exists(path.Join(target, "go.mod")) {
		return buildGo(target, out)
	}

	return nil
}
func runFile(target string, out string) error {
	base := path.Base(target)
	ext := path.Ext(target)
	if base == "CMakeLists.txt" {
		return buildCmake(path.Dir(target))
	}

	if ext == ".c" {
		return buildC(target, out)
	}

	if ext == ".py" {
		cp.Copy(target, out)
	}

	return nil
}
