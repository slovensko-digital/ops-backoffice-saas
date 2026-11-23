module Ops::TicketArticleTriggersSubscriptionsExtensions
  def trigger_update_subscriptions
    Ops::ArticleVisibilityChangedWebhookJob.perform_later(self) if saved_change_to_internal?
    super
  end
end
