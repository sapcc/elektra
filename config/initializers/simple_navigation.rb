require "navigation_renderers/fancy_list"

SimpleNavigation.config_file_path = File.join(Rails.root, 'config', 'navigations')
SimpleNavigation.register_renderer fancy_list: SimpleNavigation::Renderer::FancyList
