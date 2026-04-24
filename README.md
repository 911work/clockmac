# ClockMac

Маленький виджет-окошко для macOS с тремя часами: локальное, Москва, Лиссабон.
Нажимаешь «Редактировать» — можно поменять время в любой колонке, в остальных
оно пересчитается. Удобно прикинуть «если у меня 15:00, то во сколько у них».

## Требования

- macOS 13+
- Xcode 15+ или установленный Swift toolchain (`swift --version`)

## Запустить из терминала

```bash
swift run
```

Откроется окошко с тремя часовыми поясами. Оно «всплывает» поверх других окон
и двигается за любой участок фона.

## Собрать как `.app` бандл

Если хочется обычное приложение, которое можно таскать в Dock:

```bash
swift build -c release

APP="ClockMac.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/ClockMac "$APP/Contents/MacOS/ClockMac"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>ClockMac</string>
    <key>CFBundleIdentifier</key><string>local.clockmac</string>
    <key>CFBundleName</key><string>ClockMac</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

open "$APP"
```

## Как использовать

- По умолчанию все три колонки тикают в реальном времени.
- Кнопка «Редактировать» включает режим ручного ввода: в каждой колонке
  появляется маленький таймпикер. Меняешь часы/минуты в любой — остальные
  сразу показывают это же мгновение в своих зонах.
- «Сейчас» сбрасывает обратно на текущее время.
