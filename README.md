# spice-vdagent — macOS Builds

Pre-built [spice-vdagent](https://github.com/utmapp/vd_agent) binaries for Intel (x86_64) and Apple Silicon (arm64) macOS, distributed via Homebrew.

Built from UTM's [vd_agent](https://github.com/utmapp/vd_agent) source on GitHub Actions via an automated matrix pipeline.

## Supported Configurations

| macOS Version | Codename | x86_64 | arm64 |
|---------------|----------|--------|-------|
| 14            | Sonoma   | ✓      | ✓     |
| 15            | Sequoia  | ✓      | ✓     |
| 26            | Tahoe    | ✓      | ✓     |

Users on macOS 13 (Ventura) or older will automatically compile from source.

## Install

```bash
brew tap proxmox-mac-guest/spice
brew install spice-vdagent
brew services start spice-vdagent
```

## Proxmox Setup

Ensure your VM has a VirtIO serial device with the SPICE vdagent port:

```
qm set <vmid> --agent enabled=1,type=isa
```

The ISA serial is for mac-guest-agent (QEMU Guest Agent). SPICE vdagent uses a separate VirtIO serial port auto-configured with SPICE display.

## Versioning

When a new upstream release appears, push a matching tag to trigger the build pipeline:

```bash
git tag v0.23.0 && git push origin v0.23.0
```

The workflow builds all 6 bottle variants in parallel, runs dry-run tests, creates a GitHub Release, and updates the Homebrew tap automatically. If multiple builds of the same upstream version are needed, use a suffix (e.g., `v0.22.1-1`).

## Credits

- [UTM vd_agent](https://github.com/utmapp/vd_agent) — upstream source (GPL-3.0)
- [mac-guest-agent](https://github.com/mav2287/mac-guest-agent) — complementary QEMU Guest Agent for macOS
