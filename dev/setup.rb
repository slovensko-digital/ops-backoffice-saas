# Local development only. The zammad-dev-setup service in docker-compose.yml runs it on every
# `docker compose up`, after zammad-init. Safe to run again.
#
# The portal's tech account gets new groups (e.g. Podúlohy) only from the scheduler
# "OPS - add all groups to tech role." every 15 minutes, which zammad-init restarts on every start.
# Until then every subtask job fails with "Not authorized". Assign them right away.
Ops::AssignTechRoleToAllGroupsJob.perform_now

puts "OPS Tech Account role has all groups: #{Role.find_by!(name: 'OPS Tech Account').groups.pluck(:name).join(', ')}"

# A Backoffice started by dev/up has no sample tickets (CREATE_SAMPLE_TICKET=false), only the portal's tickets. The
# sample tickets task (zammad/lib/tasks/ops/backoffice.rake) also gives the admin the Incoming group and the role
# that sees OPS tickets, give them without it. Zammad's own welcome ticket goes too, and the sample tickets of a
# Backoffice started before CREATE_SAMPLE_TICKET=false, their customer is example.portal.customer@localhost.
if ENV['CREATE_SAMPLE_TICKET'] != 'true'
  admin = User.find_by!(email: ENV.fetch('ADMIN_EMAIL'))
  incoming = Group.find_by!(name: 'Incoming')
  admin.group_names_access_map = admin.group_names_access_map.merge(incoming.name => ['full'])
  admin.roles |= [Role.find_by!(name: 'Správca podnetov pre OPS')]
  admin.save!

  Ticket.where(title: 'Help me! I am an example ticket 🎓', customer: User.find_by(email: 'nicole.braun@zammad.org')).find_each(&:destroy!)
  Ticket.where(customer: User.find_by(email: 'example.portal.customer@localhost')).find_each(&:destroy!)
  puts "Admin #{admin.email} has group Incoming and role Správca podnetov pre OPS, no sample tickets: #{Ticket.count} tickets"
end
