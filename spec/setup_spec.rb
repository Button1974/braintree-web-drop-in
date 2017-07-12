require_relative "helpers/drop_in_helper"

describe "setup" do
  include DropIn

  it "requires a selector or container" do
    visit "http://#{HOSTNAME}:#{PORT}?container=null&selector=null"

    expect(find("#error")).to have_content("options.container is required.")
  end

  it "requires authorization" do
    visit "http://#{HOSTNAME}:#{PORT}?authorization=null"

    expect(find("#error")).to have_content("options.authorization is required.")
  end

  it "does not setup paypal when not configured" do
    visit "http://#{HOSTNAME}:#{PORT}?paypal=null&paypalCredit=null"

    expect(page).not_to have_selector(".braintree-option__paypal")
    expect(page).to have_content("Card Number")
    expect(page).to have_content("Expiration Date")
  end

  it "supports locale" do
    visit "http://#{HOSTNAME}:#{PORT}?locale=es_ES"

    expect(page).to have_content("Tarjeta")
  end

  it "supports custom locale object" do
    translations = '{"chooseAWayToPay":"My Choose a Way to Pay String"}'
    visit URI.encode("http://#{HOSTNAME}:#{PORT}?translations=#{translations}&locale=es_ES")

    expect(page).to have_content("My Choose a Way to Pay String")
    expect(page).to have_content("Tarjeta")
  end
end

