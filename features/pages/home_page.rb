class HomePage
  include Capybara::DSL

  def sign_up(credentials = {})
    visit_home_page

    click_link 'Login'
    click_link 'Click here to register!'

    fill_in 'first_name',            with: credentials['first_name']
    fill_in 'last_name',             with: credentials['last_name']
    fill_in 'email',                 with: credentials['email']
    fill_in 'password',              with: credentials['password']
    fill_in 'password_confirmation', with: credentials['password_confirmation']

    click_button 'Continue to Profile'
  end

  def sign_in(credentials = {})
    visit_home_page

    click_link 'Login'

    fill_in 'email',    with: credentials['email']
    fill_in 'password', with: credentials['password']

    click_button 'Login'
  end

  def log_out
    visit '/logout'
  end

  def visit_home_page
    visit '/'
  end

  def has_sign_up_link?
    has_content? 'Sign Up'
  end

  def has_sign_in_link?
    has_content? 'Login'
  end

  def has_logout_link?
    has_content? 'Logout'
  end

  def has_message?(message)
    has_content? message
  end

  def remove_user
    User.delete_all
  end
end
