require! <[fs gulp main-bower-files gulp-chmod gulp-concat gulp-filter gulp-insert gulp-pug gulp-livereload gulp-livescript gulp-rename gulp-replace gulp-stylus gulp-util nib streamqueue tiny-lr]>

paths =
  app: \app
  build: \public
paths.html = paths.app+\/**/*.html
paths.pug = paths.app+\/**/*.pug
paths.css = paths.app+\/**/*.css
paths.styl = paths.app+\/**/*.styl
paths.js = paths.app+\/**/*.js
paths.ls = paths.app+\/**/*.ls
paths.res = paths.app+\/res/**
port = parseInt(fs.readFileSync \port encoding: \utf-8)
tiny-lr-port = 35729

tiny-lr-server = tiny-lr!
livereload = -> gulp-livereload tiny-lr-server

gulp.task \html ->
  html = gulp.src paths.html
  pug = gulp.src(paths.pug).pipe gulp-pug {+pretty}
  streamqueue {+objectMode}
    .done html, pug
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \css ->
  css-bower = gulp.src main-bower-files! .pipe gulp-filter \**/*.css .pipe gulp-replace /(\.\.\/)?themes\/default\/assets/g \.
  css-app = gulp.src paths.css
  styl-app = gulp.src(paths.styl).pipe gulp-stylus use: nib!, import: <[nib]>
  streamqueue {+objectMode}
    .done css-bower, css-app, styl-app
    .pipe gulp-concat \app.css
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \js ->
  js-bower = gulp.src main-bower-files! .pipe gulp-filter \**/*.js .pipe gulp-replace /(\.\.\/)?\/themes\/default\/assets/g \.
  js-app = gulp.src paths.js
  ls-app = gulp.src(paths.ls).pipe gulp-livescript {+bare}
  streamqueue {+objectMode}
    .done js-bower, js-app, ls-app
    .pipe gulp-concat \app.js
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \do !->
  gulp.src <[do.ls]>
    .pipe gulp-livescript {+bare}
    .pipe gulp-insert.prepend "#!/usr/local/bin/node\n"
    .pipe gulp-rename extname: ''
    .pipe gulp-chmod 755
    .pipe gulp.dest paths.build

gulp.task \res ->
  gulp.src paths.res
    .pipe gulp.dest paths.build+\/res
    .pipe livereload!
  gulp.src \bower_components/semantic-ui/dist/themes/default/assets/fonts/*
    .pipe gulp.dest paths.build+\/fonts

gulp.task \server ->
  require! \express
  express-server = express!
  express-server.use require(\connect-livereload)!
  Do = require \./public/do
  express-server.get \/do (req, res) !-> Do req._parsed-url.query, res
  express-server.use express.static paths.build
  express-server.listen port
  gulp-util.log "Listening on port: #port"

gulp.task \watch <[build server]> ->
  tiny-lr-server.listen tiny-lr-port, ->
    return gulp-util.log it if it
  gulp.watch [paths.html,paths.pug], <[html]>
  gulp.watch [paths.css,paths.styl], <[css]>
  gulp.watch [paths.js,paths.ls], <[js]>
  gulp.watch [\do.ls], <[do]>
  gulp.watch [paths.res], <[res]>

gulp.task \build <[html css js do res]>
gulp.task \default <[watch]>

# vi:et:ft=ls:nowrap:sw=2:ts=2
