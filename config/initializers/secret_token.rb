if Rails.env.production?
  VndaBling::Application.config.secret_token = ENV["SECRET_TOKEN"]
else
  # run: `bin/rake secret_token:generate` if you doesn't have the secret token file yet
  secret_token_file = Rails.root.join("config/.secret-token")
  if secret_token_file.exist?
    VndaBling::Application.config.secret_token = secret_token_file.read
  end
end
