module PostsHelper

  # @param message [String]
  def format_post_message(message)
    message.gsub("\n", '<br />').html_safe
  end
end