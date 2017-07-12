require_relative "helpers/paypal_helper"
require_relative "helpers/drop_in_helper"

describe "requestPaymentMethod" do
  include PayPal
  include DropIn

  describe "with callback API" do
    it "a card" do
      visit "http://#{HOSTNAME}:#{PORT}"

      click_option("card")
      hosted_field_send_input("number", "4111111111111111")
      hosted_field_send_input("expirationDate", "1019")
      hosted_field_send_input("cvv", "123")

      submit_pay

      expect(find(".braintree-heading")).to have_content("Paying with")

      # Drop-in Details
      expect(page).to have_content("Ending in ••11")

      # Nonce Details
      expect(page).to have_content("CreditCard")
      expect(page).to have_content("ending in 11")
      expect(page).to have_content("Visa")
    end

    it "PayPal", :paypal do
      visit "http://#{HOSTNAME}:#{PORT}"

      click_option("paypal")

      open_popup_and_complete_login

      submit_pay

      expect(find(".braintree-heading")).to have_content("Paying with PayPal")

      expect(page).to have_content("PayPalAccount")
      expect(page).to have_content(ENV["PAYPAL_USERNAME"])
    end

    it "PayPal Credit", :paypal do
      visit "http://#{HOSTNAME}:#{PORT}"

      click_option("paypalCredit")

      open_popup_and_complete_login do
        expect(page).to have_content("PayPal Credit");
      end

      submit_pay

      expect(find(".braintree-heading")).to have_content("Paying with PayPal")

      expect(page).to have_content("PayPalAccount")
      expect(page).to have_content(ENV["PAYPAL_USERNAME"])
    end
  end

  describe "wth promise API" do
    it "a card" do
      visit "http://#{HOSTNAME}:#{PORT}/promise.html"

      click_option("card")
      hosted_field_send_input("number", "4111111111111111")
      hosted_field_send_input("expirationDate", "1019")
      hosted_field_send_input("cvv", "123")

      submit_pay

      expect(find(".braintree-heading")).to have_content("Paying with")

      # Drop-in Details
      expect(page).to have_content("Ending in ••11")

      # Nonce Details
      expect(page).to have_content("CreditCard")
      expect(page).to have_content("ending in 11")
      expect(page).to have_content("Visa")
    end

    it "PayPal", :paypal do
      visit "http://#{HOSTNAME}:#{PORT}/promise.html"

      click_option("paypal")

      open_popup_and_complete_login

      submit_pay

      expect(find(".braintree-heading")).to have_content("Paying with PayPal")

      expect(page).to have_content("PayPalAccount")
      expect(page).to have_content(ENV["PAYPAL_USERNAME"])
    end
  end
end
