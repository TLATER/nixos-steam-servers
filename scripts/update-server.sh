#!/usr/bin/env bash
#
# Script to control installing/updating servers with steamcmd.
#
# # Used variables:
#
# - **APP_ID**: The steam app id to install
# - **STEAM_USER**: The steam user to log in as. Use of `anonymous` should be
#   preferred.
# - **STATE_DIRECTORY**: The directory to store state in. Expected to be
#   provided by systemd.
# - **CREDENTIALS_DIRECTORY**: The directory containing credentials -
#   should have a `steam` file if a non-`anonymous` $STEAM_USER is
#   used. Also expected to be provided by systemd.

set -eu

if ! [[ -v APP_ID && -v STATE_DIRECTORY ]]; then
    echo "Error: Required environment variables not set. This script should be invoked through systemd."
    exit 1
fi

if [[ "$STEAM_USER" != 'anonymous' && ! -v CREDENTIALS_DIRECTORY ]]; then
    echo "Error: Missing credentials for $STEAM_USER. Use 'anonymous' to sign in anonymously."
    exit 1
fi

mkdir -p "${STATE_DIRECTORY}/.steamcmd"
steamcmd <<EOF
force_install_dir $STATE_DIRECTORY
login $STEAM_USER
$(cat "$CREDENTIALS_DIRECTORY/steam")
app_update $APP_ID
quit
EOF
