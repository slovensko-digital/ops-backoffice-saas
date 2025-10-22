#!/usr/bin/env ruby
require 'fileutils'

def replace_file_with(file, &block)
  File.write(file, block.call(File.read(file)))
end

# Update log level configuration to use environment variable
replace_file_with('config/environments/production.rb') do |content|
  content.gsub('config.log_level = :info', 'config.log_level = ENV.fetch("LOG_LEVEL", "info")')
end

# Append ops seeds to the end of the list
replace_file_with('db/seeds.rb') do |content|
  content.gsub(/(seeds = %w\[.*)\]/, '\1 ops_custom_settings ops_custom_fields]')
end

# change logo
replace_file_with('public/assets/images/icons.svg') do |content|
  content.gsub(/<symbol id="icon-logo".*?<\/symbol>/m, File.read('hacks/logo.svg'))
end

replace_file_with('app/views/layouts/application.html.erb') do |content|
  content.gsub(/<\/head>/, <<-HACK)
  <%= stylesheet_link_tag "/assets/ops-application.css?v#{content.hash}" %>
</head>
  HACK
end

replace_file_with('app/views/layouts/desktop.html.erb') do |content|
  content.gsub(/<\/head>/, <<-HACK)
  <%= stylesheet_link_tag "/assets/ops-desktop.css?v#{content.hash}" %>
</head>
  HACK
end

replace_file_with('app/views/layouts/mobile.html.erb') do |content|
  content.gsub(/<\/head>/, <<-HACK)
  <%= stylesheet_link_tag "/assets/ops-mobile.css?v#{content.hash}" %>
</head>
  HACK
end
