Rails.application.config.to_prepare do
  ActionMailer::Base.helper LogoHelper
  ActionMailer::Base.helper BrandColorHelper
end
