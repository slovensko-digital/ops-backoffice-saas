# Local development only, run by dev/init.sh: what /docker-entrypoint.sh zammad-init does on an installed Zammad,
# in one Rails boot.
Rails.application.load_tasks

puts 'Clearing cache...'
Rails.cache.clear
puts 'Executing migrations...'
Rake::Task['db:migrate'].invoke
puts 'Synchronizing locales and translations...'
Locale.sync
Translation.sync
Setting.set('es_url', '')
