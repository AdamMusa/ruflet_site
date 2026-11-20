# Image

Render local, remote, or generated images.

## Example

```ruby
image(
  "https://picsum.photos/320/180",
  width: 320,
  height: 180
)
```

## Common properties

- positional source
- `src`
- `width`
- `height`
- `fit`
- `border_radius`
- `placeholder_src`

## Usage

```ruby
image(
  "assets/icon.png",
  width: 96,
  height: 96
)
```

## Notes

- Use local assets for app icons and packaged images
