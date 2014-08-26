xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "#{@user.name}'s news feed!!"
    xml.language 'en-US'
    xml.managingEditor 'support@connectpal.com'

    @feed_events.each do |post|
      xml.item do
        xml.link profile_url(@user)
        xml.description restore_message_format(post.message)
        xml.title post.title
        xml.updated post.updated_at.xmlschema
      end
    end
  end
end
