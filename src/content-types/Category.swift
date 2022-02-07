enum Category: String, CaseIterable {
    case bitcoinProtocol, bitcoinCore, lightningNetwork, cypherpunkPhilosophy, cryptography, swiftLanguage

    var name: String {
        switch(self) {
        case .bitcoinProtocol:
            return "Bitcoin Protocol"
        case .bitcoinCore:
            return "Bitcoin Core"
        case .lightningNetwork:
            return "Lightning Network"
        case .cypherpunkPhilosophy:
            return "Cypherpunk Philosophy"
        case .cryptography:
            return "Cryptography"
        case .swiftLanguage:
            return "The Swift Programming Language"
        }
    }
}
