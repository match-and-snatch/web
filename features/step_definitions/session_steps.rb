def home_page
  @home_page ||= HomePage.new
end

### GIVEN ###
Given /^I do not exist as a user$/ do
end

Given /^I exist as a user$/ do
  home_page.sign_up
end

Given /^I am not signed in$/ do
  home_page.log_out
end

### WHEN ###
When /^I return to the home page$/ do
  home_page.visit_home_page
end

When /^I sign in with a wrong \"([^\"]*)\" email$/ do |wrong_email|
  home_page.sign_in_with_wrong_email(wrong_email)
end

When /^I sign in with a wrong \"([^\"]*)\" password$/ do |wrong_password|
  home_page.sign_in_with_wrong_password(wrong_password)
end

When /^I sign in with valid credentials$/ do
  home_page.sign_in
end

### THEN ###
Then /^I should be signed in$/ do
  expect(home_page.has_logout_link?).to eq(true)
  expect(home_page.has_sign_in_link?).to eq(false)
end

Then /^I see \"([^\"]*)\" message$/ do |message|
   expect(home_page.has_message?(message)).to eq(true)
end

Then /^I should be signed out$/ do
  expect(home_page.has_sign_in_link?).to eq(true)
  expect(home_page.has_logout_link?).to eq(false)
end
