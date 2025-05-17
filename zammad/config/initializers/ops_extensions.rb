ActiveSupport.on_load(:after_initialize) do
  TicketArticlesController.prepend Ops::TicketArticlesControllerExtensions
  Service::Ticket::Article::ChangeVisibility.prepend Ops::Service::Ticket::Article::ChangeVisibilityExtensions
  CreatesTicketArticles.prepend Ops::CreatesTicketArticlesExtensions
  User.prepend Ops::UserExtensions
end
