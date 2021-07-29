//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Kevin Guan on 7/4/21.
//

import Alamofire
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), news: [News(source: "Source 1", title: "Title 1", link: "https://apple.com"), News(source: "Source 2", title: "Title 2", link: "https://google.com")])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), news: [News(source: "Source 1", title: "Title 1", link: "https://apple.com"), News(source: "Source 2", title: "Title 2", link: "https://google.com")])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let now = Date()
        let hour = Calendar.current.component(.hour, from: Date())
        let next = hour >= 7 ? Calendar.current.date(byAdding: .minute, value: 15, to: now)! : Calendar.current.date(byAdding: .hour, value: 7 - hour, to: now)!

        if let userDefaults = UserDefaults(suiteName: "group.com.kevinguan.NewsWidget") {
            userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "date")
        }

        AF.request(Config.URL, method: .get).responseJSON { (response: DataResponse) in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    if let main = value as? [String: Any] {
                        if let error = main["error"] as? Bool, !error, let news = main["news"] as? [[String]], news.count > 0 {
                            var news_list = [News]()
                            for new in news {
                                news_list.append(News(source: new[0], title: new[1], link: new[2]))
                            }

                            UserDefaults.standard.set(news, forKey: "news")

                            entries = [SimpleEntry(date: Date(), news: news_list)]
                            let timeline = Timeline(entries: entries, policy: .after(next))
                            completion(timeline)
                            return
                        }
                    }
                }

            case .failure(let error):
                print(error.localizedDescription)
            }

            if let news = UserDefaults.standard.array(forKey: "news") as? [[String]] {
                var news_list = [News]()
                for new in news {
                    news_list.append(News(source: new[0], title: new[1], link: new[2]))
                }

                UserDefaults.standard.set(news, forKey: "news")
                entries = [SimpleEntry(date: Date(), news: news_list)]
                let timeline = Timeline(entries: entries, policy: .after(next))
                completion(timeline)
                return
            }

            entries = [SimpleEntry(date: Date(), news: [News(source: "Source 1", title: "Title 1", link: "https://apple.com"), News(source: "Source 2", title: "Title 2", link: "https://google.com")])]
            let timeline = Timeline(entries: entries, policy: .after(next))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let news: [News]
}

struct WidgetExtensionEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(.sRGB, red: 38/255, green: 52/255, blue: 101/255, opacity: 1)

            if entry.news.count > 1, let first = entry.news.first, let next = entry.news.last {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Latest News")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 3)
                        .padding(.vertical, 10)

                    Link(destination: URL(string: "widget://\(first.link)")!) {
                        Text(first.source)
                            .lineLimit(1)
                            .foregroundColor(.red)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 3)
                        Text(first.title)
                            .lineLimit(2)
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .frame(height: 32, alignment: .topLeading)
                            .padding(.horizontal, 3)
                            .padding(.bottom, 5)
                    }

                    Link(destination: URL(string: "widget://\(next.link)")!) {
                        Text(next.source)
                            .lineLimit(1)
                            .foregroundColor(.red)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 3)
                        Text(next.title)
                            .lineLimit(2)
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 3)
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .leading
                )
            } else if let first = entry.news.first {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Latest News")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                    Link(destination: URL(string: "widget://\(first.link)")!) {
                        Text(first.source)
                            .lineLimit(1)
                            .foregroundColor(.red)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .padding(.horizontal)
                        Text(first.title)
                            .lineLimit(5)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            } else {
                Text("Oh Well. Something went wrong!")
            }
        }
    }
}

@main
struct WidgetExtension: Widget {
    let kind: String = "latestNews"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Latest News")
        .description("This widget shows you the latest news.")
        .supportedFamilies([.systemMedium])
    }
}
