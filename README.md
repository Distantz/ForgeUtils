# ForgeUtils
[![Build and Release](https://github.com/Distantz/ForgeUtils/actions/workflows/new-release.yaml/badge.svg)](https://github.com/Distantz/ForgeUtils/actions/workflows/new-release.yaml)
![GitHub deployments](https://img.shields.io/github/deployments/Distantz/ForgeUtils/github-pages?label=docs%20deployment)

*Making Planet Coaster 2 modding approachable and easy.*

ForgeUtils is a utility mod for Planet Coaster 2, for abstracting many utility functions behind unchanging APIs.

## Powered by ForgeUtils
- **ProTrack**: https://github.com/Distantz/mod_protrack.
- **Alpine Coaster**: https://www.nexusmods.com/planetcoaster2/mods/30

## Main Features
- LuaCATs and LuaLS support, for autocomplete, intellisense and other features when using a compatible IDE (VSCode, neovim).
- Fully documented. Easy to pick up for beginners to Planet Coaster 2 modding.
- Easy utilities to add Lua hooks to almost any file.
- Easy utilities to add JavaScript UI hooks through Lua.
- Builders for inserting Custom Tracked Rides and Custom Scenery through a stable API.
- Automatic database bindings to common game tables.

## Docs
Documentation is available at https://forgeutils.distantz.com. The documentation on this site is automatically created from the main branch of this repository.

## Versioning
ForgeUtils uses semantic versioning with the form `<major>.<minor>.<patch>`. All code or documentation changes require a bump in the semantic version.

### Major
Incremented when a breaking change, which can either be an addition or fix, is made. The minor and patch numbers must be set to `0` when this occurs.

### Minor
Incremented when a non-breaking addition is made. The patch number must be set to `0` when this occurs.

### Patch
Incremented when a non-breaking change is made.
