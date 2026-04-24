import SwiftUI

private enum ClaudeTheme {
    static let tint       = Color(red: 0.96, green: 0.95, blue: 0.92).opacity(0.35) // cream veil
    static let accent     = Color(red: 0.85, green: 0.46, blue: 0.34)                // #D97757 crail
    static let ink        = Color(red: 0.17, green: 0.16, blue: 0.15)
    static let inkMuted   = Color(red: 0.45, green: 0.43, blue: 0.40)
    static let hairline   = Color(red: 0.80, green: 0.76, blue: 0.70).opacity(0.55)
}

struct ContentView: View {
    @AppStorage("tzIdsCSV") private var tzIdsCSV: String = ""
    @State private var timeZoneIds: [String] = []

    @State private var now = Date()
    @State private var displayed = Date()
    @State private var isEditing = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var isOffRealTime: Bool {
        !Calendar.current.isDate(displayed, equalTo: now, toGranularity: .minute)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(Array(timeZoneIds.enumerated()), id: \.offset) { idx, _ in
                        ClockColumn(
                            timeZoneId: Binding(
                                get: { timeZoneIds[idx] },
                                set: { timeZoneIds[idx] = $0 }
                            ),
                            date: $displayed,
                            isEditing: isEditing
                        )
                        if idx < timeZoneIds.count - 1 {
                            Rectangle()
                                .fill(ClaudeTheme.hairline)
                                .frame(width: 1, height: 86)
                        }
                    }
                }
                .padding(.top, 18)

                if isEditing || isOffRealTime {
                    Button {
                        displayed = Date()
                        now = displayed
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 10, weight: .medium))
                            Text("Сейчас")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(ClaudeTheme.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(Color.white.opacity(0.35))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .stroke(ClaudeTheme.hairline, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)

            IconButton(
                systemName: isEditing ? "checkmark" : "pencil",
                active: isEditing
            ) {
                toggleEditing()
            }
            .padding(.top, 10)
            .padding(.trailing, 12)
        }
        .frame(width: 560)
        .background(ClaudeTheme.tint)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .animation(.easeInOut(duration: 0.18), value: isEditing)
        .animation(.easeInOut(duration: 0.18), value: isOffRealTime)
        .onAppear {
            loadTimeZoneIds()
            displayed = now
        }
        .onReceive(timer) { _ in
            now = Date()
            if !isEditing {
                displayed = now
            }
        }
        .onChange(of: timeZoneIds) { _ in
            tzIdsCSV = timeZoneIds.joined(separator: ",")
        }
    }

    private func loadTimeZoneIds() {
        if tzIdsCSV.isEmpty {
            timeZoneIds = [TimeZone.current.identifier, "Europe/Moscow", "Europe/Lisbon"]
        } else {
            let parsed = tzIdsCSV.split(separator: ",").map(String.init)
            timeZoneIds = parsed.count == 3 ? parsed
                : [TimeZone.current.identifier, "Europe/Moscow", "Europe/Lisbon"]
        }
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

private struct IconButton: View {
    let systemName: String
    let active: Bool
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(active ? Color.white : ClaudeTheme.ink)
                .frame(width: 22, height: 22)
                .background(
                    Circle().fill(
                        active
                            ? ClaudeTheme.accent
                            : (hovering ? Color.white.opacity(0.55) : Color.white.opacity(0.25))
                    )
                )
                .overlay(
                    Circle().stroke(ClaudeTheme.hairline, lineWidth: active ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}

private struct ClockColumn: View {
    @Binding var timeZoneId: String
    @Binding var date: Date
    let isEditing: Bool

    @State private var showPicker = false

    private var timeZone: TimeZone {
        TimeZone(identifier: timeZoneId) ?? .current
    }

    var body: some View {
        VStack(spacing: 8) {
            Button {
                showPicker.toggle()
            } label: {
                VStack(spacing: 2) {
                    Text(cityName(for: timeZoneId))
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(ClaudeTheme.ink)
                    Text(offsetLabel)
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1.2)
                        .foregroundStyle(ClaudeTheme.inkMuted)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPicker, arrowEdge: .top) {
                TimeZonePicker(selected: $timeZoneId) {
                    showPicker = false
                }
                .frame(width: 280, height: 340)
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

    private var offsetLabel: String {
        let seconds = timeZone.secondsFromGMT(for: date)
        let sign = seconds >= 0 ? "+" : "−"
        let abs = Swift.abs(seconds)
        let h = abs / 3600
        let m = (abs % 3600) / 60
        return m == 0 ? "GMT\(sign)\(h)" : String(format: "GMT%@%d:%02d", sign, h, m)
    }

    private func cityName(for id: String) -> String {
        let city = id.split(separator: "/").last.map(String.init) ?? id
        return city.replacingOccurrences(of: "_", with: " ")
    }
}

private struct TimeZonePicker: View {
    @Binding var selected: String
    let onPick: () -> Void
    @State private var query = ""

    private var all: [String] {
        TimeZone.knownTimeZoneIdentifiers.sorted()
    }

    private var filtered: [String] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                TextField("Поиск города…", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filtered, id: \.self) { id in
                        TimeZoneRow(id: id, isSelected: id == selected) {
                            selected = id
                            onPick()
                        }
                    }
                }
            }
        }
    }
}

private struct TimeZoneRow: View {
    let id: String
    let isSelected: Bool
    let action: () -> Void
    @State private var hovering = false

    private var city: String {
        let c = id.split(separator: "/").last.map(String.init) ?? id
        return c.replacingOccurrences(of: "_", with: " ")
    }

    private var region: String {
        let parts = id.split(separator: "/")
        return parts.count > 1 ? String(parts[0]) : ""
    }

    private var offsetLabel: String {
        guard let tz = TimeZone(identifier: id) else { return "" }
        let s = tz.secondsFromGMT()
        let sign = s >= 0 ? "+" : "−"
        let abs = Swift.abs(s)
        let h = abs / 3600
        let m = (abs % 3600) / 60
        return m == 0 ? "GMT\(sign)\(h)" : String(format: "GMT%@%d:%02d", sign, h, m)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(city)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                    if !region.isEmpty {
                        Text(region)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(offsetLabel)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ClaudeTheme.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(hovering ? Color.primary.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
