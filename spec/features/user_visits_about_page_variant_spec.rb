require 'feature_helper'
require 'cookie_names'
require 'piwik_test_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the about page' do
  context 'session cookie also contains variant b' do
    before(:each) do
      stub_api_idp_list_for_loa
      page.set_rack_session(transaction_simple_id: 'test-rp')
      experiment = { "short_hub_2019_q3-preview" => "short_hub_2019_q3-preview_variant_b_2_idp" }
      set_session_and_ab_session_cookies!(experiment)
    end

    it "will display the page and report the user's selection to piwik" do
      visit '/about'

      expect(page).to have_content 'GOV.UK Verify is a secure way to prove who you are online. It aims to protect people from the growing problem of online identity theft.'
      expect_feedback_source_to_be(page, 'ABOUT_PAGE', '/about')

      expect(page).to have_link('Next', href: '/about-certified-companies')
    end

    it 'will display the about page in Welsh' do
      visit '/am'
      expect(page).to have_content 'Mae GOV.UK Verify yn wasanaeth diogel a adeiladwyd i frwydro'
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  context 'session cookie also contains variant c' do
    before(:each) do
      stub_api_idp_list_for_loa
      page.set_rack_session(transaction_simple_id: 'test-rp')
      experiment = { "short_hub_2019_q3-preview" => "short_hub_2019_q3-preview_variant_c_2_idp_short_hub" }
      set_session_and_ab_session_cookies!(experiment)
    end

    it "will display the combined about page" do
      visit '/about'

      expect(page).to have_content 'GOV.UK Verify is a secure way to prove who you are online. It helps protect you against online identity theft.'
      expect(page).to have_content 'You create an identity account with a company that meets government privacy and security standards.'
      expect(page).to have_content 'The company will ask you questions and check your identity documents.'
      expect(page).to have_content 'It will never share your information for any other purpose without your consent.'

      expect_feedback_source_to_be(page, 'ABOUT_PAGE', '/about')

      expect(page).to have_link('Continue', href: '/will-it-work-for-me')
    end

    it 'will display the Welsh about page but it will actually be in English' do
      visit '/am'

      expect(page).to have_content 'GOV.UK Verify is a secure way to prove who you are online. It helps protect you against online identity theft.'
      expect(page).to have_content 'You create an identity account with a company that meets government privacy and security standards.'
      expect(page).to have_content 'The company will ask you questions and check your identity documents.'
      expect(page).to have_content 'It will never share your information for any other purpose without your consent.'

      expect(page).to have_css 'html[lang=cy]'
    end
  end
end