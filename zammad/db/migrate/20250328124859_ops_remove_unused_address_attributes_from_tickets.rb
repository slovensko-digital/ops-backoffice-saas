class OpsRemoveUnusedAddressAttributesFromTickets < ActiveRecord::Migration[6.1]
  def up
    return unless Setting.exists?(name: 'system_init_done')

    CoreWorkflow.delete_by(name: 'hide state and county')

    [
      'address_state',
      'address_county',
      'address_suburb',
    ].each do |attribute|
      ObjectManager::Attribute.remove(object: 'Ticket', name: attribute)
    end

    ObjectManager::Attribute.migration_execute
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
