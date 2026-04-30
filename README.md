# spice-vdagent — Intel macOS Builds

Pre-built [spice-vdagent](https://github.com/utmapp/vd_agent) binaries for Intel (x86_64) macOS, distributed via Homebrew.

Built from UTM's [vd_agent](https://github.com/utmapp/vd_agent) source on GitHub Actions.

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

Versions track UTM's vd_agent releases (e.g., 0.22.1).

## Credits

- [UTM vd_agent](https://github.com/utmapp/vd_agent) — upstream source (GPL-3.0)
- [mac-guest-agent](https://github.com/mav2287/mac-guest-agent) — complementary QEMU Guest Agent for macOS
