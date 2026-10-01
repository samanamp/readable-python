#!/usr/bin/env ruby
# Wraps each src/<slug>.html fragment in the shared page shell and writes <slug>.html.
# Run: ruby build.rb   (no dependencies; the output is plain static HTML for GitHub Pages)

TITLE = "Readable Python"
CHAPTERS = [
  ["index",         nil, "Readable Python",              "A short style booklet for ML systems code, in the spirit of vLLM and SGLang."],
  ["principles",    1,   "Principles",                   "Five ideas the rest of the booklet follows from."],
  ["shape",         2,   "The shape of a system",        "One loop you can read in one screen, built from named steps."],
  ["state",         3,   "State",                        "Every piece of state has exactly one owner."],
  ["functions",     4,   "Functions",                    "Small, one level of abstraction, results instead of side effects."],
  ["naming",        5,   "Naming",                       "Names from the domain, used consistently."],
  ["comments",      6,   "Comments and docstrings",      "Say why. Never what, never when."],
  ["errors",        7,   "Errors",                       "Fail loudly at boundaries; decide recovery in one place."],
  ["concurrency",   8,   "Concurrency and the GPU",      "Few threads, one owner per thread, overlap only what overlaps."],
  ["abstractions",  9,   "Abstractions",                 "Build for the load you have."],
  ["tests",         10,  "Tests",                        "Tests are the specification people actually read."],
  ["ai-code",       11,  "Reviewing AI-written code",    "What to cut before it merges."],
]

HEAD = <<~HTML
  <!doctype html>
  <html lang="en">
  <head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>%{title}</title>
  <meta name="description" content="%{lede}">
  <link rel="stylesheet" href="style.css">
  <script>try{var t=localStorage.getItem("theme");if(t)document.documentElement.dataset.theme=t;}catch(e){}</script>
  </head>
  <body>
  <header class="site">
    <a href="index.html">#{TITLE}</a>
    <span><span class="crumb">%{crumb}</span> <button class="theme" type="button" onclick="toggleTheme()">theme</button></span>
  </header>
  <main>
HTML

FOOT = <<~HTML
  %{pager}
  </main>
  <footer class="site">
    <p>Written for humans first. Formatting is left to <code>ruff format</code>; this booklet is about structure.</p>
  </footer>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/python.min.js"></script>
  <script>
  if (window.hljs) hljs.highlightAll();
  function toggleTheme() {
    var d = document.documentElement;
    var dark = d.dataset.theme ? d.dataset.theme === "dark" : matchMedia("(prefers-color-scheme: dark)").matches;
    d.dataset.theme = dark ? "light" : "dark";
    try { localStorage.setItem("theme", d.dataset.theme); } catch (e) {}
  }
  </script>
  </body>
  </html>
HTML

def link(ch, label)
  slug, num, title = ch
  name = num ? "#{num}. #{title}" : "Cheat sheet &amp; contents"
  %(<a href="#{slug}.html"><span>#{label}</span>#{name}</a>)
end

CHAPTERS.each_with_index do |ch, i|
  slug, num, title, lede = ch
  body = File.read(File.join(__dir__, "src", "#{slug}.html"))
  prev_ch = i > 0 ? CHAPTERS[i - 1] : nil
  next_ch = CHAPTERS[i + 1]
  pager = +%(<nav class="pager">)
  pager << link(prev_ch, "Previous") if prev_ch
  pager << link(next_ch, "Next").sub("<a ", %(<a class="next" )) if next_ch
  pager << "</nav>"
  heading = num ? %(<h1><span class="num">#{num}</span>#{title}</h1>\n<p class="lede">#{lede}</p>\n) : ""
  page_title = num ? "#{num}. #{title} · #{TITLE}" : TITLE
  crumb = num ? "Chapter #{num} of #{CHAPTERS.size - 1}" : ""
  html = format(HEAD, title: page_title, lede: lede, crumb: crumb) + heading + body + format(FOOT, pager: pager)
  File.write(File.join(__dir__, "#{slug}.html"), html)
  puts "wrote #{slug}.html"
end
