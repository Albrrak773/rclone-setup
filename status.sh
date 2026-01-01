
if ! command -v lnav &> /dev/null; then
    echo "'lnav' is not installed. Please install it using your package manager or visit https://lnav.org/downloads"
    exit 1
fi
if ! command -v btop &> /dev/null; then
    echo "'btop' is not installed. Please install it using your package manager or visit https://github.com/aristocratos/btop?tab=readme-ov-file#installation"
    exit 1
fi
if ! command -v zellij &> /dev/null; then
    echo "'zellij' is not installed. Please install it using your package manager or visit https://zellij.dev/documentation/installation.html"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
zellij --layout "$SCRIPT_DIR/status.kdl"