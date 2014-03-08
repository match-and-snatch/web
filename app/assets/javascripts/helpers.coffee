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
  $parent = $container.parent()
  $container.replaceWith(replacement)
  bud.Core.init_widgets($parent)

window.bud.replace_html = (container, replacement) ->
  $(container).html(replacement)
  bud.Core.init_widgets(container)

window.bud.append_html = (container, replacement) ->
  $(container).append(replacement)
  bud.Core.init_widgets(container)

window.bud.prepend_html = (container, replacement) ->
  $(container).prepend(replacement)
  bud.Core.init_widgets(container)

window.bud.clear_html = (container) ->
  $(container).html('')

window.bud.get = (identifier) ->
  $("[data-identifier=#{identifier}]")