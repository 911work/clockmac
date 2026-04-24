import SwiftUI

struct ContentView: View {
    @State private var now = Date()
    @State private var displayed = Date()
    @State private var isEditing = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let localTZ = TimeZone.current
    private let moscowTZ = TimeZone(identifier: "Europe/Moscow")!
    private let lisbonTZ = TimeZone(identifier: "Europe/Lisbon")!

    private var localTitle: String {
        let id = TimeZone.current.identifier
        let city = id.split(separator: "/").last.map(String.init) ?? id
        return city.replacingOccurrences(of: "_", with: " ")
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                ClockColumn(
                    title: localTitle,
                    subtitle: "локальное",
                    timeZone: localTZ,
                    date: $displayed,
                    isEditing: isEditing
                )
                divider
                ClockColumn(
                    title: "Москва",
                    subtitle: "MSK",
                    timeZone: moscowTZ,
                    date: $displayed,
                    isEditing: isEditing
                )
                divider
                ClockColumn(
                    title: "Лиссабон",
                    subtitle: "WET/WEST",
                    timeZone: lisbonTZ,
                    date: $displayed,
                    isEditing: isEditing
                )
            }

            HStack(spacing: 10) {
                Button(action: toggleEditing) {
                    Label(isEditing ? "Готово" : "Редактировать",
                          systemImage: isEditing ? "checkmark.circle" : "pencil")
                }
                .buttonStyle(.borderedProminent)

                if isEditing || !Calendar.current.isDate(displayed, equalTo: now, toGranularity: .minute) {
                    Button {
                        displayed = Date()
                        now = displayed
                    } label: {
                        Label("Сейчас", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .font(.callout)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(width: 380)
        .onAppear {
            displayed = now
        }
        .onReceive(timer) { _ in
            now = Date()
            if !isEditing {
                displayed = now
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 1, height: 70)
    }

    private func toggleEditing() {
        if isEditing {
            isEditing = false
            displayed = Date()
            now = displayed
        } else {
            isEditing = true
        }
    }
}

private struct ClockColumn: View {
    let title: String
    let subtitle: String
    let timeZone: TimeZone
    @Binding var date: Date
    let isEditing: Bool

    var body: some View {
        VStack(spacing: 4) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }

            if isEditing {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.field)
                .labelsHidden()
                .environment(\.timeZone, timeZone)
                .environment(\.locale, Locale(identifier: "ru_RU"))
                .frame(maxWidth: 90)
            } else {
                Text(timeString)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }

            Text(dateString)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var timeString: String {
        let f = DateFormatter()
        f.timeZone = timeZone
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.timeZone = timeZone
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEE, d MMM"
        return f.string(from: date)
    }
}
