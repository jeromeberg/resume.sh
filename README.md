# resume.sh

Generate an ATS-friendly PDF resume from a markdown file.

## Requirements

- Pandoc
- WeasyPrint

On macOS:

```sh
brew install pandoc weasyprint
```

## Usage

```sh
./resume.sh <input.md> [options]
```

The markdown input file is required as the first argument. See `example.md` to create yours.

The resume is generated in `out/resume.pdf`.

### Output

The output file is created in `out/` directory.

Write the PDF to a different file:

```sh
# relative path (in out/)
./resume.sh resume.md -o output.pdf

# absolute path
./resume.sh resume.md -o ~/Documents/resume.pdf
```

### Options

| Option           | Description             |
|------------------|-------------------------|
| `--output`, `-o` | Set output filepath     |
| `--template`     | Set template            |
| `--color`        | Set accent color        |
| `--title`        | Override metadata title |
| `--help`, `-h`   | Show usage and options  |

## Customization

### Content

Contact links are defined in the metadata:

```yaml
links:
  - label: example.com
    url: https://example.com
  - label: github.com/name
    url: https://github.com/name
```

Override the title from the Markdown metadata:

```sh
./resume.sh resume.md --title "Full-stack developer"
```

### Template

Select a template from `templates/`:

```sh
./resume.sh resume.md --template compact
```

List of templates:
- `default`: default template.
- `compact`: contact links to the right side.

### Color

Default accent color: `orange`.

Set the accent color:

```sh
# predefined color name
./resume.sh resume.md --color blue

# hex color code (#rrggbb)
./resume.sh resume.md --color "#b45309"
```

Predefined colors:

| Name     | Value     |
|----------|-----------|
| `orange` | #b45309 |
| `blue`   | #1d4ed8 |
| `green`  | #15803d |
| `pink`   | #be185d |
