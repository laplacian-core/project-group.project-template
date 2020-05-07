#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"

LOCAL_REPO_PATH="$PROJECT_BASE_DIR/../mvn-repo"
if [[ -d "$PROJECT_BASE_DIR/subprojects/mvn-repo" ]]
then
  LOCAL_REPO_PATH="$PROJECT_BASE_DIR/subprojects/mvn-repo"
fi

OPT_NAMES='hvr:-:'

HELP=
VERBOSE=
MAX_RECURSION=10
SKIP_GENERATION=


run_publish_local() {
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
      max-recursion)
        MAX_RECURSION=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      skip-generation)
        SKIP_GENERATION='yes';;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    h) HELP='yes';;
    v) VERBOSE='yes';;
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
  -r, --max-recursion [VALUE]
    This option is the same as the option of the same name in [generate.sh](<./scripts/generate.sh>). (Default: 10)
  --skip-generation
    This option is the same as the option of the same name in [generate.sh](<./scripts/generate.sh>).
END
}

source $SCRIPT_BASE_DIR/.publish-local/main.sh
run_publish_local "$@"