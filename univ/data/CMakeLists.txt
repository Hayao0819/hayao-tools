cmake_minimum_required(VERSION 3.13)
project({{.Name}} CXX)

add_executable(
    {{.Name}}
    {{.Files}}
)

