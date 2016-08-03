module MarkdownHelper
  # @return [Redcarpet::Markdown]
  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end

  # @param str [String]
  # @return [String]
  def markdown_to_html(str)
    markdown.render(str).html_safe
  end
end
