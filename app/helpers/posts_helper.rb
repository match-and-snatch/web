module PostsHelper

  # @param message [String]
  def format_post_message(message)
    format_message(message.strip)
  end

  def format_comment_message(comment)
    message = comment.message.dup.strip.tap do |message|
      comment.mentions.each do |id, name|
        message.gsub!(name, "<b>#{name}</b>")
      end
    end

    format_message(message)
  end

  def format_message(message)
    message.gsub("\n", '<br />').html_safe
  end
end