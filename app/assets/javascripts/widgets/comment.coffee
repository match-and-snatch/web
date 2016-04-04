class bud.widgets.Comment extends bud.Widget
  @SELECTOR: '.Comment'

  initialize: ->
    @$comment_row = @$container.parent()
    @$visibility_toggler = @$container.find('li.visibility_toggler')
    @$edit_container = @$container.children('.edit_container')

  toggle: (visible) ->
    @$container.children('.edit_container:visible').toggle()

    bud.Core.destroy_widgets(@$edit_container)

    if visible
      @$comment_row.css('opacity',  1)
      @$visibility_toggler.text('Hide')
      @$visibility_toggler.parent('a').attr 'href', (i, href) -> href.replace /make_visible/, 'hide'
    else
      @$comment_row.css('opacity',  0.5)
      @$visibility_toggler.text('Show')
      @$visibility_toggler.parent('a').attr 'href', (i, href) -> href.replace /hide/, 'make_visible'

    bud.Core.init_widgets(@$edit_container)
