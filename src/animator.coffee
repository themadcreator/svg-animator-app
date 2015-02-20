{$, Backbone, _} = require './mvc'


#
# The Controller manages UI events and triggers events to control the animator
#
class Controller
  @FRAME_DELAY_MSEC : 30

  _playing : false

  constructor : ({@controls}) ->
    _.extend(@, Backbone.Events)
    @controls.find('#play').click @_onPlay
    @controls.find('#stop').click @_onStop
    @controls.find('#cycle').click @_cyclePalette

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

  _cyclePalette : =>
    @trigger 'cycle-palette'

#
# The Animator has 3 jobs
#
# 1. Convert the model into a set of frames
#
# 2. Listen to the controller for render and cycle events
#
# 3. Render each frame in order (when requested) by inserting it into the SVG
#    'stage'.
#
class Animator
  @FRAME_REGEX = /frame([0-9]+)/

  constructor : ({@stage, @model, @controller}) ->
    @_attachCss()
    @_remapStyles()
    @_frames = @_extractFrames()
    @_frameIndex = 0
    @_paletteIndex = 0

    @controller.on 'render', @render
    @controller.on 'reset', @reset
    @controller.on 'cycle-palette', @cycle

    @cycle()
    @render()

  # Link the model's CSS to this document so the rules are applied
  _attachCss : ->
    $('head').append("<link rel=\"stylesheet\" type=\"text/css\" href=\"#{@model.css}\">")

  # Convert the auto-generated Illustrator class names to sane ones
  _remapStyles : ->
    return unless @model.classes?
    for mappingKey, mappingValue of @model.classes
      @model.svg.find('.' + mappingKey).attr('class', mappingValue)
    return

  # Find all the groups in the SVG that contain an id like "frame0", "frame1",
  # etc. and return them as an array in sorted order.
  _extractFrames : () ->
    return _.chain(@model.svg.find('svg > g'))
      .map((el) -> $(el))
      .filter((el) -> Animator.FRAME_REGEX.test(el.attr('id')))
      .sortBy((el) -> parseInt(Animator.FRAME_REGEX.exec(el.attr('id'))[1]))
      .value()

  # Attach a class from the model's `palettes` array to the stage to define
  # the palette.
  cycle : =>
    return unless @model.palettes?
    @stage.attr('class', @model.palettes[@_paletteIndex])
    @_paletteIndex = (@_paletteIndex + 1) % @model.palettes.length
    return
  
  # Return the frames to the start.
  reset : =>
    @_frameIndex = 0
  
  # Replace the contents of the SVG stage with the next frame in sequence.
  render : =>
    frame = @_frames[@_frameIndex]
    return unless frame?
    @stage.html(frame)
    @_frameIndex = (@_frameIndex + 1) % @_frames.length
    

module.exports = {Animator, Controller}