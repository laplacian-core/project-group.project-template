#!/usr/bin/env bash

set -e
RAW_HOST=https://raw.githubusercontent.com/nabla-squared/laplacian.projects/master

PROJECT_DIR="$(pwd)"
PROJECT_GROUP_NAME=$(basename $PROJECT_DIR)
MODEL_DIR='model'
PROJECT_MODEL_FILE="$MODEL_DIR/project.yaml"
MODEL_SCHEMA_PARTIAL='model-schema-partial.json'
MODEL_SCHEMA_FULL='model-schema-full.json'

SCRIPTS_DIR='scripts'
PROJECT_GENERATOR="$SCRIPTS_DIR/generate.sh"
PROJECT_GENERATOR_MAIN="$SCRIPTS_DIR/.generate/main.sh"
LAPLACIAN_GENERATOR="$SCRIPTS_DIR/laplacian-generate.sh"
VSCODE_SETTING=".vscode/settings.json"

show_processing_message() {
  echo "Installing Laplacian Generator scripts.."
}

main() {
  show_processing_message
  create_blank_project_file
  install
  show_end_message
}

create_blank_project_file() {
  cat <<EOF > $PROJECT_MODEL_FILE
project:
  group: ${PROJECT_GROUP_NAME}
  name: projects
  type: project-group
  version: "1.0.0"
  description:
    en: |
      ${PROJCT_GROUP_NAME} projects.
  module_repositories:
    local:
      ../mvn-repo
    remote:
    - https://github.com/nabla-squared/mvn-repo
  model_files:
  - dest/
EOF
}

install() {
  install_file $LAPLACIAN_GENERATOR
  install_file $PROJECT_GENERATOR
  install_file $PROJECT_GENERATOR_MAIN
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
  ./$PROJECT_GENERATOR --help
}

main "$@"