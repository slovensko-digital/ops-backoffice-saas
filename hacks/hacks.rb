#!/usr/bin/env ruby
require 'fileutils'

def replace_file_with(file, &block)
  File.write(file, block.call(File.read(file)))
end

# change logo
replace_file_with('public/assets/images/icons.svg') do |content|
  content.gsub(/<symbol id="icon-logo".*?<\/symbol>/m, File.read('hacks/logo.svg'))
end

replace_file_with('app/views/layouts/application.html.erb') do |content|
  content.gsub(/<\/head>/, <<-HACK)
  <%= stylesheet_link_tag "/assets/ops.css?v#{content.hash}" %>
</head>
  HACK
end
FileUtils.cp('hacks/ops.css', 'public/assets/ops.css')
