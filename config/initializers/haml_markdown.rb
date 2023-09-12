# TODO: needs to be investigated -> Filters is not a module
#/app/config/initializers/haml_markdown.rb:1:in `<top (required)>': Filters is not a module (TypeError)
#/app/vendor/bundle/ruby/2.7.0/gems/haml-6.1.2/lib/haml/filters/base.rb:5: previous definition of Filters was here

# module Haml::Filters
#   remove_filter("Markdown") #remove the existing Markdown filter

#   module Markdown # the contents of this are as before, but without the lazy_require call
#     include Haml::Filters::Base

#     def render(text)
#       markdown.render(text)
#     end

#     private

#     def markdown
#       render_options = {
#         filter_html: false,
#         hard_wrap: true,
#         no_styles: true,
#         prettify: true,
#         safe_links_only: true,
#         with_toc_data: true,
#       }

#       extensions = {
#         autolink: true,
#         fenced_code_blocks: true,
#         disable_indented_code_blocks: true,
#         footnotes: false,
#         highlight: true,
#         no_images: true,
#         no_intra_emphasis: true,
#         quote: true,
#         space_after_headers: false,
#         strikethrough: true,
#         superscript: true,
#         tables: true,
#         underline: true,
#       }

#       renderer = Redcarpet::Render::HTML.new(render_options)
#       @markdown ||= Redcarpet::Markdown.new(renderer, extensions)
#     end
#   end
# end
