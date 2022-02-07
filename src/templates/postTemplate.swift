let postTemplate = Site.templateB { site, post in baseLayout(site: site, post: post, main: """
<main class="post"><article>
    <header>
        <p class="date">\(post.dateFormatted) • <a href="/category/\(post.category)">\(post.category.name)</a></p>
        <h1 class="title">
            \(post.title)
        </h1>
    </header>
    <main>
    \(post.content)
    </main>
</article></main>
""" ) }
