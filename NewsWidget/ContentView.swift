//
//  ContentView.swift
//  NewsWidget
//
//  Created by Kevin Guan on 7/4/21.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("date", store: UserDefaults(suiteName: "group.com.kevinguan.NewsWidget")) var date: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Refreshed \(Int(Date().timeIntervalSince1970) - date) seconds ago")
            Button(action: {
                WidgetCenter.shared.reloadAllTimelines()
            }) {
                Text("Refresh Widget")
            }

            Button(action: {
                guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
                let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
                workspace?.perform(Selector(("openApplicationWithBundleID:")), with: Config.APP)
            }) {
                Text("Open Reeder")
            }
        }
        .padding()
    }
}
