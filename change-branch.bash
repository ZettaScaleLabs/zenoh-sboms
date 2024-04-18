#!/usr/bin/env bash

readonly submodules=$(git submodule --quiet foreach 'echo $sm_path')

for submodule in $submodules; do
  git submodule set-branch --branch "$1" "$submodule"
done

git submodule update --remote
