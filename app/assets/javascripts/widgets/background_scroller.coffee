class bud.widgets.BackgroundScroller extends bud.Widget
  @SELECTOR: '.BackgroundScroller'

  initialize: ->
    @url = @$container.data('url')
    @background_height = @$container.data('height')
    @$target = bud.get(@$container.data('target'))
    @$focus_target = bud.get(@$container.data('focus_target')) || @$target

    @$target.css('background-repeat', 'repeat-y')

    position = @$container.data('position')

    @$target.css('background-position', "center #{position}%")

    if @url
      @$container.click @enable_editing

  enable_editing: =>
    window.scrollTo(0, 0)
    bud.pub('popup.show.overlay')

    $('body').css('cursor', 'move')
    $('body').click @disable_editing

    @$focus_target.css('z-index', '12000')
    @$focus_target.addClass('editing')

    @current_y = null
    $(document).mousemove @on_mouse_move

  on_mouse_move: (e) =>
    @current_y ||= e.pageY
    delta_y      = e.pageY - @current_y
    @current_y   = e.pageY

    pos = parseInt(@$target.css('background-position').replace(/^.* /, ''))
    diff = (delta_y * 2.0) / @background_height * 100

    @cpos or= pos
    @cpos -= diff

    if @cpos > 100
      @cpos = 100
    else if @cpos < 0
      @cpos = 0

    @$target.css('background-position', "50% #{@cpos}%")

  disable_editing: =>
    return unless @current_y

    @$focus_target.css('z-index', '')
    @$focus_target.removeClass('editing')

    $('body').css('cursor', 'auto')
    $('body').unbind 'click', @disable_editing

    bud.pub('popup.hide.overlay')

    $(document).unbind 'mousemove', @on_mouse_move
    bud.Ajax.post(@url, {_method: 'PUT', cover_picture_position: @cpos} )

    false
