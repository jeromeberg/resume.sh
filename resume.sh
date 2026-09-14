#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
input_path="$dir/resume.md"
templates_dir="$dir/templates"
output_dir="$dir/out"

title=""
template="default"
color="orange"
output="resume.pdf"

print_help() {
  cat <<'EOF'
Usage: ./resume.sh [options]

Options:
  --input FILE     Override input file (default: resume.md).
  --title TITLE    Override title from input metadata.
  --template NAME  Use template from templates/ (default: default).
  --color COLOR    Set accent color (default: orange).
  --output NAME    Override output file (default: resume.pdf).
  -h, --help       Show this help message.
EOF
}

while (($#)); do
  case "$1" in
    --input)
      [[ $# -ge 2 ]] || { echo "error: --input requires a value" >&2; exit 2; }
      input_path="$2"
      shift 2
      ;;
    --input=*)
      input_path="${1#*=}"
      shift
      ;;
    --title)
      [[ $# -ge 2 ]] || { echo "error: --title requires a value" >&2; exit 2; }
      title="$2"
      shift 2
      ;;
    --title=*)
      title="${1#*=}"
      shift
      ;;
    --template)
      [[ $# -ge 2 ]] || { echo "error: --template requires a value" >&2; exit 2; }
      template="$2"
      shift 2
      ;;
    --template=*)
      template="${1#*=}"
      shift
      ;;
    --color)
      [[ $# -ge 2 ]] || { echo "error: --color requires a value" >&2; exit 2; }
      color="$2"
      shift 2
      ;;
    --color=*)
      color="${1#*=}"
      shift
      ;;
    --output)
      [[ $# -ge 2 ]] || { echo "error: --output requires a value" >&2; exit 2; }
      output="$2"
      shift 2
      ;;
    --output=*)
      output="${1#*=}"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      print_help >&2
      exit 2
      ;;
  esac
done

[[ -n "$input_path" ]] || {
  echo "error: --input requires a value" >&2
  exit 2
}
if [[ "$input_path" != /* ]]; then
  input_path="$PWD/$input_path"
fi
[[ "$template" =~ ^[A-Za-z0-9_-]+$ ]] || {
  echo "error: invalid template name: $template" >&2
  exit 2
}
case "$color" in
  orange) accent_color="#b45309" ;;
  blue) accent_color="#1d4ed8" ;;
  green) accent_color="#15803d" ;;
  yellow) accent_color="#a16207" ;;
  pink) accent_color="#be185d" ;;
  *)
    if [[ "$color" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
      accent_color="$color"
    else
      echo "error: invalid color '$color'; use orange, blue, green, yellow, pink, or #RRGGBB" >&2
      exit 2
    fi
    ;;
esac
[[ -n "$output" ]] || {
  echo "error: --output requires a value" >&2
  exit 2
}
[[ "$output" != */* && "$output" != "." && "$output" != ".." ]] || {
  echo "error: --output must be a filename, not a path" >&2
  exit 2
}

output_path="$output_dir/$output"

template_dir="$templates_dir/$template"
template_path="$template_dir/template.html"
stylesheet_path="$template_dir/style.css"

[[ -f "$input_path" ]] || { echo "error: input markdown file not found: $input_path" >&2; exit 1; }
[[ -f "$template_path" && -f "$stylesheet_path" ]] || {
  echo "error: template '$template' not found in $templates_dir" >&2
  exit 1
}

command -v pandoc >/dev/null 2>&1 || {
  echo "error: pandoc is required" >&2
  exit 1
}
command -v weasyprint >/dev/null 2>&1 || {
  echo "error: weasyprint is required" >&2
  exit 1
}

mkdir -p "$output_dir"
html_path="$(mktemp "${TMPDIR:-/tmp}/resume.XXXXXX.html")"
trap 'rm -f "$html_path"' EXIT

pandoc_args=(
  "$input_path"
  --from=markdown
  --to=html5
  --standalone
  --template="$template_path"
  --css="$stylesheet_path"
  --embed-resources
  "--variable=accent_color:$accent_color"
  --output="$html_path"
)

if [[ -n "$title" ]]; then
  pandoc_args+=("--metadata=title:$title")
fi

pandoc "${pandoc_args[@]}"
weasyprint --quiet --pdf-tags "$html_path" "$output_path"

echo "Created $output_path"
