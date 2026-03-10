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
        html << %(<pre class="#{classes}"><code>#{ERB::Util.html_escape(code.join("\n"))}</code></pre>)
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
end
