#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"

LOCAL_REPO_PATH="$PROJECT_BASE_DIR/../mvn-repo"
if [[ -d "$PROJECT_BASE_DIR/subprojects/mvn-repo" ]]
then
  LOCAL_REPO_PATH="$PROJECT_BASE_DIR/subprojects/mvn-repo"
fi

OPT_NAMES='hvdr:-:'

HELP=
VERBOSE=
DRY_RUN=
MAX_RECURSION=10


run_generate() {
  parse_args "$@"
  ! [ -z $VERBOSE ] && set -x
  ! [ -z $HELP ] && show_usage && exit 0
  main
}

parse_args() {
  while getopts $OPT_NAMES OPTION;
  do
    case $OPTION in
    -)
      case $OPTARG in
      help)
        HELP='yes';;
      verbose)
        VERBOSE='yes';;
      dry-run)
        DRY_RUN='yes';;
      max-recursion)
        MAX_RECURSION=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    h) HELP='yes';;
    v) VERBOSE='yes';;
    d) DRY_RUN='yes';;
    r) MAX_RECURSION=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
    esac
  done
}

show_usage () {
cat << END
Usage: $(basename "$0") [OPTION]...
  -h, --help
    Displays how to use this command.
  -v, --verbose
    Displays more detailed command execution information.
  -d, --dry-run
    After this command is processed, the generated files are output to the `.NEXT` directory
    without reflecting to the folders of `dest/` `doc/` `scripts/`.
    In addition, the difference between the contents of the `.NEXT` directory and the current files.
    This directory also contains any intermediate files created during the generation.
  -r, --max-recursion [VALUE]
    The upper limit of the number of times to execute recursively
    when the contents of the `model/` `template/` directory are updated
    during the generation process. (Default: 10)
END
}

source $SCRIPT_BASE_DIR/.generate/main.sh
run_generate "$@"