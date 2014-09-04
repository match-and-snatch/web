def create_visitor
  @visitor ||= { first_name: 'sergei',
                 last_name: 'zinin',
                 email: 'serge@gmail.com',
                 password: 'password',
                 password_confirmation: 'password' }
end

def remove_user
  @user ||= User.where(email: @visitor[:email]).first
  @user.destroy unless @user.nil?
end

def sign_in
  visit '/'
  click_link 'Login'
  fill_in 'email', with: @visitor[:email]
  fill_in 'password', with: @visitor[:password]
  click_button 'Login'
end

### GIVEN ###
Given(/^I do not exist as a user$/) do
  create_visitor
  remove_user
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I am not logged in$/ do
  visit '/logout'
end

### WHEN ###
When /^I return to the site$/ do
  visit '/'
end

When(/^I sign in with a wrong email$/) do
  create_visitor
  @visitor = @visitor.merge(email: 'notanemail')
  sign_in
end

When(/^I sign in with a wrong password$/) do
  create_visitor
  @visitor = @visitor.merge(password: 'wrongpassword')
  sign_in
end

When(/^I sign in with valid credentials$/) do
  create_visitor
  sign_in
end

### THEN ###
Then /^I see a successful sign in message$/ do
  page.should have_content 'Welcome Sergei Zinin'
end

Then /^I should be signed in$/ do
  page.should have_content 'Logout'
  page.should_not have_content 'Sign up'
  page.should_not have_content 'Login'
end

Then /^I see an invalid login message$/ do
  page.should have_content 'Email or password is invalid.'
end

Then /^I should be signed out$/ do
  page.should have_content 'Sign Up'
  page.should have_content 'Login'
  page.should_not have_content 'Logout'
end