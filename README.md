# melanie-first-project

A small Fortran + CMake playground for learning everyday scientific software
development.

The example program runs a tiny 2D diffusion simulation. It reads a text
configuration file, writes a log file, produces CSV data, and exports legacy
VTK files that open directly in ParaView.

## What This Teaches

- Compiling a Fortran project with CMake.
- Running an executable with a configuration file.
- Reading log files and output files.
- Opening `.vtk` results in ParaView.
- Running tests with CTest.
- Using GitHub Actions for CI.
- Blocking common quality problems such as trailing whitespace and weak commit
  messages.
- Practicing small, reviewable software development habits.

## Quick Start

Requirements:

- CMake 3.20 or newer.
- A Fortran compiler such as `gfortran`.
- ParaView, optional, for viewing `.vtk` output files.

The included presets use `gfortran` on purpose so beginners get a predictable
compiler. Advanced users can still configure manually with another compiler.

Configure and build:

```sh
cmake --preset debug
cmake --build --preset debug
```

Run the example:

```sh
./build/debug/diffusion_playground examples/default/simulation.ini build/debug/playground-output
```

Run the tests:

```sh
ctest --preset debug
```

Run the local quality checks:

```sh
scripts/check-whitespace.sh
scripts/check-commit-message.sh "Add diffusion playground #42"
scripts/check-branch-name.sh 42-add-diffusion-playground
```

## Output Files

After a run, inspect `build/debug/playground-output/`.

- `melanie_demo.log`: human-readable run log.
- `melanie_demo_summary.txt`: final settings and statistics.
- `melanie_demo_step_0000.csv`: CSV field data for spreadsheets or scripts.
- `melanie_demo_step_0000.vtk`: VTK snapshot for ParaView.
- Later `step_XXXX` files: snapshots as the simulation evolves.

Now uses `.pvd` files in the output.

Open one of the `.vtk` files in ParaView, click **Apply**, and color by the
`temperature` scalar.

## Project Map

- `app/`: the command-line program.
- `src/`: reusable Fortran modules.
- `tests/`: small test programs registered with CTest.
- `examples/default/`: configuration files to edit and rerun.
- `docs/`: intern-friendly walkthroughs.
- `scripts/`: local quality checks.
- `.github/workflows/`: GitHub Actions CI and hygiene checks.

Start with [docs/intern-guide.md](docs/intern-guide.md).
