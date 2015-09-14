class Layout < Hash

  def lock
    self[:locked] = true
  end

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
    self[:js_data] ||= { error_messages: I18n.t('errors').except(:messages), locked: self[:locked] }
  end

  def custom_css
    self[:custom_css]
  end

  def custom_css=(val)
    self[:custom_css] = val.presence
  end
end
