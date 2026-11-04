class RemapTicketsCategoryJob < ApplicationJob
  def perform
    Ticket.find_each do |ticket|
      RemapTicketCategoryJob.perform_later(ticket)
    end
  end
end
