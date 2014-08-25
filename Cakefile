{exec} = require 'child_process'

class Builder
  @compile = (options = {}) ->
    console.log 'Compiling Coffescript file ...'
    exec 'coffee -c -o . src/jquery.scrollable-pagination.coffee', (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr if stdout or stderr
      console.log 'Done !'
      options.then?()

  @minify = (options = {}) ->
    console.log 'Minifying Javascript file ...'
    exec 'uglifyjs jquery.scrollable-pagination.js -o jquery.scrollable-pagination.min.js', (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr if stdout or stderr
      console.log 'Done !'
      options.then?()

task 'build', 'Build project to a js file and minifies it', ->
  Builder.compile(then: -> Builder.minify())

task 'build:compile', 'Build project to a js file', ->
  Builder.compile()

task 'build:minify', 'Minifies the compiled js file', ->
  Builder.minify()
