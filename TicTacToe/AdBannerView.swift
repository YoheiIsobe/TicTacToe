//
//  AdBannerView.swift
//  TicTacToe
//
//  Created by Takuma Nezu on 2025/11/24.
//

import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID

        // rootViewController 安全取得
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            banner.rootViewController = rootVC
            print("rootViewController が正常")
        } else {
            print("rootViewController が nil")
        }

        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

