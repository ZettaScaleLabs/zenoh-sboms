#!/usr/bin/env bash

shopt -s globstar nullglob

readonly out_dir="$(dirname "$0" | realpath)/dist"

function generate_cargo_sboms () {
  local repos=(
    'zenoh'
    'zenoh-plugin-dds'
    'zenoh-plugin-mqtt'
    'zenoh-plugin-ros1'
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
      for f in "$repo"/**/*.cdx.json; do 
         mv "$f" "$repo_out_dir"
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
      python3 -m cyclonedx_py environment > "$repo_out_dir"/zenoh-python.cdx.json
    )
  done
}

function generate_gradle_sboms () {
  local repos=(
    'zenoh-java'
    'zenoh-kotlin'
  )

  # TODO: https://github.com/CycloneDX/cyclonedx-gradle-plugin
}

# TODO: zenoh-c, zenoh-cpp

generate_cargo_sboms
generate_python_sboms
