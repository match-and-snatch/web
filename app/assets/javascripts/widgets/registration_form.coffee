class bud.widgets.RegistrationForm extends bud.widgets.Form
  @SELECTOR: '.RegistrationForm'

  params: ->
    login    = @$container.find('[name=login]').val()
    email    = @$container.find('[name=email]').val()
    password = @$container.find('[name=password]').val()

    {email: email, password: password, login: login}
