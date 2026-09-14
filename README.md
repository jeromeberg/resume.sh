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
./resume.sh
```

The generated file is `out/resume.pdf`.

Use a different input file (Markdown):

```sh
./resume.sh --input input.md
```

Write the PDF to a different file:

```sh
./resume.sh --output output.pdf
```

### Options

| Option         | Description                    |
|----------------|--------------------------------|
| `--input`      | Set input file (`resume.md`)   |
| `--output`     | Set output file (`resume.pdf`) |
| `--template`   | Set template (`default`)       |
| `--color`      | Set accent color (`orange`)    |
| `--title`      | Override title from metadata   |
| `--help`, `-h` | List options                   |

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
./resume.sh --title "Full-stack developer"
```

### Template

Select a template from `templates/`:

```sh
./resume.sh --template compact
```

List of templates:
- `default`: default template.
- `compact`: default template with contact links to the right side.

### Color

Set the accent color:

```sh
./resume.sh --color blue
./resume.sh --color "#b45309"
```

Predefined colors:

- `orange`: `#b45309` (default)
- `blue`: `#1d4ed8`
- `green`: `#15803d`
- `yellow`: `#a16207`
- `pink`: `#be185d`

Custom colors must use the six-digit `#RRGGBB` format.