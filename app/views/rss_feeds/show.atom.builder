xml.instruct! :xml, version: '1.0'
xml.feed xmlns: 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "#{@user.name}'s news feed"
    xml.link href: user_rss_feed_url(@user.id), rel: 'self'
    xml.link href: profile_url(@user)
    xml.updated @feed_events.first.updated_at.xmlschema
    xml.id @user.id

    @feed_events.each do |post|
      xml.entry do
        xml.link href: profile_url(@user)

        xml.id      post.id
        xml.title   post.message
        xml.updated post.updated_at.xmlschema

        xml.author do
          xml.name @user.name
        end
      end
    end
  end
end