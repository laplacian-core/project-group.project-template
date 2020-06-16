SUBPROJECTS_DIR="model/project/subprojects/{{hyphen project.group}}"
NEW_PROJECTS_MODEL_FILE="$PROJECT_BASE_DIR/$SUBPROJECTS_DIR/$PROJECT_NAME.yaml"

main() {
  create_subproject_model_file
  update_project
  show_next_action_message
}

create_subproject_model_file() {
  mkdir -p $(dirname $NEW_PROJECTS_MODEL_FILE)
cat <<EOF > $NEW_PROJECTS_MODEL_FILE
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

hyphenize() {
  local str=$1
  echo  ${str//[_.: ]/-}
}

update_project() {
  $SCRIPT_BASE_DIR/generate.sh
}

show_next_action_message() {
  echo ""
  echo "Created the new project's definition at: $NEW_PROJECTS_MODEL_FILE"
  echo "1. Edit this file if you need."
  echo "2. Run ./scripts/generate-$(hyphenize ${PROJECT_NAME}).sh to generate the project's content."
  echo ""
}
