module.exports = function(grunt) {

    grunt.initConfig({
        uglify: {
            my_target: {
                files: {
                    'connect4.js': ['connect4.js']
                }
            }
        },
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
    grunt.loadNpmTasks('grunt-contrib-uglify');

    grunt.registerTask('default', ['elm']);
    grunt.registerTask('release', ['clean','elm','uglify']);

};
