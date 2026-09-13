#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
resume_path="$dir/resume.md"
themes_dir="$dir/themes"
output_dir="$dir/out"

title=""
theme="orange"
output_name="resume.pdf"

print_help() {
  cat <<'EOF'
Usage: ./resume.sh [options]

Options:
  --title TITLE    Override title from resume.md.
  --theme THEME    Use theme from themes/ (default: orange).
  --output NAME    Override output filename (default: resume.pdf).
  -h, --help       Show this help message.
EOF
}

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
    --theme)
      [[ $# -ge 2 ]] || { echo "error: --theme requires a value" >&2; exit 2; }
      theme="$2"
      shift 2
      ;;
    --theme=*)
      theme="${1#*=}"
      shift
      ;;
    --output)
      [[ $# -ge 2 ]] || { echo "error: --output requires a value" >&2; exit 2; }
      output_name="$2"
      shift 2
      ;;
    --output=*)
      output_name="${1#*=}"
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

[[ "$theme" =~ ^[A-Za-z0-9_-]+$ ]] || {
  echo "error: invalid theme name: $theme" >&2
  exit 2
}
[[ -n "$output_name" ]] || {
  echo "error: --output requires a value" >&2
  exit 2
}
[[ "$output_name" != */* && "$output_name" != "." && "$output_name" != ".." ]] || {
  echo "error: --output must be a filename, not a path" >&2
  exit 2
}

output_path="$output_dir/$output_name"

theme_dir="$themes_dir/$theme"
template_path="$theme_dir/template.html"
stylesheet_path="$theme_dir/style.css"

[[ -f "$resume_path" ]] || { echo "error: resume.md not found" >&2; exit 1; }
[[ -f "$template_path" && -f "$stylesheet_path" ]] || {
  echo "error: theme '$theme' not found in $themes_dir" >&2
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
  "$resume_path"
  --from=markdown
  --to=html5
  --standalone
  --template="$template_path"
  --css="$stylesheet_path"
  --embed-resources
  --output="$html_path"
)

if [[ -n "$title" ]]; then
  pandoc_args+=("--metadata=title:$title")
fi

pandoc "${pandoc_args[@]}"
weasyprint --quiet --pdf-tags "$html_path" "$output_path"

echo "Created $output_path"
