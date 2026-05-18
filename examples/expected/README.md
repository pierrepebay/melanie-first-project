This directory explains the kind of files the example run produces.

Generated files are intentionally not committed. Build and run the project, then
inspect `build/debug/playground-output/`:

- `melanie_demo.log`: timestamped messages from the run.
- `melanie_demo_summary.txt`: final statistics.
- `melanie_demo_step_0000.csv`: tabular data.
- `melanie_demo_step_0000.vtk`: ParaView-readable scalar field.

The step number increases as the simulation evolves.
