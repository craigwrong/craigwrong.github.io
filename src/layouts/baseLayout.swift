import SwiftySites

func baseLayout (site: Site, page: Page? = nil, post: Post? = nil, main: String) -> String { """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="stylesheet" href="/assets/global.css" />
        <link rel="stylesheet" href="/assets/highlight.css" />
        <script src="/assets/highlight.js"></script>
        <script>hljs.highlightAll();</script>
        <title>\(site.config.title) | \(page?.title ?? post!.title)</title>
    </head>
    <body>
        <header>
            <div>
                <div class="site-title">
                    <span class="name">Workchain Manipulator ⚡️</span> – Bitcoin-only software development</div>
                \(navigationPartial(site, page))
            </div>
        </header>
        \(main)
        \(footerPartial(site, page))
    </body>
</html>
""" }
