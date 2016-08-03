module MarkdownHelper

  # @param str [String]
  # @return [String]
  def markdown_to_html(str)
    Kramdown::Document.new(str, parse_block_html: true).to_html.html_safe
  end
end
