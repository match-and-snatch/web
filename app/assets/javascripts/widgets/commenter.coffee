#= require ./form

# Appends HTML to a target container once form is posted
# @data target [String] Target identifier
class bud.widgets.Commenter extends bud.widgets.Form
  @SELECTOR: '.Commenter'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))
    @$container.find('textarea').focus()

  on_success: (response) =>
    super
    bud.append_html(@$target, response['html'])
    @$container[0].reset()
