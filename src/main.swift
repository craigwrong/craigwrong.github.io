import SwiftySites

let posts = [
    postSimulateTheBitcoinNetworkWithCoreAndDocker,
    postManualPayToTaprootDescriptors,
    postIntroducingSwiftBitcoinLibrary,
]

let site = Site(
    config,
    content: (
        [pageHome, pageAbout, pageCategories],
        posts,
        categories
    ),
    template: (
        [pageTemplate, homeTemplate, categoriesTemplate],
        [postTemplate],
        [categoryTemplate]
    )
)

site.render()
