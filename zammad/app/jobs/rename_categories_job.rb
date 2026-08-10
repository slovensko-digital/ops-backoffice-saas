class RenameCategoriesJob < ApplicationJob
  def perform
    Ticket.transaction do
      Ticket.where(ops_category: "Komunikácie", ops_subcategory: "schody", ops_subtype: "poškodená").update_all(ops_subtype: "poškodené")
      Ticket.where(ops_category: "Komunikácie", ops_subcategory: "schody", ops_subtype: "neodhrnutá").update_all(ops_subtype: "neodhrnuté")
      Ticket.where(ops_category: "Komunikácie", ops_subcategory: "schody", ops_subtype: "neposypaná").update_all(ops_subtype: "neposypané")
      Ticket.where(ops_category: "Komunikácie", ops_subcategory: "schody", ops_subtype: "znečistená").update_all(ops_subtype: "znečistené")
      Ticket.where(ops_category: "Kanalizácia", ops_subcategory: "kanalizáčná vpusť").update_all(ops_subcategory: "kanalizačná vpusť")
      Ticket.where(ops_category: "Kanalizácia", ops_subcategory: "kanalizáčná mriežka").update_all(ops_subcategory: "kanalizačná mriežka")
      Ticket.where(ops_category: "Osvetlenie", ops_subcategory: "osvetlenie", ops_subtype: "nefunknčné").update_all(ops_subtype: "nefunkčné")
    end
  end
end
