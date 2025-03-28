class OpsRenameSomeAddressAttributesInTickets < ActiveRecord::Migration[7.0]
  def up
    return unless Setting.exists?(name: 'system_init_done')

    [
      [ "address_street", 'Adresa (Ulica)', 57, true ],
      [ "address_municipality", 'Adresa (Mesto / Obec)', 53, true ],
      [ "address_municipality_district", 'Adresa (Mestská časť)', 54, true ]
    ].each do |name, title, position, shown|
      ObjectManager::Attribute.add(
        object: 'Ticket',
        name: name.dup,
        display: __(title),
        data_type: 'input',
        data_option: {
          type: 'text',
          default: '',
          null: true,
          maxlength: 255,
        },
        active: true,
        screens: {
          create_middle: {
            'ticket.customer' => { shown: shown },
            'ticket.agent' => { shown: shown }
          },
          edit: {
            'ticket.customer' => { shown: true },
            'ticket.agent' => { shown: true }
          }
        },
        position: position,
        created_by_id: 1,
        updated_by_id: 1,
      )
    end

    ObjectManager::Attribute.migration_execute

    Ticket.find_each do |ticket|
      ticket.update!(
        address_street: ticket.address_road,
        address_municipality: ticket.address_city,
        address_municipality_district: ticket.address_city_district,
      )
    end

    CoreWorkflow.find_by(name: 'ops - read-only ticket attributes') do |flow|
      # remove entries for old attributes from the hash and add new entries
      flow.perform = flow.perform.except(
        "ticket.address_road",
        "ticket.address_city",
        "ticket.address_city_district",
        "ticket.address_street",
        "ticket.address_municipality",
        "ticket.address_municipality_district"
      ).merge(
        "ticket.address_street" => { "operator" => "set_readonly", "set_readonly" => "true" },
        "ticket.address_municipality" => { "operator" => "set_readonly", "set_readonly" => "true" },
        "ticket.address_municipality_district" => { "operator" => "set_readonly", "set_readonly" => "true" }
      )
      flow.save!
    end

    [
      "address_road",
      "address_city",
      "address_city_district"
    ].each do |name|
      ObjectManager::Attribute.remove(object: 'Ticket', name: name)
    end

    ObjectManager::Attribute.migration_execute
  end
end
