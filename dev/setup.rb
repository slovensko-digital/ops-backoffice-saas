# Local development only. The zammad-dev-setup service in docker-compose.yml runs it on every
# `docker compose up`, after zammad-init. Safe to run again.
#
# The portal's tech account gets new groups (e.g. Podúlohy) only from the scheduler
# "OPS - add all groups to tech role." every 15 minutes, which zammad-init restarts on every start.
# Until then every subtask job fails with "Not authorized". Assign them right away.
Ops::AssignTechRoleToAllGroupsJob.perform_now

puts "OPS Tech Account role has all groups: #{Role.find_by!(name: 'OPS Tech Account').groups.pluck(:name).join(', ')}"

# The admin sees the OPS tickets in Incoming. The sample tickets task (zammad/lib/tasks/ops/backoffice.rake) gives
# the same, but only when it creates the sample tickets.
admin = User.find_by!(email: ENV.fetch('ADMIN_EMAIL'))
admin.group_names_access_map = admin.group_names_access_map.merge('Incoming' => ['full'])
admin.roles |= [Role.find_by!(name: 'Správca podnetov pre OPS')]
admin.save!
puts "Admin #{admin.email} has group Incoming and role Správca podnetov pre OPS"

# A Backoffice started by dev/up has no sample tickets (CREATE_SAMPLE_TICKET=false), only the portal's tickets.
# Zammad's own welcome ticket goes too, and the sample tickets of a Backoffice started before
# CREATE_SAMPLE_TICKET=false, their customer is example.portal.customer@localhost.
if ENV['CREATE_SAMPLE_TICKET'] != 'true'
  Ticket.where(title: 'Help me! I am an example ticket 🎓', customer: User.find_by(email: 'nicole.braun@zammad.org')).find_each(&:destroy!)
  Ticket.where(customer: User.find_by(email: 'example.portal.customer@localhost')).find_each(&:destroy!)
  puts "No sample tickets: #{Ticket.count} tickets"
end
