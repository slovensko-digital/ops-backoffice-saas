module Ops::ArticleVisibilityWindow
  WINDOW = 24.hours

  # visibility of an ops article can only change within a day of sending it;
  # after that, only support (admins) can still change it.
  def self.check!(article, user)
    return unless article.ticket.origin == 'ops'
    return if user.role?('Admin')
    return unless article.created_at
    return if article.created_at + WINDOW >= Time.zone.now

    raise Exceptions::Forbidden, __('Komentár je možné skryť alebo zverejniť len do 24 hodín od jeho odoslania.')
  end
end
