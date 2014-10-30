def home_page
  @home_page ||= HomePage.new
end

### GIVEN ###
Given /^I exist as a user:$/ do |credentials|
  home_page.generate_user(credentials.hashes.first)
end

Given /^I sign up with credentials:$/ do |credentials|
  home_page.sign_up(credentials.hashes.first)
end

Given /^I am not signed in$/ do
  home_page.log_out
end

### WHEN ###
When /^I return to the home page$/ do
  home_page.visit_home_page
end

When /^I sign in with email \"([^\"]*)\" and password \"([^\"]*)\"$/ do |email, password|
  home_page.sign_in(email: email, password: password)
end

### THEN ###
Then /^I should be signed in$/ do
  expect(home_page.has_logout_link?).to eq(true)
  expect(home_page.has_sign_in_link?).to eq(false)
end

Then /^I should see \"([^\"]*)\" message$/ do |message|
   expect(home_page.has_message?(message)).to eq(true)
end

Then /^I should be signed out$/ do
  expect(home_page.has_sign_in_link?).to eq(true)
  expect(home_page.has_logout_link?).to eq(false)
end
