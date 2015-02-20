{$}                    = require './mvc'
{Animator, Controller} = require './animator'

module.exports = ->

  $.getJSON('models.json')
  # Select test model
  .then((models) -> models.test_model)
  # Load SVG for model
  .then((model) ->
    return $.get(model.svg)
      .then((modelSvg) -> model.svg = $(modelSvg))
      .then(-> model)

  )
  # Construct animator UI
  .then((model) ->
    controller = new Controller({controls : $('#controls')})
    animator   = new Animator({stage : $('svg #stage'), model, controller})
  )