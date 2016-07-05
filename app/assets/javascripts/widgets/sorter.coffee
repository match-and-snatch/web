class bud.widgets.Sorter extends bud.Widget
  @SELECTOR: '.Sorter'

  initialize: ->
    @url = @$container.data('url')
    @horizontal = @$container.data('horizontal')
    @$target = bud.get(@$container.data('target'))

    return if @lis().length <= 1

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
    @$sortable_item.next('.Cell').remove()

    @cells().hide()

  start_drag: (e) =>
    unless @dragging
      unless $(e.target).is('a')
        @$sortable_item = $(e.currentTarget)
        @indentTop = e.pageY - @$sortable_item.offset().top
        @indentLeft = e.pageX - @$sortable_item.offset().left
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
    bud.Ajax.post(@url, {ids: @ids()}, success: @on_success, replace: @on_replace)

  on_success: =>
    @$container.removeClass('pending')

  on_replace: (response) =>
    @$container.removeClass('pending')
    bud.replace_container(@$target, response)

  update_ordering: ->
    lis = @lis().sort (a, b) =>
      if @horizontal
        $(a).position().left - $(b).position().left
      else
        $(a).position().top - $(b).position().top

    @$container.append(lis.css('position', 'static'))

  on_mouse_move: (e) =>
    if @dragging
      @$sortable_item.offset(top: e.pageY- @indentTop, left: e.pageX - @indentLeft)
      if @horizontal
        @highlight_nearest_cell(e.pageX + @$sortable_item.width(), e.pageY)
      else
        @highlight_nearest_cell(e.pageX, e.pageY + @$sortable_item.height())

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
      distance = Math.abs if @horizontal
        cell.offset().left - x
      else
        cell.offset().top - y

      if distance < nearest_distance
        nearest_distance = distance
        nearest_cell = cell

    cells.hide()
    nearest_cell.show() if nearest_cell
    return nearest_cell
