class OpsChangeOpsIssueTypeToSelect < ActiveRecord::Migration[7.0]
  def up
    return unless Setting.exists?(name: 'system_init_done')

    if ObjectManager::Attribute.where(name: 'ops_issue_type', object_lookup: ObjectLookup.by_name('Ticket')).exists?
      ObjectManager::Attribute.remove(name: 'ops_issue_type', object: 'Ticket')
      ObjectManager::Attribute.migration_execute
    end

    ObjectManager::Attribute.add(
      object: 'Ticket',
      name: 'ops_issue_type',
      display: 'Typ dopytu',
      data_type: 'select',
      data_option: {
        options: [
          { name: 'Podnet', value: 'issue' },
          { name: 'Otázka', value: 'question' },
          { name: 'Pochvala', value: 'praise' }
        ],
        customsort: 'on',
        default: '',
        null: true,
        nulloption: true,
        maxlength: 255,
      },
      active: true,
      screens: {
        create_middle: {
          'ticket.agent' => { shown: false },
          'ticket.customer' => { shown: false }
        },
        edit: {
          'ticket.agent' => { shown: false },
          'ticket.customer' => { shown: false }
        }
      },
      position: 15,
      created_by_id: 1,
      updated_by_id: 1
    )

    ObjectManager::Attribute.migration_execute

    Ticket.where(origin: 'ops').find_each { |ticket| ticket.update(ops_issue_type: "issue") }
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot revert ops_issue_type to string'
  end
end
