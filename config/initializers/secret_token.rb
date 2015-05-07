Gaintegration::Application.config.secret_token = if Rails.env.production?
  ENV["SECRET_TOKEN"]
else
  'e5103fea8206cb4cb3525acc9c295fe10517b8681acb9be28c5372b271da89dd3cd3a638b69c4d081eb36d4f3c4caffb2c3dead3c316eadb0fb097a63183a357'
end
