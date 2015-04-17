module ApplicationHelper
  
  def generate_url(url, params = {})
     uri = URI(url)
     uri.query = params.to_query
     uri.to_s
  end

  def open_workspace(user)
    odoo_app = Doorkeeper::Application.where(name: 'odoo').first
    access_token = Doorkeeper::AccessToken.create!(
        application_id: odoo_app.uid,
        resource_owner_id: user.id,
        scopes: 'userinfo',
        expires_in: 7200
    )
    params = {
        # db: user.email.split('@').first,
        # login: user.email,
        # client_id: odoo_app.uid,
        # response_type: "code",
        # redirect_uri: odoo_app.redirect_uri,
        # scope: 'public',
        access_token: access_token.token,
        token_type: 'bearer',
        expires_in: 7200,
        state: {
            login: user.email
        }.to_json
    }
    return generate_url("http://cenit-odoo.dev:8069/auth_oauth/doorkeeper_cb", params)
    # return generate_url("/oauth/authorize", params)
  end
   
end
