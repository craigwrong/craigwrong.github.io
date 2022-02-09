let site = Site(config,
    contentA: [
        pageHome, pageAbout, pageCategories
    ],
    contentB: [
        postSimulateTheBitcoinNetworkWithCoreAndDocker,
        postManualPayToTaprootDescriptors,
    ],
    templates: [
        pageTemplate, homeTemplate, postTemplate, categoriesTemplate, categoryTemplate
    ],
    generators: [
        categoriesGenerator
    ])

site.render()
