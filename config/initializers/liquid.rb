Rails.application.config.to_prepare do

  # Custom Liquid tags are loaded here
  Dir.glob(Rails.root.join("app/liquid/tags/*.rb")).sort.each do |filename|
    require_dependency filename
  end
end