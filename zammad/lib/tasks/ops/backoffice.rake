# name, title, position, shown_on_creation
READ_ONLY_ATTRIBUTES = [
  ['ops_category', 'Kategória v Odkaze pre starostu', 17, false],
  ['ops_subcategory', 'Podkategória', 19, false],
  ['ops_subtype', 'Typ Problému', 20, false],
  ['address_municipality', 'Adresa (Mesto / Obec)', 53, true],
  ['address_municipality_district', 'Adresa (Mestská časť)', 54, true],
  ['address_street', 'Adresa (Ulica)', 56, true],
  ['address_house_number', 'Adresa (Číslo domu)', 57, true],
]

class RequestMock
  attr_accessor :remote_ip, :env
  def initialize(remote_ip, env)
    @remote_ip = remote_ip
    @env = env
  end
end

def setup_admin_user
  admin_user_data = {
    email: ENV.fetch('ADMIN_EMAIL'),
    password: ENV.fetch('ADMIN_PASSWORD'),
    firstname: ENV.fetch('ADMIN_FIRSTNAME'),
    lastname: ENV.fetch('ADMIN_LASTNAME')
  }

  request = RequestMock.new('127.0.0.1', { 'HTTP_ACCEPT_LANGUAGE' => ENV.fetch('DEFAULT_LOCALE', 'sk') })
  Service::User::AddFirstAdmin.new.execute(user_data: admin_user_data, request: request)
end

def setup_technical_user(role_ids)
  Rails.logger.info "Setting up technical user..."
  params = {
    "firstname":"Aplikácia",
    "lastname":"Odkaz pre starostu",
    "note":"",
    "role_ids": role_ids,
    "active":true,
    "vip":false,
    "id":"c-3",
    "updated_by_id": "1",
    "created_by_id": "1",
  }
  user = User.new(params)
  user.associations_from_param(params)
  user.save!

  token = Token.create!(
    action:     'api',
    persistent: true,
    user_id:    user.id,
    name: "Token 2",
    preferences: {"permission"=>["admin.user", "report", "ticket.agent", "admin.group", "admin.role"]}
  )
  token.token = ENV.fetch('API_TOKEN', SecureRandom.urlsafe_base64(48))
  token.save!
end

def create_ops_user_roles
  Rails.logger.info "Create OPS User role..."
  ops_user_role = Role.find_or_initialize_by(name: 'OPS User') do |role|
    role.note = __('Odkaz pre starostu portal users.')
    role.default_at_signup = false
    role.preferences = {}
    role.updated_by_id = 1
    role.created_by_id = 1
  end
  ops_user_role.save!

  Rails.logger.info "Create Správca podnetov pre OPS role..."
  agent_ops_role = Role.find_or_initialize_by(name: 'Správca podnetov pre OPS').tap do |role|
    role.note = __('Agent Odkazu pre starostu.')
    role.active = true
    role.updated_by_id = 1
    role.created_by_id = 1
  end
  agent_ops_role.permission_grant('ticket.agent')
  agent_ops_role.save!
end

def create_ops_tech_account_role
  Rails.logger.info "Create OPS Tech Account role..."
  ops_tech_account_role = Role.find_or_initialize_by(name: 'OPS Tech Account').tap do |role|
    role.note = __('OPS tech account.')
    role.active = true
    role.updated_by_id = 1
    role.created_by_id = 1
  end
  ops_tech_account_role.permission_grant('admin.user')
  ops_tech_account_role.permission_grant("admin.group")
  ops_tech_account_role.permission_grant("admin.role")
  ops_tech_account_role.permission_grant('ticket.agent')
  ops_tech_account_role.permission_grant('user_preferences.access_token')
  ops_tech_account_role.groups << Group.find_by(name: 'Incoming')
  ops_tech_account_role.groups << Group.find_by(name: 'Stará verzia Odkaz pre starostu')
  ops_tech_account_role.save!
  ops_tech_account_role
end

def create_subject_admin_role
  Rails.logger.info "Create Administrátor systému role..."
  role = Role.find_or_initialize_by(name: 'Administrátor systému').tap do |role|
    role.active = true
    role.updated_by_id = 1
    role.created_by_id = 1
  end

  role.permission_grant("admin.channel_email")
  role.permission_grant("admin.channel_facebook")
  role.permission_grant("admin.channel_formular")
  role.permission_grant("admin.channel_google")
  role.permission_grant("admin.channel_chat")
  role.permission_grant("admin.channel_microsoft_graph")
  role.permission_grant("admin.channel_microsoft365")
  role.permission_grant("admin.channel_sms")
  role.permission_grant("admin.channel_telegram")
  role.permission_grant("admin.channel_twitter")
  role.permission_grant("admin.channel_web")
  role.permission_grant("admin.channel_whatsapp")
  role.permission_grant("admin.integration")
  role.permission_grant("admin.core_workflow")
  role.permission_grant("admin.translation")
  role.permission_grant("admin.data_privacy")
  role.permission_grant("admin.monitoring")
  role.permission_grant("admin.branding")
  role.permission_grant("admin.calendar")
  role.permission_grant("admin.group")
  role.permission_grant("admin.checklist")
  role.permission_grant("admin.knowledge_base")
  role.permission_grant("admin.macro")
  role.permission_grant("admin.overview")
  role.permission_grant("admin.role")
  role.permission_grant("admin.scheduler")
  role.permission_grant("admin.sla")
  role.permission_grant("admin.security")
  role.permission_grant("admin.tag")
  role.permission_grant("admin.template")
  role.permission_grant("admin.text_module")
  role.permission_grant("admin.time_accounting")
  role.permission_grant("admin.trigger")
  role.permission_grant("admin.user")
  role.permission_grant("admin.ticket")
  role.permission_grant("admin.ticket_auto_assignment")
  role.permission_grant("admin.ticket_duplicate_detection")
  role.permission_grant("admin.ticket_priority")
  role.permission_grant("admin.ticket_state")
  role.permission_grant("knowledge_base.editor")
  role.permission_grant("report")
  role.permission_grant("admin.report_profile")
  role.permission_grant("user_preferences")

  role.save!
end

def update_agent_role_permissions
  Rails.logger.info "Update agent role permissions..."
  agent_role = Role.find_by(name: 'Agent')
  agent_role.permission_revoke('user_preferences')

  agent_role.permission_grant('user_preferences.appearance')
  agent_role.permission_grant('user_preferences.avatar')
  agent_role.permission_grant('user_preferences.calendar')
  agent_role.permission_grant('user_preferences.device')
  agent_role.permission_grant('user_preferences.language')
  agent_role.permission_grant('user_preferences.linked_accounts')
  agent_role.permission_grant('user_preferences.notifications')
  agent_role.permission_grant('user_preferences.out_of_office')
  agent_role.permission_grant('user_preferences.overview_sorting')
  agent_role.permission_grant('user_preferences.password')
  agent_role.permission_grant('user_preferences.two_factor_authentication')

  agent_role.save!
end

def setup_elastic
  Rails.logger.info "Setting up Elasticsearch..."
  Setting.set('es_url', "#{ENV.fetch('ELASTICSEARCH_SCHEMA')}://#{ENV.fetch('ELASTICSEARCH_HOST')}:#{ENV.fetch('ELASTICSEARCH_PORT')}")
  Setting.set('es_user', ENV.fetch('ZAMMAD_ELASTICSEARCH_USER'))
  Setting.set('es_password', ENV.fetch('ZAMMAD_ELASTICSEARCH_PASSWORD'))
  Setting.set('es_index', ENV.fetch('ELASTICSEARCH_NAMESPACE'))
end

def setup_notifications
  Setting.set('notification_sender', "#{ENV.fetch('NOTIFICATION_SENDER')} <#{ENV.fetch('NOTIFICATION_SMTP_USER')}>")

  Channel.where(area: "Email::Notification").select{ |ch| ch.options[:outbound][:adapter] == "smtp" }.first.update!(
    options: {
      "outbound" => {
        "adapter" => "smtp",
        "options" => {
          "host" => ENV.fetch('NOTIFICATION_SMTP_HOST'),
          "user" => ENV.fetch('NOTIFICATION_SMTP_USER'),
          "password" => ENV.fetch('NOTIFICATION_SMTP_PASSWORD'),
          "port" => ENV.fetch('NOTIFICATION_SMTP_PORT'),
          "ssl_verify" => true,
          "domain" => ENV.fetch('FQDN', 'localhost'),
          "enable_starttls_auto" => true
        }
      }
    },
    active: true
  )

  Channel.where(area: "Email::Notification").select{ |ch| ch.options[:outbound][:adapter] == "sendmail" }.first.update!(active: false)

  # Do not send email notifications about updated unassigned tickets to all agents
  Setting.set(
    'ticket_agent_default_notifications',
    {
      "create" => {
        "criteria" => { "owned_by_me" => true, "owned_by_nobody" => true, "subscribed" => true, "no" => false },
        "channel" => { "email" => true, "online" => true }
      },
      "update" => {
        "criteria" => { "owned_by_me" => true, "owned_by_nobody" => false, "subscribed" => true, "no" => false },
        "channel" => { "email" => true, "online" => true }
      },
      "reminder_reached" => {
        "criteria" => { "owned_by_me" => true, "owned_by_nobody" => false, "subscribed" => false, "no" => false },
        "channel" => { "email" => true, "online" => true }
      },
      "escalation" => {
        "criteria" => { "owned_by_me" => true, "owned_by_nobody" => false, "subscribed" => false, "no" => false },
        "channel" => { "email" => true, "online" => true }
      }
    }
  )
end

namespace :ops do
  namespace :backoffice do
    desc "Migrates backoffice environment"
    task migrate: :environment do
      next unless User.any?

      unless User.count > 2
        setup_admin_user

        Rails.logger.info "Migrating backoffice environment..."
        Rails.logger.info "Setting branding..."
        Setting.set('fqdn', ENV.fetch('FQDN'))
        Setting.set('product_name', ENV.fetch('PRODUCT_NAME'))
        Setting.set('organization', ENV.fetch('ORGANIZATION'))
        Setting.set('http_type', ENV.fetch('HTTP_TYPE', 'http'))
        Setting.set('ticket_hook', "Tiket#")

        Ticket::Article::Type.find_by_name(:note).update!(communication: true)

        Rails.logger.info "Setting access control..."
        Setting.set('user_create_account', false) # Disable user creation via web interface
        Setting.set('api_password_access', false) # Disable password access to REST API
        Setting.set('auth_third_party_auto_link_at_inital_login', true)
        Setting.set('auth_third_party_no_create_user', true)

        Rails.logger.info "Turning on sidebar article attachments..."
        Setting.set('ui_ticket_zoom_sidebar_article_attachments', 'true')

        Rails.logger.info "Destroying unused ticket states..."
        Ticket::State.find_by(name: "merged").destroy
      end

      if ENV.fetch('GOOGLE_OAUTH2_CLIENT_ID', "").present? && ENV.fetch('GOOGLE_OAUTH2_CLIENT_SECRET', "").present?
        Rails.logger.info "Setting up Google OAuth2..."
        Setting.set("auth_google_oauth2", true)
        Setting.set("auth_google_oauth2_credentials", {
          "client_id"=>ENV.fetch('GOOGLE_OAUTH2_CLIENT_ID'),
          "client_secret"=>ENV.fetch('GOOGLE_OAUTH2_CLIENT_SECRET')
        })
      end

      Rails.logger.info "Create incoming group..."
      incoming_group = Group.find_or_initialize_by(name: 'Incoming').tap do |group|
        group.note = __('Incoming tickets group.')
        group.active = true
        group.updated_by_id = 1
        group.created_by_id = 1
      end
      incoming_group.save!

      Rails.logger.info "Set Incoming group as default for new web tickets..."
      Setting.set('customer_ticket_create_group_ids', [ incoming_group.id ])

      Rails.logger.info "Allowing only 'phone-in' new tickets in UI..."
      Setting.set('ui_ticket_create_available_types', [ "phone-in" ])

      Rails.logger.info "Create Stará verzia Odkaz pre starostu group..."
      import_group = Group.find_or_initialize_by(name: 'Stará verzia Odkaz pre starostu').tap do |group|
        group.note = __('Podnety importované zo staršej verzie Odkazu pre starostu.')
        group.active = true
        group.updated_by_id = 1
        group.created_by_id = 1
      end
      import_group.save!

      setup_elastic if ENV['ELASTICSEARCH_ENABLED'] == 'true'

      create_ops_user_roles
      ops_tech_role = create_ops_tech_account_role

      setup_technical_user([ ops_tech_role.id, Role.find_by(name: "Správca podnetov pre OPS").id, Role.find_by(name: "Admin").id ]) unless User.count > 3

      update_agent_role_permissions

      create_subject_admin_role

      setup_notifications if ENV['NOTIFICATION_SENDER'].present? && ENV['NOTIFICATION_SMTP_PASSWORD'].present? && ENV['NOTIFICATION_SMTP_USER'].present?

      Setting.set("monitoring_token", ENV['MONITORING_TOKEN']) if ENV['MONITORING_TOKEN'].present?

      # add ops readonly attributes to ticket
      READ_ONLY_ATTRIBUTES.each do |name, title, position, shown|
        ObjectManager::Attribute.add(
          object: 'Ticket',
          name: name.dup,
          display: __(title),
          data_type: 'input',
          data_option: {
            type: 'text',
            default: '',
            null: true,
            maxlength: 255,
          },
          active: true,
          screens: {
            create_middle: {
              'ticket.customer' => { shown: shown },
              'ticket.agent' => { shown: shown }
            },
            edit: {
              'ticket.customer' => { shown: shown },
              'ticket.agent' => { shown: shown }
            }
          },
          position: position,
          created_by_id: 1,
          updated_by_id: 1,
        )
      end

      # add origin to tickets
      ObjectManager::Attribute.add(
        object: 'Ticket',
        name: 'origin',
        display: __('Zdroj'),
        data_type: 'select',
        data_option: {
          options: [
            { name: 'Odkaz pre starostu', value: 'ops' }
          ],
          customsort: 'on',
          default: nil,
          null: true,
          nulloption: true,
          maxlength: 255,
        },
        active: true,
        screens: {
          create_middle: {
            'ticket.customer' => { shown: false },
            'ticket.agent' => { shown: false }
          },
          edit: {
            'ticket.customer' => { shown: false },
            'ticket.agent' => { shown: false }
          }
        },
        position: 16,
        created_by_id: 1,
        updated_by_id: 1
      )

      # add investment to tickets
      ObjectManager::Attribute.add(
        object: 'Ticket',
        name: 'ops_investment',
        display: __('Investičná akcia'),
        data_type: 'boolean',
        data_option: {
          options: { false => 'nie', true => 'áno' },
          default: false,
          null: true,
          relation: ''
        },
        active: true,
        screens: {
          create_middle: {
            'ticket.customer' => { shown: false },
            'ticket.agent' => { shown: false }
          },
          edit: {
            'ticket.customer' => { shown: false },
            'ticket.agent' => { shown: false }
          }
        },
        position: 42,
        created_by_id: 1,
        updated_by_id: 1
      )

      # add ops_likes_count to tickets
      ObjectManager::Attribute.add(
        object: 'Ticket',
        name: 'ops_likes_count',
        display: __('Počet hlasov'),
        data_type: 'integer',
        data_option: {
          "default" => nil, "min" => 0, "max" => 999999999, "null" => true, "options" => {}, "relation" => ""
        },
        active: true,
        screens: {
          edit: {
            'ticket.agent' => { shown: false },
            'ticket.customer' => { shown: false },
          },
          create_middle: {
            'ticket.agent' => { shown: false },
            'ticket.customer' => { shown: false },
          }
        },
        position: 100,
        created_by_id: 1,
        updated_by_id: 1,
      )

      # rm old ops_state from tickets
      if ObjectManager::Attribute.where(name: 'ops_state', data_type: 'input', object_lookup: ObjectLookup.by_name('Ticket')).exists?
        ObjectManager::Attribute.remove(object: 'Ticket', name: 'ops_state')
        ObjectManager::Attribute.migration_execute
      end

      # add ops_state to tickets
      ObjectManager::Attribute.add(
        object: 'Ticket',
        name: 'ops_state',
        display: __('Stav v Odkaze pre starostu'),
        data_type: 'select',
        data_option: {
          options: {
            "waiting" => "Čakajúci",
            "rejected" => "Zamietnutý",
            "sent_to_responsible" => "Zaslaný zodpovednému",
            "in_progress" => "V riešení",
            "marked_as_resolved" => "Označený za vyriešený",
            "resolved" => "Vyriešený",
            "unresolved" => "Neriešený",
            "closed" => "Uzavretý",
            "referred" => "Odstúpený",
          },
          default: 'waiting',
          nulloption: true,
          null: true,
        },
        active: true,
        screens: {
          create_middle: {
            'ticket.agent' => { shown: false },
            'ticket.customer' => { shown: false },
          },
          edit: {
            'ticket.agent' => { shown: false },
            'ticket.customer' => { shown: false },
          }
        },
        position: 39,
        created_by_id: 1,
        updated_by_id: 1
      )

      ObjectManager::Attribute.migration_execute

      # add text_module
      TextModule.find_or_initialize_by(name: 'OPS - Verejný komentár pre odkazprestarostu').tap do |tm|
        tm.keywords = "verejný, portal, ops, občan"
        tm.content = "[[ops portal]]"
        tm.note = "Značka, ktorá v Odkaze pre starostu spôsobí automatické zverejnenie na portáli odkazu pre starostu."
        tm.active = true
        tm.updated_by_id = 1
        tm.created_by_id = 1
      end.save!

      # make origin readonly for all tickets
      CoreWorkflow.find_or_initialize_by(name: 'ops - read-only origin').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "create_middle", "edit" ] }
        flow.condition_saved = {}
        flow.condition_selected = {}
        flow.perform = {
          "ticket.origin" => { "operator" => "set_readonly", "set_readonly" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 500
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      # show origin only if set
      CoreWorkflow.find_or_initialize_by(name: 'ops - show ticket origin if set').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = { "ticket.origin" => { "operator" => "is set", "value" => [] } }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.origin" => { "operator" => "show", "show" => "true" },
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 100
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      # make ops attributes read-only
      CoreWorkflow.find_or_initialize_by(name: 'ops - read-only ticket attributes').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "create_middle", "edit" ] }
        flow.condition_saved = { "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] } }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_likes_count" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_responsible_subject" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_responsible_subject_changed_at" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_state" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.address_lat" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.address_lon" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.address_postcode" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_portal_url" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_issue_type" => { "operator" => "set_readonly", "set_readonly" => "true" },
        }.merge(READ_ONLY_ATTRIBUTES.map { |name, _, _, _| [name, { "operator" => "set_readonly", "set_readonly" => "true" }] }.to_h)
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 100
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - read-only attributes for tickets with different responsible subject').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "create_middle", "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_responsible_subject" => {
            "operator" => "is not",
            "value_completion" => "",
            "value" => [
              {
                "label" => ENV.fetch('OPS_RESPONSIBLE_SUBJECT'),
                "value" => ENV.fetch('OPS_RESPONSIBLE_SUBJECT_ID')
              }
            ]
          }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_responsible_subject" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_responsible_subject_changed_at" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_state" => { "operator" => "set_readonly", "set_readonly" => "true" },
          "ticket.ops_investment" => { "operator" => "set_readonly", "set_readonly" => "true" },
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 120
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - show ops attributes for ops tickets').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "issue", "question" ] }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_likes_count" => { "operator" => "show", "show" => "true" },
          "ticket.ops_state" => { "operator" => "show", "show" => "true" },
          "ticket.ops_responsible_subject" => { "operator" => "show", "show" => "true" },
          "ticket.address_lat" => { "operator" => "show", "show" => "true" },
          "ticket.address_lon" => { "operator" => "show", "show" => "true" },
          "ticket.address_postcode" => { "operator" => "show", "show" => "true" },
          "ticket.ops_portal_url" => { "operator" => "show", "show" => "true" },
          "ticket.ops_issue_type" => { "operator" => "show", "show" => "true" },
          "ticket.ops_investment" => { "operator" => "show", "show" => "true" },
        }.merge(READ_ONLY_ATTRIBUTES.map { |name, _, _, _| [name, { "operator" => "show", "show" => "true" }] }.to_h)
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 99
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - setup ops attributes for ops praises').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "praise" ] }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_likes_count" => { "operator" => "show", "show" => "true" },
          "ticket.ops_state" => { "operator" => "show", "show" => "true" },
          "ticket.ops_issue_type" => { "operator" => "show", "show" => "true" },
          "ticket.address_municipality" => { "operator" => "hide", "hide" => "true" },
          "ticket.address_municipality_district" => { "operator" => "hide", "hide" => "true" },
          "ticket.address_street" => { "operator" => "hide", "hide" => "true" },
          "ticket.address_house_number" => { "operator" => "hide", "hide" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 99
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - show ops portal url for ops public praises').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "praise" ] },
          "ticket.ops_state" => { "operator" => "is", "value" => [ "resolved" ] },
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_portal_url" => { "operator" => "show", "show" => "true" },
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 99
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - show ops_category for manual ticket if present').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is not", "value" => [ "ops" ] },
          "ticket.ops_category" => { "operator" => "is set", "value" => [] }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_category" => { "operator" => "show", "show" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 99
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - show ops_subcategory for manual ticket if present').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is not", "value" => [ "ops" ] },
          "ticket.ops_subcategory" => { "operator" => "is set", "value" => [] }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_subcategory" => { "operator" => "show", "show" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 99
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - show ops_subtype for manual ticket if present').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is not", "value" => [ "ops" ] },
          "ticket.ops_subtype" => { "operator" => "is set", "value" => [] }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_subtype" => { "operator" => "show", "show" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 99
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      # allow only certain ops_states to be selected
      CoreWorkflow.find_or_initialize_by(name: 'ops - only allow certain ops_states').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_state" => { "operator" => "is not", "value" => [ "resolved", "unresolved", "closed" ] }
        }
        flow.condition_selected = {}
        flow.perform = { "ticket.ops_state" => {
          "operator" => [ "set_fixed_to", "set_mandatory" ],
          "set_fixed_to" => [ "sent_to_responsible", "in_progress", "marked_as_resolved", "referred" ],
          "set_mandatory" => "true"
        } }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 100
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'ops - set ops_state and responsible subject readonly if final').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_state" => { "operator" => "is", "value" => [ "resolved", "unresolved", "closed" ] }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_state" => { "operator" => [ "set_readonly" ], "set_readonly" => "true" },
          "ticket.ops_responsible_subject" => { "operator" => [ "set_readonly" ], "set_readonly" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = false
        flow.priority = 130
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      # allow Správca podnetov pre OPS to edit ops attributes ops_state and ops_responsible_subject
      CoreWorkflow.find_or_initialize_by(name: 'OPS - povoliť role Správca podnetov pre OPS meniť stav a zodpovedný subjekt pre Odkaz pre starostu').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "issue", "question" ] }
        }
        flow.condition_selected = { "session.role_ids" => { "operator" => "is", "value" => [ Role.find_by(name: "Správca podnetov pre OPS").id ] } }
        flow.perform = {
          "ticket.ops_state" => { "operator" => "unset_readonly", "unset_readonly" => "true" },
          "ticket.ops_responsible_subject" => { "operator" => "unset_readonly", "unset_readonly" => "true" }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = true
        flow.priority = 120
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      # when ops_responsible_subject is changed, set ops_state to "sent_to_responsible" and state to pending close 1 week
      CoreWorkflow.find_or_initialize_by(name: 'OPS - zmeniť stav tiketu pri zmene zodpovednosti').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] }
        }
        flow.condition_selected = {
          "session.role_ids" => { "operator" => "is", "value" => [ Role.find_by(name: "Správca podnetov pre OPS").id ] },
          "ticket.ops_responsible_subject" => { "operator" => "just changed", "value_completion" => "", "value" => [ ] }
        }
        flow.perform = {
          "ticket.ops_state" => { "operator" => [ "set_fixed_to", "set_readonly" ],
            "set_fixed_to" => [ "sent_to_responsible" ],
            "set_readonly" => "true"
          },
          "ticket.investment" => { "operator" => "set_readonly", "set_readonly" => "true" },
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = true
        flow.priority = 200
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      # add workflow to stop all other workflows for ops tech user role
      CoreWorkflow.find_or_initialize_by(name: 'ops - stop all other workflows for ops tech user role').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {}
        flow.condition_selected = { "session.role_ids" => { "operator" => "is", "value" => [ Role.find_by(name: "OPS Tech Account").id ] } }
        flow.perform = {}
        flow.active = true
        flow.stop_after_match = true
        flow.changeable = false
        flow.priority = 1
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!

      CoreWorkflow.find_or_initialize_by(name: 'OPS - Zobraz ID dopytu v prehľade').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.ops_issue_identifier" => { "operator" => [ "set_readonly", "show" ],
            "set_readonly" => "true",
            "show" => "true"
          },
        }
        flow.active = false
        flow.stop_after_match = false
        flow.changeable = true
        flow.priority = 50
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save! unless CoreWorkflow.where(name: 'OPS - Zobraz ID dopytu v prehľade').exists?

      CoreWorkflow.find_or_initialize_by(name: 'OPS - Zobraz odkaz na kataster ak existujú koordináty').tap do |flow|
        flow.object = "Ticket"
        flow.preferences = { "screen" => [ "edit" ] }
        flow.condition_saved = {
          "ticket.address_lat" => { "operator" => "is set", "value" => "" },
          "ticket.address_lon" => { "operator" => "is set", "value" => "" }
        }
        flow.condition_selected = {}
        flow.perform = {
          "ticket.zbgis_link" => {
            "operator" => ["show", "set_readonly"],
            "show" => "true",
            "set_readonly" => "true"
          }
        }
        flow.active = true
        flow.stop_after_match = false
        flow.changeable = true
        flow.priority = 250
        flow.updated_by_id = 1
        flow.created_by_id = 1
      end.save!


      # add ticket.updated webhook
      Webhook.find_or_initialize_by(name: 'OPS - ticket.updated').tap do |webhook|
        webhook.endpoint = File.join(ENV.fetch('OPS_CONNECTOR_URL'), 'connector/backoffice/webhook')
        webhook.signature_token = ENV.fetch('WEBHOOK_SECRET')
        webhook.ssl_verify = ENV.fetch('OPS_CONNECTOR_URL').start_with?('https')
        webhook.note = "Oznámenie zmeny v tickete pre Odkaz pre starostu."
        webhook.customized_payload = true
        webhook.custom_payload = {
          "type" => "ticket.updated",
          "timestamp" => "\#{ticket.updated_at}",
          "data" => {
            "tenant_id" => ENV.fetch('WEBHOOK_TENANT_ID'),
            "ticket_id" => "\#{ticket.id}"
          }
        }.to_json
        webhook.preferences = {}
        webhook.active = true
        webhook.updated_by_id = 1
        webhook.created_by_id = 1
      end.save!

      # add article.created webhook
      Webhook.find_or_initialize_by(name: 'OPS - article.created').tap do |webhook|
        webhook.endpoint = File.join(ENV.fetch('OPS_CONNECTOR_URL'), 'connector/backoffice/webhook')
        webhook.signature_token = ENV.fetch('WEBHOOK_SECRET')
        webhook.ssl_verify = ENV.fetch('OPS_CONNECTOR_URL').start_with?('https')
        webhook.note = "Oznámenie zmeny v article pre Odkaz pre starostu."
        webhook.customized_payload = true
        webhook.custom_payload = {
          "type" => "article.created",
          "timestamp" => "\#{article.created_at}",
          "data" => {
            "tenant_id" => ENV.fetch('WEBHOOK_TENANT_ID'),
            "ticket_id" => "\#{ticket.id}",
            "article_id" => "\#{article.id}"
          }
        }.to_json
        webhook.preferences = {}
        webhook.active = true
        webhook.updated_by_id = 1
        webhook.created_by_id = 1
      end.save!

      tech_user = User.find_by(firstname: "Aplikácia", lastname: "Odkaz pre starostu")

      # add trigger for ticket.updated
      Trigger.find_or_initialize_by(name: 'OPS - ticket updated').tap do |trigger|
        trigger.condition = {
          "operator" => "AND",
          "conditions" => [
            { "name" => "ticket.origin", "operator" => "is", "value" => [ "ops" ] },
            { "name" => "ticket.ops_issue_type", "operator" => "is", "value" => [ "issue", "question" ] },
            { "name" => "ticket.updated_by_id", "operator" => "is not", "pre_condition" => "specific", "value" => [ tech_user.id ] },
            { "operator" => "OR", "conditions" => [
                { "name" => "ticket.ops_state", "operator" => "has changed", "value" => [ ] },
                { "name" => "ticket.ops_responsible_subject", "operator" => "has changed", "value" => [ ] },
                { "name" => "ticket.ops_investment", "operator" => "has changed", "value" => [ ] },
              ]
            }
          ]
        }
        trigger.perform = { "notification.webhook" => { "webhook_id" => Webhook.find_by(name: 'OPS - ticket.updated').id } }
        trigger.disable_notification = true
        trigger.localization = "system"
        trigger.timezone = "system"
        trigger.note = ""
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end.save!

      # add trigger for article.created
      Trigger.find_or_initialize_by(name: 'OPS - article created').tap do |trigger|
        trigger.condition = {
          "operator" => "AND",
          "conditions" => [
            { "name" => "ticket.origin", "operator" => "is", "value" => [ "ops" ] },
            { "name" => "ticket.ops_issue_type", "operator" => "is", "value" => [ "issue", "question" ] },
            { "name" => "article.type_id", "operator" => "is", "value" => [Ticket::Article::Type.find_by(name: "note").id] },
            { "name" => "article.internal", "operator" => "is", "value" => ["false"] },
            { "name" => "article.action", "operator" => "is", "value" => "create" },
            { "name" => "article.created_by_id", "operator" => "is not", "value" => [ tech_user.id ] }
          ]
        }
        trigger.perform = { "notification.webhook" => { "webhook_id" => Webhook.find_by(name: 'OPS - article.created').id } }
        trigger.disable_notification = true
        trigger.localization = "system"
        trigger.timezone = "system"
        trigger.note = ""
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end.save!

      # add trigger for more than 10 votes (allow user changes)
      Trigger.find_or_create_by!(name: 'OPS - viac ako 10 hlasov') do |trigger|
        trigger.condition = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "issue", "question" ] },
          "ticket.ops_likes_count" => { "operator" => "after (absolute)", "value" => 10 },
          "ticket.tags" => { "operator" => "contains one not", "value" => "10 hlasov" }
        }
        trigger.perform = {
          "article.note" => {
            "body" => "Dopyt dosiahol na portáli Odkaz pre starostu už 10 hlasov.",
            "internal" => "true",
            "subject" => "Dopyt dosiahol 10 hlasov"
          },
          "ticket.tags" => { "operator" => "add", "value" => "10 hlasov" }
        }
        trigger.disable_notification = true
        trigger.localization = "system"
        trigger.timezone = "system"
        trigger.note = ""
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end

      # add trigger for more than 100 votes (allow user changes)
      Trigger.find_or_create_by!(name: 'OPS - viac ako 100 hlasov') do |trigger|
        trigger.condition = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "issue", "question" ] },
          "ticket.ops_likes_count" => { "operator" => "after (absolute)", "value" => 100 },
          "ticket.tags" => { "operator" => "contains one not", "value" => "100 hlasov" }
        }
        trigger.perform = {
          "article.note" => {
            "body" => "Dopyt dosiahol na portáli Odkaz pre starostu už 100 hlasov.",
            "internal" => "true",
            "subject" => "Dopyt dosiahol 100 hlasov"
          },
          "ticket.tags" => { "operator" => "add", "value" => "100 hlasov" },
          "ticket.priority_id"=>{"value"=>"3"}
        }
        trigger.disable_notification = true
        trigger.localization = "system"
        trigger.timezone = "system"
        trigger.note = ""
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end

      Trigger.find_or_initialize_by(name: 'OPS - upozornenie pri novej pochvale').tap do |trigger|
        trigger.condition = {
          "ticket.origin" => { "operator" => "is", "value" => [ "ops" ] },
          "ticket.action" => { "operator" => "is", "value" => "create" },
          "ticket.ops_issue_type" => { "operator" => "is", "value" => [ "praise" ] }
        }
        trigger.perform = {
          "article.note" => {
            "body" => "<div>Pochvalu nie je možné komentovať. Ak sem pridáte nejakú odpoveď, nikam sa nepošle.</div>",
            "internal" => "true",
            "subject" => "Nová pochvala",
          }
        }
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end.save!

      # add trigger for sending public agent article via email
      Trigger.find_or_initialize_by(name: 'OPS - email public agent article to customer').tap do |trigger|
        trigger.condition = {
          "article.action" => { "operator" => "is", "value" => "create" },
          "ticket.origin" => { "operator" => "is not", "value" => [ "ops" ] },
          "article.type_id" => { "operator" => "is", "value" => [Ticket::Article::Type.find_by(name: "note").id] },
          "article.sender_id" => { "operator" => "is", "value" => [ Ticket::Article::Sender.lookup(name: 'Agent').id ] },
          "article.internal" => { "operator" => "is", "value" => [ "false" ] },
          "customer.email" => { "operator" => "contains", "value" => "@" }
        }
        trigger.perform = {
          "notification.email" => {
            "body" => "\#{created_article.body_as_html}",
            "internal" => "false",
            "recipient" => [ "ticket_customer" ],
            "subject" => "Odpoveď na - \#{ticket.title}",
            "include_attachments" => "true"
          }
        }
        trigger.disable_notification = true
        trigger.localization = "system"
        trigger.timezone = "system"
        trigger.note = ""
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end.save!

      Trigger.find_or_initialize_by(name: 'OPS - zmena zodpovednosti naspäť na tento subjekt - notifikácia').tap do |trigger|
        trigger.condition = {
          "operator" => "AND",
          "conditions" => [
            { "name" => "ticket.origin", "operator" => "is", "value" => [ "ops" ] },
            { "name" => "ticket.ops_issue_type", "operator" => "is", "value" => [ "issue", "question" ] },
            { "name" => "ticket.ops_responsible_subject", "operator" => "has changed", "value" => [ ] },
            {
              "name" => "ticket.ops_responsible_subject",
              "operator" => "is",
              "value" => [
                {
                  "label" => ENV.fetch('OPS_RESPONSIBLE_SUBJECT'),
                  "value" => ENV.fetch('OPS_RESPONSIBLE_SUBJECT_ID')
                }
              ]
            },
            { "name" => "ticket.updated_by_id", "operator" => "is", "value" => [ tech_user.id ] },
          ]
        }
        trigger.perform = {
          "article.note" => {
            "body" => "Podnet bol opäť priradený #{ENV.fetch('OPS_RESPONSIBLE_SUBJECT')}.",
            "internal" => "false",
            "subject" => "Podnet bol opäť priradený",
            "sender" => "Customer"
          },
          "ticket.state_id" => { "value" => Ticket::State.find_by(name: "new").id.to_s },
        }
        trigger.note = "NEMENIŤ - spúšťač používa špeciálne parametre, ktoré budú zmazané pri úprave spúšťača."
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end.save!

      Trigger.find_or_initialize_by(name: 'OPS - zmena zodpovednosti na iný subjekt - notifikácia').tap do |trigger|
        trigger.condition = {
          "operator" => "AND",
          "conditions" => [
            { "name" => "ticket.origin", "operator" => "is", "value" => [ "ops" ] },
            { "name" => "ticket.ops_issue_type", "operator" => "is", "value" => [ "issue", "question" ] },
            { "name" => "ticket.ops_responsible_subject", "operator" => "has changed", "value" => [ ] },
            {
              "name" => "ticket.ops_responsible_subject",
              "operator" => "is not",
              "value" => [
                {
                  "label" => ENV.fetch('OPS_RESPONSIBLE_SUBJECT'),
                  "value" => ENV.fetch('OPS_RESPONSIBLE_SUBJECT_ID')
                }
              ]
            },
          ]
        }
        trigger.perform = {
          "article.note" => {
            "body" => "Podnet bol priradený inému subjektu.",
            "internal" => "true",
            "subject" => "Podnet bol priradený inému subjektu",
          },
          "ticket.state_id" => { "value" => Ticket::State.find_by(name: "pending close").id.to_s },
          "ticket.pending_time" => { "operator" => "relative", "value" => "5", "range" => "day" },
        }
        trigger.note = "NEMENIŤ - spúšťač používa špeciálne parametre, ktoré budú zmazané pri úprave spúšťača."
        trigger.activator = "action"
        trigger.execution_condition_mode = "selective"
        trigger.active = true
        trigger.updated_by_id = 1
        trigger.created_by_id = 1
      end.save!

      # deactivate predefined triggers
      Trigger.find_by(name: 'auto reply (on new tickets)')&.update!(active: false)

      # add sample tickets
      if ENV['CREATE_SAMPLE_TICKET'] == "true" && Ticket.count < 2
        Rails.logger.info "Creating sample tickets..."

        if ENV['ADMIN_EMAIL']
          user = User.find_by(email: ENV.fetch('ADMIN_EMAIL'))
          user.groups << Group.find_by(name: 'Incoming')
          user.roles << Role.find_by(name: 'Správca podnetov pre OPS')
          user.save!
        end

        UserInfo.current_user_id = User.last.id

        customer = User.create!(
          email: "example.portal.customer@localhost",
          firstname: "Portal Customer",
          lastname: "Example",
          role_ids: [Role.find_by(name: 'OPS User').id]
        )

        agent = User.create!(
          email: "example.agent@localhost",
          firstname: "Agent",
          lastname: "Example",
          role_ids: [Role.find_by(name: 'Agent').id, Role.find_by(name: 'Správca podnetov pre OPS').id],
          group_ids: [incoming_group.id, import_group.id],
        )

        ticket = Ticket.create!(
          group_id: incoming_group.id,
          owner_id: agent.id,
          state_id: 1,
          ops_state: "in_progress",
          title: "OPS: Poškodená dlažba chodníka",
          customer_id: customer.id,
          origin: "ops",
          ops_responsible_subject: {"label"=>"MÚ Staré Mesto", "value"=>1},
          ops_category: "Komunikácie",
          ops_subcategory: "chodník",
          ops_subtype: "poškodená dlažba",
          ops_issue_type: "issue",
          ops_likes_count: 13,
          address_municipality: "Bratislava",
          address_municipality_district: "okres Bratislava I",
          address_street: "Vysoká",
          address_house_number: "7490/2A",
          address_lat: 48.14816,
          address_lon: 17.10674,
          address_postcode: "81106",
          ops_portal_url: "https://ops.dev.slovensko.digital/issues/1",
        )

        ticket.articles.create!(
          type_id: Ticket::Article::Type.find_by(name: "web").id,
          sender_id: Ticket::Article::Sender.find_by(name: "Customer").id,
          content_type: "text/plain",
          body: "Chodník je poškodený, dlažba je rozbitá a nerovná.",
          internal: false,
          origin_by_id: customer.id,
        )

        ticket.articles.create!(
          type_id: Ticket::Article::Type.find_by(name: "note").id,
          sender_id: Ticket::Article::Sender.find_by(name: "Agent").id,
          content_type: "text/plain",
          body: "Odpoveď agenta",
          internal: false,
          origin_by_id: agent.id,
          created_by_id: agent.id,
          updated_by_id: agent.id,
        )

        ticket.articles.create!(
          type_id: Ticket::Article::Type.find_by(name: "note").id,
          sender_id: Ticket::Article::Sender.find_by(name: "Agent").id,
          content_type: "text/plain",
          body: "Interná odpoveď agenta",
          internal: true,
          origin_by_id: agent.id,
          created_by_id: agent.id,
          updated_by_id: agent.id,
        )

        ticket = Ticket.create!(
          group_id: incoming_group.id,
          owner_id: agent.id,
          state_id: 1,
          title: "Custom podnet: Nepokosená tráva",
          customer_id: customer.id,
          origin: nil,
          address_municipality: "Bratislava",
          address_municipality_district: "okres Bratislava I",
          address_street: "Vysoká",
          address_house_number: "7490/2A",
          address_postcode: "81106",
        )

        ticket.articles.create!(
          type_id: Ticket::Article::Type.find_by(name: "web").id,
          sender_id: Ticket::Article::Sender.find_by(name: "Customer").id,
          content_type: "text/plain",
          body: "Tráva na verejnom priestranstve nie je pokosená.",
          internal: false,
          origin_by_id: customer.id,
        )

        ticket.articles.create!(
          type_id: Ticket::Article::Type.find_by(name: "note").id,
          sender_id: Ticket::Article::Sender.find_by(name: "Agent").id,
          content_type: "text/plain",
          body: "Odpoveď agenta",
          internal: false,
          origin_by_id: agent.id,
          created_by_id: agent.id,
          updated_by_id: agent.id,
        )

        ticket.articles.create!(
          type_id: Ticket::Article::Type.find_by(name: "note").id,
          sender_id: Ticket::Article::Sender.find_by(name: "Agent").id,
          content_type: "text/plain",
          body: "Interná odpoveď agenta",
          internal: true,
          origin_by_id: agent.id,
          created_by_id: agent.id,
          updated_by_id: agent.id,
        )

        UserInfo.current_user_id = 1
      end
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['ops:backoffice:migrate'].execute
end

Rake::Task['db:seed'].enhance do
  Rake::Task['ops:backoffice:migrate'].execute
end
