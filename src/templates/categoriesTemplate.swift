let categoriesTemplate = Site.templateA("/category") { site, page in baseLayout(site: site, page: page, main: """
<main>
    \(page.content)
    <hr />
    <ul>
        \(Category.allCases.reduce("") {
            $0 + """
            <li>
                <a href="/category/\($1)">\($1.name)</a>
            </li>
            """
        })
    </ul>
</main>
""" ) }
