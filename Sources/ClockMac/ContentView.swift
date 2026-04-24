import SwiftUI

private enum ClaudeTheme {
    static let background = Color(red: 0.96, green: 0.95, blue: 0.92)      // #F5F2EB bone
    static let surface    = Color(red: 0.93, green: 0.91, blue: 0.86)      // subtle divider wash
    static let accent     = Color(red: 0.85, green: 0.46, blue: 0.34)      // #D97757 crail
    static let accentHover = Color(red: 0.78, green: 0.40, blue: 0.29)
    static let ink        = Color(red: 0.17, green: 0.16, blue: 0.15)      // #2C2928
    static let inkMuted   = Color(red: 0.45, green: 0.43, blue: 0.40)
    static let hairline   = Color(red: 0.80, green: 0.76, blue: 0.70)
}

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
        VStack(spacing: 18) {
            HStack(alignment: .top, spacing: 18) {
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

            HStack(spacing: 8) {
                Button(action: toggleEditing) {
                    Text(isEditing ? "Готово" : "Редактировать")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .foregroundStyle(Color.white)
                        .background(ClaudeTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                if isEditing || !Calendar.current.isDate(displayed, equalTo: now, toGranularity: .minute) {
                    Button {
                        displayed = Date()
                        now = displayed
                    } label: {
                        Text("Сейчас")
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .foregroundStyle(ClaudeTheme.ink)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(ClaudeTheme.hairline, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(width: 560)
        .background(ClaudeTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            .fill(ClaudeTheme.hairline)
            .frame(width: 1, height: 86)
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
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(ClaudeTheme.ink)
                Text(subtitle.uppercased())
                    .font(.system(size: 9, weight: .medium, design: .default))
                    .tracking(1.2)
                    .foregroundStyle(ClaudeTheme.inkMuted)
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
                .frame(maxWidth: 110)
            } else {
                Text(timeString)
                    .font(.system(size: 38, weight: .regular, design: .serif))
                    .monospacedDigit()
                    .foregroundStyle(ClaudeTheme.ink)
            }

            Text(dateString)
                .font(.system(size: 11, design: .serif))
                .italic()
                .foregroundStyle(ClaudeTheme.inkMuted)
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
