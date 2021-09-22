# frozen_string_literal: true

# Create Accounts and manage associated roles
class AccountsController < ApplicationController
  include Dry::Monads[:result]

  # Add a new account to identity provider
  def new; end

  # Request identigy provider Add a new account
  def create
    # after_insert =
    #   lambda do |_user|
    #     flash[:success] = 'Account created'
    #     redirect_to root_path
    #   end
    new_account = Accounts::Create.new.call(params)
    if new_account.success?
      flash[:success] = 'Account created'
    else
      flash[:danger] = "Error creating Account: #{new_account.failure}"
    end
    redirect_to root_path
  end

  # Add a new role to existing account
  def add_role; end
end