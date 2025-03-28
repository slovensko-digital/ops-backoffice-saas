class OpsRemoveOldHidingCoreWorkflow < ActiveRecord::Migration[6.0]
  def up
    return unless Setting.exists?(name: 'system_init_done')

    CoreWorkflow.delete_by(name: 'hide state and group from create_middle')
  end

  def down
    CoreWorkflow.find_or_initialize_by(name: 'hide state and group from create_middle').tap do |flow|
      flow.object = "Ticket"
      flow.preferences = { "screen" => [ "create_middle" ] }
      flow.condition_saved = {}
      flow.condition_selected = {
        "session.role_ids" => { "operator" => "is", "value" => [ Role.find_by(name: "Customer").id ] }
      },
      flow.perform = {
        "ticket.state_id" => { "operator" => "hide", "hide" => "true" },
        "ticket.group_id" => { "operator" => "hide", "hide" => "true" }
      }
      flow.active = true
      flow.stop_after_match = false
      flow.changeable = true
      flow.priority = 100
      flow.updated_by_id = 1
      flow.created_by_id = 1
    end.save!
  end
end
