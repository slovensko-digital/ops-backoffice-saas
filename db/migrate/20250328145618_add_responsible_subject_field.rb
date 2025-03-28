class AddResponsibleSubjectField < ActiveRecord::Migration[6.1]
  def up
    return unless Setting.exists?(name: 'system_init_done')

    ObjectManager::Attribute.add(
      object: 'Ticket',
      name: 'ops_responsible_subject',
      display: __('Zodpovedný subjekt v Odkaze pre starostu'),
      data_type: 'autocompletion_ajax_external_data_source',
      data_option: {
        search_url: File.join(ENV.fetch('OPS_PORTAL_URL'), "/api/v1/responsible_subjects/search?q=\#{search.term}"),
        verify_ssl: ENV['OPS_PORTAL_URL'].start_with?('https'),
        http_auth_type: "",
        search_result_list_key: "",
        search_result_value_key: "id",
        search_result_label_key: "name",
        options: {},
        default: '',
        null: true,
        nulloption: true,
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
      position: 22,
      created_by_id: 1,
      updated_by_id: 1
    )

    ObjectManager::Attribute.migration_execute
  end

  def down
    ObjectManager::Attribute.remove(object: 'Ticket', name: 'ops_responsible_subject')
    ObjectManager::Attribute.migration_execute
  end
end
