# Global events
# See more: https://github.com/cowboy/jquery-tiny-pubsub
(->
  o = $(window.bud)

  window.bud.sub   = -> o.on.apply      o, arguments
  window.bud.unsub = -> o.off.apply     o, arguments
  window.bud.pub   = -> o.trigger.apply o, arguments
)()

# HTML helpers
window.bud.replace_container = (container, replacement) ->
  $container = $(container)
  bud.Widget.destroy($container)
  bud.Core.destroy_widgets($container)
  $parent = $container.parent()
  $container.replaceWith(replacement)
  bud.Core.init_widgets($parent)

window.bud.replace_html = (container, replacement) ->
  bud.Core.destroy_widgets($(container))
  $(container).html(replacement)
  bud.Core.init_widgets(container)

window.bud.append_html = (container, replacement) ->
  $(container).append(replacement)
  bud.Core.init_widgets(container)

window.bud.prepend_html = (container, replacement) ->
  $(container).prepend(replacement)
  bud.Core.init_widgets(container)

window.bud.clear_html = (container) ->
  bud.Core.destroy_widgets($(container))
  $(container).empty()

window.bud.confirm = (string, callback) ->
  bud.widgets.ConfirmationPopup.ask(string, callback)

window.bud.get = (identifier) ->
  if _.isArray(identifier)
    elem = $((_.map(identifier, (id) -> "[data-identifier=#{id}]")).join(','))
  else
    elem = $("[data-identifier=#{identifier}]")

  if elem.length > 0
    return elem
  else
    return null

bud.is_mobile =
  Android: ->
    /Android/i.test navigator.userAgent
  BlackBerry: ->
    /BlackBerry/i.test navigator.userAgent
  iOS: ->
    /iPhone|iPad|iPod/i.test navigator.userAgent
  Windows: ->
    /IEMobile/i.test navigator.userAgent
  any: ->
    @Android() or @BlackBerry() or @iOS() or @Windows()

