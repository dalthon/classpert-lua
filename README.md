# Classpert's Lua Docker Image

This docker image and repository are prepared to follow [Classpert](https://classpert.com/)'s
course [Building a Programming Language](https://classpert.com/classpertx/courses/building-a-programming-language/cohort).

It is based on Alpine linux and contains:

* lua (5.4.4)
* luarocks
* lpeg
* luaunit

## Usage

All you need installed is `docker`, `make` and `awk` (optional) regardless
your OS.

Once you have them, everything is controlled by make tasks, so you need to
build image with `make build`, then everything is set.

### Help

Show all available make tasks and help.

```sh
make help
```

Or just

```sh
make
```

### Run interactive lua

```sh
make lua
```

### Run shell inside container

```sh
make shell
```

### Run lessons

If you wish to follow this repo's convention of keeping lessons inside folder
`lessons` in files like: `lesson/lesson_01/02_something.lua`, you can run it
with:

```sh
make lesson-01-02
```

### Build Image

```sh
make build
```

## Disclaimer

This repository is not an official repository maintained by Classpert.
