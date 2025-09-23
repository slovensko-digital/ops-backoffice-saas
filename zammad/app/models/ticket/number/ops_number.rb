module Ticket::Number::OpsNumber
  extend Ticket::Number::Base

  def self.generate
    Ticket::Number::Increment.generate
  end

  def self.check(string)
    ticket = Ticket::Number::Increment.check(string)
    return ticket if ticket

    ticket_hook = Setting.get('ticket_hook')
    ticket_hook_divider = Setting.get('ticket_hook_divider').to_s

    string.scan(%r{(?<=\W|^)#{Regexp.quote(ticket_hook)}#{Regexp.quote(ticket_hook_divider)}((OPS|SUB)-[\d-]{2,48})\b}i) do
      ticket = Ticket.find_by(number: $1)
      break if ticket
    end

    ticket
  end

  def self.config
    Setting.get('ticket_number_increment')
  end

  private_class_method :config
end
