require "test_helper"

class MarkdownRendererTest < ActiveSupport::TestCase
  test "highlights shell commands without leaking placeholder text" do
    markdown = <<~MARKDOWN
      ```bash
      gem install ruflet
      ruflet new my_app
      cd my_app
      bundle install
      ruflet run main
      ```
    MARKDOWN

    html = MarkdownRenderer.render(markdown).html

    assert_includes html, %(<span class="tok-function">gem</span> install)
    assert_includes html, %(<span class="tok-function">ruflet</span> new my_app)
    assert_includes html, %(class="docs-code-copy-button")
    assert_includes html, %(data-controller="copy-code")
    assert_includes html, %(data-action="click->copy-code#copy")
    assert_includes html, %(data-copy-code-target="code")
    refute_includes html, "TOKPLACEHOLDER"
    refute_includes html, "tok<span"
    refute_includes html, %(tok<span class="tok-flag">-f</span>unction)
  end

  test "restores highlighted strings and comments" do
    markdown = <<~MARKDOWN
      ```ruby
      puts "hello" # greeting
      ```
    MARKDOWN

    html = MarkdownRenderer.render(markdown).html

    assert_includes html, %(<span class="tok-string">&quot;hello&quot;</span>)
    assert_includes html, %(<span class="tok-comment"># greeting</span>)
    refute_includes html, "TOKPLACEHOLDER"
    refute_includes html, "{{{tok_"
  end

  test "highlights app structure tree folders and files" do
    markdown = <<~MARKDOWN
      ```tree
      my_app/
        Gemfile
        assets/
          icon.png
      ```
    MARKDOWN

    html = MarkdownRenderer.render(markdown).html

    assert_includes html, %(<span class="tok-folder">my_app/</span>)
    assert_includes html, %(  <span class="tok-file">Gemfile</span>)
    assert_includes html, %(  <span class="tok-folder">assets/</span>)
    assert_includes html, %(    <span class="tok-file">icon.png</span>)
  end

  test "renders GitHub-flavored tables" do
    markdown = <<~MARKDOWN
      Intro paragraph.
      | Helper | Native purpose |
      | --- | :---: |
      | `column`, `row` | Vertical or [horizontal](/docs/row) layout. |
      | `pipe` | Escaped \\| pipe |
      | `short` |

      After the table.
    MARKDOWN

    html = MarkdownRenderer.render(markdown).html

    assert_includes html, "<p>Intro paragraph.</p><table>"
    assert_includes html, %(<thead><tr><th>Helper</th><th style="text-align: center">Native purpose</th></tr></thead>)
    assert_includes html, %(<td><code>column</code>, <code>row</code></td>)
    assert_includes html, %(<td style="text-align: center">Vertical or <a href="/docs/row">horizontal</a> layout.</td>)
    assert_includes html, %(<td style="text-align: center">Escaped | pipe</td>)
    assert_includes html, %(<tr><td><code>short</code></td><td style="text-align: center"></td></tr>)
    assert_includes html, "</table><p>After the table.</p>"
    refute_includes html, "<p>|"
  end

  test "keeps pipes outside a table as paragraph text" do
    html = MarkdownRenderer.render("Use `a | b` here.\nNo table | follows.").html

    assert_includes html, "<p>Use <code>a | b</code> here. No table | follows.</p>"
    refute_includes html, "<table>"
  end

  test "keeps wrapped list items in one item" do
    markdown = <<~MARKDOWN
      - `link` pushes a screen. Set `nav: "root"`,
        `"replace"`, or `"back"` instead.
      - Second item
      1. First step that
         wraps.

        After the list.
    MARKDOWN

    html = MarkdownRenderer.render(markdown).html

    assert_includes html, %(<li><code>link</code> pushes a screen. Set <code>nav: &quot;root&quot;</code>, <code>&quot;replace&quot;</code>, or <code>&quot;back&quot;</code> instead.</li><li>Second item</li></ul>)
    assert_includes html, "<ol><li>First step that wraps.</li></ol>"
    assert_includes html, "<p>After the list.</p>"
  end

  test "an indented list marker ends the item instead of joining it" do
    html = MarkdownRenderer.render("- Parent\n  - Child").html

    assert_includes html, "<li>Parent</li>"
    refute_includes html, "Parent - Child"
  end

  test "docs pages render their tables as tables" do
    Rails.root.glob("app/content/docs/*.md").each do |path|
      html = MarkdownRenderer.render(path.read).html

      refute_match(/<p>\s*\|/, html, "#{path.basename} renders a table as raw pipes")
    end

    components = MarkdownRenderer.render(DocsCatalog.find("rails-native-components").source.read).html
    assert_operator components.scan("<table>").length, :>=, 6
  end

  test "double stars inside code spans stay code and leave bold alone" do
    html = MarkdownRenderer.render("- `page(**props)` and `service(type, **props)` add controls. **Requires the next release**.").html

    assert_includes html, "<code>page(**props)</code> and <code>service(type, **props)</code> add controls. <strong>Requires the next release</strong>."
    assert_includes MarkdownRenderer.render("**`code` in bold** and [`link`](/docs/x)").html,
      %(<strong><code>code</code> in bold</strong> and <a href="/docs/x"><code>link</code></a>)
  end

  test "renders inline markdown images" do
    html = MarkdownRenderer.render("![iOS](/assets/platform_ios.svg) **iOS**").html
    src = ActionController::Base.helpers.asset_path("platform_ios.svg")

    assert_includes html, %(<img src="#{src}" alt="iOS" class="docs-inline-image">)
    assert_includes html, %(<strong>iOS</strong>)
  end
end
