#!/usr/bin/env bash
# network-checker/net.sh
# Lightweight, safe network information and basic checks.
# Usage: net.sh [target]

set -u

check_cmd() { command -v "$1" >/dev/null 2>&1; }

print_banner() {
	echo "========================================"
	echo " network-checker — basic network checks"
	echo "========================================"
}

print_help() {
	cat <<'EOF'
Usage: net.sh [target]

If no [target] argument is provided the script will prompt for one.

Performs (when available):
 - DNS resolution (dig/host/nslookup)
 - ICMP ping
 - Traceroute (traceroute/tracepath)
 - Lightweight port checks (nmap if installed, otherwise nc)
 - HTTP header fetch (curl)
 - Local interface addresses (ip/ifconfig)

WARNING: Only run scans against systems and networks you own or have explicit permission to test.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	print_help
	exit 0
fi

target="${1:-}"
if [ -z "$target" ]; then
	read -rp "Enter IP address or hostname to check: " target
fi

if [ -z "$target" ]; then
	echo "No target provided. Exiting."
	exit 1
fi

print_banner
echo "Target: $target"
echo

echo "[1/6] DNS resolution"
if check_cmd dig; then
	dig +short "$target" || true
elif check_cmd host; then
	host "$target" || true
elif check_cmd nslookup; then
	nslookup "$target" || true
else
	echo "  (no dig/host/nslookup found)"
fi

echo
echo "[2/6] Ping (4 packets)"
if check_cmd ping; then
	# many pings support -c; if not, this may fail — keep it best-effort
	if ping -c 4 "$target" 2>/dev/null; then
		:
	else
		echo "  Ping failed or filtered."
	fi
else
	echo "  (ping not available)"
fi

echo
echo "[3/6] Traceroute"
if check_cmd traceroute; then
	traceroute -m 30 "$target" || true
elif check_cmd tracepath; then
	tracepath "$target" || true
else
	echo "  (no traceroute/tracepath found)"
fi

echo
echo "[4/6] Port checks"
if check_cmd nmap; then
	echo "  Running light nmap scan (top ports). This requires permission from the target owner."
	# Non-aggressive, top-ports scan
	nmap -Pn --top-ports 1000 -T4 "$target" || true
elif check_cmd nc; then
	echo "  nmap not found; using nc to probe common ports (fast checks)."
	ports=(22 21 23 53 80 110 139 143 443 445 3306 3389 5900 8080)
	for p in "${ports[@]}"; do
		if nc -z -w1 "$target" "$p" 2>/dev/null; then
			echo "  Port $p: open"
		fi
	done
else
	echo "  (no nmap or nc found; skipping port checks)"
fi

echo
echo "[5/6] HTTP headers (if web service present)"
if check_cmd curl; then
	curl -Is --max-time 5 "http://$target" | head -n 15 || true
	echo
	curl -Is --max-time 5 "https://$target" | head -n 15 || true
else
	echo "  (curl not available)"
fi

echo
echo "[6/6] Local interface information"
if check_cmd ip; then
	ip -4 -o addr show || true
elif check_cmd ifconfig; then
	ifconfig || true
else
	echo "  (no ip/ifconfig found)"
fi

if check_cmd whois; then
	echo
	echo "WHOIS (light):"
	whois "$target" | sed -n '1,40p' || true
fi

echo
echo "Summary: basic checks finished."
echo "Reminder: only run scans against systems you have explicit permission to test."

exit 0


