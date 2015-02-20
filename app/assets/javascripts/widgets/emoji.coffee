class bud.widgets.Emoji
  @SELECTOR = '.Emoji'

  @init: (parent_container) ->
    return unless parent_container
    parent_container.find(@SELECTOR).minEmojiSVG()
