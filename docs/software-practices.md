# Software Practices

This playground models habits that scale to larger scientific codes.

## Keep Changes Small

Make one conceptually complete change at a time. A good change can be explained
in one sentence and tested locally.

## Prefer Reproducible Commands

Use the documented commands first:

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

Presets reduce "works on my machine" drift.

## Validate Inputs Early

`src/config_mod.f90` rejects unstable or nonsensical settings before the
simulation starts. This is kinder than letting the program produce misleading
output.

## Write Useful Logs

Logs should explain what happened, where files were written, and what numerical
state changed. The example logs configuration values, stability information,
and summary statistics.

## Test Behavior

Tests in this repo are small Fortran programs. They return success with exit
code 0 and fail with `error stop`.

## Automate Boring Checks

The scripts in `scripts/` catch easy-to-avoid review noise:

- trailing whitespace
- missing final newlines
- unclear commit messages
- unclear branch names

CI runs those checks so reviewers can focus on behavior.
