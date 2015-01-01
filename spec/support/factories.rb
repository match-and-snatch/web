def create_user(attrs = {})
  User.create!({}.merge(attrs))
end

def create_tag(attrs = {})
  Tag.create!({title: 'test'}.merge(attrs))
end

def create_offer(attrs = {})
  performer = create_user
  tag = create_tag
  OfferFlow.new(performer: performer).create({title: 'test', tag_ids: [tag.id]}.merge(attrs)).offer
end
