ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "SLI"
  inflect.acronym "SassC"
  inflect.acronym "UUID"
end

Rails.autoloaders.main.ignore(Rails.root.join('lib/generators/*'))