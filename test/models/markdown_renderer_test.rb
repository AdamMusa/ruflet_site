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

  test "renders inline markdown images" do
    html = MarkdownRenderer.render("![iOS](/assets/platform_ios.svg) **iOS**").html
    src = ActionController::Base.helpers.asset_path("platform_ios.svg")

    assert_includes html, %(<img src="#{src}" alt="iOS" class="docs-inline-image">)
    assert_includes html, %(<strong>iOS</strong>)
  end
end
