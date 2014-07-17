class bud.widgets.UnreadMessage extends bud.Widget
  @SELECTOR: '.UnreadMessage'

  initialize: ->
    unless @$container.hasClass('read')
      @target = @get_target()
      @count = parseInt(@target.html()) - 1
      @target.html(@count)
      @$container.addClass('read')
