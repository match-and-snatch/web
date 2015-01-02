#= require ./popup

class bud.widgets.ConfirmationPopup extends bud.widgets.Popup
  @SELECTOR: '.ConfirmationPopup'

  initialize: ->
    super
    @callback = -> # nothing
    @$ok = @$container.find('.Ok')
    @$question = @$container.find('.Question')
    @$ok.click @on_ok
    bud.widgets.ConfirmationPopup.__instance = @

  @instance: -> @__instance
  @ask: (question, callback) -> @instance().ask(question, callback)

  ask: (question, callback) ->
    @callback = callback
    @$question.html(question)
    @show()

  on_ok: =>
    @callback()
    @hide()
