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
desktop_stage "Flight Desktop prerequisites"
if ! apt -qq --installed list tigervnc-common | grep -q tigervnc-common; then
  desktop_miss 'Package: tigervnc-common'
fi
if ! apt -qq --installed list xauth | grep -q xauth; then
  desktop_miss 'Package: xauth'
fi

desktop_stage "Prerequisite: polkit policies"
if [ "$UID" == 0 ]; then
  if ! [ -f /etc/polkit-1/localauthority/10-vendor.d/20-flight-desktop-gnome.pkla ]; then
    desktop_miss 'Configuration: polkit policies'
  fi
else
  desktop_miss 'Configuration: users are unable to verify polkit policies'
fi

desktop_stage "Package: gnome-session"
if ! apt -qq --installed list gnome-session | grep -q gnome-session; then
  desktop_miss 'Package: gnome-session'
fi

if [ -x /usr/bin/dconf ]; then
  desktop_stage "Prerequisite: GNOME screensaver disabled"
  if [ ! -f /etc/dconf/db/local.d/00-flight-disable-gnome-screenlock ]; then
    desktop_miss 'Configuration: GNOME screensaver is not disabled'
  fi
fi

desktop_stage "Package: xterm"
if ! apt -qq --installed list xterm | grep -q xterm; then
  desktop_miss 'Package: xterm'
fi

desktop_stage "Package: gnome-terminal"
if ! apt -qq --installed list gnome-terminal | grep -q gnome-terminal; then
  desktop_miss 'Package: gnome-terminal'
fi

desktop_stage "Package: fonts-noto-color-emoji"
if ! apt -qq --installed list fonts-noto-color-emoji | grep -q fonts-noto-color-emoji; then
  desktop_miss 'Package: fonts-noto-color-emoji'
fi

desktop_stage "Package: evince"
if ! apt -qq --installed list evince | grep -q evince; then
  desktop_miss 'Package: evince'
fi

desktop_stage "Package: firefox"
if ! apt -qq --installed list firefox | grep -q firefox; then
  desktop_miss 'Package: firefox'
fi
