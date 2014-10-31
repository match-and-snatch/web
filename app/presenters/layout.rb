class Layout < Hash

  def title=(val)
    self[:title] = val
  end

  def title
    self[:title] || 'ConnectPal.com'
  end

  def hide_navigation
    self[:show_navigation] = false
  end

  def show_navigation?
    if has_key? :show_navigation
      self[:show_navigation]
    else
      true
    end
  end

  def js_data
    self[:js_data] ||= { error_messages: I18n.t('errors').except(:messages) }
  end
end
