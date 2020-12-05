# Concuerror Elixir Examples

This repository is a simple Elixir project to help you play with
[Concuerror](https://github.com/parapluu/Concuerror), a tool to detect and
report concurrency errors.

Concuerror was mainly made for Erlang programs, but it is possible to make it
work with Elixir projects. You can clone this repo and play with it, or read
the following instructions to make it work for your own project.

## Setup

### Get the executable

To use Concuerror, first get the binary by running:

```bash
git clone https://github.com/parapluu/Concuerror.git
cd Concuerror
make
```

The binary will be available at `bin/concuerror`. You can add it to your
`PATH` or move it to a folder already in your `PATH`. In the next steps, I will
assume that the `concuerror` command is available.

### Install dot (optional)

Concuerror can generate diagrams in `.dot` format to help you visualize the
race conditions. If you wish to use that feature, you will need to install that
command to convert `.dot` files to images.

In Ubuntu, you would do it with:

```bash
sudo apt install graphviz
```

### Prepare your repository

Follow these steps if you're trying Concuerror on your own Elixir projects. If
you just use this toy project, this is already done.

Concuerror cannot work with Elixir test files in `.exs`, which are not
compiled. It requires normal modules compiled to `.beam` files. For this
reason, we must update the configuration of our project to make sure that
Concuerror test files are compiled.

We will first create a specific folder in our tests where our Concuerror test
files will go:

```bash
mkdir -p test/concuerror
```

Then update the configuration in `mix.exs` with the following changes:

```elixir
  def project do
    [
      # ...
      elixirc_paths: elixirc_paths(Mix.env),
      test_pattern: "*_test.ex*",
      warn_test_pattern: nil
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/concuerror"]
  defp elixirc_paths(_), do: ["lib"]
```

The `elixirc_paths` tells Elixir which path should get compiled, depending on
the current environment. Here, we're adding our `concuerror` folder when we're
in the `test` environment.

The other two parameters are used to suppress warnings about test files that
do not match the usual `*_test.exs` pattern, since our test files will be
regular `.ex` files.

Note: we could decide to run the Concuerror tests in their own specific env,
like `test_concurrency` for example. In that case there is no need suppress
warnings if you never run `mix test` in that environment.

## Running Concuerror tests

### Writing a test

A Concuerror test will take the form of a normal Elixir module with a `test`
function. Note that if you don't call the function `test`, you can use the
`--test` option to choose another function.

```elixir
defmodule MyModule.ConcurrencyTest do
  def test do
    # Operations to run
  end
end
```

See the files in this repository if you need examples.

### Running a test

First compile your modules:

```bash
MIX_ENV=test mix compile
```

To run `concuerror`, you must provide the name of the test module, the path to
the Elixir binaries and the path to the compiled `.beam` files (on your local
project):

```bash
concuerror \
  --pa <path_to_elixir_bin> \
  --pa <path_to_ex_unit_bin> \
  --pa <path_to_this_project_bin> \
  -m <your_test_module>
```

For example, on my machine, I would do:

```bash
concuerror \
  --pa /usr/lib/elixir/lib/elixir/ebin \
  --pa /usr/lib/elixir/lib/ex_unit/ebin \
  --pa _build/test/lib/concuerror_elixir_examples/ebin/ \
  -m Elixir.MyModule.ConcurrencyTest
```

Note that the module name must be prefixed with `Elixir.`, since a module
`My.Module.Name` actually corresponds to the atom `:"Elixir.My.Module.Name"`.

The report of the test will be written to a file named `concuerror_report.txt`.

#### Script

Since the command is a bit verbose and complex, I provided a simple bash script
to avoid repeating these paths and the `Elixir.` prefix. For the previous
example, it would look like:

```bash
./concuerror_test MyModule.ConcurrencyTest
```

You can adapt it to your needs.

#### Options

Concuerror provides many [options](https://hexdocs.pm/concuerror/index.html).

Here are a few of them that I found most useful:
- `--show_races true` highlights the pair of racing instructions in the report.
- `--test <test_name>` specifies the name of the test function, if it not equal
  to the default ("test").
- `--timeout <value>` (default: 5000ms) a process is considered stuck in an
  infinite loop between two operations with side-effects, if this timeout is
  exceeded.
- `--keep-going` keeps checking new interleavings even if an error was already
  found (by default it stops at the first error found).
- `--interleaving_bound <value>` limits the number of tested interleavings to
  the given value (useful if there are too many interleavings to test).
- `--graph <file_name>` outputs a graph of the event trace that led to an
  error (see next section to show the graph).

### Show the graph (optional)

If you use the `--graph` option to generate a `.dot` file, you can convert it
to an image using:

```bash
dot -Tpng my_graph.dot > my_graph.png

# To show it from the terminal:
# eog my_graph.png
```
