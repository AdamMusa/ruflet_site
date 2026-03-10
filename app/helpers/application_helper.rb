module ApplicationHelper
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
