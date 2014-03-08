#= require ./form

class bud.widgets.Poster extends bud.widgets.Form
  @SELECTOR: '.Poster'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))

  on_success: (response) =>
    bud.prepend_html(@$target, response['html'])
    @$container[0].reset()
