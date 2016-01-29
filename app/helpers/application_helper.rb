module ApplicationHelper
  
  def generate_url(url, params = {})
     uri = URI(url)
     uri.query = params.to_query
     uri.to_s
  end

  def cenitodoo_url(user, odoo_app)
    params = {
      client_id: odoo_app.uid,
      redirect_uri: odoo_app.redirect_uri.split.first,
      response_type: 'token',
      state: {
        login: user.email
      }.to_json
    }
    generate_url('/oauth/authorize', params)
  end
  
  def cenithub_url(cenit_app)
    params = { 
      client_id: cenit_app.uid, 
      redirect_uri: cenit_app.redirect_uri.split.first, 
      response_type: 'code'
    }
    generate_url("/oauth/authorize", params)
  end
end
