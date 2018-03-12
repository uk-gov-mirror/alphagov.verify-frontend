require 'partials/viewable_idp_partial_controller'

class AboutLoa2VariantController < ApplicationController
  include ViewableIdpPartialController

  layout 'slides', except: [:choosing_a_company]

  def index
    @tailored_text = current_transaction.tailored_text
    render 'about/about'
  end

  def choosing_a_company
    render 'about/choosing_a_company'
  end

  def identity_accounts
    render 'about/identity_accounts_LOA2_variant'
  end
end