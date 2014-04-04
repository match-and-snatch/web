#= require ./popup

# Shows remote URL in the popup
# @data url [String]
class bud.widgets.AjaxPopup extends bud.widgets.Popup
  @SELECTOR: '.AjaxPopup'

  initialize: ->
    super
    @url = @$container.data('url')

  show: =>
    super
    bud.Ajax.get(@url, {}, {success: @on_response_received})

  on_response_received: (response) =>
    @$container.css('max-height', "#{$(window).height() - 30}px")
    @$container.css('max-width', "#{$(window).width() - 30}px")
    bud.replace_html(@$container, response['html'])
    @autoplace()
    @$container.find('img').load(@autoplace)
