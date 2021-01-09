#!/bin/bash
set -e

# print output in a neat box
function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

# validate argument count
if [[ $# -ne 2 ]]; then
  box_out "Invalid arguments..." "Usage: ./install.sh BASE_DIR SIESTA_VERSION"
  exit 1
fi

# set variables
BASE_DIR=$1
SIESTA_DIR=$BASE_DIR/siesta
OPENBLAS_DIR=$BASE_DIR/openblas
SCALAPACK_DIR=$BASE_DIR/scalapack
SIESTA_FULL_VERSION=$2
SIESTA_PART_VERSION=$(echo $SIESTA_FULL_VERSION | cut -d'-' -f 1)

# validate supported versions
SUPPORTED_VERSIONS=('4.1-b3' '4.1-b4')

function contains() {
  local array="$1[@]"
  local value=$2
  local ret="INVALID"
  for element in "${!array}"; do
    if [[ $element == "$value" ]]; then
      ret="VALID"
      break
    fi
  done
  echo $ret
}

VERSION_VALID=$(contains SUPPORTED_VERSIONS $SIESTA_FULL_VERSION)

if [[ $VERSION_VALID == "INVALID" ]]; then
  box_out "Version $SIESTA_FULL_VERSION not in supported versions..." "Supported versions are" "${SUPPORTED_VERSIONS[@]}"
  exit 2
fi

# validate empty installation directories
if [[ -d $SIESTA_DIR ]]; then
  box_out "Existing installation of Siesta found at $SIESTA_DIR..." "Please remove the directory manually or choose a different base directory..."
  exit 3
fi

if [[ -d $OPENBLAS_DIR ]]; then
  box_out "Existing installation of OpenBLAS found at $OPENBLAS_DIR..." "Please remove the directory manually or choose a different base directory..."
  exit 3
fi

if [[ -d $SCALAPACK_DIR ]]; then
  box_out "Existing installation of ScaLAPACK found at $SCALAPACK_DIR..." "Please remove the directory manually or choose a different base directory..."
  exit 3
fi

# print validation success message
box_out "Validation OK" "" "BASE_DIR = $BASE_DIR" "SIESTA_DIR = $SIESTA_DIR" "OPENBLAS_DIR = $OPENBLAS_DIR" "SCALAPACK_DIR = $SCALAPACK_DIR" "SIESTA_VERSION = $SIESTA_FULL_VERSION"
read -p "Press Enter to continue..."
