# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register 'application/x-mpegurl', :m3u8

ActionController::Renderers.add :m3u8 do |object, options|
  self.content_type ||= 'application/x-mpegurl'
  object
end
