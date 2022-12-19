SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = "active"
  navigation.active_leaf_class = "nav-active-leaf"
  navigation.items do |primary|
    primary.item :compute_admin,
                 "Host Aggregates",
                 -> { plugin("compute").host_aggregates_path },
                 if: -> { plugin_available?(:compute) },
                 highlights_on: %r{compute/host_aggregates/?.*}

    primary.item :compute_admin,
                 "Compute Services",
                 -> { plugin("compute").services_path },
                 if: -> { plugin_available?(:compute) },
                 highlights_on: %r{compute/services/?.*}

    primary.item :compute_admin,
                 "Hypervisor Stats",
                 -> { plugin("compute").hypervisors_path },
                 if: -> { plugin_available?(:compute) },
                 highlights_on: %r{compute/hypervisors/?.*}

    primary.dom_attributes = { class: "nav nav-tabs", role: "menu" }
  end
end
