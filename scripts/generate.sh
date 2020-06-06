#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"


OPT_NAMES='hvdr:-:'

ARGS=
HELP=
VERBOSE=
DRY_RUN=
MAX_RECURSION=10
LOCAL_MODULE_REPOSITORY=
UPDATES_SCRIPTS_ONLY=


run_generate() {
  parse_args "$@"
  ! [ -z $VERBOSE ] && set -x
  ! [ -z $HELP ] && show_usage && exit 0

  source $SCRIPT_BASE_DIR/.generate/main.sh
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
      local-module-repository)
        LOCAL_MODULE_REPOSITORY=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      updates-scripts-only)
        UPDATES_SCRIPTS_ONLY='yes';;
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
  ARGS=$@
}

show_usage () {
cat << 'END'
Usage: ./scripts/generate.sh [OPTION]...
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
  --local-module-repository [VALUE]
    The repository path to store locally built modules.
    The modules in this repository have the highest priority.
  --updates-scripts-only
    Updates script files only.
    This option is used to generate the generator script itself
    when the project is initially generated.
END
}

run_generate "$@"