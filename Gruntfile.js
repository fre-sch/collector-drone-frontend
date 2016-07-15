module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        options: {
          bare: true
        },
        expand: true,
        flatten: true,
        src: ['src/**/*.coffee'],
        dest: 'build/coffee_js',
        ext: '.js'
      }
    },
    pug: {
        compile: {
            files: {
                'build/dist/index.html': ['src/html/index.pug']
            }
        }
    },
    less: {
        compile: {
            options: {
                sourceMap: true
            },
            files: {
                'build/dist/css/drone.css': 'src/styles/drone.less'
            }
        }
    },
    browserify: {
      dist: {
        src: 'build/coffee_js/App.js',
        dest: 'build/dist/js/dist/app.js'
      }
    },
    copy: {
        dist: {
            expand: true,
            cwd: "./static",
            src: ["./**"],
            dest: "build/dist/"
        }
    },
    watch: {
      scripts: {
        files: [
            'Gruntfile.js',
            'src/**',
            'static/**'
        ],
        tasks: ['default'],
        options: {
          spawn: false,
        },
      },
    },
    connect: {
      server: {
        options: {
          port: 8000,
          hostname: '*',
          base: 'build/dist',
          directory: 'build/dist',
          livereload: true
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-pug');
  grunt.loadNpmTasks('grunt-contrib-less');

  grunt.registerTask('default', [
      'coffee:compile',
      'browserify:dist',
      "pug:compile",
      "less:compile",
      "copy:dist"
  ]);

  grunt.registerTask('serve', [
      'connect:server',
      'watch:scripts'
  ]);

};
