module.exports = (grunt) ->

	src =
		main: "src/main/"
		test: "src/test/"
		libs: "dist/js/lib/"
		dist: "dist/"
		
	resSrc =
		main: "#{src.main}/resources/"
		test: "#{src.test}/resources/"
		dist: "#{src.dist}/resources/"

	jsSrc = 
		main: "#{src.main}js/"
		test: "#{src.test}js/"
		dist: "#{src.dist}js/"
		
	htmlSrc =
		main: "#{src.main}html/"
		dist: "#{src.dist}"
		
	cofSrc =
		main: "#{src.main}coffee/"
		dist: jsSrc.dist
		test: jsSrc.test

	# Initialize the configuration.
	grunt.initConfig

		# -- Common variables

		# Load configuration from JSON.
		pkg: grunt.file.readJSON "package.json"
		
		# Define the header for source files.
		banner: """/*
				  \ * <%= pkg.name %> - <%= pkg.version %> (<%= grunt.template.today(\"yyyy-mm-dd\") %>)
				  \ * Copyright <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.organization || pkg.author.name %>, <%= pkg.author.email %>. All rights reserved.
				  \ */
				  \ 
				  """
				  
		# -- Plugin configuration

		# Manage dependencies with bower.
		"bower-install-simple":
			options:
				directory: src.libs
			prod:
				options:
					production: true
					
		bower:
			completeRequireJs:
				rjsConfig: "#{jsSrc.dist}app.build.js"
				
				options:
					transitive: true
		
		# Specify directories to clean.
		clean:
			files: [src.dist]
			
		coffee:
			compile:
				files:
					"dist/js/test.js": [ "#{cofSrc.main}*.coffee" ]
				options:
				  bare: true
					
		coffeelint:
			sources: [ "#{cofSrc.main}*.coffee" ]
			
		# Files to be copied during build.
		copy:
			html: 
				expand: true
				cwd: htmlSrc.main
				src: ["**"]
				dest: htmlSrc.dist
				
			resources:
				expand: true
				cwd: resSrc.main
				src: ["**"]
				dest: resSrc.dist
				
			
		# Configuration for concatunation: Put the file header to each file.
		concat:
			options:
				banner: "<%= banner %>"
				stripBanners: true
				
			dist:
				src: ["#{jsSrc.main}<%= pkg.name %>.js"]
				dest: "#{jsSrc.dist}<%= pkg.name %>.js"
				
			main:
				src: ["#{jsSrc.main}app.build.js"]
				dest: "#{jsSrc.dist}app.build.js"

		# Configuration for jshint.
		jshint:
			src:
				src: ["#{jsSrc.main}**/*.js"]
				
			test:
				src: ["#{jsSrc.test}**/*.js"]

			# Allow certain options.
			options:
				browser: true
				boss: true
				
		# Configurations for uglify.
		uglify:
			options:
				banner: "<%= banner %>"

			build:
				src: "<%= concat.dist.dest %>"
				dest: "#{jsSrc.dist}<%= pkg.name %>.min.js"
				
		wiredep: 
			target:
                src: "#{src.dist}**/*.html",
                ignorePath: src.dist


	# Load external Grunt task plugins.
	grunt.loadNpmTasks "grunt-bower-install-simple"
	grunt.loadNpmTasks "grunt-bower-requirejs"
	grunt.loadNpmTasks "grunt-coffeelint"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-concat"
	grunt.loadNpmTasks "grunt-contrib-jshint"
	grunt.loadNpmTasks "grunt-contrib-uglify"
	grunt.loadNpmTasks "grunt-wiredep"

	# Default task.
	grunt.registerTask "default", ["clean", "jshint", "concat", "uglify", "coffeelint", "coffee", "copy", "bower-install", "bower", "wiredep" ]
	grunt.registerTask "bower-install", ["bower-install-simple:prod"]