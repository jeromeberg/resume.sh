#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
templates_dir="$dir/templates"
output_dir="$dir/out"

title=""
template="default"
color="orange"
output="resume.pdf"

print_help() {
  cat <<'EOF'
Usage: ./resume.sh <input.md> [options]

Generate an ATS-friendly PDF resume from a markdown file.
https://github.com/jeromeberg/resume.sh

Options:
  --output, -o PATH  Set output filepath / name.
  --template NAME    Use template from templates/.
  --color COLOR      Set accent color.
  --title TITLE      Override metadata title.
  --help, -h         Show this help message.
EOF
}

if (($# == 0)); then
  echo "error: input markdown file is required as the first argument" >&2
  print_help >&2
  exit 2
fi
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  print_help
  exit 0
fi
if [[ "$1" == -* ]]; then
  echo "error: input markdown file must be the first argument" >&2
  print_help >&2
  exit 2
fi
input_path="$1"
shift

while (($#)); do
  case "$1" in
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
    -o|--output)
      [[ $# -ge 2 ]] || { echo "error: $1 requires a value" >&2; exit 2; }
      output="$2"
      shift 2
      ;;
    -o=*|--output=*)
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
  echo "error: input markdown file is required as the first argument" >&2
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
  pink) accent_color="#be185d" ;;
  *)
    if [[ "$color" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
      accent_color="$color"
    else
      echo "error: invalid color '$color'; use predefined color name or hex color code (#RRGGBB)" >&2
      exit 2
    fi
    ;;
esac
[[ -n "$output" ]] || {
  echo "error: --output requires a value" >&2
  exit 2
}
if [[ "$output" == /* ]]; then
  output_path="$output"
else
  output_path="$output_dir/$output"
fi

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

mkdir -p "$(dirname "$output_path")"
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
