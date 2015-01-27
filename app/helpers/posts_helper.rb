module PostsHelper
  TRUNCATED_COMMENT_LENGTH = 300

  # @param message [String]
  def format_post_message(message)
    format_message(message.strip)
  end

  def format_comment_message(comment, truncate_long: true)
    if truncate_long && comment.message.length > TRUNCATED_COMMENT_LENGTH
      message = truncate(comment.message, length: TRUNCATED_COMMENT_LENGTH)
      full_comment = comment
    else
      message = comment.message
    end

    message = message.dup.strip.tap do |message|
      comment.mentions.each do |id, name|
        message.gsub!(name, "<b>#{name}</b>")
      end
    end

    format_message(message, full_comment: full_comment)
  end

  def format_message(message, full_comment: nil)
    result = message.gsub("\n", '<br />')
    result = auto_link(result, html: {target: '_blank'}) do |text|
      truncate(text, length: 45)
    end

    if full_comment
      container_id = "comment-text-#{full_comment.id}"
      comment_link = link_to 'See More', comment_path(full_comment), class: 'AjaxLink', data: {target: container_id}
      "<span data-identifier='#{container_id}'>#{result} &nbsp; #{comment_link}</span>".html_safe
    else
      result
    end
  end

  def restore_message_format(message)
    CGI.unescapeHTML(message) unless message.blank?
  end
end