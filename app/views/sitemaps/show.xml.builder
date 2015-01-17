xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.priority 1.0
  end

  %w(about pricing contact_us terms_of_use privacy_policy faq).each do |page|
    xml.url do
      xml.loc "#{root_url}#{page}"
      xml.priority 0.7
    end
  end

  @public_profiles.find_each do |profile|
    xml.url do
      xml.loc profile_url(profile)
      xml.priority 0.9
    end
  end
end