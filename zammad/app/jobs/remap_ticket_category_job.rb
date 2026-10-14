class RemapTicketCategoryJob < ApplicationJob
  def perform(ticket)
    category, subcategory, subtype = Ticket::CategoryMapper.map_legacy_categories_to_new(ticket.ops_category, ticket.ops_subcategory, ticket.ops_subtype)

    ticket.update!(
      ops_category: category,
      ops_subcategory: subcategory,
      ops_subtype: subtype
    ) if category
  end
end
