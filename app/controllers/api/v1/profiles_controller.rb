module Api::V1
  class ProfilesController < ApiController
    #doorkeeper_for :index
    #doorkeeper_for :create, :scopes => [:write]
    
    before_action :doorkeeper_authorize!, only: [:index, :create]

    respond_to :json

    def index
      respond_with Profile.all
    end

    def create
      respond_with 'api_v1', Profile.create!(params[:profile])
    end
  end
end
