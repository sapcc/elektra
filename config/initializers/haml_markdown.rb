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
