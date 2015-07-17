xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9", "xmlns:xhtml" => "http://www.w3.org/1999/xhtml" do
  xml.url do
    xml.loc root_url
    xml.xhtml :link, rel: "alternate", media: "only screen and (max-width: 768px)", href: "#{APP_CONFIG['mobile_site_url']}/"
    xml.priority 1.0
  end

  %w(about pricing contact_us terms_of_use privacy_policy faq).each do |page|
    xml.url do
      xml.loc "#{root_url}#{page}"
      xml.xhtml :link, rel: "alternate", media: "only screen and (max-width: 768px)", href: "#{APP_CONFIG['mobile_site_url']}/#{page}"
      xml.priority 0.7
    end
  end

  @public_profiles.find_each do |profile|
    xml.url do
      xml.loc profile_url(profile)
      xml.xhtml :link, rel: "alternate", media: "only screen and (max-width: 768px)", href: "#{APP_CONFIG['mobile_site_url']}#{profile_path(profile)}"
      xml.priority 0.9
    end
  end
end