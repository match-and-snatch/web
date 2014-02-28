class bud.widgets.RegistrationForm extends bud.widgets.Form
  @SELECTOR: '.RegistrationForm'

  params: ->
    first_name            = @$container.find('[name=first_name]').val()
    last_name             = @$container.find('[name=last_name]').val()
    email                 = @$container.find('[name=email]').val()
    password              = @$container.find('[name=password]').val()
    password_confirmation = @$container.find('[name=password_confirmation]').val()

    {
    email: email,
    password: password,
    password_confirmation: password_confirmation,
    first_name: first_name,
    last_name: last_name
    }
