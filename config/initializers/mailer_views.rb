Rails.application.config.to_prepare do
  Accounts::Engine.paths["app/views"].existent.each do |path|
    ActionMailer::Base.prepend_view_path path
  end
end
