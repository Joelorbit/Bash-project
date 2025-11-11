# network-checker

Small helper script for basic network information and lightweight checks.

Features

- DNS resolution (dig / host / nslookup)
- Ping
- Traceroute / tracepath
- Port checks (nmap if available, otherwise nc probe for common ports)
- HTTP header fetch (curl)
- Local interface addresses (ip / ifconfig)

Usage

1. Make the script executable (optional):

```bash
chmod +x net.sh
```

2. Run with a target argument or let the script prompt you:

```bash
./net.sh example.com
# or
bash net.sh 192.0.2.1
```

Notes & prerequisites

- This script calls external tools when available. Install the ones you want (dig, nmap, curl, traceroute, nc).
- The script is intentionally conservative and will skip checks if the corresponding tool isn't installed.

Important legal & ethical warning
Only run scans and probes against hosts and networks you own or for which you have explicit written permission. Unauthorized scanning can be illegal and may get you blocked or worse.

Want more?

- If you want a more advanced scanner (custom port ranges, asynchronous checks, output to JSON), tell me what you need and I can extend the script.

License: use at your own risk. This is a small utility to help with diagnostics and learning.
