#= require ./form

class bud.widgets.LoginForm extends bud.widgets.Form
  @SELECTOR: '.LoginForm'

  params: ->
    email    = @$container.find('[name=email]').val()
    password = @$container.find('[name=password]').val()

    {email: email, password: password}
