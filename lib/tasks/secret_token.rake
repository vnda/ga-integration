namespace :secret_token do
  task :generate do
    path = File.expand_path("../../../config/.secret-token", __FILE__)
    File.open(path, "w") { |f| f.write(SecureRandom.hex(64)) } unless File.exist?(path)
  end
end
