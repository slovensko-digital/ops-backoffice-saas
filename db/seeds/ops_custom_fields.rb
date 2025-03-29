ObjectManager::Attribute.add(
  object: 'Ticket',
  name: 'address_lat',
  display: 'Adresa (Zem. šírka)',
  data_type: 'input',
  data_option: {
    default: '',
    type: 'text',
    maxlength: 20,
    linktemplate: "https://www.openstreetmap.org/?mlat=\#{ticket.address_lat}&mlon=\#{ticket.address_lon}#map=18/\#{ticket.address_lat}/\#{ticket.address_lon}",
    null: true,
    options: {},
    relation: ''
  },
  active: true,
  screens: {
    create_middle: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    },
    edit: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    }
  },
  position: 59,
  created_by_id: 1,
  updated_by_id: 1
)

ObjectManager::Attribute.add(
  object: 'Ticket',
  name: 'address_lon',
  display: 'Adresa (Zem. dĺžka)',
  data_type: 'input',
  data_option: {
    default: '',
    type: 'text',
    maxlength: 20,
    linktemplate: "https://www.openstreetmap.org/?mlat=\#{ticket.address_lat}&mlon=\#{ticket.address_lon}#map=18/\#{ticket.address_lat}/\#{ticket.address_lon}",
    null: true,
    options: {},
    relation: ''
  },
  active: true,
  screens: {
    create_middle: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    },
    edit: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    }
  },
  position: 60,
  created_by_id: 1,
  updated_by_id: 1
)

ObjectManager::Attribute.add(
  object: 'Ticket',
  name: 'ops_responsible_subject',
  display: __('Zodpovedný subjekt v Odkaze pre starostu'),
  data_type: 'autocompletion_ajax_external_data_source',
  data_option: {
    search_url: File.join(ENV.fetch('OPS_PORTAL_URL'), "/api/v1/responsible_subjects/search?q=\#{search.term}"),
    verify_ssl: ENV['OPS_PORTAL_URL'].start_with?('https'),
    http_auth_type: "",
    search_result_list_key: "",
    search_result_value_key: "id",
    search_result_label_key: "name",
    options: {},
    default: '',
    null: true,
    nulloption: true,
  },
  active: true,
  screens: {
    create_middle: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    },
    edit: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    }
  },
  position: 22,
  created_by_id: 1,
  updated_by_id: 1
)

ObjectManager::Attribute.add(
  object: 'Ticket',
  name: 'address_postcode',
  display: 'Adresa (PSČ)',
  data_type: 'input',
  data_option: {
    default: '',
    type: 'text',
    maxlength: 8,
    linktemplate: "",
    null: true,
    options: {},
    relation: ''
  },
  active: true,
  screens: {
    edit: {
      'ticket.agent' => { shown: true }
    },
  },
  position: 58,
  created_by_id: 1,
  updated_by_id: 1
)

ObjectManager::Attribute.add(
  object: 'Ticket',
  name: 'ops_portal_url',
  display: 'Odkaz na portál',
  data_type: 'input',
  data_option: {
    default: '',
    type: 'url',
    maxlength: 2048,
    null: true,
    options: {},
    relation: ''
  },
  editable: true,
  active: true,
  screens: {
    edit: {
      'ticket.agent' => { shown: false },
      'ticket.customer' => { shown: false }
    },
    create_middle: {
      'ticket.customer' => { shown: false },
      'ticket.agent' => { shown: false }
    }
  },
  position: 101,
  created_by_id: 1,
  updated_by_id: 1
)
