module ApplicationHelper
  def github_icon
    content_tag(:svg, viewBox: "0 0 24 24", fill: "currentColor", class: "h-5 w-5", aria: { hidden: true }) do
      tag.path(d: "M12 2C6.48 2 2 6.58 2 12.23c0 4.52 2.87 8.36 6.84 9.71.5.1.68-.22.68-.48 0-.24-.01-1.04-.01-1.88-2.78.62-3.37-1.21-3.37-1.21-.46-1.18-1.11-1.5-1.11-1.5-.91-.64.07-.62.07-.62 1 .07 1.53 1.06 1.53 1.06.9 1.57 2.35 1.12 2.92.86.09-.67.35-1.12.63-1.38-2.22-.26-4.55-1.14-4.55-5.09 0-1.13.39-2.05 1.03-2.78-.1-.26-.45-1.31.1-2.73 0 0 .84-.28 2.75 1.06A9.3 9.3 0 0 1 12 6.84c.85 0 1.71.12 2.51.35 1.9-1.34 2.74-1.06 2.74-1.06.55 1.42.2 2.47.1 2.73.64.73 1.03 1.65 1.03 2.78 0 3.96-2.34 4.82-4.57 5.08.36.32.68.95.68 1.92 0 1.39-.01 2.5-.01 2.84 0 .27.18.59.69.49A10.25 10.25 0 0 0 22 12.23C22 6.58 17.52 2 12 2Z")
    end
  end

  def feature_icon(name)
    if name == :ruby
      return image_tag("ruby.png", alt: "Ruby", class: "h-6 w-6 object-contain")
    end

    if name == :gems
      return image_tag("rubygem.png", alt: "RubyGems", class: "h-6 w-6 object-contain")
    end

    classes = "h-6 w-6"

    path =
      case name
      when :devices
        tag.path(d: "M4 7.5A2.5 2.5 0 0 1 6.5 5h7A2.5 2.5 0 0 1 16 7.5v5A2.5 2.5 0 0 1 13.5 15h-1.25v1.25A1.75 1.75 0 0 1 10.5 18h-4A2.5 2.5 0 0 1 4 15.5v-8Z", fill: "none", stroke: "currentColor", "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "1.75") +
          tag.path(d: "M7 18h3.5", fill: "none", stroke: "currentColor", "stroke-linecap": "round", "stroke-width": "1.75")
      when :controls
        tag.rect(x: "4", y: "4", width: "6", height: "6", rx: "1.5", fill: "none", stroke: "currentColor", "stroke-width": "1.75") +
          tag.rect(x: "14", y: "4", width: "6", height: "6", rx: "1.5", fill: "none", stroke: "currentColor", "stroke-width": "1.75") +
          tag.rect(x: "4", y: "14", width: "6", height: "6", rx: "1.5", fill: "none", stroke: "currentColor", "stroke-width": "1.75") +
          tag.rect(x: "14", y: "14", width: "6", height: "6", rx: "1.5", fill: "none", stroke: "currentColor", "stroke-width": "1.75")
      when :web
        tag.circle(cx: "12", cy: "12", r: "8", fill: "none", stroke: "currentColor", "stroke-width": "1.75") +
          tag.path(d: "M4.5 12h15M12 4.5a12.7 12.7 0 0 1 0 15M12 4.5a12.7 12.7 0 0 0 0 15", fill: "none", stroke: "currentColor", "stroke-linecap": "round", "stroke-width": "1.5")
      when :package
        tag.path(d: "M5 7.5 12 4l7 3.5v9L12 20l-7-3.5v-9Z", fill: "none", stroke: "currentColor", "stroke-linejoin": "round", "stroke-width": "1.75") +
          tag.path(d: "M12 20v-8.5", fill: "none", stroke: "currentColor", "stroke-width": "1.75")
      when :mobile
        tag.rect(x: "7.5", y: "3.5", width: "9", height: "17", rx: "2", fill: "none", stroke: "currentColor", "stroke-width": "1.75") +
          tag.path(d: "M11 17.5h2", fill: "none", stroke: "currentColor", "stroke-linecap": "round", "stroke-width": "1.75")
      when :blocks
        tag.path(d: "M7 7h5v5H7zM12 12h5v5h-5zM12 7h5v5h-5zM7 12h5v5H7z", fill: "none", stroke: "currentColor", "stroke-linejoin": "round", "stroke-width": "1.75")
      when :accessibility
        tag.circle(cx: "12", cy: "5.5", r: "2", fill: "none", stroke: "currentColor", "stroke-width": "1.75") +
          tag.path(d: "M12 8v5m0 0-4 7m4-7 4 7m-8-9 4-2 4 2", fill: "none", stroke: "currentColor", "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "1.75")
      end

    content_tag(:svg, path, viewBox: "0 0 24 24", fill: "none", class: classes, aria: { hidden: true })
  end
end
