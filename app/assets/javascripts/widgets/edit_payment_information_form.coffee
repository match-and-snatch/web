#= require ./form

class bud.widgets.EditPaymentInformationForm extends bud.widgets.Form
  @SELECTOR: '.EditPaymentInformationForm'

  params: ->
    holder_name = @$container.find('[name=holder_name]').val()
    routing_number = @$container.find('[name=routing_number]').val()
    account_number = @$container.find('[name=account_number]').val()

    {
    _method: 'put',
    holder_name: holder_name,
    routing_number: routing_number,
    account_number: account_number
    }
