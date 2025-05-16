class OpsRemoveHideOpsAttrsWorkflow < ActiveRecord::Migration[7.1]
  def up
    cw = CoreWorkflow.find_by(name: 'ops - hide ops attributes for non-ops tickets')
    cw.destroy if cw
  end

  def down
    # No rollback needed
  end
end
