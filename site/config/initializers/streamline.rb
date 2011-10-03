def _make_url(path)
  # Remove any extra slashes
  path = "/#{path}"
  path.gsub!(/\/\/+/, '/')

  URI.join(
    Rails.configuration.streamline[:host],
    path
  ).to_s
end

RedHatCloud::Application.configure do
  YAML.load_file("#{Rails.root}/config/streamline.yml").each do |name,default|
    url = _make_url(
      config.streamline[name] || 
      "#{Rails.configuration.streamline[:base_url]}/#{default}"
    )
    config.streamline.merge!({ name => url })
  end
end
