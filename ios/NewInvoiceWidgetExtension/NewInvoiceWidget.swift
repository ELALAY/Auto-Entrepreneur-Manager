import SwiftUI
import WidgetKit

private let widgetLaunchUrl = URL(string: "autoentinvoice://invoice/new?homeWidget=1")!

private let brandGradient = LinearGradient(
    colors: [
        Color(red: 15 / 255, green: 118 / 255, blue: 110 / 255),
        Color(red: 13 / 255, green: 148 / 255, blue: 136 / 255),
        Color(red: 20 / 255, green: 184 / 255, blue: 166 / 255),
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct NewInvoiceWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            brandGradient
            HStack(spacing: 6) {
                Image("LauncherIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .cornerRadius(6)
                Text("widget_title")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .widgetURL(widgetLaunchUrl)
    }
}

struct NewInvoiceWidget: Widget {
    let kind: String = "NewInvoiceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NewInvoiceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(Text("widget_display_name"))
        .description(Text("widget_description"))
        .supportedFamilies([.systemSmall])
    }
}

@main
struct NewInvoiceWidgetBundle: WidgetBundle {
    var body: some Widget {
        NewInvoiceWidget()
    }
}
