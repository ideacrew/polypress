# frozen_string_literal: true

# Authenticate and manage an Account's session
class SessionController < ApplicationController
  include Dry::Monads[:result]
  def new; end

  def create
    tokens = Accounts::SignIn.new.call(params)
    return unless tokens.success?

    cookies.permanent[:keycloak_token] = tokens.success
    redirect_to root_path if Keycloak::Client.user_signed_in?
  end

  def destroy
    flash[:success] = 'Logged out' if Keycloak::Client.logout
    redirect_to root_path
  end

  def forgot_password; end

  def reset_password
    Accounts.ResetPassword(params, root_path)
    flash[:success] =
      'If this account exists instructions on resetting your password will be sent to your email address'
    redirect_to root_path
  end
end
