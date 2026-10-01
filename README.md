# Readable Python

A short style booklet for ML systems code (schedulers, engines, serving loops), aiming for the readability of codebases like vLLM and SGLang.

Read it at **https://samanamp.github.io/readable-python/**

Fifteen rules on one page, then eleven short chapters with before/after examples:

1. Principles
2. The shape of a system
3. State
4. Functions
5. Naming
6. Comments and docstrings
7. Errors
8. Concurrency and the GPU
9. Abstractions
10. Tests
11. Reviewing AI-written code

## Editing

Chapters live in `src/*.html` as body fragments. `build.rb` wraps each one in the shared page shell (header, prev/next links, footer) and writes the top-level `*.html` files that GitHub Pages serves.

```sh
ruby build.rb   # no dependencies
```

Commit both `src/` and the generated pages. There is no build step on GitHub's side.
