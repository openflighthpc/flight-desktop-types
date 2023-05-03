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
contains() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

if [ -f /etc/redhat-release ] && grep -q 'release 8' /etc/redhat-release; then
  distro=rhel8
fi

if [ -f /etc/redhat-release ] && grep -q 'release 9' /etc/redhat-release; then
  distro=rhel9
fi

desktop_stage "Flight Desktop prerequisites"
if ! rpm -qa tigervnc-server-minimal | grep -q tigervnc-server-minimal; then
  desktop_miss 'Package: tigervnc-server-minimal'
fi
if ! rpm -qa xorg-x11-xauth | grep -q xorg-x11-xauth; then
  desktop_miss 'Package: xorg-x11-xauth'
fi

IFS=$'\n' groups=(
  $(
    yum grouplist hidden | \
      sed '/^Installed Groups:/,$!d;/^Available Groups:/,$d;/^Installed Groups:/d;s/^[[:space:]]*//' | \
      tr '[:upper:]' '[:lower:]'
  )
)

if [ $UID == 0 ]; then
  # This verification can only be successfully performed by the
  # superuser due to permissions on the `/etc/polkit-1/localauthority`
  # directory.
  desktop_stage "Prerequisite: polkit policies"
  if ! [ -f /etc/polkit-1/localauthority/10-vendor.d/20-flight-desktop-gnome.pkla ]; then
    desktop_miss 'Configuration: polkit policies'
  fi
fi

if [ "$distro" == "rhel8" ] || [ "$distro" == "rhel9"]; then
  desktop_stage "Package group: base-x"
  if ! contains 'base-x' "${groups[@]}"; then
    desktop_miss 'Package group: base-x'
  fi
else
  desktop_stage "Package group: X Window System"
  if ! contains 'x window system' "${groups[@]}"; then
    desktop_miss 'Package group: X Window System'
  fi
fi

desktop_stage "Package group: Fonts"
if ! contains 'fonts' "${groups[@]}"; then
  desktop_miss 'Package group: Fonts'
fi

desktop_stage "Package group: GNOME"
if ! contains 'gnome' "${groups[@]}"; then
  desktop_miss 'Package group: GNOME'
fi

if [ -x /usr/bin/dconf ]; then
  desktop_stage "Prerequisite: GNOME screensaver disabled"
  if [ ! -f /etc/dconf/db/local.d/00-flight-disable-gnome-screenlock ]; then
    desktop_miss 'Configuration: GNOME screensaver is not disabled'
  fi
fi

desktop_stage "Package: evince"
if ! rpm -qa evince | grep -q evince; then
  desktop_miss 'Package: evince'
fi

desktop_stage "Package: firefox"
if ! rpm -qa firefox | grep -q firefox; then
  desktop_miss 'Package: firefox'
fi
