class bud.widgets.Graph extends bud.Widget
  @SELECTOR: '.Graph'

  initialize: ->
    @data = @$container.data('data')
    bud.Ajax.getScript('//cdnjs.cloudflare.com/ajax/libs/d3/3.4.5/d3.min.js').done(@on_d3_loaded)
    bud.Ajax.getScript('//cdnjs.cloudflare.com/ajax/libs/rickshaw/1.4.6/rickshaw.min.js').done(@on_rickshaw_loaded)

  on_d3_loaded: =>
    @d3_loaded = true

    if @rickshaw_loaded
      @init_graph()

  on_rickshaw_loaded: =>
    @rickshaw_loaded = true

    if @d3_loaded
      @init_graph()

  init_graph: ->
    @$container.empty()

    graph = new Rickshaw.Graph( {
      element: @$container[0],
      width: 600,
      height: 180,
      series: [{
        color: 'steelblue',
        data: @data
      }]
    })
    graph.render()
