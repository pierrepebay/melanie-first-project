#!/usr/bin/env bash
set -euo pipefail

cmake --preset debug
cmake --build --preset debug
./build/debug/diffusion_playground \
  examples/default/simulation.ini \
  build/debug/playground-output
ctest --preset debug
