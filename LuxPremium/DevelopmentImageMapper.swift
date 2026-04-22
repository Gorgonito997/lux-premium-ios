import Foundation

enum DevelopmentImageMapper {
    static func mapIdToDrawable(_ id: String) -> String {
        let cleanId = id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if cleanId.contains("cerveira") {
            return "dev_cerveira_premium"
        }

        if cleanId.contains("entroncamento") {
            return "dev_entroncamento_premium"
        }

        if cleanId.contains("gaia") {
            return "dev_gaia_premium"
        }

        if cleanId.contains("gondomar") {
            return "dev_gondomar_green"
        }

        if cleanId.contains("poiares") {
            return "dev_poiares_premium"
        }

        if cleanId.contains("sao_joao") {
            return "dev_sao_joao_premium"
        }

        if cleanId.contains("trofa") {
            return "dev_trofa_premium"
        }

        if cleanId.contains("valongo") {
            return "dev_valongo_premium"
        }

        return "foto_por_defecto"
    }
}
