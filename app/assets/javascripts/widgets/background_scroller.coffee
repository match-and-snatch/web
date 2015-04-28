class bud.widgets.BackgroundScroller extends bud.Widget
  @SELECTOR: '.BackgroundScroller'

  initialize: ->
    @url = @$container.data('url')
    @base_height = @$container.data('base_height')
    @$target = bud.get(@$container.data('target'))
    @$focus_target = bud.get(@$container.data('focus_target')) || @$target

    @$target.css('background-repeat', 'repeat-y')

    position = @$container.data('position')

    if @is_reduced()
      position = 0.47 * position / (@base_height / @$target.height()) # 204 / (208  / 84) = 82.38
    # 4,5144230769
    # new height: 63,795527157

    @$target.css('background-position', "center #{position}px")

    if @url
      @$container.click @enable_editing

  enable_editing: =>
    window.scrollTo(0, 0);
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

    @y_position = parseInt(@$target.css('background-position').replace(/^.* /, '')) + delta_y * 2
    @y_position = 0 if @y_position > 0
    @$target.css('background-position', "50% #{@y_position}px")

  disable_editing: =>
    return unless @current_y

    @$focus_target.css('z-index', '')
    @$focus_target.removeClass('editing')

    $('body').css('cursor', 'auto')
    $('body').unbind 'click', @disable_editing

    bud.pub('popup.hide.overlay')

    $(document).unbind 'mousemove', @on_mouse_move
    bud.Ajax.post(@url, {_method: 'PUT', cover_picture_position: @y_position} )

    false

  is_reduced: -> @base_height > @$target.height()
