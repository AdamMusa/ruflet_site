class MarkdownRenderer
  Heading = Struct.new(:id, :text, :level, keyword_init: true)
  Result = Struct.new(:html, :headings, keyword_init: true)

  def self.render(markdown)
    new(markdown).render
  end

  def initialize(markdown)
    @lines = markdown.to_s.gsub("\r\n", "\n").split("\n")
    @headings = []
    @heading_ids = Hash.new(0)
  end

  def render
    html = []
    index = 0

    while index < @lines.length
      line = @lines[index]

      if line.strip.empty?
        index += 1
        next
      end

      if line.start_with?("```")
        language = line.delete_prefix("```").strip
        code = []
        index += 1
        while index < @lines.length && !@lines[index].start_with?("```")
          code << @lines[index]
          index += 1
        end
        classes = ["docs-code-block", ("language-#{language}" unless language.empty?)].compact.join(" ")
        html << %(<pre class="#{classes}"><code>#{highlight_code(code.join("\n"), language)}</code></pre>)
        index += 1
        next
      end

      if (match = line.match(/\A(#{'#' * 6}|#{'#' * 5}|#{'#' * 4}|#{'#' * 3}|#{'#' * 2}|#)\s+(.+)\z/))
        level = match[1].length
        text = match[2].strip
        id = heading_id(text)
        @headings << Heading.new(id: id, text: text, level: level)
        html << %(<h#{level} id="#{id}" data-docs-heading="#{id}">#{inline_markup(text)}</h#{level}>)
        index += 1
        next
      end

      if line.match?(/\A[-*]\s+/)
        items = []
        while index < @lines.length && (item_match = @lines[index].match(/\A[-*]\s+(.+)\z/))
          items << item_match[1]
          index += 1
        end
        html << "<ul>#{items.map { |item| "<li>#{inline_markup(item)}</li>" }.join}</ul>"
        next
      end

      if line.match?(/\A\d+\.\s+/)
        items = []
        while index < @lines.length && (item_match = @lines[index].match(/\A\d+\.\s+(.+)\z/))
          items << item_match[1]
          index += 1
        end
        html << "<ol>#{items.map { |item| "<li>#{inline_markup(item)}</li>" }.join}</ol>"
        next
      end

      if line.match?(/\A>\s?/)
        quote = []
        while index < @lines.length && (quote_match = @lines[index].match(/\A>\s?(.*)\z/))
          quote << quote_match[1]
          index += 1
        end
        html << %(<blockquote><p>#{inline_markup(quote.join(" "))}</p></blockquote>)
        next
      end

      paragraph = [line.strip]
      index += 1
      while index < @lines.length && !@lines[index].strip.empty? && !block_start?(@lines[index])
        paragraph << @lines[index].strip
        index += 1
      end
      html << %(<p>#{inline_markup(paragraph.join(" "))}</p>)
    end

    Result.new(html: html.join.html_safe, headings: @headings)
  end

  private

  def block_start?(line)
    line.start_with?("```") ||
      line.match?(/\A\#{1,6}\s+/) ||
      line.match?(/\A[-*]\s+/) ||
      line.match?(/\A\d+\.\s+/) ||
      line.match?(/\A>\s?/)
  end

  def heading_id(text)
    base = text.gsub(/`/, "").parameterize
    count = @heading_ids[base]
    @heading_ids[base] += 1
    count.zero? ? base : "#{base}-#{count + 1}"
  end

  def inline_markup(text)
    html = ERB::Util.html_escape(text)
    html = html.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
      label = ERB::Util.html_escape(Regexp.last_match(1))
      href = ERB::Util.html_escape(Regexp.last_match(2))
      external = href.start_with?("http://", "https://")
      attrs = external ? ' target="_blank" rel="noreferrer"' : ""
      %(<a href="#{href}"#{attrs}>#{label}</a>)
    end
    html = html.gsub(/\*\*([^*]+)\*\*/) { "<strong>#{ERB::Util.html_escape(Regexp.last_match(1))}</strong>" }
    html = html.gsub(/`([^`]+)`/) { "<code>#{ERB::Util.html_escape(Regexp.last_match(1))}</code>" }
    html
  end

  def highlight_code(code, language)
    escaped = ERB::Util.html_escape(code)
    case language.to_s.downcase
    when "ruby", "rb"
      highlight_ruby(escaped)
    when "bash", "sh", "zsh", "shell"
      highlight_bash(escaped)
    when "yaml", "yml"
      highlight_yaml(escaped)
    else
      escaped
    end
  end

  def highlight_ruby(code)
    highlight_with_placeholders(code) do |html|
      html.gsub!(/\b(require|class|module|def|do|end|if|elsif|else|when|case|while|until|return|super|private|protected|public|rescue|begin)\b/, '<span class="tok-keyword">\1</span>')
      html.gsub!(/\b(true|false|nil)\b/, '<span class="tok-atom">\1</span>')
      html.gsub!(/\b([A-Z][A-Za-z0-9_:]*)\b/, '<span class="tok-constant">\1</span>')
      html.gsub!(/(\b\d+(?:\.\d+)?\b)/, '<span class="tok-number">\1</span>')
      html
    end
  end

  def highlight_bash(code)
    highlight_with_placeholders(code) do |html|
      html.gsub!(/\b(gem|bundle|ruflet|cd|bin\/rails|rails|puts)\b/, '<span class="tok-function">\1</span>')
      html.gsub!(/(\-\-[a-z0-9_-]+|\-[a-zA-Z])/, '<span class="tok-flag">\1</span>')
      html
    end
  end

  def highlight_yaml(code)
    highlight_with_placeholders(code) do |html|
      html.gsub!(/^([a-zA-Z0-9_-]+:)/, '<span class="tok-key">\1</span>')
      html.gsub!(/\b(true|false|null)\b/, '<span class="tok-atom">\1</span>')
      html.gsub!(/(\b\d+(?:\.\d+)?\b)/, '<span class="tok-number">\1</span>')
      html
    end
  end

  def highlight_with_placeholders(code)
    html = code.dup
    placeholders = []

    html.gsub!(/(&quot;[^&\n]*&quot;|&#39;[^&\n]*&#39;)/) do
      placeholders << %(<span class="tok-string">#{Regexp.last_match(1)}</span>)
      "__TOK_#{placeholders.length - 1}__"
    end

    html.gsub!(/(#.*)$/) do
      placeholders << %(<span class="tok-comment">#{Regexp.last_match(1)}</span>)
      "__TOK_#{placeholders.length - 1}__"
    end

    html = yield(html)

    placeholders.each_with_index do |token, index|
      html.gsub!("__TOK_#{index}__", token)
    end

    html
  end
end
