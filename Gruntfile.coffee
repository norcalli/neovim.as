module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  # grunt.loadNpmTasks 'grunt-contrib-coffee'
  # grunt.loadNpmTasks 'grunt-contrib-copy'

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    shell:
      target:
        command: "cd build && npm install --production"

    copy:
      prod:
        files: [
          { flatten: true, expand: true, src: ["./package.json", "src/nvim.html", "src/nvim.css"], dest: "build/" }
        ]
        options:
          process: (c, p)->
            return c if p.indexOf(".json") < 0
            o = JSON.parse c
            o.main = o.main.replace("src/", "")
            JSON.stringify o

    coffee:
      prod:
        options:
          join: true
        files:
          'build/launcher.js': 'src/launcher.coffee'
          'build/nvim/config.js': 'src/nvim/config.coffee'
          'build/nvim/key_handler.js': 'src/nvim/key_handler.coffee'
          'build/nvim/main.js': 'src/nvim/main.coffee'
          'build/nvim/nvim.js': 'src/nvim/nvim.coffee'
          'build/nvim/helpers.js': 'src/nvim/helpers.coffee'
          'build/nvim/ui.js': 'src/nvim/ui.coffee'

      dev:
        options:
          join: true
          sourceMap: true
        files:
          'src/launcher.js': 'src/launcher.coffee'
          'src/nvim/config.js': 'src/nvim/config.coffee'
          'src/nvim/key_handler.js': 'src/nvim/key_handler.coffee'
          'src/nvim/main.js': 'src/nvim/main.coffee'
          'src/nvim/nvim.js': 'src/nvim/nvim.coffee'
          'src/nvim/helpers.js': 'src/nvim/helpers.coffee'
          'src/nvim/ui.js': 'src/nvim/ui.coffee'


  grunt.registerTask 'default', ['coffee:dev']
  grunt.registerTask 'prod', ['coffee:prod', "copy", "shell"]

