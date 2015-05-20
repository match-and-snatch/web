class bud.widgets.UnreadMessage extends bud.Widget
  @SELECTOR: '.UnreadMessage'

  initialize: ->
    unless @$container.hasClass('read')
      @target = @get_target()
      @count = Math.max(parseInt(@target.html()) - 1, 0)
      @target.html(@count)
      @$container.addClass('read')
