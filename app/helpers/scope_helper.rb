module ScopeHelper
  # monkey path
  # remove ?domain_id=.. and ?project_id=.... from urls
  def url_for(options={})
    if options and options.is_a?(String)
      options.gsub!(/&?domain_id=[^&]*/,'')
      options.gsub!(/&?project_id=[^&]*/,'')
      options.gsub!(/\?$/,'')
    end
    super(options)
  end
end
