module PostsHelper
  TRUNCATED_COMMENT_LENGTH = 300
  TRUNCATED_POST_LENGTH    = 500

  # @param message [String]
  def format_post_message(post, truncate_long: true)
    longer_than_limit = post.message.length > TRUNCATED_POST_LENGTH

    message = if truncate_long && longer_than_limit
                truncate(post.message, length: TRUNCATED_POST_LENGTH, escape: false)
              else
                post.message
              end

    format_message(message, record: post, truncated: truncate_long, show_expand_link: longer_than_limit)
  end

  def format_comment_message(comment, truncate_long: true)
    longer_than_limit = comment.message.length > TRUNCATED_COMMENT_LENGTH

    message = if truncate_long && longer_than_limit
                truncate(comment.message, length: TRUNCATED_COMMENT_LENGTH, escape: false)
              else
                comment.message
              end

    message = message.dup.strip.tap do |message|
      comment.mentions.each do |id, name|
        message.gsub!(name, "<b>#{name}</b>")
      end
    end

    format_message(message, record: comment, truncated: truncate_long, show_expand_link: longer_than_limit)
  end

  def format_message(message, record: nil, truncated: false, show_expand_link: false)
    result = message.strip.gsub("\n", '<br />')
    result = auto_link(result, html: {target: '_blank'}) do |text|
      truncate(text, length: 45)
    end

    if record && show_expand_link
      container_id = "#{record.class.base_class.name.downcase}-text-#{record.id}"
      text_url = polymorphic_url([:text, record.becomes(record.class.base_class)], truncate: !truncated)
      expand_link = link_to "See #{truncated ? 'More' : 'Less'}", text_url, class: 'AjaxLink', data: {target: container_id}
      content_tag :span, "#{result} &nbsp; #{expand_link}".html_safe, data: {identifier: container_id}
    else
      result
    end
  end

  def restore_message_format(message)
    CGI.unescapeHTML(message) unless message.blank?
  end
end
