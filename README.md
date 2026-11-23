# sasa-workshop-iml
SASA 2026 workshop on Interpretable Machine Learning

## Workshop website

The site is a static GitHub Pages site. To publish it after merging these
changes, open the repository's **Settings → Pages**, select **Deploy from a
branch**, and choose the default branch and `/ (root)`. Once published, the
site will be available at <https://mnwright.github.io/sasa-workshop-iml/>.

The slides and exercises are not yet in this repository. Add the PDF slides,
rendered HTML exercises, and any files they depend on (such as images or
`*_files` directories) to the repository. Then replace the availability
message in `index.html` with links to the files, using relative paths, for
example:

```html
<ul>
  <li><a href="materials/slides.pdf">Slides (PDF)</a></li>
  <li><a href="materials/exercises.html">Exercises</a></li>
</ul>
```

Add the Rmd source files as well if participants should be able to download
them. Keep each rendered exercise's supporting files in their original relative
locations. The `.nojekyll` file allows GitHub Pages to serve directories whose
names begin with an underscore.
