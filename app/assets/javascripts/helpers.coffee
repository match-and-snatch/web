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
  replace_container = (target, content) ->
    $container = $(target)
    bud.Widget.destroy($container)
    bud.Core.destroy_widgets($container)
    $parent = $container.parent()
    $container.replaceWith(content)
    bud.Core.init_widgets($parent)

  _fill_container(replace_container, container, replacement)

window.bud.delete_container = ($container) ->
  bud.Widget.destroy($container)
  bud.Core.destroy_widgets($container)
  $container.remove()

window.bud.replace_html = (container, replacement, callback) ->
  replace_html = (target, content) ->
    $container = $(target)
    bud.Core.destroy_widgets($container)
    $container.html(content)
    callback?()
    bud.Core.init_widgets($container)

  _fill_container(replace_html, container, replacement)

window.bud.append_html = (container, replacement) ->
  append_html = (target, content) ->
    $(target).append(content)
    bud.Core.init_widgets(target)

  _fill_container(append_html, container, replacement)

window.bud.prepend_html = (container, replacement) ->
  prepend_html = (target, content) ->
    $(target).prepend(content)
    bud.Core.init_widgets(target)

  _fill_container(prepend_html, container, replacement)

window.bud.clear_html = (container) ->
  clear_html = (target) ->
    $container = $(target)
    bud.Core.destroy_widgets($container)
    $container.empty()

  if _.isObject(container) && !(container instanceof jQuery)
    _.each container, (target, key, list) ->
      clear_html(target)
  else
    clear_html(container)

window.bud.confirm = (string, callback) ->
  bud.widgets.ConfirmationPopup.ask(string, callback)

window.bud.get = (identifier) ->
  return null unless identifier

  if _.isArray(identifier)
    elem = $((_.map(identifier, (id) -> "[data-identifier=#{id}]")).join(','))
  else if _.isObject(identifier)
    elem = {}
    _.each identifier, (id, key, list) ->
      elem[key] = $("[data-identifier=#{id}]")
  else
    elem = $("[data-identifier=#{identifier}]")

  if _.isEmpty(elem) || elem?.length == 0
    return null
  else
    return elem

window.bud.is_mobile =
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

window.bud.goto = (url) ->
  window.history.pushState(null, null, url)
  window.bud.pub('window.locationchange', url)

window.bud.replace_url = (url) ->
  window.history.replaceState(null, null, url)
  window.bud.pub('window.locationchange', url)

_fill_container = (callback, container, replacement) ->
  if _.isObject(container) && !(container instanceof jQuery)
    _.each container, (target, key, list) ->
      callback(target, _get_content(replacement, key))
  else
    callback(container, _get_content(replacement))

_get_content = (replacement, key = 'html') ->
  if _.isObject(replacement) && !(replacement instanceof jQuery)
    replacement[key]
  else
    replacement
