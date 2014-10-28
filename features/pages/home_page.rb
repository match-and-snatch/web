class HomePage
  include Capybara::DSL

  def sign_up
    visit_home_page

    click_link 'Login'
    click_link 'Click here to register!'

    fill_in 'first_name', with: visitor_data[:first_name]
    fill_in 'last_name', with: visitor_data[:last_name]
    fill_in 'email', with: visitor_data[:email]
    fill_in 'password', with: visitor_data[:password]
    fill_in 'password_confirmation', with: visitor_data[:password_confirmation]

    click_button 'Continue to Profile'
  end

  def sign_in
    visit_home_page

    click_link 'Login'

    fill_in 'email', with: visitor_data[:email]
    fill_in 'password', with: visitor_data[:password]

    click_button 'Login'
  end

  def sign_in_with_wrong_email(wrong_email)
    visitor_data[:email] = wrong_email
    sign_in
  end

  def sign_in_with_wrong_password(wrong_password)
    visitor_data[:password] = wrong_password
    sign_in
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

  private

  def visitor_data
    @visitor_data ||= { first_name: 'sergei',
                        last_name: 'zinin',
                        email: 'serge@gmail.com',
                        password: 'password',
                        password_confirmation: 'password' }
  end
end
