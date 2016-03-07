class HomeController < ApplicationController

  include ApplicationHelper

  def index
  end

  def odoo_redirect
    url = cenitodoo_url()
    redirect_to url
  end
end
