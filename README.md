# resume-md

Generate a PDF resume from a markdown file.

## Requirements

- Pandoc
- WeasyPrint

On macOS:

```sh
brew install pandoc weasyprint
```

## Usage

```sh
./resume.sh
```

The generated file is `out/resume.pdf`.

Contact links are defined in the `resume.md` metadata:

```yaml
links:
  - label: example.com
    url: https://example.com
  - label: github.com/name
    url: https://github.com/name
```

Override the title from the Markdown metadata:

```sh
./resume.sh --title "Full-stack developer"
```

Select a theme from `themes/`:

```sh
./resume.sh --theme orange
```

Write the PDF to a different file:

```sh
./resume.sh --output custom.pdf
```
