//
//  LuxPremiumTests.swift
//  LuxPremiumTests
//
//  Created by admin on 4/14/26.
//

import Testing
@testable import LuxPremium

struct LuxPremiumTests {

    @Test func developmentImageMapperMapsKnownIds() {
        #expect(DevelopmentImageMapper.mapIdToDrawable(" cerveira_premium_lote3 ") == "dev_cerveira_premium")
        #expect(DevelopmentImageMapper.mapIdToDrawable("ENTRONCAMENTO_lote2") == "dev_entroncamento_premium")
        #expect(DevelopmentImageMapper.mapIdToDrawable("gaia_premium_lote1") == "dev_gaia_premium")
        #expect(DevelopmentImageMapper.mapIdToDrawable("gondomar_fase_2") == "dev_gondomar_green")
        #expect(DevelopmentImageMapper.mapIdToDrawable("poiares_lote9") == "dev_poiares_premium")
        #expect(DevelopmentImageMapper.mapIdToDrawable("sao_joao_lotea") == "dev_sao_joao_premium")
        #expect(DevelopmentImageMapper.mapIdToDrawable("trofa-lote-1") == "dev_trofa_premium")
        #expect(DevelopmentImageMapper.mapIdToDrawable("valongo lote especial") == "dev_valongo_premium")
    }

    @Test func developmentImageMapperReturnsDefaultForUnknownIds() {
        #expect(DevelopmentImageMapper.mapIdToDrawable("desarrollo_desconocido") == "foto_por_defecto")
    }
}
