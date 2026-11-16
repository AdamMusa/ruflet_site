# frozen_string_literal: true

require "pathname"

# Reads property types and defaults from the ruflet-engine Dart renderers.
#
# Two styles exist in the engine:
#
# * Controls with a declared contract (`ControlSpec`) list each key as
#   `PropSpec('name', PropType.color, ..., skins: {Skin.cupertino})` and parse
#   it with a `PropReader` call such as `r.number('elevation')` or
#   `r.enumValue(Clip.values, 'clip_behavior', Clip.none)`.
# * The rest read keys directly: `control.getDouble("elevation", 1.0)`.
#
# Both give a type, and a literal second argument gives the default. The
# result maps a wire type to {property => {"type", "default", "skins"}}; the
# sync script keeps only keys the Ruby control actually accepts.
module EngineProps
  module_function

  GETTER_TYPES = {
    "Bool" => "Boolean", "Double" => "Number", "Int" => "Integer", "String" => "String",
    "Color" => "Color", "WidgetStateColor" => "Color", "Padding" => "Padding",
    "Margin" => "Padding", "EdgeInsets" => "Padding", "WidgetStatePadding" => "Padding",
    "IconData" => "Icon", "Src" => "String", "Url" => "Url", "Expand" => "Boolean or Integer",
    "ResponsiveNumber" => "Number or breakpoint map", "Key" => "String",
    "WidgetStateDouble" => "Number", "WidgetStateTextStyle" => "TextStyle",
    "WidgetStateBorderSide" => "BorderSide", "WidgetStateOutlinedBorder" => "OutlinedBorder",
    "WidgetStateMouseCursor" => "MouseCursor", "ImageProvider" => "Image source"
  }.freeze

  PROP_TYPES = {
    "boolean" => "Boolean", "integer" => "Integer", "number" => "Number", "string" => "String",
    "color" => "Color", "stateColor" => "Color", "stateNumber" => "Number", "stateIcon" => "Icon",
    "stateBorderSide" => "BorderSide", "textStyle" => "TextStyle", "edgeInsets" => "Padding",
    "borderRadius" => "BorderRadius", "outlinedBorder" => "OutlinedBorder", "alignment" => "Alignment",
    "duration" => "Duration", "animation" => "Animation", "enumName" => "Enum", "icon" => "Icon",
    "image" => "Image source", "mouseCursor" => "MouseCursor", "widget" => "Control",
    "textOrWidget" => "String or Control", "iconOrWidget" => "Icon or Control", "widgets" => "Array of controls"
  }.freeze

  # Builders that take a child control rather than a parsed value.
  WIDGET_READERS = {
    "buildWidget" => "Control", "child" => "Control", "buildWidgets" => "Array of controls",
    "children" => "Array of controls", "buildTextOrWidget" => "String or Control",
    "buildIconOrWidget" => "Icon or Control"
  }.freeze

  def getter_type(getter)
    name = getter.sub(/\Aget/, "").sub(/<.*>\z/, "")
    return nil if name.empty?

    GETTER_TYPES.fetch(name) { name }
  end

  # The text of one argument list starting just after `(`, split at top-level
  # commas. Stops at the matching `)`.
  def call_arguments(source, start)
    depth = 0
    args = [+""]
    quote = nil
    source[start..].each_char do |char|
      if quote
        args.last << char
        quote = nil if char == quote
        next
      end
      case char
      when "'", '"'
        quote = char
        args.last << char
      when "(", "[", "{"
        depth += 1
        args.last << char
      when ")", "]", "}"
        return args.map(&:strip) if depth.zero?

        depth -= 1
        args.last << char
      when ","
        depth.zero? ? args << +"" : args.last << char
      else
        args.last << char
      end
    end
    args.map(&:strip)
  end

  # A Dart default expression as documentation, or nil when it is not a
  # literal (theme lookups, computed values).
  def literal_default(expression)
    text = expression.to_s.strip.delete_suffix("!")
    case text
    when "true", "false" then text
    when /\A-?\d+(?:\.\d+)?\z/ then text.sub(/\.0\z/, "")
    when /\A(['"])(.*)\1\z/ then Regexp.last_match(2).inspect
    when /\A(?:const\s+)?Duration\(\s*(milliseconds|seconds|microseconds):\s*(\d+)\s*\)\z/
      unit = { "milliseconds" => "ms", "seconds" => "s", "microseconds" => "µs" }.fetch(Regexp.last_match(1))
      "#{Regexp.last_match(2)} #{unit}"
    when "Duration.zero" then "0 ms"
    when /\A(?:Clip|MainAxisAlignment|CrossAxisAlignment|TextAlign|BoxFit|Axis|MainAxisSize|StackFit|BlendMode|FilterQuality|ImageRepeat|TextOverflow|ScrollViewKeyboardDismissBehavior|Curves|TabAlignment|TextCapitalization|DatePickerMode|DatePickerEntryMode|PopupMenuPosition|DismissDirection|SnackBarBehavior|ListTileControlAffinity|TextInputAction|Brightness|VerticalDirection|WrapAlignment|Orientation)\.([A-Za-z]+)\z/
      Regexp.last_match(1)
    end
  end

  def skin_for(path)
    base = File.basename(path)
    return "material" if base.start_with?("material_")
    return "cupertino" if base.start_with?("cupertino_")

    nil
  end

  # Direct reads on any of `receivers` in one file.
  def direct_reads(path, receivers)
    source = File.read(path, encoding: "UTF-8")
    receiver = Regexp.union(receivers)
    pattern = /(?<!\w)(?:#{receiver})\s*\??\.(get[A-Za-z]*(?:<[^>]+>)?|buildWidget|buildWidgets|buildTextOrWidget|buildIconOrWidget|children|child)\(\s*["']([a-z_0-9]+)["']/
    reads = []
    source.to_enum(:scan, pattern).each do
      match = Regexp.last_match
      getter, name = match[1], match[2]
      args = call_arguments(source, match.end(0))
      type = WIDGET_READERS[getter] || getter_type(getter)
      default_index = getter.start_with?("getEnum") ? 2 : 1
      reads << { name: name, type: type, default: literal_default(args[default_index]), skin: skin_for(path) }
    end
    reads
  end

  # Declared contracts and their PropReader parsing.
  def spec_reads(path)
    source = File.read(path, encoding: "UTF-8")
    reads = []
    source.scan(/PropSpec\(\s*'([a-z_0-9]+)'\s*,\s*PropType\.(\w+)([^;]*?)\)\s*[,\]]/m) do |name, prop_type, rest|
      skins = rest[/skins:\s*\{([^}]*)\}/, 1].to_s.scan(/Skin\.(\w+)/).flatten
      reads << { name: name, type: PROP_TYPES[prop_type], default: nil, skin: nil, skins: skins.empty? ? nil : skins, spec: true }
    end
    source.to_enum(:scan, /\br\.(\w+)\(\s*(?:[\w.]+\.values\s*,\s*)?'([a-z_0-9]+)'/).each do
      match = Regexp.last_match
      reader, name = match[1], match[2]
      args = call_arguments(source, match.end(0))
      default = literal_default(args[1])
      default ||= "false" if reader == "boolean" && args.length == 1
      reads << { name: name, type: PROP_TYPES[reader], default: default, skin: nil }
    end
    reads
  end

  # wire type => renderer class, from every `case "Wire": return Class(` in
  # an extension's createWidget switch. Fall-through labels share the class.
  def dispatch_table(path)
    table = {}
    pending = []
    File.read(path, encoding: "UTF-8").each_line do |line|
      pending.concat(line.scan(/case\s+["']([A-Za-z0-9]+)["']\s*:/).flatten)
      klass = line[/return\s+([A-Z]\w*)\s*\(/, 1]
      next unless klass && pending.any?

      pending.each { |wire| table[wire] = klass }
      pending = []
    end
    table
  end

  def snake(name)
    name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  end

  # Renderer files for one wire type: the file that defines the dispatched
  # class, plus files named after the wire type with a platform prefix or a
  # core/skin suffix (`slider.dart`, `adaptive_slider.dart`,
  # `cupertino_slider.dart`, `button_core.dart`, `cupertino_button_skin.dart`).
  def renderer_files(wire, klass, dart_files, class_index)
    bases = [snake(wire), snake(wire).delete("_")].uniq
    names = bases.flat_map do |base|
      ["#{base}.dart", "adaptive_#{base}.dart", "material_#{base}.dart", "cupertino_#{base}.dart",
       "#{base}_core.dart", "cupertino_#{base}_skin.dart"]
    end
    files = dart_files.select { |path| names.include?(File.basename(path)) }
    files << class_index[klass] if class_index[klass]
    files.uniq
  end

  # {wire type => {property => {"type", "default", "skins"}}}
  def details(packages_dir)
    packages_dir = Pathname.new(packages_dir)
    result = {}
    Pathname.glob(packages_dir.join("ruflet*/lib")).each do |lib|
      dart_files = Dir[lib.join("**/*.dart").to_s].sort
      class_index = {}
      dart_files.each do |path|
        File.read(path, encoding: "UTF-8").scan(/^class\s+([A-Z]\w*)/).flatten.each { |klass| class_index[klass] ||= path }
      end
      dispatchers = dart_files.select { |path| path.end_with?("ruflet_core_extension.dart", "/extension.dart") }
      dispatchers.each do |dispatcher|
        dispatch_table(dispatcher).each do |wire, klass|
          reads = renderer_files(wire, klass, dart_files, class_index).flat_map do |path|
            direct_reads(path, %w[control widget.control]) + spec_reads(path)
          end
          result[wire] = merge_reads(reads) unless reads.empty?
        end
      end
    end
    result
  end

  def merge_reads(reads)
    reads.group_by { |read| read[:name] }.to_h do |name, list|
      specs = list.select { |read| read[:spec] }
      types = (specs.any? ? specs : list).filter_map { |read| read[:type] }
      type = types.tally.max_by { |_type, count| count }&.first
      defaults = list.select { |read| read[:default] }.uniq { |read| [read[:default], read[:skin]] }
      default = case defaults.map { |read| read[:default] }.uniq.length
      when 0 then nil
      when 1 then defaults.first[:default]
      else
        labelled = defaults.select { |read| read[:skin] }
        if labelled.map { |read| read[:skin] }.uniq.length == labelled.length && labelled.length == defaults.length
          labelled.sort_by { |read| read[:skin] }.map { |read| "#{read[:default]} (#{read[:skin].capitalize})" }.join(", ")
        end
      end
      skins = specs.filter_map { |read| read[:skins] }.first
      [name, { "type" => type, "default" => default, "skins" => skins }.compact]
    end
  end
end
