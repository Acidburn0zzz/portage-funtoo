#!/bin/bash
# Copyright 2010-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

PYTHON_VERSIONS="2.6 2.7 3.1 3.2 3.3"

# has to be run from portage root dir
cd "${0%/*}" || exit 1

case "${NOCOLOR:-false}" in
	yes|true)
		GOOD=
		BAD=
		NORMAL=
		;;
	no|false)
		GOOD=$'\e[1;32m'
		BAD=$'\e[1;31m'
		NORMAL=$'\e[0m'
		;;
esac

interrupted() {
	echo "interrupted." >&2
	exit 1
}

trap interrupted SIGINT

unused_args=()

while [ $# -gt 0 ] ; do
	case "$1" in
		--python-versions=*)
			PYTHON_VERSIONS=${1#--python-versions=}
			;;
		--python-versions)
			shift
			PYTHON_VERSIONS=$1
			;;
		*)
			unused_args[${#unused_args[@]}]=$1
			;;
	esac
	shift
done

set -- "${unused_args[@]}"

exit_status="0"
for version in ${PYTHON_VERSIONS}; do
	if [[ -x /usr/bin/python${version} ]]; then
		echo -e "${GOOD}Testing with Python ${version}...${NORMAL}"
		if ! /usr/bin/python${version} -Wd pym/portage/tests/runTests "$@" ; then
			echo -e "${BAD}Testing with Python ${version} failed${NORMAL}"
			exit_status="1"
		fi
		echo
	fi
done

exit ${exit_status}
