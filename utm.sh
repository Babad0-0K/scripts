#!/bin/bash

# ===================================================================
# Filename:        utm.sh
# Author:          Lorenzo De Simone
# Version:         1.0
# Created:         2025-04-16
# Description:     CLI Script to start UTM VMs based by course
# ===================================================================

# todo: add courses array
# todo: -l list courses +VMs

# Declare VMs and Courses Array
declare -a _IFA_VMS
declare -a _IFA_COURSES

# List VMs
while IFS= read -r line
	do
		if [[ "${line: -5:1}" == "-" ]]; then
			_IFA_VMS+=("$line")
		fi
done < <(utmctl list | sed '1d' | awk '{print $3}')


# GETOPTS STUFF
_OPTSTRING="a:f:h"

while getopts ${_OPTSTRING} _FACH; do
	case "${_FACH}" in
		a)
			_ACTION_OPT="${OPTARG}"
			;;
		f)
			_FACH_OPT="${OPTARG}"
			;;
		h)
			echo "Usage: utm [-a action] [-f <fach>] [-h]"
			exit 0
			;;
		\?)
			echo "Invalid option: -${OPTARG}" >&2
			exit 1
			;;
		:)
			echo "Option -${OPTARG} requires an arugment" >&2
			exit 1
			;;
esac
done

# Function to operate VMs for chosen Fach 
function operateVMS {
	local _action_opt=${1}
	local _fach_opt=${2}

	for i in "${_IFA_VMS[@]}"
	do
		if [[ "${i: -4}" == "${_fach_opt}" ]]; then
			echo  "utmctl ${_action_opt} ${i}"
		fi
	done
}

# Main Script
operateVMS "${_ACTION_OPT}" "${_FACH_OPT}"