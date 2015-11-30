class DirectoryController < ApplicationController
  before_action :set_item, only: :show
  respond_to :html
  autocomplete :item, :name

  def index
    @items = Item.all
    @name = params[:name]
    @tag = params[:tag]
    @spec = params[:spec]
    
    if @spec.present?
      @items = @items.where(:raml_url.ne => nil) if @spec == 'raml'
      @items = @items.where(:swagger_json_url.ne => nil) if @spec == 'swagger'
    end
    
    @items = @items.with_name(@name) if @name.present?
    if (tag_items = Tag.where(name: @tag).try(:first).try(:items)).present?
      @items = @items.where( :id.in => tag_items.map(&:id) ) if @tag.present?
    end
  end

  def show
  end

  private
    def set_item
      @item = Item.where(slug: params[:id]).first
    end

    def item_params
      params.permit(:name, :slug, :description)
    end
    
    def autocomplete_items(parameters)
      model          = parameters[:model]
      method         = parameters[:method]
      options        = parameters[:options]
      scopes         = options[:scopes]
      is_full_search = options[:full]
      term           = parameters[:term]
      limit          = get_autocomplete_limit(options)
      order          = get_autocomplete_order(method, options)

      if is_full_search
        search = '.*' + Regexp.escape(term) + '.*'
      else
        search = '^' + Regexp.escape(term)
      end

      items = model.where(method.to_sym => /#{search}/i).limit(limit).order_by(order)

      case scopes
        when Symbol then
          items = items.send(scopes)
        when Array then
          scopes.each { |scope| items = items.send(scope) } unless scopes.empty?
      end
      items
    end
end
