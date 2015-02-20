{$, Backbone, _} = require './mvc'

CLASS_MAPPING = {
  'st0' : 'big-box'
  'st1' : 'small-box'
}

STYLE_GROUPS = [
  'bright'
  'cool'
  'hot'
]

FRAME_REGEX = /frame([0-9]+)/


class Controller
  FRAME_DELAY_MSEC : 30

  constructor : ({@controls}) ->
    _.extend(@, Backbone.Events)
    @_playing 
    @controls.find('#play').click @_onPlay
    @controls.find('#stop').click @_onStop
    @controls.find('#cycle').click @_cycleStyles

  _onPlay : =>
    return if @_playing
    @_playing = true
    @_playLoop()

  _onStop : =>
    @_playing = false
    @trigger 'reset'
    @trigger 'render'

  _playLoop : =>
    requestAnimationFrame(=>
      if @_playing
        @trigger('render')
        setTimeout(@_playLoop, Controller.FRAME_DELAY_MSEC)
    )

  _cycleStyles : =>
    @trigger 'cycle-styles'


class Animator

  constructor : ({@stage, @model, @controller}) ->
    @_remapStyles()
    @_frames = @_extractFrames()
    @_frameIndex = 0
    @_styleIndex = 0

    @controller.on 'render', @render
    @controller.on 'reset', @reset
    @controller.on 'cycle-styles', @cycle

    @cycle()
    @render()

  _remapStyles : ->
    for mappingKey, mappingValue of CLASS_MAPPING
      @model.find('.' + mappingKey).attr('class', mappingValue)
    return

  _extractFrames : () ->
    return _.chain(@model.find('svg > g'))
      .map((el) -> $(el))
      .filter((el) -> FRAME_REGEX.test(el.attr('id')))
      .sortBy((el) -> FRAME_REGEX.exec(el.attr('id'))[1])
      .value()

  cycle : =>
    @stage.attr('class', STYLE_GROUPS[@_styleIndex])
    @_styleIndex = (@_styleIndex + 1) % STYLE_GROUPS.length
    return

  reset : =>
    @_frameIndex = 0

  render : =>
    frame = @_frames[@_frameIndex]
    return unless frame?
    @stage.html(frame)
    @_frameIndex = (@_frameIndex + 1) % @_frames.length
    

module.exports = {Animator, Controller}