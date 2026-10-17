#!/usr/bin/env sh
set -exu

# Check init system
if ! command -v runit >/dev/null 2>&1; then
	exit 1
fi

# Check current directory
if [ "$(basename "$PWD")" != "supreme_reflector" ]; then
	echo "Please cd into supreme_reflector directory - the name must be supreme_reflector"
	exit 1
fi

# Find helper relative to this script
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPER="$SCRIPT_DIR/derive_best_mirror.py"

if [ ! -f "$HELPER" ]; then
	echo "Missing helper: $HELPER"
	exit 1
fi

# Install execution files
sudo mkdir -p '/usr/local/lib/supreme_reflector'
sudo cp -a -v "$HELPER" '/usr/local/lib/supreme_reflector/derive_best_mirror.py'
sudo cp -a -v "$PWD/main.sh" '/usr/bin/supreme_reflector'

# Install service
sudo mkdir -p '/etc/service/supreme_reflector'
sudo touch '/etc/service/supreme_reflector/run'
sudo tee '/etc/service/supreme_reflector/run' <<'EOF'
#!/usr/bin/env sh
while true; do
    /usr/bin/supreme_reflector 2>/dev/null > /etc/pacman.d/mirrorlist
    sleep 24h
done
EOF

sudo chmod +x '/etc/service/supreme_reflector/run'
sudo ln -s '/etc/service/supreme_reflector' '/run/runit/service/supreme_reflector'
