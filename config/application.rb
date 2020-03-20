require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # 表示するタイムゾーン
    config.time_zone = "Tokyo"

    # ActionMailerで使用するオプション
    config.action_mailer.default_url_options = {
      host: "localhost",
    }

    # DBに登録するときのタイムゾーン
    config.active_record.default_timezone = :local
  end
end
