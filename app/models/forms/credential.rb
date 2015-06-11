class Forms::Credential
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :user_id, :type, :blob, :project, :access, :secret, :name, :public_key

  validates :user_id, :type, :blob, presence: true



  def initialize(identity_service, user_id, params = {})
    @identity_service = identity_service
    @user_id          = user_id
    @options          = params[:forms_credential] || {}
    @project          = @options[:project]
    @blob             = @options[:blob].to_json


    if params[:id]
      @keystone_credential = @identity_service.credentials(params[:id])
    else
      @type = @options[:type]
    end

  end

  def update_attributes(params = {})
  end

  def destroy
    @keystone_credential.destroy
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
    options = { user_id: @user_id, type: @type, blob: @blob }
    options.merge!({project_id: @project}) if @project

    puts "||||||||||||||||||||||||||||||||||||||||||||||||||  Options for create: #{options.inspect}   |||||||||||| project id: #{@project}"

    credential = @identity_service.credentials.create(options)
    # credential = @identity_service.credentials.create(user_id: '7adde6c509104e2ba75f4212fea83a18', type: 'ec2', blob: {access: '123', secret: '123'}.to_json)

    true

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
