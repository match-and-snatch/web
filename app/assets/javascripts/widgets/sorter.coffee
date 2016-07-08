class bud.widgets.Sorter extends bud.Widget
  @SELECTOR: '.Sorter'

  initialize: ->
    @url = @$container.data('url')
    @$target = bud.get(@$container.data('target'))

    return if @lis().length <= 1

    _.each @lis(), (li) =>
      li = $(li)
      li.mousedown @start_drag
      li.mouseup @stop_drag

    @draw_cells()

  draw_cells: ->
    @cells().remove()
    @new_cell('latest_cell').appendTo(@$container)
    @cells().hide()

  new_cell: (id) ->
    $('<li class="Cell"></li>').attr("id", id)

  start_drag: (e) =>
    unless @dragging
      unless $(e.target).is('a')
        @$sortable_item = $(e.currentTarget)
        @indentTop = e.pageY - @$sortable_item.offset().top
        @indentLeft = e.pageX - @$sortable_item.offset().left
        @$sortable_item.css('position', 'absolute')
        @dragging = true
        $(document).mousemove @on_mouse_move
        return false
    return true

  stop_drag: =>
    if @dragging
      @dragging = false
      @$sortable_item.css('position', 'static')
      $(document).unbind 'mousemove', @on_mouse_move
      @update_ordering()
      @draw_cells()
      @save_positions()

  ids: ->
    _.map @lis(), (li) -> $(li).data('oid')

  save_positions: ->
    @$container.addClass('pending')
    bud.Ajax.post(@url, {ids: @ids()}, success: @on_success, replace: @on_replace)

  on_success: =>
    @$container.removeClass('pending')

  on_replace: (response) =>
    @$container.removeClass('pending')
    bud.replace_container(@$target, response)

  update_ordering: ->
    @$nearest_cell.replaceWith(@$sortable_item)

  on_mouse_move: (e) =>
    if @dragging
      y = e.pageY - @indentTop
      x = e.pageX - @indentLeft
      @$sortable_item.offset(top: y, left: x)
      @highlight_nearest_cell(x, y)

  cells: ->
    @$container.children('.Cell')

  lis: ->
    @$container.children('li').not('.Cell')

  highlight_nearest_cell: (x, y) ->
    @cells().show()

    $nearest_li = null
    @$nearest_cell = null
    nearest_distance = 9999

    _.each @$container.children('li').not(@$sortable_item), (li) =>
      $cell = $(li)

      x1 = $cell.offset().left
      y1 = $cell.offset().top

      distance = Math.sqrt(Math.pow(x1 - x, 2) + Math.pow(y1 - y, 2))
      if distance < nearest_distance
        nearest_distance = distance
        $nearest_li = $cell

    @$nearest_cell = if $nearest_li.hasClass('Cell')
      $nearest_li
    else
      @new_cell().insertBefore($nearest_li)

    @$container.children('.Cell').not('#latest_cell').not(@$nearest_cell).remove()
    @cells().hide()
    @$nearest_cell.show().css('width', @$sortable_item.width()) if @$nearest_cell

    return @$nearest_cell
