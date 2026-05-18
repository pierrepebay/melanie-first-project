# ParaView Notes

The simulation writes legacy ASCII `.vtk` files. They are larger than binary
files, but they are easy to open in a text editor and understand.

A typical file begins like this:

```text
# vtk DataFile Version 3.0
Diffusion playground output
ASCII
DATASET STRUCTURED_POINTS
DIMENSIONS 25 17 1
```

ParaView reads the grid dimensions, spacing, and scalar values. The scalar field
is named `temperature`.

## Open a Snapshot

1. Build and run the example.
2. Open ParaView.
3. Open `build/debug/playground-output/melanie_demo_step_0024.vtk`.
4. Click Apply.
5. Color by `temperature`.

## Compare Snapshots

Open `melanie_demo_step_0000.vtk` and `melanie_demo_step_0024.vtk`. The peak
temperature should become smoother after diffusion.

## Debugging Tips

- If ParaView shows nothing, check that you clicked Apply.
- If the scalar menu is empty, open the `.vtk` file and look for
  `SCALARS temperature double 1`.
- If the grid looks too coarse, increase `nx` and `ny` in the config file.
