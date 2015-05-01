# Toggles popup visibility
class bud.widgets.PopupTrigger extends bud.Widget
  @SELECTOR: '.PopupTrigger'

  initialize: ->
    @target = @$container.data('target') or @$container.parents('.Popup, .RemotePopup, .AjaxPopup, .ConfirmationPopup').data('identifier')
    #if bud.is_mobile.any()
    @$container.on 'touchstart', @on_click
    #else
    @$container.click @on_click

  on_click: (e) =>
    if bud.is_mobile.any()
      e.stopPropagation()
      e.preventDefault()
    bud.pub("popup.toggle.#{@target}")
    return !@$container.is('a')
