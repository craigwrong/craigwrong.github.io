let site = Site(config,
    contentA: [
        pageHome, pageAbout
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
