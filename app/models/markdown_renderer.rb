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
        html << render_code_block(code.join("\n"), language)
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
    html = html.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do
      alt = ERB::Util.html_escape(Regexp.last_match(1))
      src = ERB::Util.html_escape(resolve_image_src(Regexp.last_match(2)))
      %(<img src="#{src}" alt="#{alt}" class="docs-inline-image">)
    end
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

  def resolve_image_src(src)
    return src unless src.start_with?("/assets/")

    ActionController::Base.helpers.asset_path(src.delete_prefix("/assets/"))
  end

  def render_code_block(code, language)
    classes = ["docs-code-block", ("language-#{language}" unless language.empty?)].compact.join(" ")

    <<~HTML.chomp
      <div class="docs-code-block-wrap" data-controller="copy-code" style="position: relative; margin: 1.5rem 0 1.75rem;">
        <button type="button" class="docs-code-copy-button" data-copy-code-target="button" data-action="click->copy-code#copy" style="position: absolute; top: 0.7rem; right: 0.75rem; z-index: 1; border: 1px solid rgba(255, 255, 255, 0.12); background: rgba(15, 23, 42, 0.96); color: #cbd5e1; padding: 0.35rem 0.6rem; font-size: 0.75rem; font-weight: 700; line-height: 1; cursor: pointer;">Copy</button>
        <pre class="#{classes}" style="margin: 0; padding-top: 2.7rem;"><code data-copy-code-target="code">#{highlight_code(code, language)}</code></pre>
      </div>
    HTML
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
    when "tree"
      highlight_tree(escaped)
    when "erb", "html", "html+erb", "rhtml", "xml"
      highlight_markup(escaped)
    else
      escaped
    end
  end

  # Highlight HTML / ERB: tag names, attribute names, quoted values, HTML
  # comments, and embedded `<%= … %>` expressions. Operates on already
  # HTML-escaped text (`&lt;`, `&quot;`, …).
  def highlight_markup(code)
    html = code.dup
    stash = []
    # Stash inserted markup behind a placeholder so later passes never re-scan
    # a span we already produced (e.g. the `class=` inside a `<span class=…>`).
    hold = ->(markup) { stash << markup; placeholder_token(stash.length - 1) }

    # ERB expressions: color the `<%= … %>` delimiters, and highlight the Ruby
    # inside so a screen written with helpers reads like Ruby, not one blob.
    html.gsub!(/(&lt;%=?)(.*?)(%&gt;)/m) do
      open_delim = Regexp.last_match(1)
      inner = Regexp.last_match(2)
      close_delim = Regexp.last_match(3)
      colored = %(<span class="tok-embed">#{open_delim}</span>#{highlight_ruby(inner)}<span class="tok-embed">#{close_delim}</span>)
      hold.call(colored)
    end
    # HTML comments.
    html.gsub!(/&lt;!--.*?--&gt;/m) { |c| hold.call(%(<span class="tok-comment">#{c}</span>)) }
    # Quoted attribute values.
    html.gsub!(/(&quot;.*?&quot;|&#39;.*?&#39;)/m) { hold.call(%(<span class="tok-string">#{Regexp.last_match(1)}</span>)) }

    # Tag names on open/close tags.
    html.gsub!(%r{(&lt;/?)([a-zA-Z][\w:-]*)}) do
      lead = Regexp.last_match(1)
      name = Regexp.last_match(2)
      "#{lead}#{hold.call(%(<span class="tok-keyword">#{name}</span>))}"
    end
    # Attribute names (word immediately before `=`).
    html.gsub!(/(\s)([a-zA-Z_:][\w:.-]*)(=)/) do
      ws = Regexp.last_match(1)
      name = Regexp.last_match(2)
      "#{ws}#{hold.call(%(<span class="tok-flag">#{name}</span>))}="
    end

    # Restore placeholders (repeat so nested tokens — e.g. ERB inside a quoted
    # value — are fully expanded).
    loop do
      changed = false
      stash.each_with_index { |markup, index| changed = true if html.gsub!(placeholder_token(index), markup) }
      break unless changed
    end
    html
  end

  RUBY_KEYWORDS = %w[require class module def do end if elsif else unless when case while until
                     return yield super private protected public rescue ensure begin then].freeze

  # Single-pass tokenizer over already HTML-escaped Ruby. Scanning each token
  # once (rather than layering gsubs) means an inserted span is never re-matched
  # by a later rule — e.g. the word `class` inside `class="tok-key"`.
  RUBY_TOKEN = Regexp.union(
    /\#[^\n]*/,                              # comment
    /&quot;.*?&quot;|&#39;.*?&#39;/,         # string
    /\b[a-z_]\w*:(?=\s)/,                    # keyword arg / hash key: `class:`
    /(?<![:\w]):[a-z_]\w*[!?]?/,             # symbol: `:filled`
    /\b[A-Z][A-Za-z0-9_]*\b/,               # constant
    /\b\d+(?:\.\d+)?\b/,                     # number
    /\b[a-z_]\w*[!?]?\b/                     # bareword (keyword? atom? plain)
  )

  def highlight_ruby(code)
    code.gsub(RUBY_TOKEN) do |tok|
      if tok.start_with?("#")
        %(<span class="tok-comment">#{tok}</span>)
      elsif tok.start_with?("&quot;", "&#39;")
        %(<span class="tok-string">#{tok}</span>)
      elsif tok.end_with?(":")
        %(<span class="tok-key">#{tok.chomp(":")}</span>:)
      elsif tok.start_with?(":")
        %(<span class="tok-atom">#{tok}</span>)
      elsif tok =~ /\A[A-Z]/
        %(<span class="tok-constant">#{tok}</span>)
      elsif tok =~ /\A\d/
        %(<span class="tok-number">#{tok}</span>)
      elsif %w[true false nil].include?(tok)
        %(<span class="tok-atom">#{tok}</span>)
      elsif RUBY_KEYWORDS.include?(tok)
        %(<span class="tok-keyword">#{tok}</span>)
      else
        tok
      end
    end
  end

  def highlight_bash(code)
    highlight_with_placeholders(code) do |html|
      html.gsub!(/(\-\-[a-z0-9_-]+|\-[a-zA-Z])/, '<span class="tok-flag">\1</span>')
      html.gsub!(/\b(gem|bundle|ruflet|cd|bin\/rails|rails|puts)\b/, '<span class="tok-function">\1</span>')
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

  def highlight_tree(code)
    code.gsub(/^(\s*)(.+\/)$/) { "#{$1}<span class=\"tok-folder\">#{$2}</span>" }
      .gsub(/^(\s*)([^<\s].*)$/) { "#{$1}<span class=\"tok-file\">#{$2}</span>" }
  end

  def highlight_with_placeholders(code)
    html = code.dup
    placeholders = []

    html.gsub!(/(&quot;[^&\n]*&quot;|&#39;[^&\n]*&#39;)/) do
      placeholders << %(<span class="tok-string">#{Regexp.last_match(1)}</span>)
      placeholder_token(placeholders.length - 1)
    end

    html.gsub!(/(#.*)$/) do
      placeholders << %(<span class="tok-comment">#{Regexp.last_match(1)}</span>)
      placeholder_token(placeholders.length - 1)
    end

    html = yield(html)

    placeholders.each_with_index do |token, index|
      html.gsub!(placeholder_token(index), token)
    end

    html
  end

  def placeholder_token(index)
    alphabet = ("a".."z").to_a
    token = +""
    current = index

    loop do
      token.prepend(alphabet[current % alphabet.length])
      current = (current / alphabet.length) - 1
      break if current.negative?
    end

    "{{{tok_#{token}}}}"
  end
end
