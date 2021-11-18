# frozen_string_literal: true

module EmailService
  class ApplicationController < DashboardController
    include AwsSesHelper
    include EmailHelper
    include TemplateHelper

    def ui_switcher
      if current_user.has_role?('cloud_support_tools_viewer')
        redirect_to emails_path
      end
    end
 
    def restrict_access
      unless current_user.has_role?('cloud_support_tools_viewer')
        redirect_to index_path
      end
    end 

    def render_paginatable_for_configset(items, filter={})
      return if !@pagination_enabled || !items || items.length.zero?
      content_tag(:div, class: 'pagination') do
        if @pagination_current_page > 1 || @pagination_has_next
          concat(content_tag(:span, "#{@pagination_seen_items + 1} - #{@pagination_seen_items + items.length} ", class: 'current-window'))
          if @pagination_current_page > 1
            concat(' | ')
            if filter.key?(:search) and filter.key?(:searchfor)
              concat(link_to('Previous Page', page: @pagination_current_page - 1, marker: items.first.id, reverse: true, search: filter[:search], searchfor: filter[:searchfor]))
            else
              concat(link_to('Previous Page', page: @pagination_current_page - 1, marker: items.first.id, reverse: true))
            end
          end
          if @pagination_has_next
            concat(' | ')
            if filter.key?(:search) and filter.key?(:searchfor)
              concat(link_to('Next Page', page: @pagination_current_page + 1, marker: items.last.id, search: filter[:search], searchfor: filter[:searchfor]))
            else
              concat(link_to('Next Page', page: @pagination_current_page + 1, marker: items.last.id))
            end
          end
          concat(' | ')
          if filter.key?(:search) and filter.key?(:searchfor)
            concat(link_to('All', per_page: 9999, search: filter[:search], searchfor: filter[:searchfor]))
          else
            concat(link_to('All', per_page: 9999))
          end
        end
      end
    end

    
  end
end
