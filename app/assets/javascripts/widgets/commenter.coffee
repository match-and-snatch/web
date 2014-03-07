#= require ./form

class bud.widgets.Commenter extends bud.widgets.Form
  @SELECTOR: '.Commenter'

  initialize: ->
    super
    @$target = $(@$container.data('target'))
    @$container.find('textarea').focus()

  on_success: (response) =>
    bud.append_html(@$target, response['html'])
    @$container[0].reset()
