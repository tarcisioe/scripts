Scripts
=======

This is my bash scripts repo. Some things only make sense for me, some others
may be useful for more people. ¯\\\_(ツ)\_/¯

This repository was born out of my [dotfiles repo](https://gitlab.com/tarcisioe/configs).
Many times people asked me for some of my scripts, so here they live now.

These scripts are meant to be useful **and** readable enough so that people can
learn with them. This means they are written with some care and should be well
documented (you can yell at me if they are not).

To use these scripts, just add the `bin/` subdirectory to your PATH.

To understand them, keep reading.


How do I read this $\*@#?
-------------------------

That's a very educated way to ask, thank you very much.


### The header

All scripts found here begin the same way, along these lines:

```bash
#!/bin/bash

source scriptlib-init

require ui

SOME_CONST="..."
```

What we see here is the following:

* `#!/bin/bash` is called a "shebang". It tells the operating system that this
  file should be executed with `bash`. I chose bash because it is widely
  available and doesn't suck as bad as `sh`.
* `source scriptlib-init` is somewhat of a magic line right now. It enables the
  `require` mechanism. Don't think too much about it. It is explained much later
  in this README.
* `require ui`, or `require` anything for that matter, loads a file from the
  `lib` folder, taking care not to load it more than once.
* `SOME_CONST="..."` is a variable definition. I follow the convention that
  uppercase variables are constants, and use them very sparingly to avoid
  conflicts with environment variables, or variables used by `bash`.

### The `main` function

Every script has a `main` function. This is __not__ needed in a shellscript,
but I like it. In most cases the `main` function does only two things:

* Parse the command line arguments;
* Call a function which actually does the work, with "digested" arguments.

I use `getopt` for parsing arguments since it easily accepts short and long
arguments.


### Every other function

For reasons that will become clear soon, every other function is usually pretty
short. They usually only name their arguments for readability and call one or
two commands, maybe with a conditional.


### Error handling

Error handling in Bash is kind of a pain, so we rely on three things:

* `set -e`, which is not perfect by any means;
* `&&` and `||` for chaining commands when they succed/fail, respectively;
* Keeping functions really, really short. Why, you ask? Read on.

`set -e` works weirdly with functions. In the following situation:

```bash
set -e

func {
    false  # this returns non-zero, so it is an error
    echo a
}

func
```

the program aborts as expected, after `false`. But in this _other_ situation:

```bash
set -e

func {
    false  # this returns non-zero, so it is an error
    echo a
}

func || echo "Failed"
```

It **does not**. `echo a` runs, which in turn make `func` succeed, and `echo
"Failed"` does not run. This is a really weird behaviour, so by keeping
functions as short as possible and chaining commands with `&&` wherever we
can/makes sense is our best bet.

Whenever a function can't be that short, we make the function run in a subshell
("{}" become "()") and we call `set -e` inside them as well. That is usually the
case in `main` and other bulky functions such as the ones that `main` directly
calls.


### The so-called "library"

The `lib` folder contains common code, shared between scripts. That code is
thoroughly documented, so I won't get into much detail here. Mostly we have
utility functions to:

* Call existing utilities quietly/with more "programmatic" arguments.
* Produce better-formatted output with colors and whatnot.
* Ease common tasks such as select a value based on a condition or get the
  script name.

Unfortunately, that means the scripts here aren't standalone. Sorry about that,
I guess.


### `scriptlib-init`, what the...

Every script in this repository starts by sourcing `scriptlib-init`. It is in
the `bin` directory and has the following important lines:

```bash
set -euo pipefail

SCRIPT_LIB_ROOT="$(readlink -f "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../lib")"
source "${SCRIPT_LIB_ROOT}/init.sh" "${SCRIPT_LIB_ROOT}"
```

That should be enough to put off any normal person, but stay with me here. There
are two things happening here. The first line enables some interesting features
in `bash`:

* `-e` means we want to exit on error. This doesn't apply perfectly to
  functions, though, so we still need care;
* `-u` means we want to exit if an undefined variable is used;
* `-o pipefail` means we want to exit if a pipe operation (output redirection
  to another process) fails.

The following two lines are:

* Finding the directory where the scripts live:
    * `readlink -f "$0"` resolves any symbolic links to where the script is
      located;
    * `dirname` gets only the directory part of a path, removing the last
      segment;
    * The second (outermost) `readlink -f` resolves any `..` in the path.
* `source`ing the init file, which basically turns on the `require` mechanism,
  allowing for ease of modularity on the scripts.

What comes after that is just taking care to warn the user that this file is
meant to be sourced, not executed.
