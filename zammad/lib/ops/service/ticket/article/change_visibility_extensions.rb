module Ops::Service::Ticket::Article::ChangeVisibilityExtensions
  def execute(article:, internal:)
    # mobile version change visibility
    Service::Ticket::Update::Validator::OpsEnsureRoleForArticleVisibilityChange.new(
      ticket: article.ticket,
      article_data: { internal: internal },
      user: current_user,
      ).valid!

    super
  end
end
