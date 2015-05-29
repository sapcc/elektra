class Forms::Project
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :name

  validates :name, presence: true



  def initialize(domain_id, identity_service, params = {})
    @identity_service = identity_service
    @domain_id = domain_id
    @user_id = params[:user_id]
    @options  = params[:forms_project] || {}

    puts "+++++++++++++++++++++++++++++++ Params: #{params.inspect}"
    puts "---====---===-=-=-=-==-- ID YO: #{params[:id]}"

    if params[:id]
      @keystone_project = @identity_service.user_project(params[:id])
    else
      @name = @options[:name]
    end

  end

  def update_attributes(params = {})
  end

  def destroy
    @keystone_project.destroy
    true
  end


  def persisted?
    false
  end

  def save
    if valid?
      persist!
    else
      false
    end
  end


  private

  def persist!
    project = @identity_service.create_project(name: @name, domain_id: @domain_id)
    project.grant_role_to_user(@identity_service.roles(name: "admin").first.id, @user_id) # give admin role to user, expects role with name "admin" to exist, will fail miserably if it doesn't
    puts "+++++++++++++++++++++++++++++++++++++++ project created, name: #{@name}, domain id: #{@domain_id} ----return value: #{project.inspect}"
  rescue => e
    # e.body.errors.each do |attribute, messages|
    #   messages.each do |message|
    #     errors.add(attribute, message)
    #   end
    # end
    puts "++++++++++++++++++++++++++++ ERROR: #{e.message}"
    puts e.backtrace.join("\n")
    false
  end

end
