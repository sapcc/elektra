module Core
  module Paginatable
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    def self.extended(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def paginatable(options={per_page:20},&block)
        return nil unless block_given?
        @pagination_enabled = true
        @pagination_per_page = options[:per_page]
        @pagination_has_next = false
        @pagination_current_page = (params[:page] || 1).to_i
        @pagination_seen_items = (@pagination_current_page - 1)*@pagination_per_page

        pagination_options = {
          limit: options[:per_page].to_i + 1,
          sort_dir: (params[:reverse] && @pagination_current_page>1)? 'desc' : 'asc'
        }
        pagination_options[:marker] = params[:marker] if (params[:marker] && @pagination_current_page>1)
        result = block.call(pagination_options)

        if result.is_a?(Array)
          if result.length>options[:per_page]
            @pagination_has_next = true
            result.pop
          end
          result.reverse! if (params[:reverse] && @pagination_current_page>1)
        end

        return result
      end
    end
  end
end
