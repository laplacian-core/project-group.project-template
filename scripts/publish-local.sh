#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"


OPT_NAMES='hvr:-:'

ARGS=
HELP=
VERBOSE=
MAX_RECURSION=10
SKIP_GENERATION=
LOCAL_MODULE_REPOSITORY=


run_publish_local() {
  parse_args "$@"
  ! [ -z $VERBOSE ] && set -x
  ! [ -z $HELP ] && show_usage && exit 0

  source $SCRIPT_BASE_DIR/.publish-local/main.sh
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
      local-module-repository)
        LOCAL_MODULE_REPOSITORY=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
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
  ARGS=$@
}

show_usage () {
cat << 'END'
Usage: ./scripts/publish-local.sh [OPTION]...
  -h, --help
    Displays how to use this command.
  -v, --verbose
    Displays more detailed command execution information.
  -r, --max-recursion [VALUE]
    This option is the same as the option of the same name in [generate.sh](<./scripts/generate.sh>). (Default: 10)
  --skip-generation
    This option is the same as the option of the same name in [generate.sh](<./scripts/generate.sh>).
  --local-module-repository [VALUE]
    The path to the local repository where the built module will be stored.
    If the repository does not exist in the specified path, it will be created automatically.
END
}

run_publish_local "$@"