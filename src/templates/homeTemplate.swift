let homeTemplate = Site.templateA("/") { site, page in baseLayout(site: site, page: page, main: """
<main class="home">
    <section class="intro">
        \(page.content)
    </section>
    <section>
        <h1>Latest Posts</h1>
        \(site.contentB.sorted(by: Post.dateDescendingOrder).enumerated().map {
            """
            \(summaryPartial(site, $1))
            \($0 < site.contentB.count - 1 ? "<hr />" : "")
            """
        }.joined())
    </section>
</main>
""" ) }
