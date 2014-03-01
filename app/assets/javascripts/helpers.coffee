# Global events
# See more: https://github.com/cowboy/jquery-tiny-pubsub
window.bud.sub   = -> $(window.bud).on.apply      $(window.bud), arguments
window.bud.unsub = -> $(window.bud).off.apply     $(window.bud), arguments
window.bud.pub   = -> $(window.bud).trigger.apply $(window.bud), arguments

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
