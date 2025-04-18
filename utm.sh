#!/bin/bash

# ===================================================================
# Filename:        utm.sh
# Author:          Lorenzo De Simone
# Version:         1.0
# Created:         2025-04-16
# Description:     CLI Script to start UTM VMs based by Class
# ===================================================================


##########################
### Preparation Tasks ####
##########################

# Declare VMs and classes array
declare -a _IFA_VMS
declare -a _IFA_CLASSES

# Search for IFA VMs and save to _IFA_VMS
function funcCheckVm() {
	while IFS= read -r line
		do
			if [[ "${line: -5:1}" == "-" ]]; then
				_IFA_VMS+=("$line")
			fi
	done < <(utmctl list | sed '1d' | awk '{print $3}')
}

# Get class from VM Name and save to _IFA_CLASSES
function funcCheckClasses() {
	for _vm in "${_IFA_VMS[@]}"
		do
			if ! [[ $(echo ${_IFA_CLASSES[@]} | fgrep -w "${_vm: -4}") ]]; then
				_IFA_CLASSES+=("${_vm: -4}")
			fi
	done
}

funcCheckVm
funcCheckClasses


##########################
### Built-in Functions ###
##########################

# List Classes 
function funcListClasses() {
	for _class in "${_IFA_CLASSES[@]}"
		do
			echo "  ${_class}"
		done
}

# List VMs sorted by Class
function funcListVm() {
	for _class in "${_IFA_CLASSES[@]}"
		do
			echo "VMs for class: ${_class}"
			for _vm in "${_IFA_VMS[@]}"
				do
				if [[ "${_vm: -4}" == "${_class}" ]]; then
					echo "  * ${_vm}"
				fi
			done
			echo ""
	done
}


#########################
### Script Usage Text ###
#########################

function funcHelp(){
	echo "USAGE:"
	echo "  utm -a <action> -f <fach>"
	echo ""
	echo "EXAMPLE:"
	echo "  utm -a start -f BMBS"
	echo "  utm -a stop -f BMBS"
	echo ""
	echo "OPTIONS:"
	echo "  -l, list - List VMs sorted by Class"
	echo "  -h, help - this text"
	echo "  -a, action - what to do with the VMs"
	echo "  -f, class - which class VMs you want to operate"
	echo ""
	echo "ACTIONS:"
	echo "  start"
	echo "  stop"
	echo "  suspend"
	echo ""
	echo "CLASSES:"
	funcListClasses	
}


###############################
#### GETOPTS - TOOL OPTIONS ###
###############################

_OPTSTRING="a:f:lh"

while getopts ${_OPTSTRING} _FACH; do
	case "${_FACH}" in
		a)
			_ACTION_OPT="${OPTARG}"
			;;
		f)
			_FACH_OPT="${OPTARG}"
			;;
		l)
			funcListVm
			exit 1
			;;
		h)
			funcHelp
			exit 1
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
function operateVMS() {
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