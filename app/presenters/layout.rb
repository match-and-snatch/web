class Layout < Hash

  def page_title=(val)
    self[:title] = val
  end

  def page_title
    self[:title] || 'Match And Snatch'
  end

  def js_data
    self[:js_data] ||= { error_messages: I18n.t('errors').except(:messages) }
  end
end
