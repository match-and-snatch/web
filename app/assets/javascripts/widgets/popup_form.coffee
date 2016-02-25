#= require ./form

class bud.widgets.PopupForm extends bud.widgets.Form
  @SELECTOR: '.PopupForm'

  on_success: =>
    super
    bud.pub("popup.show")

  on_replace: (response) =>
    bud.replace_container(@get_target(), response)
    bud.pub("popup.show")
