let pageTemplate = Site.templateA(exclude: #"^/category/[\W\w]+$|/post|/category|/"#) { site, page in baseLayout(site: site, page: page, main: """
<main class="page">\(page.content)</main>
""" ) }
