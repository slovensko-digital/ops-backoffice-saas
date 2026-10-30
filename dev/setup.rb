# Local development only. The zammad-dev-setup service in docker-compose.yml runs it on every
# `docker compose up`, after zammad-init. Safe to run again.
#
# The portal's tech account gets new groups (e.g. Podúlohy) only from the scheduler
# "OPS - add all groups to tech role." every 15 minutes, which zammad-init restarts on every start.
# Until then every subtask job fails with "Not authorized". Assign them right away.
Ops::AssignTechRoleToAllGroupsJob.perform_now

puts "OPS Tech Account role has all groups: #{Role.find_by!(name: 'OPS Tech Account').groups.pluck(:name).join(', ')}"
