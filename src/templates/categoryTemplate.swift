let categoryTemplate = Site.templateA(#"/category/[\W\w]+"#) { site, page in baseLayout(site: site, page: page, main: """
<main class="category">
    <div>\(page.content)</div>
    <div>
        <a href="/category">All categories</a>
    </div>
    <br />
    <section>
        \(site.contentB
            .filter { $0.category == page.category }
            .sorted(by: Post.dateDescendingOrder).enumerated().map { """
                \(summaryPartial(site, $1))
                \($0 < site.contentB.count - 1 ? "<hr />" : "")
            """ }
            .joined()
        )
    </section>
</main>
""" ) }
