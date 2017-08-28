gulp            = require 'gulp'
webserver       = require 'gulp-webserver'
less            = require 'gulp-less'
flatten         = require 'gulp-flatten'
source          = require 'vinyl-source-stream'
browserify      = require 'browserify'
watchify        = require 'watchify'
cjsxify         = require 'cjsxify'
reactify        = require 'reactify'
templatify      = require 'gulp-template-html'

handleErrors = (title) -> (args...)->
  # TODO: Send error to notification center with gulp-notify
  console.error(title, args...)
  # Keep gulp from hanging on this task
  @emit('end')


buildBrowserify = (srcPath, destDir, destFile, isWatching) ->
  args = (if isWatching then watchify.args else {})
  args.entries = [srcPath]
  args.extensions = ['.js', '.jsx']
  args.debug = true if isWatching

  bundler = browserify(args)

  bundler.transform(cjsxify)
  bundler.transform(reactify)

  bundler = watchify(bundler, {}) if isWatching

  bundle = ->
    bundler
    .bundle()
    .on('error', handleErrors('Browserify error'))
    .pipe(source(destFile))
    .pipe(gulp.dest(destDir))

  bundler.on('update', bundle) if isWatching
  bundle()


build = (isWatching)->
  destDir = './'
  destDirFonts = './fonts'

  destFile = './dist/build.js'
  srcPath = './src/index.jsx'
  buildBrowserify(srcPath, destDir, destFile, isWatching)
  .on 'end', ->
    gulp.src('bower_components/**/*.{eot,svg,ttf,woff,woff2}')
    .pipe(flatten())
    .pipe(gulp.dest(destDirFonts))


gulp.task 'styles', ->
  destDirCss = './dist'
  destDirCssFonts = './fonts'
  # Build the CSS file
  gulp.src('./style/all.less')
  .pipe(less())
  .pipe(gulp.dest(destDirCss))

  # Move the font files over to dist as well
  gulp.src('./node_modules/**/*.{eot,svg,ttf,woff,woff2}')
  .pipe(flatten())
  .pipe(gulp.dest(destDirCssFonts))

gulp.task 'template', ->
  contentSrc = 'src/*.html'
  templateDir = 'templates/template.html'
  destDir = './'
  gulp.src(contentSrc)
  .pipe(templatify(templateDir))
  .pipe(gulp.dest(destDir))

gulp.task 'dist', ['styles'], -> build(false)

gulp.task 'serve', ['dist'], ->
  build(true)
  config = webserver
    port: process.env['PORT'] or undefined
    # host: '0.0.0.0'
    open: true
    livereload:
      filter: (f) -> console.log(arguments)
    # fallback: 'index.html'

  gulp.src('./')
    .pipe(config)
