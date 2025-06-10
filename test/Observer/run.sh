#! /usr/bin/bash

# mkdir -p .build/
# clang++ -std=c++23 main.cpp -o .build/main
# ./.build/main

cmake -B build
cmake --build build
