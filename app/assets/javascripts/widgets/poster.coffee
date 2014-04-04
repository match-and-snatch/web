#= require ./form

# Form used for posting user posts on profile page
class bud.widgets.Poster extends bud.widgets.Form
  @SELECTOR: '.Poster'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))

  on_success: (response) =>
    bud.prepend_html(@$target, response['html'])
    @$container[0].reset()
    bud.pub('post')

  on_replace: (response) =>
    super
    @$container[0].reset()
