#= require widgets/form

class bud.widgets.DialogueForm extends bud.widgets.Form
  @SELECTOR: '.DialogueForm'

  initialize: ->
    super
    @scroll_to_bottom()

  scroll_to_bottom: ->
    @get_target().scrollTop(@get_target().prop("scrollHeight"))

  on_after: =>
    super
    @$container[0].reset()
    @scroll_to_bottom()

