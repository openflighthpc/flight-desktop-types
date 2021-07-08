# =============================================================================
# Copyright (C) 2021-present Alces Flight Ltd.
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

set -x

# Give a moment for the terminal to load
sleep 10

# Get the index and id
idx=$(echo "$flight_DESKTOP_SCRIPT_index")
id=$(echo "$flight_DESKTOP_SCRIPT_id")

# Remove the flight_DESKTOP_SCRIPT_* variables
unset $(env | grep '^flight_DESKTOP_SCRIPT_' | cut -d '=' -f1 | xargs)

# Start the process in a detached screen session
tag="flight-desktop.$idx.$id"
screen -dmS "$tag" -- "$@"

# Determine the screen ID
screen_id=$(screen -list | grep "$tag" | cut -f2)

# Determine the TTY
tty=$(who | grep "(:1)" | cut -d' ' -f3)

# Notify the user the script is running
echo "Script Started! Attach to it with: screen -r $screen_id" >/dev/$tty