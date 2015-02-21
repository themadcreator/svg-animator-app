{$, Backbone, Marionette, _} = require './mvc'

#
# Measures the milliseconds between calls to .next()
#
class DiffTimer
  @_last : new Date().getTime()
  next   : ->
    now      = new Date().getTime()
    diffMsec = now - @_last
    @_last   = now
    return diffMsec

#
# Creates a circular cursor for the elements of an array.
#
class Cycler
  constructor : (@_values = [], @_index = 0) ->
  
  values : (@_values = []) ->
    @reset()
    return @

  reset : ->
    @_index = 0
    return @current()

  current : ->
    return @_values[@_index]

  next : ->
    @_index = (@_index + 1) % @_values.length
    return @current()

  prev : ->
    return if @_values.length is 0
    @_index = if @_index is 0 then @_values.length - 1 else @_index - 1
    return @current()


#
# This view manages UI events and triggers events to control the animator
#
class AnimatorControls extends Marionette.ItemView  
  _playing    : false
  _phase      : 0
  _nominalFps : 10
  _frameDelay : 100

  template : false

  events :
    'click #play'         : '_onPlay'
    'click #play-half'    : '_onPlayHalf'
    'click #play-quarter' : '_onPlayQuarter'
    'click #frame-prev'   : '_onFramePrev'
    'click #frame-next'   : '_onFrameNext'
    'click #stop'         : '_onStop'

  initialize : ({@dispatch}) ->
    @_timer = new DiffTimer()
    
    @dispatch.on 'set-model', @setModel

  setModel : (model) =>
    @_nominalFps = model?.fps ? 10

  _setSpeed : (speed) =>
    @_frameDelay = Math.max(10, 1000.0 / (@_nominalFps * speed))

  _onPlay : =>
    @_setSpeed(1)
    @_startPlay()

  _onPlayHalf : =>
    @_setSpeed(0.5)
    @_startPlay()

  _onPlayQuarter : =>
    @_setSpeed(0.25)
    @_startPlay()

  _onFramePrev : =>
    @_playing = false
    @dispatch.trigger 'frame-prev'
    @dispatch.trigger 'render'

  _onFrameNext : =>
    @_playing = false
    @dispatch.trigger 'frame-next'
    @dispatch.trigger 'render'

  _onStop : =>
    @_playing = false
    @dispatch.trigger 'frame-reset'
    @dispatch.trigger 'render'

  _startPlay : =>
    return if @_playing
    @_playing = true
    @_timer.next() # reset frame timer
    @_playLoop()

  _playLoop : =>
    requestAnimationFrame(=>
      return unless @_playing
      @_playTick()
      # This 10 msec delay keeps the processing to a minimum but limits FPS to about 100
      setTimeout(@_playLoop, 10) 
    )

  _playTick : ->
    diffMsec = @_timer.next()
    @_phase += diffMsec
    if @_phase > @_frameDelay
      @dispatch.trigger 'frame-next'
      @dispatch.trigger 'render'
      @_phase %= @_frameDelay
    return

#
# This view manages UI events and triggers events to control the selection of models
#
class ModelControls extends Marionette.ItemView  
  _modelIndex : 0

  template : false

  events :
    'click #cycle-model'   : '_onCycleModel'
    'click #cycle-palette' : '_onCyclePalette'

  initialize : ({@models, @dispatch}) ->
    @_models = new Cycler(@models)
    @dispatch.trigger 'set-model', @_models.current()

  _onCycleModel : =>
    @dispatch.trigger 'set-model', @_models.next()

  _onCyclePalette : =>
    @dispatch.trigger 'cycle-palette'


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
  
  constructor : ({@stage, @dispatch}) ->
    @_frames   = new Cycler()
    @_palettes = new Cycler()

    @dispatch.on 'set-model', @setModel

    @dispatch.on 'render', @render
    @dispatch.on 'frame-reset', @frameReset
    @dispatch.on 'frame-next', @frameNext
    @dispatch.on 'frame-prev', @framePrev
    @dispatch.on 'cycle-palette', @paletteNext

  setModel : (model) =>
    if model?
      @_attachCss(model.css)
      @_remapStyles(model.svg, model.classes)
      @_frames.values @_extractFrames(model.svg)
      @_palettes.values model.palettes
    else
      @_palettes.values []
      @_frames.values []

    @showPalette()
    @render()

  # Link the model's CSS to this document so the rules are applied
  _attachCss : (css) ->
    $('#model-style').attr('href', css)
    #$('head').append("<link rel=\"stylesheet\" type=\"text/css\" href=\"#{css}\">")

  # Convert the auto-generated Illustrator class names to sane ones
  _remapStyles : (svg, classes) ->
    return unless classes?
    for mappingKey, mappingValue of classes
      svg.find('.' + mappingKey).attr('class', mappingValue)
    return

  # Find all the groups in the SVG that contain an id like "frame0", "frame1",
  # etc. and return them as an array in sorted order.
  _extractFrames : (svg) ->
    return _.chain(svg.find('svg > g'))
      .map((el) -> $(el))
      .filter((el) -> Animator.FRAME_REGEX.test(el.attr('id')))
      .sortBy((el) -> parseInt(Animator.FRAME_REGEX.exec(el.attr('id'))[1]))
      .value()

  paletteNext : =>
    @_palettes.next()
    @showPalette()
    return

  # Attach a class from the model's `palettes` array to the stage to define
  # the palette.
  showPalette : =>
    if (palette = @_palettes.current())?
      @stage.attr('class', palette)
  
  # Replace the contents of the SVG stage with the next frame in sequence.
  render : =>
    if (frame = @_frames.current())?
      @stage.html(frame.clone())
    else
      @stage.empty()

  # Return the frames to the start.
  frameReset : =>
    @_frames.reset()
  
  frameNext : =>
    @_frames.next()

  framePrev : =>
    @_frames.prev()
    

module.exports = {
  Dispatch : _.extend({}, Backbone.Events, cid: 'dispatcher')
  Animator
  AnimatorControls
  ModelControls
}