window.bud.replace_html = (container, replacement) ->
  $(container).html(replacement)
  bud.Core.init_widgets(container)

window.bud.append_html = (container, replacement) ->
  $(container).append(replacement)
  bud.Core.init_widgets(container)

window.bud.prepend_html = (container, replacement) ->
  $(container).prepend(replacement)
  bud.Core.init_widgets(container)
