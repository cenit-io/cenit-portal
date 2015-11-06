class ApiDirectoryController < ApplicationController
  before_action :set_item, only: :show
  respond_to :html

  def index
    @items = Item.all
    @name = params[:name]
    @items = @items.with_name(@name) if @name.present?
    respond_with(@items)
  end

  def show
    respond_with(@item)
  end

  private
    def set_item
      @item = Item.where(slug: params[:id]).first
    end

    def item_params
      params.permit(:name, :slug, :description)
    end
end
