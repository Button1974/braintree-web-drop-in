require_relative "helpers/paypal_helper"

describe "updateConfiguration" do
  include PayPal

  it "updates PayPal configuration", :paypal do
    visit "http://#{HOSTNAME}:#{PORT}?showUpdatePayPalMenu=true"

    find("#paypal-config-checkout").click()
    click_option("paypal")

    open_popup_and_complete_login do
      expect(page).to_not have_content("future payments");
    end

    find("#paypal-config-vault").click()
    click_option("paypal")

    complete_iframe_flow do
      expect(page).to have_content("future payments");
    end
  end

  it "updates PayPal Credit configuration", :paypal do
    visit "http://#{HOSTNAME}:#{PORT}?showUpdatePayPalMenu=true"

    find("#paypal-config-checkout").click()
    click_option("paypalCredit")

    open_popup_and_complete_login do
      expect(page).to_not have_content("future payments");
    end

    find("#paypal-config-vault").click()
    click_option("paypalCredit")

    complete_iframe_flow do
      expect(page).to have_content("future payments");
    end
  end

  it "removes authorized PayPal account when configuration is updated", :paypal do
    visit "http://#{HOSTNAME}:#{PORT}?showUpdatePayPalMenu=true"

    find("#paypal-config-checkout").click()
    click_option("paypal")

    open_popup_and_complete_login do
      expect(page).to_not have_content("future payments");
    end

    expect(page).to have_content(ENV["PAYPAL_USERNAME"])

    find("#paypal-config-vault").click()

    expect(page).to_not have_content(ENV["PAYPAL_USERNAME"])
  end
end
