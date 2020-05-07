#!/usr/bin/env bash

source $SCRIPT_BASE_DIR/.publish-local/publish.sh

main() {
  if [ -z $SKIP_GENERATION ]
  then
    generate
  fi
  publish
}

generate() {
  $SCRIPT_BASE_DIR/generate.sh
}