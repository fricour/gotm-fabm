#!/bin/bash

# mkdir build
# cd build

cmake ~/gotm/code -DGOTM_USE_FABM=on

make

./gotm -v
