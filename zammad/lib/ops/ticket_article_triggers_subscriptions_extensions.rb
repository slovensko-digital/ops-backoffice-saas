module Ops::TicketArticleTriggersSubscriptionsExtensions
  def trigger_update_subscriptions
    Ops::ArticleUpdatedWebhookJob.perform_later(self)
    super
  end
end
