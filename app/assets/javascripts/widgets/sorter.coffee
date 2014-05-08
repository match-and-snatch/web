class bud.widgets.Sorter extends bud.Widget
  @SELECTOR: '.Sorter'

  initialize: ->
    @url = @$container.data('url')

    _.each @lis(), (li) =>
      li = $(li)
      li.mousedown @start_drag
      li.mouseup @stop_drag

  draw_cells: ->
    @cells().remove()

    new_cell = -> $('<li class="Cell"></li>')
    lis = @lis()
    _.each lis, (li) -> new_cell().insertAfter($(li))
    new_cell().prependTo(@$container)
    @$target.next('.Cell').remove()

    @cells().hide()

  start_drag: (e) =>
    unless @dragging
      unless $(e.target).is('a')
        @$target = $(e.currentTarget)
        @draw_cells()
        @dragging = true
        $(document).mousemove @on_mouse_move
        return false
    return true

  stop_drag: =>
    if @dragging
      @dragging = false
      $(document).unbind 'mousemove', @on_mouse_move
      @update_ordering()
      @draw_cells()
      @save_positions()

  ids: ->
    _.map @lis(), (li) -> $(li).data('oid')

  save_positions: ->
    @$container.addClass('pending')
    bud.Ajax.post(@url, {ids: @ids()}, success: @on_success)

  on_success: =>
    @$container.removeClass('pending')

  update_ordering: ->
    lis = @lis().sort (a, b) ->
      $(a).position().top >= $(b).position().top

    @$container.append(lis.css('position', 'static'))

  on_mouse_move: (e) =>
    if @dragging
      @$target.offset(top: e.pageY, left: e.pageX)
      @highlight_nearest_cell(e.pageX, e.pageY + @$target.height())

  cells: ->
    @$container.children('.Cell')

  lis: ->
    @$container.children('li').not('.Cell')

  highlight_nearest_cell: (x, y) ->
    cells = @cells()
    cells.show()

    nearest_cell = null
    nearest_distance = 9999

    _.each cells, (cell) =>
      cell = $(cell)
      distance = Math.abs(cell.offset().top - y)

      if distance < nearest_distance
        nearest_distance = distance
        nearest_cell = cell

    cells.hide()
    nearest_cell.show() if nearest_cell
    return nearest_cell
