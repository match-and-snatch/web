xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc "#{APP_CONFIG['mobile_site_url']}/"
    xml.priority 1.0
  end

  %w(about pricing contact_us terms_of_use privacy_policy faq users search login signup).each do |page|
    xml.url do
      xml.loc "#{APP_CONFIG['mobile_site_url']}/#{page}"
      xml.priority 0.7
    end
  end

  @public_profiles.find_each do |profile|
    xml.url do
      xml.loc "#{APP_CONFIG['mobile_site_url']}#{profile_path(profile)}"
      xml.priority 0.9
    end
  end
end