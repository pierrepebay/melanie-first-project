# Intern Guide

This repo is a tiny scientific software lab. The program is small enough to
read in one sitting, but it includes the moving parts you will meet in larger
projects.

## 1. Configure and Build

```sh
cmake --preset debug
cmake --build --preset debug
```

CMake reads `CMakeLists.txt`, discovers the Fortran compiler, and writes build
files under `build/debug/`. The build step compiles the modules in `src/`, then
links the executable from `app/`.

The preset asks for `gfortran` explicitly. That avoids accidentally selecting a
different Fortran compiler installed on the machine.

Try this:

```sh
cmake --build --preset debug --verbose
```

Look for the compiler command lines and the final link command.

## 2. Run the Program

```sh
./build/debug/diffusion_playground examples/default/simulation.ini build/debug/playground-output
```

The first argument is the configuration file. The optional second argument
overrides `output_dir` so generated files stay inside the build directory.

## 3. Read the Configuration

Open `examples/default/simulation.ini`.

Good experiments:

- Increase `nx` and `ny`, then compare the CSV and VTK file sizes.
- Increase `steps`, then look at the later snapshots.
- Set `alpha = 1.0` and rerun. The validation should stop the unstable
  configuration before the simulation starts.

## 4. Inspect Outputs

After a run, open `build/debug/playground-output/`.

- Start with `melanie_demo.log`.
- Compare the min, max, and mean values between steps.
- Open a CSV file in a text editor or spreadsheet.
- Open a `.vtk` file in ParaView.

## 5. Use ParaView

1. Open ParaView.
2. File -> Open.
3. Select a file such as `melanie_demo_step_0024.vtk`.
4. Click Apply.
5. In the coloring menu, choose `temperature`.
6. Try Surface, Surface With Edges, and Points.

The file is a legacy VTK `STRUCTURED_POINTS` dataset. The project writes that
format directly, so no VTK library is needed at compile time.

## 6. Run Tests

```sh
ctest --preset debug
```

CTest runs:

- `config-reader`: verifies the example configuration parses correctly.
- `field-update`: checks a single diffusion step.
- `example-run`: runs the real executable and confirms it writes VTK output.

When a test fails, rerun with more detail:

```sh
ctest --preset debug --rerun-failed --output-on-failure
```

## 7. Understand CI/CD

GitHub Actions workflows live in `.github/workflows/`.

- `ci.yml` builds and tests the project.
- `quality.yml` checks whitespace, commit message style, and pull request
  branch names.

The quality workflow expects commit messages like:

```text
#42: Add diffusion playground
#43: Fix unstable time step validation
#44: Document ParaView workflow
```

Pull request branches should look like:

```text
42-add-diffusion-playground
43-fix-unstable-time-step-validation
```

## 8. Suggested Exercises

- Add a new configuration key named `background_temperature`.
- Add a test for invalid grid sizes.
- Write a Python or shell script that plots the CSV output.
- Add a second VTK scalar named `step_index`.
- Change the initial condition from one hot spot to two hot spots.
- Add a GitHub Actions job that uploads the generated VTK files as artifacts.
