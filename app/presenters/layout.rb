class Layout < Hash

  def title=(val)
    self[:title] = val
  end

  def title
    self[:title] || 'ConnectPal.com'
  end
end