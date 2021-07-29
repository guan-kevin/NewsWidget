//
//  NewsWidgetApp.swift
//  NewsWidget
//
//  Created by Kevin Guan on 7/4/21.
//
// Icon Source: https://macosicons.com/u/Elias
//

import BetterSafariView
import SwiftUI

@main
struct NewsWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if url.absoluteString.hasPrefix("widget://") {
                        let string_url = url.absoluteString.replacingOccurrences(of: "widget://", with: "")

                        if let safari_url = URL(string: string_url) {
                            UIApplication.shared.open(safari_url)
                        }
                    }
                }
        }
    }
}
