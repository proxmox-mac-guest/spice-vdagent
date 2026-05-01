# Proxmox VE Setup for spice-vdagent + mac-guest-agent

This guide configures a macOS 15.x hackintosh VM on Proxmox VE with both SPICE vdagent (clipboard) and QEMU Guest Agent (fsfreeze/shutdown/OS info).

## Prerequisites

- macOS 15.x (Sequoia) hackintosh VM on Proxmox VE 8.x
- Working SPICE display (not VNC)

## QEMU Configuration

Run these commands on the Proxmox host:

### 1. Enable QEMU Guest Agent (ISA serial)

```bash
qm set <VMID> --agent enabled=1,type=isa
```

This creates an ISA serial port at `/dev/cu.serial1` in the guest for mac-guest-agent.

### 2. Ensure SPICE display is configured

```bash
qm set <VMID> --display spice
```

When SPICE display is enabled, Proxmox auto-configures the VirtIO serial device with the `com.redhat.spice.0` port that spice-vdagent uses.

### 3. Verify the full QEMU config

```bash
qm config <VMID> | grep -E 'agent|display|serial'
```

Expected output should include:
```
agent: 1,type=isa
display: spice
serial0: socket
```

## Guest Setup

### Install mac-guest-agent (QEMU Guest Agent)

Download from https://github.com/mav2287/mac-guest-agent/releases and install.

### Install spice-vdagent (SPICE vdagent)

```bash
brew tap proxmox-mac-guest/spice
brew install spice-vdagent
brew services start spice-vdagent

# Install per-user LaunchAgent for clipboard
cp "$(brew --prefix)/Cellar/spice-vdagent/0.22.1/com.redhat.spice.vdagent.plist" ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.redhat.spice.vdagent.plist
```

## Verify Both Agents

```bash
# Check spice-vdagentd daemon
brew services info spice-vdagent

# Check spice-vdagent per-user agent
launchctl list | grep spice

# Check mac-guest-agent
launchctl list | grep guest-agent

# From Proxmox host, test QGA communication
qm agent <VMID> ping
qm agent <VMID> fsfreeze status
```

## Coexistence

| Agent | Channel | Device | Protocol | Purpose |
|-------|---------|--------|----------|---------|
| mac-guest-agent | ISA serial | /dev/cu.serial1 | QGA | fsfreeze, shutdown, OS info |
| spice-vdagentd | VirtIO serial | /dev/tty.com.redhat.spice.0 | SPICE | clipboard sharing |

No conflicts — different channels, different protocols, different purposes.

## Troubleshooting

### Clipboard not working

1. Verify SPICE display is active (not VNC): `qm config <VMID> | grep display`
2. Check daemon logs: `cat /var/log/spice-vdagentd.stdout.log`
3. Check VirtIO serial device exists: `ls -la /dev/tty.com.redhat.spice.0`
4. Restart: `brew services restart spice-vdagent`

### QGA not responding

1. Verify ISA serial config: `qm config <VMID> | grep agent`
2. Check mac-guest-agent logs
3. Test from host: `qm agent <VMID> ping`
