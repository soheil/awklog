class WelcomeController < ApplicationController
  protect_from_forgery except: :log
  layout 'loggedout'

  def log
    log = Log.create(
      raw: params[:log], 
      top: params[:top], 
      host_ip: params[:host_ip], 
      hostname: params[:hostname], 
      api_key: request.headers['apikey'],
    )
    log.delay.index
    head 200
  end

  def pricing_iframe
    render layout: nil
  end
end
