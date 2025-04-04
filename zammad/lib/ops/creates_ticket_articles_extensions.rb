module Ops
  module CreatesTicketArticlesExtensions
    def article_create(ticket, params)
      validator = ::Service::Ticket::Update::Validator::OpsEnsureRoleForArticleVisibilityChange.new(
        user: current_user,
        ticket: ticket,
        article_data: params,
      )

      begin
        validator.valid!
      rescue ::Service::Ticket::Update::Validator::BaseError => e
        raise ::Exceptions::Forbidden, e.message
      end

      super
    end
  end
end
