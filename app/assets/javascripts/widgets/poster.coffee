#= require ./form

# Form used for posting user posts on profile page
class bud.widgets.Poster extends bud.widgets.Form
  @SELECTOR: '.Poster'

  on_prepend: (response) =>
    super(response)
    @after_render()

  on_replace: (response) =>
    super(response)
    @after_render()

  after_render: ->
    @$container[0].reset()
    bud.pub('post')

