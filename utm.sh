#!/bin/bash

# ===================================================================
# Filename:        utm.sh
# Author:          Lorenzo De Simone
# Version:         1.0
# Created:         2025-04-16
# Description:     CLI Script to start UTM VMs based by course
# ===================================================================


# CSIN VMs // not needed anymore
_CL1="LAB-CL1-CSIN"
_DC1="LAB-DC1-CSIN"

# BMBs VMs // not needed anymore
_KALI1="kali-2025-W15_HF-BMBS"

declare -a _COURSE_VMS

# List VMs
while IFS= read -r line
	do
		if [[ "${line: -5:1}" == "-" ]]; then
			_COURSE_VMS+=("$line")
		fi
done < <(utmctl list | sed '1d' | awk '{print $3}')

#echo "${_COURSE_VMS[*]}"


# GETOPTS STUFF
#_OPTSTRING="a:f:h"

#while getopts ${_OPTSTRING} _FACH; do
#	case "${_FACH}" in
#		a)
#			_ACTION_OPT="${OPTARG}"
#			;;
#		f)
#			_FACH_OPT="${OPTARG}"
#			;;
#		h)
#			echo "Usage: utm [-a action] [-f <fach>] [-h]"
#			exit 0
#			;;
#		\?)
#			echo "Invalid option: -${OPTARG}" >&2
#			exit 1
#			;;
#		:)
#			echo "Option -${OPTARG} requires an arugment" >&2
#			exit 1
#			;;
#esac
#done

# Functions to operate VMs for chosen Fach 
function operateVMS {
	local _action_opt=${1}
	local _fach_opt=${2}

	for i in "${_COURSE_VMS[@]}"
	do
		if [[ "${i: -4}" == "${_fach_opt}" ]]; then
			# utmctl "${_action_opt}" "${i}"
			echo  "utmctl ${_action_opt} ${i}"
		fi
	done
}
_ACTION_OPT="start"
_FACH_OPT="CSIN"

operateVMS "${_ACTION_OPT}" "${_FACH_OPT}"

# Functions to operate VMs for chosen Fach // not needed anymore
#function operateCSIN {
#	utmctl "${_ACTION_OPT}" "${_CL1}"
#	utmctl "${_ACTION_OPT}" "${_DC1}"	
#}

#function operateBMBS {
#	utmctl "${_ACTION_OPT}" "${_KALI1}"
#}


# Main Script
#if [[ "${_FACH_OPT}" == "CSIN" ]]; then
#	operateCSIN
#fi

#if [[ "${_FACH_OPT}" == "BMBS" ]]; then
#	operateBMBS
#fi