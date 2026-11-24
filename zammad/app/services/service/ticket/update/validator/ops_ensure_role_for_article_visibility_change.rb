# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Service::Ticket::Update::Validator
  class OpsEnsureRoleForArticleVisibilityChange < Base

    def valid!
      return if ticket.origin != 'ops'
      return if article_data[:body].present? && internal? # adding private article is always allowed
      return if @user.role?('Správca podnetov pre OPS')

      raise Error
    end

    class Error < Service::Ticket::Update::Validator::BaseError
      def initialize
        super(__('Nemáte oprávnenie komunikovať verejne.'))
      end
    end

    private

    # Cast like ActiveRecord does when it saves the article, so "false", "0" or 0
    # count as public here too. Anything else that isn't true counts as public as well.
    def internal?
      ActiveModel::Type::Boolean.new.cast(article_data[:internal]) == true
    end
  end
end
