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
FONTS = "https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible+Mono:wght@400..700" \
        "&family=Atkinson+Hyperlegible+Next:ital,wght@0,400..800;1,400&display=swap"

def rp(n); format("RP%02d", n.to_i); end

# Source fragments say "Rule 4." in rule boxes and "rule 4" in prose; render both as lint codes.
def transform(body)
  body = body.gsub(%r{<div class="rule">Rule (\d+)\. (.*?)\s*<span class="why">(.*?)</span></div>}m) do
    %(<div class="rule"><span class="code">#{rp($1)}</span><div><p class="stmt">#{$2.strip}</p><p class="why">#{$3.strip}</p></div></div>)
  end
  body = body.gsub(%r{<div class="rule">(?!<span)(.*?)</div>}m) { %(<div class="rule plain"><p class="stmt">#{$1.strip}</p></div>) }
  body = body.gsub(/\b[Rr]ule (\d+)\b/) { rp($1) }
  body.gsub("<table>", %(<div class="table-wrap"><table>)).gsub("</table>", "</table></div>")
end

def rail(current)
  items = CHAPTERS.drop(1).map do |slug, num, title|
    cur = slug == current ? %( aria-current="page") : ""
    %(<li><a href="#{slug}.html"#{cur}><span class="n">#{format('%02d', num)}</span><span>#{title}</span></a></li>)
  end
  open = ""
  <<~HTML
    <nav class="rail" aria-label="Contents">
      <div class="book"><a href="index.html">#{TITLE}</a><button class="theme" type="button" onclick="toggleTheme()">theme</button></div>
      <details#{open}><summary>Contents</summary>
        <ol>
          <li><a href="index.html"#{current == "index" ? ' aria-current="page"' : ""}><span class="n">RP</span><span>Cheat sheet</span></a></li>
          #{items.join("\n      ")}
        </ol>
      </details>
    </nav>
  HTML
end

def pager_link(ch, label, cls)
  slug, num, title = ch
  name = num ? title : "Cheat sheet"
  %(<a class="#{cls}" href="#{slug}.html"><span>#{label}#{num ? " · #{format('%02d', num)}" : ""}</span>#{name}</a>)
end

CHAPTERS.each_with_index do |(slug, num, title, lede), i|
  body = transform(File.read(File.join(__dir__, "src", "#{slug}.html")))
  prev_ch = i > 0 ? CHAPTERS[i - 1] : nil
  next_ch = CHAPTERS[i + 1]
  pager = +%(<nav class="pager" aria-label="Chapters">)
  pager << pager_link(prev_ch, "Previous", "prev") if prev_ch
  pager << pager_link(next_ch, "Next", "next") if next_ch
  pager << "</nav>"
  heading = num ? %(<p class="eyebrow">Chapter #{format('%02d', num)} of #{CHAPTERS.size - 1}</p>\n<h1>#{title}</h1>\n<p class="lede">#{lede}</p>\n) : ""
  page_title = num ? "#{title} · #{TITLE}" : TITLE
  html = <<~HTML
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#{page_title}</title>
    <meta name="description" content="#{lede}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="#{FONTS}">
    <link rel="stylesheet" href="style.css">
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 32 32%27%3E%3Crect width=%2732%27 height=%2732%27 rx=%275%27 fill=%27%23ffe55c%27/%3E%3Ctext x=%2716%27 y=%2721.5%27 font-family=%27monospace%27 font-size=%2714%27 font-weight=%27700%27 text-anchor=%27middle%27 fill=%27%2315181d%27%3ERP%3C/text%3E%3C/svg%3E">
    <script>try{var t=localStorage.getItem("theme");if(t)document.documentElement.dataset.theme=t;}catch(e){}</script>
    </head>
    <body>
    <div class="frame">
    #{rail(slug)}
    <main>
    #{heading}#{body}
    #{pager}
    <footer class="site"><p>Formatting is left to <code>ruff format</code>. This booklet is about structure. Source on <a href="https://github.com/samanamp/readable-python">GitHub</a>.</p></footer>
    </main>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/python.min.js"></script>
    <script>
    if (window.hljs) hljs.highlightAll();
    if (matchMedia("(min-width: 64rem)").matches) document.querySelector(".rail details").open = true;
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
  File.write(File.join(__dir__, "#{slug}.html"), html)
end
puts "built #{CHAPTERS.size} pages"
