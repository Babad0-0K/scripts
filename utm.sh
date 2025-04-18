#!/bin/bash

# ===================================================================
# Filename:        utm.sh
# Author:          Lorenzo De Simone
# Version:         1.0
# Created:         2025-04-16
# Description:     CLI Script to start UTM VMs based by Class
# ===================================================================


# to-do: implement error handling
# to-do: implement delete action
# to-do: implement colors

##########################
### Preparation Tasks ####
##########################

# Declare VMs, classes and actions array
declare -a _IFA_VMS
declare -a _IFA_CLASSES
declare -a _UTM_ACTIONS=("start" "stop" "suspend")

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

# List Actions
function funcListActions() {
	for _action in "${_UTM_ACTIONS[@]}"
		do
			echo "  ${_action}"
	done
}

# List VMs sorted by Class
function funcListVmByClass() {
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
	echo "  utm -a <action> -c <class>"
	echo ""
	echo "EXAMPLE:"
	echo "  utm -a start -c BMBS"
	echo "  utm -a stop -c BMBS"
	echo ""
	echo "OPTIONS:"
	echo "  -l, list - List VMs sorted by Class"
	echo "  -h, help - this text"
	echo "  -a, action - what to do with the VMs"
	echo "  -c, class - which class VMs you want to operate"
	echo ""
	echo "ACTIONS:"
	funcListActions
	echo ""
	echo "CLASSES:"
	funcListClasses	
}


###############################
#### GETOPTS - TOOL OPTIONS ###
###############################

_OPTSTRING="a:c:lh"

while getopts "${_OPTSTRING}" opt; do
	case "${opt}" in
		h) funcHelp; exit 0;;
		a) _ACTION_OPT="${OPTARG}"; _CHECKARG1=1;;
		c) _CLASS_OPT="${OPTARG}"; _CHECKARG2=2;;
		l) funcListVmByClass; exit 0;;
		\?) echo "**Unknown option**" >&2; echo ""; funcHelp; exit 1;;
		:) echo "**Missing option argument**" >&2; echo ""; funcHelp; exit 1;;
	esac
done

shift $(( OPTIND - 1 ))

# Check if Argument Action and Argument Class has been set
if [ "${_CHECKARG1}" == "" ] || [ "${_CHECKARG2}" == "" ]; then
	echo "**At least one argument is missing**"
	echo ""
	funcHelp
	exit
fi

# Function to operate VMs for chosen Fach 
function operateVMS() {
	local _action_opt=${1}
	local _class_opt=${2}

	for i in "${_IFA_VMS[@]}"
	do
		if [[ "${i: -4}" == "${_class_opt}" ]]; then
			echo  "utmctl ${_action_opt} ${i}"
		fi
	done
}

# Main Script
operateVMS "${_ACTION_OPT}" "${_CLASS_OPT}"