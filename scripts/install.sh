#!/usr/bin/env bash

set -e
RAW_HOST='https://raw.githubusercontent.com/nabla-squared/laplacian.projects/master'

PROJECT_DIR="$(pwd)"
PROJECT_GROUP_NAME=$(basename $PROJECT_DIR)
MODEL_DIR='model'
PROJECT_MODEL_FILE="$MODEL_DIR/project.yaml"
MODEL_SCHEMA_PARTIAL='model-schema-partial.json'
MODEL_SCHEMA_FULL='model-schema-full.json'

SCRIPTS_DIR='scripts'
PROJECT_GENERATOR="$SCRIPTS_DIR/generate.sh"
LAPLACIAN_GENERATOR="$SCRIPTS_DIR/laplacian-generate.sh"
VSCODE_SETTING=".vscode/settings.json"

PROJECT_TYPE='project-group'
LOCAL_MODULE_REPOSITORY='../mvn-repo'

OPT_NAMES='t:-:'

main() {
  parse_args "$@"
  show_processing_message
  create_blank_project_file
  install
  show_end_message
}

parse_args() {
  while getopts $OPT_NAMES OPTION;
  do
    case $OPTION in
    -)
      case $OPTARG in
      project-type)
        PROJECT_TYPE=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      local-module-repository)
        LOCAL_MODULE_REPOSITORY=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    t) PROJECT_TYPE=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
    esac
  done
  ARGS=$@
}

show_processing_message() {
  echo "Installing Laplacian Generator scripts.."
}

create_blank_project_file() {
  mkdir -p $(dirname $PROJECT_MODEL_FILE)
  cat <<EOF > $PROJECT_MODEL_FILE
project:
  group: ${PROJECT_GROUP_NAME}
  name: projects
  type: $PROJECT_TYPE
  version: '1.0.0'
  description:
    en: |
      ${PROJECT_GROUP_NAME} projects.
  module_repositories:
    local:
      $LOCAL_MODULE_REPOSITORY
    remote:
    - https://raw.github.com/nabla-squared/mvn-repo/master
  model_files:
  - dest/$MODEL_DIR
EOF
}

install() {
  install_file $LAPLACIAN_GENERATOR
  install_file $PROJECT_GENERATOR
  install_file $VSCODE_SETTING
  install_file $MODEL_SCHEMA_FULL
  install_file $MODEL_SCHEMA_PARTIAL
}

install_file() {
  local rel_path="$1"
  local dir_path=$(dirname $rel_path)
  if [ ! -z $dir_path ] && [ ! -d $dir_path ]
  then
    mkdir -p $dir_path
  fi
  curl -Ls -o "$rel_path" "$RAW_HOST/$rel_path"
  if [[ $rel_path == *.sh ]]
  then
    chmod 755 "$rel_path"
  fi
}

show_end_message() {
  echo  ".. Finished."
  echo  "After editing ./$PROJECT_MODEL_FILE, run ./$PROJECT_GENERATOR to generate this project."
}

main "$@"