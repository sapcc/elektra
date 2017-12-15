module Identity
  module Projects::MembersHelper

    def render_user_name(user_name, user_description)
      unless user_description.blank?
        rendered_name = "#{user_description} (#{user_name})"
      else
        rendered_name = user_name
      end
      rendered_name
    end
  end
end
