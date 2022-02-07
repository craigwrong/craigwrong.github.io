import SwiftySites

let categoriesGenerator = Site.generatorA { site in
    Category.allCases.map { category in Page("/category/\(category)", "\(category.name)") { """
    # \(category.name) Category

    Posts on the _\(category.name)_ category.

    """ } }
}
