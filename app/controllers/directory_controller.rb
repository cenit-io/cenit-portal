class DirectoryController < ApplicationController
  before_action :set_item, only: :show
  respond_to :html

  def index
    @items = Item.all
    @name = params[:name]
    @tag = params[:tag]
    @items = @items.with_name(@name) if @name.present?
    if (tag_items = Tag.where(name: @tag).try(:first).try(:items)).present?
      @items = @items.where( :id.in => tag_items.map(&:id) ) if @tag.present?
    end
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
