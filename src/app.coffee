{$, _}   = require './mvc'
{Loader} = require './loader'
{Animator, AnimatorControls, ModelControls, Dispatch} = require './animator'

module.exports = ->

  $.getJSON('models.json')
  # Load models
  .then((models) -> Loader.loadModels(models))
  # Construct animator UI
  .then((models) ->
    dispatch         = Dispatch
    animator         = new Animator({stage : $('svg #stage'), dispatch})
    animatorControls = new AnimatorControls({el : $('#animator-controls'), dispatch})
    modelControls    = new ModelControls({el : $('#model-controls'), dispatch, models})
  )