# Zenoh SBOMs

This repository automates generation of Software Bills of Materials (SBOMs) for the Eclipse Zenoh
project. The CycloneDX SBOM standard is used for all generated SBOMs.

Eclipse Zenoh is a collection of semi-independent repositories each using a different build system
and/or programming language, thus different SBOM generation tools are used for different
repositories:

| Tool | Repositories |
|------|--------------|
| [CycloneDX Python SBOM Generation Tool](https://github.com/CycloneDX/cyclonedx-python) | zenoh-python |
| [CycloneDX Gradle Plugin](https://github.com/CycloneDX/cyclonedx-gradle-plugin) | zenoh-kotlin, zenoh-java |
| [Conan SBOM extension](https://github.com/conan-io/conan-extensions/blob/main/extensions/commands/sbom/README.md) | zenoh-c, zenoh-cpp, zenoh-pico |
| [CycloneDX Rust (Cargo) Plugin](https://github.com/CycloneDX/cyclonedx-rust-cargo) | zenoh, zenoh-plugin-webserver, zenoh-plugin-ros1, zenoh-plugin-ros2dds, zenoh-plugin-dds, zenoh-plugin-mqtt, zenoh-backend-s3, zenoh-backend-influxdb, zenoh-backend-filesystem, zenoh-backend-rocksdb |

## Usage

Trigger the `generate-sboms.yml` workflow on a target branch, or manually run the
`generate-sboms.bash` script (requires a development environment for all Eclipse Zenoh
repositories).

When using the workflow, a `zenoh-sboms` artifact (ZIP archive) will be downloadable from the
workflow summary. Each repository will have an entry in the archive containing all generated SBOMs
(they all use the `.cdx.json` extension).
