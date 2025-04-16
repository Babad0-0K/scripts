#!/bin/bash

# ===================================================================
# Filename:        utm.sh
# Author:          Lorenzo De Simone
# Version:         1.0
# Created:         2025-04-16
# Description:     CLI Script to start UTM VMs based by course
# ===================================================================


# CSIN VMs
_CL1="LAB-CL1-CSIN"
_DC1="LAB-DC1-CSIN"

# BMBs VMs
_KALI1="kali-2025-W15_HF-BMBS"

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
			echo "Usage ${0} [-a action] [-f <fach>] [-h]"
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


# Functions to operate VMs for chosen Fach
function operateCSIN {
	utmctl "${_ACTION_OPT}" "${_CL1}"
	utmctl "${_ACTION_OPT}" "${_DC1}"	
}

function operateBMBS {
	utmctl "${_ACTION_OPT}" "${_KALI1}"
}


# Main Script
if [[ "${_FACH_OPT}" == "CSIN" ]]; then
	operateCSIN
fi

if [[ "${_FACH_OPT}" == "BMBS" ]]; then
	operateBMBS
fi