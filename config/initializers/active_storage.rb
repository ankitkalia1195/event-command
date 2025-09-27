# Active Storage configuration
Rails.application.configure do
  # Set URL options for Active Storage
  config.after_initialize do
    ActiveStorage::Current.url_options = {
      host: Rails.application.routes.default_url_options[:host] || "localhost:3000",
      protocol: Rails.application.routes.default_url_options[:protocol] || "http"
    }
  end
end
