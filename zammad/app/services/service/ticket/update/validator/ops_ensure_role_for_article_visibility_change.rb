# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Service::Ticket::Update::Validator
  class OpsEnsureRoleForArticleVisibilityChange < Base

    def valid!
      return if ticket.origin != 'ops'
      return if article_data[:body].present? && article_data[:internal] # adding private article is always allowed
      return if @user.role?('Správca podnetov pre OPS')

      raise Error
    end

    class Error < Service::Ticket::Update::Validator::BaseError
      def initialize
        super(__('Nemáte oprávnenie komunikovať verejne.'))
      end
    end
  end
end
