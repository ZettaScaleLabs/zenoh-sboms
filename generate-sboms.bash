#!/usr/bin/env bash

set -xeo pipefail

shopt -s globstar nullglob

readonly self_dir="$(dirname "$0")"
readonly root_dir="$(realpath "$self_dir")"
readonly out_dir="$root_dir/dist"
readonly patches_dir="$root_dir/patches"

function generate_cargo_sboms () {
  local repos=(
    'zenoh'
    'zenoh-plugin-dds'
    'zenoh-plugin-mqtt'
    # FIXME(fuzzypixelz): Reenable this once zenoh-plugin-ros1 is fixed
    # See: https://github.com/eclipse-zenoh/zenoh-plugin-ros1/pull/55 
    # 'zenoh-plugin-ros1'
    'zenoh-plugin-ros2dds'
    'zenoh-plugin-webserver'
    'zenoh-backend-filesystem'
    'zenoh-backend-influxdb'
    'zenoh-backend-rocksdb'
    'zenoh-backend-s3'
  )

  cargo +stable install cargo-cyclonedx

  for repo in "${repos[@]}"; do
    (
      cd "$repo" || (echo "error: could not find repo $repo" && exit 1)
      cargo cyclonedx --format json

      local repo_out_dir=$out_dir/$repo
      mkdir -p "$repo_out_dir"
      for f in ./**/*.cdx.json; do
        cp "$f" "$repo_out_dir"
      done
    )
  done
}

function generate_python_sboms () {
  local repos=(
    'zenoh-python'
  )

  python3 -m pip install cyclonedx-bom
  
  for repo in "${repos[@]}"; do
    (
      cd "$repo" || (echo "error: could not find repo $repo" && exit 1)
      cargo cyclonedx --format json

      local repo_out_dir=$out_dir/$repo
      mkdir -p "$repo_out_dir"
      python3 -m cyclonedx_py environment > "$repo_out_dir"/"$repo".cdx.json
    )
  done
}

function generate_gradle_sboms () {
  local repos=(
    'zenoh-java'
    'zenoh-kotlin'
  )

  for repo in "${repos[@]}"; do
    (
      cd "$repo" || (echo "error: could not find repo $repo" && exit 1)
      git apply "$patches_dir"/"$repo"/*.patch
      gradle cyclonedxBom

      local repo_out_dir=$out_dir/$repo
      mkdir -p "$repo_out_dir"
      cp build/reports/*.cdx.json "$repo_out_dir"
      git restore .
    )
  done
}

function generate_conan_sboms () {
  local repos=(
    'zenoh-c'
    'zenoh-cpp'
    'zenoh-pico'
  )

  python3 -m pip install conan 'cyclonedx-python-lib>=5.0.0,<6'
  conan config install https://github.com/conan-io/conan-extensions.git
  conan profile detect || echo "warning: failed to generate profile"

  for repo in "${repos[@]}"; do
    (
      cd "conan-recipes/$repo" || (echo "error: could not find repo $repo" && exit 1)

      local repo_out_dir=$out_dir/$repo
      mkdir -p "$repo_out_dir"
      conan sbom:cyclonedx --format 1.4_json ./all/conanfile.py 1> "$repo_out_dir"/"$repo".cdx.json
    )
  done
}

generate_cargo_sboms
generate_python_sboms
generate_gradle_sboms
generate_conan_sboms
