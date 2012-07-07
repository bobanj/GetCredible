xml.instruct!
xml.urlset(
  'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9",
  'xmlns:image' => "http://www.google.com/schemas/sitemap-image/1.1"
) do

  [root_url, about_url, team_url, press_url, tour_url, terms_url, privacy_url].each do |url|
    xml.url do
      xml.loc url
      # xml.lastmod (Time.now - 1.day)
      xml.changefreq 'monthly'
      xml.priority 1.0
    end
  end
end
