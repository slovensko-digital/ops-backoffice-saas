module Ops::Service::Ticket::Article::ChangeVisibilityExtensions
  def execute
    # mobile version change visibility
    Ops::ArticleVisibilityWindow.check!(article, current_user)

    Service::Ticket::Update::Validator::OpsEnsureRoleForArticleVisibilityChange.new(
      ticket: article.ticket,
      article_data: { internal: internal },
      user: current_user,
    ).valid!

    super
  end
end
