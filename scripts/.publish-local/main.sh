#!/usr/bin/env bash

main() {
  if [ -z $SKIP_GENERATION ]
  then
    generate
  fi
  source $SCRIPT_BASE_DIR/.publish-local/publish.sh
  publish
}

generate() {
  $SCRIPT_BASE_DIR/generate.sh
}