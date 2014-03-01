#= require ./form

class bud.widgets.GeneralInformationForm extends bud.widgets.Form
  @SELECTOR: '.GeneralInformationForm'

  params: ->
    full_name = @$container.find('[name=full_name]').val()
    slug = @$container.find('[name=slug]').val()
    email = @$container.find('[name=email]').val()

    {
    _method: 'put'
    full_name: full_name
    slug: slug
    email: email
    }

