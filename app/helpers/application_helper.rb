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

  def cenithub_url(*args)
    if (app = args.first).is_a?(Doorkeeper::Application)
      state = args[1]
    else
      state = app
      app = state.delete(:app) || Doorkeeper::Application.where(name: 'Cenit').first
    end
    url = url_for_doorkeeper_app(app, state)
    if user_signed_in?
      url
    else
      new_user_session_path(return_to: url)
    end
  end

  def url_for_doorkeeper_app(app, state=nil)
    params = {
      client_id: app.uid,
      redirect_uri: app.redirect_uri.split.first,
      response_type: 'code'
    }
    if state
      state =
        case state
        when Hash
          state.to_json
        when String
          state
        else
          state.to_s
        end
      params[:state] = state
    end
    generate_url("/oauth/authorize", params)
  end

end
