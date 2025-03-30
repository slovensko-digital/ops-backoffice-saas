class OpsAddOpsPortalUrlToTickets < ActiveRecord::Migration[7.1]
  def up
    return unless Setting.exists?(name: 'system_init_done')

    ObjectManager::Attribute.add(
      object: 'Ticket',
      name: 'ops_portal_url',
      display: 'Odkaz na portál',
      data_type: 'input',
      data_option: {
        default: '',
        type: 'url',
        maxlength: 2048,
        null: true,
        options: {},
        relation: ''
      },
      editable: true,
      active: true,
      screens: {
        edit: {
          'ticket.agent' => { shown: false },
          'ticket.customer' => { shown: false }
        },
        create_middle: {
          'ticket.customer' => { shown: false },
          'ticket.agent' => { shown: false }
        }
      },
      position: 101,
      created_by_id: 1,
      updated_by_id: 1
    )

    ObjectManager::Attribute.migration_execute
  end
  def down
    ObjectManager::Attribute.remove(
      object: 'Ticket',
      name: 'ops_portal_url',
    )

    ObjectManager::Attribute.migration_execute
  end
end
