SUBPROJECTS_DIR="model/project/subprojects/{{hyphen project.group}}"

main() {
  create_subproject_model_file
  generate_subproject
  show_next_action_message
}

create_subproject_model_file() {
  local model_file="$PROJECT_BASE_DIR/$SUBPROJECTS_DIR/$PROJECT_NAME.yaml"
  mkdir -p $(dirname $model_file)
cat <<EOF > $model_file
_description: &description
  en: |
    The $PROJECT_NAME project.

project:
  subprojects:
  - group: '{{project.group}}'
    type: '{{hyphen project_type.name}}'
    name: '$PROJECT_NAME'
    namespace: '$NAMESPACE'
    description: *description
    version: '$PROJECT_VERSION'
#   source_repository:
#     url: https://github.com/{{hyphen project.group}}/$PROJECT_NAME.git
    {{#if (eq project_type.role 'model') ~}}
    model_files:
    - dest/model
    {{/if}}
    {{#if (eq project_type.role 'template') ~}}
    template_files:
    - dest/template
    {{/if}}
EOF
}

generate_subproject() {
  $SCRIPT_BASE_DIR/generate.sh
  $SCRIPT_BASE_DIR/generate-${PROJECT_NAME}.sh
}

show_next_action_message() {
  echo "The new subproject is created at ./subprojects/${PROJECT_NAME}/"
}
