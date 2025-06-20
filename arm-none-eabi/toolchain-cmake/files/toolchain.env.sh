#!/bin/bash
CMAKE_TOOLCHAIN_FILE="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/toolchain.cmake"
export CMAKE_TOOLCHAIN_FILE
