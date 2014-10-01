#= require ./toggler

class bud.widgets.ReplyHider extends bud.widgets.Toggler
  @SELECTOR: '.ReplyHider'

  initialize: ->
    super
    bud.sub('commenter.commented', @hide)

  destroy: ->
    bud.unsub('commenter.commented', @hide)

  hide: =>
    @$target.hide()
    $('.Replier').show()