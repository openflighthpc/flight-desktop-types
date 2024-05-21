#!/bin/bash
# =============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
#
# This file is part of Flight Desktop.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Desktop is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Desktop. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Desktop, please visit:
# https://github.com/alces-flight/flight-desktop
# ==============================================================================
set -e

set_policies() {
    mkdir -p /etc/polkit-1/localauthority/10-vendor.d
    # disable authentication prompts for all users
    cat <<EOF > /etc/polkit-1/localauthority/10-vendor.d/15-flight-desktop-users.pkla
[Flight Desktop - disable create color managed device auth prompt for all users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device
ResultAny=no
ResultInactive=no
ResultActive=no

[Flight Desktop - disable network connections prompt for all users]
Identity=unix-user:*
Action=org.freedesktop.NetworkManager.network-control
ResultAny=no
ResultInactive=no
ResultActive=no
EOF
}

if ! apt -qq --installed list tigervnc-common | grep -q tigervnc-common ||
    ! apt -qq --installed list xauth | grep -q xauth; then
  desktop_stage "Installing Flight Desktop prerequisites"
  apt -y install tigervnc-common xauth
fi

if ! [ -f /etc/polkit-1/localauthority/10-vendor.d/15-flight-desktop-users.pkla ]; then
  desktop_stage "Setting up polkit policies"
  set_policies
fi

if ! apt -qq --installed list plasma-desktop | grep -q plasma-desktop; then
  desktop_stage "Installing package: plasma-desktop"
  apt -y install plasma-desktop
fi

if ! apt -qq --installed list dolphin | grep -q dolphin; then
  desktop_stage "Installing package: dolphin"
  apt -y install dolphin
fi

if ! apt -qq --installed list konsole | grep -q konsole; then
  desktop_stage "Installing package: konsole"
  apt -y install konsole
fi

if ! apt -qq --installed list evince | grep -q evince; then
  desktop_stage "Installing package: evince"
  apt -y install evince
fi

if ! apt -qq --installed list firefox | grep -q firefox; then
  desktop_stage "Installing package: firefox"
  apt -y install firefox
fi

desktop_stage "Prequisites met"
