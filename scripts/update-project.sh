#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"
LOCAL_REPO_PATH="$PROJECT_BASE_DIR/../mvn-repo"
if [[ -d "$PROJECT_BASE_DIR/subprojects/mvn-repo" ]]
then
  LOCAL_REPO_PATH="$PROJECT_BASE_DIR/subprojects/mvn-repo"
fi

${SCRIPT_BASE_DIR}/laplacian-generate.sh \
  --plugin 'laplacian:laplacian.project.schema-plugin:1.0.0' \
  --model 'laplacian:laplacian.project.project-types:1.0.0' \
  --template 'laplacian:laplacian.project.base-template:1.0.0' \
  --model-files './model/project.yaml' \
  --model-files './model/project' \
  --target-dir './' \
  --local-repo "$LOCAL_REPO_PATH"
