require 'feature_helper'
require 'api_test_helper'
require 'uri'

RSpec.describe 'When the user visits the select phone page' do
  let(:selected_answers) {
    {
      device_type: { device_type_other: true },
      documents: { passport: true, driving_licence: true }
    }
  }
  let(:given_a_session_with_document_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }

  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions' => 'clever_questions_variant')
    stub_transactions_list
    stub_api_idp_list_for_loa
  end

  context 'with javascript disabled' do
    it 'redirects to the confirming it is you page when user has a phone' do
      stub_api_no_docs_idps
      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(confirming_it_is_you_path, only_path: true)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'phone' => { 'mobile_phone' => true }
      )
    end

    it 'allows you to overwrite the values of your selected evidence' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_a_session_with_document_evidence

      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      click_button 'Continue'

      visit '/select-phone'
      choose 'select_phone_form_mobile_phone_false', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(confirming_it_is_you_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'phone' => { 'mobile_phone' => false },
        'documents' => { 'passport' => true, 'driving_licence' => true }
      )
    end

    it 'allows you to append to an existing phone evidence ' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      page.set_rack_session(selected_answers: {
        device_type: { device_type_other: true },
        documents: { passport: true, driving_licence: true }, phone: { smart_phone: true }
      })

      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(confirming_it_is_you_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'phone' => { 'smart_phone' => true, 'mobile_phone' => true },
        'documents' => { 'passport' => true, 'driving_licence' => true }
      )
    end

    it 'shows an error message when no selections are made' do
      visit '/select-phone'
      click_button 'Continue'

      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group-error'
    end
  end

  context 'with javascript enabled', js: true do
    it 'redirects to the confirming it is yoy page when user has a phone' do
      given_a_session_with_document_evidence

      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(confirming_it_is_you_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'phone' => { 'mobile_phone' => true },
        'documents' => { 'passport' => true, 'driving_licence' => true }
      )
    end

    it 'should display a validation message when user does not answer mobile phone question' do
      visit '/select-phone'

      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end
  end

  it 'includes the appropriate feedback source' do
    visit '/select-phone'

    expect_feedback_source_to_be(page, 'SELECT_PHONE_PAGE', '/select-phone')
  end

  it 'displays the page in Welsh' do
    visit 'dewis-ffon'
    expect(page).to have_content 'Oes'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'reports to Piwik when form is valid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Phone Next' }

    page.set_rack_session(transaction_simple_id: 'test-rp')
    visit '/select-phone'

    choose 'select_phone_form_mobile_phone_true', allow_label_click: true
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'does not report to Piwik when form is invalid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Phone Next' }
    visit '/select-phone'

    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to_not have_been_made
  end
end