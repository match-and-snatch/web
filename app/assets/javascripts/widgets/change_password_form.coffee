#= require ./form

class bud.widgets.ChangePasswordForm extends bud.widgets.Form
  @SELECTOR: '.ChangePasswordForm'

  params: ->
    current_password          = @$container.find('[name=current_password]').val()
    new_password              = @$container.find('[name=new_password]').val()
    new_password_confirmation = @$container.find('[name=new_password_confirmation]').val()

    {
    _method: 'put'
    current_password: current_password
    new_password: new_password
    new_password_confirmation: new_password_confirmation
    }
