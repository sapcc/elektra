module ScopeHelper
  # monkey path
  # remove ?domain_id=.. and ?project_id=.... from urls
  def url_for(options={})
    if options and options.is_a?(String)
      options = options.gsub(/(\?|&)domain_id=[^&]*/,'').gsub(/(\?|&)project_id=[^&]*/,'')
    end
    super(options)
  end
end
