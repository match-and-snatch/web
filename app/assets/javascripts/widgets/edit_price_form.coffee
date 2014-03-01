#= require ./form

class bud.widgets.EditPriceForm extends bud.widgets.Form
  @SELECTOR: '.EditPriceForm'

  params: ->
    slug = @$container.find('[name=slug]').val()
    subscription_cost = @$container.find('[name=subscription_cost]').val()

    {
    _method: 'put',
    slug: slug,
    subscription_cost: subscription_cost
    }
