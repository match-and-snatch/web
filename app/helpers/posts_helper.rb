module PostsHelper
  TRUNCATED_COMMENT_LENGTH = 300
  TRUNCATED_POST_LENGTH    = 500

  # @param message [String]
  def format_post_message(post, truncate_long: true)
    if truncate_long && post.message.length > TRUNCATED_POST_LENGTH
      message = truncate(post.message, length: TRUNCATED_POST_LENGTH)
      full_post = post
    else
      message = post.message
    end

    format_message(message, record: full_post)
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

    format_message(message, record: full_comment)
  end

  def format_message(message, record: nil)
    result = message.strip.gsub("\n", '<br />')
    result = auto_link(result, html: {target: '_blank'}) do |text|
      truncate(text, length: 45)
    end

    if record
      full_text_url = polymorphic_url([:full_text, record.becomes(record.class.base_class)])
      container_id = "#{record.class.base_class.name.downcase}-text-#{record.id}"
      more_link = link_to 'See More', full_text_url, class: 'AjaxLink', data: {target: container_id}
      "<span data-identifier='#{container_id}'>#{result} &nbsp; #{more_link}</span>".html_safe
    else
      result
    end
  end

  def restore_message_format(message)
    CGI.unescapeHTML(message) unless message.blank?
  end
end
