require 'partials/viewable_idp_partial_controller'

class SelectPhoneVariantBController < ApplicationController
  include ViewableIdpPartialController

  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params['select_phone_form'] || {})
    if @form.valid?
      selected_answer_store.store_selected_answers('phone', @form.selected_answers)
      idps_available = recommendation_engine.any?(current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
      redirect_to idps_available ? choose_a_certified_company_path : verify_will_not_work_for_you_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def verify_will_not_work_for_you
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

private

  def recommendation_engine
    IDP_RECOMMENDATION_ENGINE_variant_b
  end
end