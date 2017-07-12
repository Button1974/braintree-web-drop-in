require_relative "helpers/drop_in_helper"

describe "payment option priority" do
  include DropIn

  it "uses default priority of card, paypal, paypalCredit" do
    visit "http://#{HOSTNAME}:#{PORT}"

    find(".braintree-heading")
    payment_options = all(:css, ".braintree-option__label")

    expect(payment_options[0]).to have_content("Card")
    expect(payment_options[1]).to have_content("PayPal")
    expect(payment_options[2]).to have_content("PayPal Credit")
  end

  it "uses custom priority of paypal, card, paypalCredit" do
    options = '["paypal","card","paypalCredit"]'
    visit URI.encode("http://#{HOSTNAME}:#{PORT}?paymentOptionPriority=#{options}")

    find(".braintree-heading")
    payment_options = all(:css, ".braintree-option__label")

    expect(payment_options[0]).to have_content("PayPal")
    expect(payment_options[1]).to have_content("Card")
    expect(payment_options[2]).to have_content("PayPal Credit")
  end

  it "shows an error when an unrecognized payment option is specified" do
    options = '["dummy","card"]'
    visit URI.encode("http://#{HOSTNAME}:#{PORT}?paymentOptionPriority=#{options}")

    expect(find("#error")).to have_content("paymentOptionPriority: Invalid payment option specified.")
  end
end
