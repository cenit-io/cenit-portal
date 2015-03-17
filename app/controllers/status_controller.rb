class StatusController < ApplicationController
  def show
      @body_id = 'status'
      @user = User.find(params[:id])
  end
end
