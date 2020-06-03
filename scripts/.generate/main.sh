#!/usr/bin/env bash

NEXT_CONTENT_DIR_NAME='.NEXT'
NEXT_CONTENT_DIR="$PROJECT_BASE_DIR/$NEXT_CONTENT_DIR_NAME"
PREV_CONTENT_DIR_NAME='.PREV'
PREV_CONTENT_DIR="$PROJECT_BASE_DIR/$PREV_CONTENT_DIR_NAME"
DEST_DIR_NAME='dest'
SRC_DIR_NAME='src'

CONTENT_DIRS='src template model'
UPDATABLE_DIRS='dest scripts doc .vscode'
CONTENT_FILES='.editorconfig .gitattributes .gitignore README.md README_*.md model-schema-*.json'

RECURSION_COUNT=1

main() {
  create_next_content_dir
  update_file_index
  while ! has_settled
  do
    (( $RECURSION_COUNT > $MAX_RECURSION )) && echo "Exceeded the maximum recursion depth: $MAX_RECURSION" && exit 1
    rm -rf $PREV_CONTENT_DIR
    cp -rf $NEXT_CONTENT_DIR $PREV_CONTENT_DIR
    generate
    RECURSION_COUNT=$(($RECURSION_COUNT + 1))
  done
  if [ -z $DRY_RUN ]
  then
    trap apply_next_content EXIT
  else
    diff --color -r $NEXT_CONTENT_DIR $PROJECT_BASE_DIR
  fi
}

create_next_content_dir() {
  rm -rf $NEXT_CONTENT_DIR $PREV_CONTENT_DIR
  mkdir -p $NEXT_CONTENT_DIR
  (cd $PROJECT_BASE_DIR
    dirs=$(for each in $CONTENT_DIRS; do [ -d $each ] && echo $each || true; done)
    files=$(for each in $CONTENT_FILES; do [ -f $each ] && echo $each || true; done)
    [ -z "$dirs" ] || cp -rf $dirs $NEXT_CONTENT_DIR
    [ -z "$files" ] || cp -f $files $NEXT_CONTENT_DIR
  )

  local src_dir="$NEXT_CONTENT_DIR/$SRC_DIR_NAME"
  local dest_dir="$NEXT_CONTENT_DIR/$DEST_DIR_NAME"

  rm -rf $dest_dir
  if [ -d $src_dir ]
  then
    cp -rf $src_dir $dest_dir
  else
    mkdir -p $dest_dir
  fi
}

normalize_path() {
  local path=$1
  if [[ $path == ./* ]]
  then
    echo "${PROJECT_BASE_DIR}/$path"
  elif [[ $path == /* ]]
  then
    echo $path
  else
    echo "$NEXT_CONTENT_DIR/$path"
  fi
}

update_file_index() {
  local index_dir="$NEXT_CONTENT_DIR/model/project"
  mkdir -p $index_dir
  cat <<EOF > "$index_dir/sources.yaml"
project:
  sources:$(file_list | sort -d)
EOF
}

file_list() {
  (cd "$PROJECT_BASE_DIR"
    local separator="\n  - "
    local dirs=
    [ -d ./model ] && dirs="$dirs ./model"
    [ -d ./template ] && dirs="$dirs ./template"
    [ -d ./src ] && dirs="$dirs ./src"
    find $dirs -type f | while read -r file
    do
      printf "$separator\"${file:2}\""
    done
    printf "\n"
  )
}

generate() {
  local generator_script="$PROJECT_BASE_DIR/scripts/laplacian-generate.sh"
  local schema_file_path="$(normalize_path 'model-schema-partial.json')"
  local schema_option=
  if [ -f $schema_file_path ]
  then
    schema_option="--model-schema $(normalize_path 'model-schema-partial.json')"
  fi
  $generator_script ${VERBOSE:+'-v'} \
    --plugin 'laplacian:laplacian.metamodel-plugin:1.0.0' \
    --plugin 'laplacian:laplacian.project.domain-model-plugin:1.0.0' \
    --plugin 'laplacian:laplacian.common-model-plugin:1.0.0' \
    --template 'laplacian:laplacian.generator.project-template:1.0.0' \
    --model 'laplacian:laplacian.project.project-types:1.0.0' \
    --model 'laplacian:laplacian.project.domain-model:1.0.0' \
    --model 'laplacian:laplacian.common-model:1.0.0' \
    $schema_option \
    --model-files $(normalize_path 'model/') \
    --template-files $(normalize_path 'template/') \
    --template-files $(normalize_path 'dest/') \
    --target-dir "$NEXT_CONTENT_DIR_NAME" \
    --local-repo "$LOCAL_REPO_PATH"
}

has_settled() {
  [ $RECURSION_COUNT == 1 ] && return 1
  [ -d $NEXT_CONTENT_DIR ] || return 1
  [ -d $PREV_CONTENT_DIR ] || return 1
  diff -r $NEXT_CONTENT_DIR $PREV_CONTENT_DIR > /dev/null
}

apply_next_content() {
  (cd $PROJECT_BASE_DIR
    dirs=$(for each in $UPDATABLE_DIRS; do [ -d $each ] && echo $each || true; done)
    files=$(for each in $CONTENT_FILES; do [ -f $each ] && echo $each || true; done)
    rm -rf $dirs
    rm -f $files
  )

  (cd $NEXT_CONTENT_DIR
    dirs=$(for each in $UPDATABLE_DIRS; do [ -d $each ] && echo $each || true; done)
    files=$(for each in $CONTENT_FILES; do [ -f $each ] && echo $each || true; done)
    cp -rf $dirs $PROJECT_BASE_DIR
    cp -f $files $PROJECT_BASE_DIR
  )

  rm -rf $NEXT_CONTENT_DIR $PREV_CONTENT_DIR
}