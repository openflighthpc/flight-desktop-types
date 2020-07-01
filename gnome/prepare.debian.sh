#!/bin/bash
# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
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

disable_gnome_screenlock() {
  mkdir -p /etc/dconf/db/local.d
  cat <<EOF > /etc/dconf/db/local.d/00-flight-disable-gnome-screenlock
[org/gnome/desktop/session]
idle-delay=uint32 0
[org/gnome/desktop/screensaver]
lock-enabled=false
lock-delay=uint32 0
EOF
  if [ ! -f /etc/dconf/profile/user ]; then
    mkdir -p /etc/dconf/profile
    cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF
  fi
  dconf update
}

set_policies() {
  local group=$1
  # disable authentication prompts for admin users
  mkdir -p /etc/polkit-1/localauthority/10-vendor.d
  cat <<EOF > /etc/polkit-1/localauthority/10-vendor.d/20-flight-desktop-gnome.pkla
[Flight Desktop - disable create color managed device auth prompt for admins]
Identity=unix-group:${group}
Action=org.freedesktop.color-manager.create-device
ResultAny=yes
ResultInactive=yes
ResultActive=yes

[Flight Desktop - disable network proxy auth prompt for admins]
Identity=unix-group:${group}
Action=org.freedesktop.packagekit.system-network-proxy-configure
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
}

if ! apt -qq --installed list tigervnc-common | grep -q tigervnc-common ||
    ! apt -qq --installed list xauth | grep -q xauth; then
  desktop_stage "Installing Flight Desktop prerequisites"
  apt -y install tigervnc-common xauth
fi

if ! [ -f /etc/polkit-1/localauthority/10-vendor.d/20-flight-desktop-gnome.pkla ]; then
  policy_group=adm
  if [ "${policy_group}" ]; then
    desktop_stage "Setting up polkit policies"
    set_policies "${policy_group}"
  fi
fi

if ! apt -qq --installed list gnome-session | grep -q gnome-session; then
  desktop_stage "Installing package: gnome-session"
  apt -y install gnome-session
fi

if [ -x /usr/bin/dconf -a ! -f /etc/dconf/db/local.d/00-flight-disable-gnome-screenlock ]; then
  desktop_stage "Disabling GNOME screensaver locking"
  disable_gnome_screenlock
fi

if ! apt -qq --installed list xterm | grep -q xterm; then
  desktop_stage "Installing package: xterm"
  apt -y install xterm
fi

if ! apt -qq --installed list gnome-terminal | grep -q gnome-terminal; then
  desktop_stage "Installing package: gnome-terminal"
  apt -y install gnome-terminal
fi

if ! apt -qq --installed list fonts-noto-color-emoji | grep -q fonts-noto-color-emoji; then
  desktop_stage "Installing package: fonts-noto-color-emoji"
  apt -y install fonts-noto-color-emoji
fi

if ! apt -qq --installed list evince | grep -q evince; then
  desktop_stage "Installing package: evince"
  apt -y install evince
fi

if ! apt -qq --installed list firefox | grep -q firefox; then
  desktop_stage "Installing package: firefox"
  apt -y install firefox
fi

if apt -qq --installed list packagekit | grep -q packagekit; then
  desktop_stage "Removing package: packagekit"
  apt -y remove packagekit
fi

desktop_stage "Prequisites met"
