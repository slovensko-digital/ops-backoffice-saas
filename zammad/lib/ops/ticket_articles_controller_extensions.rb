module Ops::TicketArticlesControllerExtensions
  def update
    # old desktop update article visibility
    article = Ticket::Article.find(params[:id])

    Service::Ticket::Update::Validator::OpsEnsureRoleForArticleVisibilityChange.new(
      ticket: article.ticket,
      article_data: { internal: params[:internal] },
      user: current_user,
    ).valid!

    super
  end
end
