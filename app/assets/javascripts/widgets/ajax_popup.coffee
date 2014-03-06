#= require ./popup

class bud.widgets.AjaxPopup extends bud.widgets.Popup
  @SELECTOR: '.AjaxPopup'

  initialize: ->
    super
    @url = @$container.data('url')

  show: =>
    super
    bud.Ajax.get(@url, {}, {success: @on_response_received})

  on_response_received: (response) =>
    bud.replace_html(@$container, response['html'])
    @autoplace()
