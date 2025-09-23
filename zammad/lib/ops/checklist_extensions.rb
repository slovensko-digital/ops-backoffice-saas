module Ops::ChecklistExtensions
  def update_ticket
    if sorted_item_ids.count != item_ids.count
      a = sorted_item_ids.map(&:to_s)
      b = item_ids.map(&:to_s)
      self.sorted_item_ids = ((a & b) | b)
      save!
    else
      # original method from Checklist model
      return if ticket.destroyed?

      ticket.updated_at = Time.current
      ticket.save!
    end
  end
end
