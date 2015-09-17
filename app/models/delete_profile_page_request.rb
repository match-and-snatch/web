class DeleteProfilePageRequest < Request
  def approve!
    super
    perform!
  end
end
