module.exports = function(grunt) {

  grunt.initConfig({
    elm: {
      compile: {
        files: {
          "connect4.js": ["connect4.elm"]
        }
      }
    },
    watch: {
      elm: {
        files: ["connect4.elm"],
        tasks: ["elm"]
      }
    },
    clean: ["elm-stuff/build-artifacts"]
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-elm');

  grunt.registerTask('default', ['elm']);

};
