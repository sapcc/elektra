class AuthenticatedUser::ImagesController < AuthenticatedUserController
  def index
  end

  def new
  end

  def create
    render text: 'create'
  end

  def edit
  end

  def update
    render text: 'update'
  end

  def destroy
    render text: 'destroy'
  end
end
