{$, _} = require './mvc'

class Loader

  @loadModels : (models) ->
    promises = _.chain(models)
      # Apply default values
      .forEach((model) ->
        _.defaults(model, {
          fps : 10
        })
      )
      # Inflate SVG
      .map((model) ->
        $.get(model.svg).then((modelSvg) -> model.svg = $(modelSvg))
      )
      .value()

    return $.when(promises...).then(-> _.values(models))

module.exports = {
  Loader
}
