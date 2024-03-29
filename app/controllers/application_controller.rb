# frozen_string_literal: true

# This is an application controller
class ApplicationController < ActionController::Base
  before_action :authenticate_account!

  def resource_not_available
    flash[:error] = "URL is invalid"
    render file: 'public/404.html', status: 404
  end

end
