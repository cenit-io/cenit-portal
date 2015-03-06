class StatusController < ApplicationController

    def index
        @body_id = 'status'
        @user = User.find(params[:id])
    end


end
