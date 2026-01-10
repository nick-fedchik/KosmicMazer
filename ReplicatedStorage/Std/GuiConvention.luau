--[[
================================================================================
KOSMICMAZER — GUI Convention
================================================================================
Мета: Уніфікований підхід до GUI у стилі Windows 95
Версія: 4.0
Статус: ACTIVE
Last Updated: 2026-01-10

Усі UI елементи гри МАЮТЬ дотримуватися стилю Windows 95 для консистентності
та унікальної естетики гри.

================================================================================
📐 1. КОЛЬОРОВА ГАМА WINDOWS 95
================================================================================

1.1. Базові кольори системи:
────────────────────────────────────────────────────────────────────────────
• Системний сірий (Background):      RGB(192, 192, 192) | #C0C0C0
• Світло-сірий (Highlight):          RGB(223, 223, 223) | #DFDFDF
• Темно-сірий (Shadow):              RGB(128, 128, 128) | #808080
• Чорний (Border/Text):              RGB(0, 0, 0)       | #000000
• Білий (Highlight Border):          RGB(255, 255, 255) | #FFFFFF

1.2. Кольори вікон:
────────────────────────────────────────────────────────────────────────────
• Active Title Bar:                  RGB(0, 0, 128)     | #000080 (синій)
• Active Title Text:                 RGB(255, 255, 255) | #FFFFFF (білий)
• Inactive Title Bar:                RGB(128, 128, 128) | #808080 (сірий)
• Inactive Title Text:               RGB(192, 192, 192) | #C0C0C0 (світло-сірий)

1.3. Кольори кнопок:
────────────────────────────────────────────────────────────────────────────
• Normal State:                      RGB(192, 192, 192) | #C0C0C0
• Hover (Highlight):                 RGB(223, 223, 223) | #DFDFDF
• Pressed (Shadow):                  RGB(128, 128, 128) | #808080
• Disabled:                          RGB(192, 192, 192) | #C0C0C0 (text: #808080)
• Default Button Border:             RGB(0, 0, 0)       | #000000 (товста рамка)

1.4. Системні кольори повідомлень:
────────────────────────────────────────────────────────────────────────────
• Success:                           RGB(0, 128, 0)     | #008000 (зелений)
• Error:                             RGB(255, 0, 0)     | #FF0000 (червоний)
• Warning:                           RGB(255, 255, 0)   | #FFFF00 (жовтий)
• Info:                              RGB(0, 0, 255)     | #0000FF (синій)

1.5. Кольори елементів управління:
────────────────────────────────────────────────────────────────────────────
• TextBox Background:                RGB(255, 255, 255) | #FFFFFF (білий)
• TextBox Border:                    RGB(0, 0, 0)       | #000000 (чорний)
• TextBox Text:                      RGB(0, 0, 0)       | #000000 (чорний)
• ScrollBar Background:              RGB(192, 192, 192) | #C0C0C0
• ScrollBar Thumb:                   RGB(192, 192, 192) | #C0C0C0 (з 3D ефектом)

================================================================================
🪟 2. СТРУКТУРА ВІКНА
================================================================================

2.1. Базова структура вікна:
────────────────────────────────────────────────────────────────────────────
WindowFrame (Frame)
├── TitleBar (Frame)                    -- Заголовок вікна
│   ├── TitleLabel (TextLabel)          -- Назва вікна
│   ├── MinimizeButton (TextButton)     -- Кнопка мінімізації (опціонально)
│   ├── MaximizeButton (TextButton)     -- Кнопка максимізації (опціонально)
│   └── CloseButton (TextButton)        -- Кнопка закриття
├── ContentFrame (Frame)                -- Основний вміст
│   └── [Ваш контент тут]
└── StatusBar (Frame)                   -- Статус бар (опціонально)
    └── StatusLabel (TextLabel)

2.2. TitleBar (Заголовок вікна):
────────────────────────────────────────────────────────────────────────────
• Висота: 20-25 pixels
• BackgroundColor3: RGB(0, 0, 128) - синій для активного вікна
• BorderSizePixel: 0
• Шрифт заголовку: SourceSansBold, 14px
• Колір тексту: RGB(255, 255, 255) - білий

Приклад коду:
```lua
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 128) -- Active title bar
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -75, 1, 0) -- Залишити місце для кнопок
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Window Title"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
```

2.3. Кнопки управління вікном:
────────────────────────────────────────────────────────────────────────────
Розміщення: Права частина TitleBar
Розмір кнопки: 20x20 pixels (або висота TitleBar - 2px)
Відступ між кнопками: 2px
Порядок (зправа наліво): Close → Maximize → Minimize

Close Button:
• Текст: "×" (multiplication sign)
• TextSize: 18
• BackgroundColor3: RGB(192, 192, 192)
• Hover: RGB(223, 223, 223)
• Pressed: RGB(255, 0, 0) - червоний

Minimize Button:
• Текст: "_" (підкреслення)
• TextSize: 14
• BackgroundColor3: RGB(192, 192, 192)

Maximize Button:
• Текст: "□" (white square) або "▢"
• TextSize: 14
• BackgroundColor3: RGB(192, 192, 192)

Приклад коду:
```lua
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 23, 0, 23)
closeButton.Position = UDim2.new(1, -25, 0, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeButton.BorderSizePixel = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

-- Hover effect
closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(223, 223, 223)
end)
closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
end)
```

2.4. ContentFrame (Основний вміст):
────────────────────────────────────────────────────────────────────────────
• BackgroundColor3: RGB(192, 192, 192) - системний сірий
• BorderColor3: RGB(0, 0, 0) - чорна рамка
• BorderSizePixel: 2
• Padding: 5-10 pixels від країв

2.5. Рамка вікна (3D бордюр):
────────────────────────────────────────────────────────────────────────────
Windows 95 використовує рельєфний 3D ефект для вікон:
• Верхня та ліва сторони: RGB(255, 255, 255) - білий (світло)
• Нижня та права сторони: RGB(128, 128, 128) - темно-сірий (тінь)

Для імітації 3D ефекту в Roblox:
```lua
-- Outer border (темна тінь)
windowFrame.BorderColor3 = Color3.fromRGB(128, 128, 128)
windowFrame.BorderSizePixel = 2

-- Inner highlight (можна додати UIStroke для додаткового шару)
local highlight = Instance.new("UIStroke")
highlight.Color = Color3.fromRGB(255, 255, 255)
highlight.Thickness = 1
highlight.Parent = windowFrame
```

================================================================================
🔘 3. КНОПКИ
================================================================================

3.1. Стандартна кнопка:
────────────────────────────────────────────────────────────────────────────
• Розмір: Мінімум 75x23 pixels
• BackgroundColor3: RGB(192, 192, 192)
• BorderColor3: RGB(0, 0, 0)
• BorderSizePixel: 1
• Шрифт: SourceSans, 14px
• TextColor3: RGB(0, 0, 0)
• Padding: 5px з усіх боків

3.2. Стани кнопки:
────────────────────────────────────────────────────────────────────────────
Normal (звичайний стан):
• BackgroundColor3: RGB(192, 192, 192)
• Рельєфна рамка (3D effect)

Hover (наведення):
• BackgroundColor3: RGB(223, 223, 223) - світліше

Pressed (натиснута):
• BackgroundColor3: RGB(128, 128, 128) - темніше
• Текст зміщується на 1px вправо та вниз (ефект натискання)

Disabled (вимкнена):
• BackgroundColor3: RGB(192, 192, 192)
• TextColor3: RGB(128, 128, 128) - сірий текст
• Немає реакції на наведення/натискання

3.3. Default button (кнопка за замовчуванням):
────────────────────────────────────────────────────────────────────────────
Кнопка, яка активується при натисканні Enter (наприклад, "OK"):
• Додаткова товста чорна рамка (BorderSizePixel = 2)
• Може мати легкий синій відтінок для виділення

3.4. Приклад коду кнопки з 3D ефектом:
────────────────────────────────────────────────────────────────────────────
```lua
local button = Instance.new("TextButton")
button.Name = "StandardButton"
button.Size = UDim2.new(0, 75, 0, 23)
button.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 1
button.Text = "OK"
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.Font = Enum.Font.SourceSans
button.TextSize = 14

-- Створення 3D ефекту за допомогою UIStroke
local highlightStroke = Instance.new("UIStroke")
highlightStroke.Color = Color3.fromRGB(255, 255, 255)
highlightStroke.Thickness = 1
highlightStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
highlightStroke.Parent = button

local shadowStroke = Instance.new("UIStroke")
shadowStroke.Color = Color3.fromRGB(128, 128, 128)
shadowStroke.Thickness = 1
shadowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
shadowStroke.Parent = button

-- Hover effect
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(223, 223, 223)
end)

button.MouseLeave:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
end)

-- Pressed effect
button.MouseButton1Down:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
    button.Position = button.Position + UDim2.new(0, 1, 0, 1) -- Shift down/right
end)

button.MouseButton1Up:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
    button.Position = button.Position - UDim2.new(0, 1, 0, 1) -- Reset position
end)
```

================================================================================
📝 4. ТЕКСТОВІ ПОЛЯ (TextBox)
================================================================================

4.1. Стандартне текстове поле:
────────────────────────────────────────────────────────────────────────────
• BackgroundColor3: RGB(255, 255, 255) - білий фон
• BorderColor3: RGB(0, 0, 0) - чорна рамка
• BorderSizePixel: 1
• TextColor3: RGB(0, 0, 0) - чорний текст
• Font: SourceSans, 14px
• Padding: 2-3px з усіх боків
• PlaceholderColor3: RGB(128, 128, 128) - сірий placeholder

4.2. Стани текстового поля:
────────────────────────────────────────────────────────────────────────────
Normal: Білий фон, чорна рамка
Focused: Білий фон, товстіша рамка (BorderSizePixel = 2)
Disabled: RGB(192, 192, 192) - сірий фон, чорна рамка

4.3. Multiline TextBox (багаторядкове):
────────────────────────────────────────────────────────────────────────────
• TextWrapped = true
• TextYAlignment = Enum.TextYAlignment.Top
• MultiLine = true
• Часто комбінується з ScrollingFrame

Приклад:
```lua
local textBox = Instance.new("TextBox")
textBox.Name = "InputField"
textBox.Size = UDim2.new(0, 200, 0, 20)
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
textBox.BorderSizePixel = 1
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.PlaceholderColor3 = Color3.fromRGB(128, 128, 128)
textBox.Font = Enum.Font.SourceSans
textBox.TextSize = 14
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.PlaceholderText = "Enter text..."

-- Focus effect
textBox.Focused:Connect(function()
    textBox.BorderSizePixel = 2
end)

textBox.FocusLost:Connect(function()
    textBox.BorderSizePixel = 1
end)
```

================================================================================
✅ 5. CHECKBOXES ТА RADIO BUTTONS
================================================================================

5.1. Checkbox (прапорець):
────────────────────────────────────────────────────────────────────────────
• Розмір: 13x13 pixels
• BackgroundColor3: RGB(255, 255, 255) - білий
• BorderColor3: RGB(0, 0, 0) - чорна рамка
• BorderSizePixel: 1
• Checked: Текст "✓" (checkmark) або ImageLabel з галочкою
• Label: TextLabel праворуч від checkbox

Приклад:
```lua
local checkbox = Instance.new("TextButton")
checkbox.Name = "Checkbox"
checkbox.Size = UDim2.new(0, 13, 0, 13)
checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
checkbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
checkbox.BorderSizePixel = 1
checkbox.Text = "" -- Пусто для unchecked
checkbox.TextColor3 = Color3.fromRGB(0, 0, 0)
checkbox.Font = Enum.Font.SourceSansBold
checkbox.TextSize = 12

local isChecked = false
checkbox.MouseButton1Click:Connect(function()
    isChecked = not isChecked
    checkbox.Text = isChecked and "✓" or ""
end)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 100, 0, 13)
label.Position = UDim2.new(0, 18, 0, 0) -- 13px checkbox + 5px spacing
label.BackgroundTransparency = 1
label.Text = "Option"
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.Font = Enum.Font.SourceSans
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
```

5.2. Radio Button (перемикач):
────────────────────────────────────────────────────────────────────────────
Аналогічно до checkbox, але:
• Форма: Круглий замість квадратного (використати ImageLabel або UICorner)
• Checked: Заповнена чорна крапка всередині
• Поведінка: Тільки один radio button може бути обраний в групі

================================================================================
📜 6. SCROLLBAR ТА SCROLLING FRAME
================================================================================

6.1. ScrollingFrame:
────────────────────────────────────────────────────────────────────────────
• BackgroundColor3: RGB(192, 192, 192)
• BorderColor3: RGB(0, 0, 0)
• BorderSizePixel: 1
• ScrollBarThickness: 17 (стандартна товщина ScrollBar в Win95)
• ScrollBarImageColor3: RGB(192, 192, 192)
• ScrollBarImageTransparency: 0

6.2. ScrollBar стилізація:
────────────────────────────────────────────────────────────────────────────
Windows 95 має характерні 3D кнопки зі стрілками вгору/вниз на ScrollBar.

Для кращої імітації рекомендується:
• Використовувати ImageLabel для стрілок (▲ ▼)
• Thumb (повзунок): RGB(192, 192, 192) з 3D ефектом

================================================================================
🔔 7. ПОВІДОМЛЕННЯ ТА ДІАЛОГИ
================================================================================

7.1. Message Box (вікно повідомлення):
────────────────────────────────────────────────────────────────────────────
Структура:
• Титульний бар з іконкою та текстом
• Іконка повідомлення (ліворуч): ⚠️ Warning, ❌ Error, ℹ️ Info, ✅ Success
• Текст повідомлення (центр)
• Кнопки внизу: "OK", "Cancel", "Yes", "No" тощо

Типи іконок:
• Error (Критична помилка): ❌ або червоне коло з хрестиком
• Warning (Попередження): ⚠️ або жовтий трикутник з оклик знаком
• Info (Інформація): ℹ️ або синє коло з "i"
• Question (Питання): ❓ або синє коло з "?"
• Success (Успіх): ✅ або зелена галочка

7.2. Toast Notification (швидке сповіщення):
────────────────────────────────────────────────────────────────────────────
Малі сповіщення, які з'являються в куті екрану:
• Розмір: 200x50 pixels
• Позиція: Правий нижній кут екрану
• Фон: Системний сірий RGB(192, 192, 192)
• Рамка: Чорна, 1px
• Іконка статусу (ліворуч)
• Текст (праворуч від іконки)
• Автоматично зникає через 3-5 секунд

Кольори фону залежно від типу:
• Success: RGB(0, 128, 0) з білим текстом
• Error: RGB(255, 0, 0) з білим текстом
• Warning: RGB(255, 255, 0) з чорним текстом
• Info: RGB(0, 0, 255) з білим текстом

================================================================================
📋 8. СПИСКИ ТА ТАБЛИЦІ
================================================================================

8.1. ListBox (список):
────────────────────────────────────────────────────────────────────────────
• BackgroundColor3: RGB(255, 255, 255) - білий фон
• BorderColor3: RGB(0, 0, 0)
• BorderSizePixel: 1
• Елементи списку:
  - Висота: 20-25 pixels
  - Normal: Білий фон, чорний текст
  - Selected: RGB(0, 0, 128) фон (синій), білий текст
  - Hover: RGB(223, 223, 223) фон (світло-сірий)

8.2. Grid/Table (таблиця):
────────────────────────────────────────────────────────────────────────────
• Header (заголовки стовпців):
  - BackgroundColor3: RGB(192, 192, 192)
  - TextColor3: RGB(0, 0, 0)
  - BorderSizePixel: 1
  - Font: SourceSansBold

• Rows (рядки):
  - Alternating colors: RGB(255, 255, 255) і RGB(240, 240, 240) (легкий сірий)
  - Selected row: RGB(0, 0, 128) з білим текстом

================================================================================
🎨 9. ІКОНКИ ТА ГРАФІКА
================================================================================

9.1. Системні іконки:
────────────────────────────────────────────────────────────────────────────
Windows 95 використовує пікселізовані іконки 16x16 або 32x32:
• Розмір: 16x16 для малих іконок, 32x32 для великих
• Стиль: Pixel art, обмежена кольорова палітра (256 кольорів)
• Формат: ImageLabel з прозорістю

Типові іконки:
• Folder: Жовта тека
• File: Білий документ з загнутим кутом
• Warning: Жовтий трикутник з оклик знаком
• Error: Червоне коло з білим хрестиком
• Info: Синє коло з білою літерою "i"

9.2. Курсори:
────────────────────────────────────────────────────────────────────────────
• Normal: Стрілка
• Busy: Пісочний годинник
• Text: I-beam (вертикальна лінія)
• Hand: Рука з вказівним пальцем (для посилань/кнопок)

Roblox не дозволяє змінювати курсор напряму, але можна використати ImageLabel
для імітації custom cursor.

================================================================================
📏 10. РОЗМІРИ ТА ВІДСТУПИ
================================================================================

10.1. Стандартні розміри:
────────────────────────────────────────────────────────────────────────────
• Кнопка: 75x23 pixels (мінімум)
• Текстове поле: Висота 20-22 pixels
• Checkbox/Radio: 13x13 pixels
• Іконка: 16x16 або 32x32 pixels
• Title Bar: 20-25 pixels висота
• Status Bar: 20-25 pixels висота
• ScrollBar: 17 pixels товщина

10.2. Відступи (Padding):
────────────────────────────────────────────────────────────────────────────
• Між елементами: 5-10 pixels
• Від країв вікна: 10 pixels
• Між кнопками: 5 pixels
• Padding текстових полів: 2-3 pixels

10.3. Шрифти та розміри тексту:
────────────────────────────────────────────────────────────────────────────
• Основний текст: SourceSans, 14px
• Заголовки вікон: SourceSansBold, 14px
• Кнопки: SourceSans, 14px
• Дрібний текст (Status Bar): SourceSans, 12px
• Великі заголовки: SourceSansBold, 16-18px

================================================================================
🧩 11. ІМЕНУВАННЯ ЕЛЕМЕНТІВ UI
================================================================================

11.1. ScreenGui:
────────────────────────────────────────────────────────────────────────────
Формат: <Purpose>Gui
Приклади:
• TeleportationGui
• InventoryGui
• SettingsGui
• LoginGui

11.2. Frames:
────────────────────────────────────────────────────────────────────────────
Формат: <Purpose>Frame або <Purpose>Panel
Приклади:
• MainFrame, ContentFrame, TitleBar
• InventoryPanel, SettingsPanel

11.3. Кнопки:
────────────────────────────────────────────────────────────────────────────
Формат: <Action>Button
Приклади:
• CloseButton, MinimizeButton, MaximizeButton
• ConfirmButton, CancelButton
• TeleportButton, ScanButton

11.4. Текстові елементи:
────────────────────────────────────────────────────────────────────────────
Формат: <Purpose>Label або <Purpose>Text
Приклади:
• TitleLabel, StatusLabel
• DescriptionText, MessageText

11.5. Текстові поля:
────────────────────────────────────────────────────────────────────────────
Формат: <Purpose>Input або <Purpose>TextBox
Приклади:
• NameInput, SearchInput
• MessageTextBox, DescriptionTextBox

================================================================================
🔧 12. UX ПРАВИЛА ТА BEST PRACTICES
================================================================================

12.1. Загальні правила:
────────────────────────────────────────────────────────────────────────────
• GUI НЕ МАЄ створювати RemoteEvents
• Всі RemoteEvents очікуються через WaitForChild або RemoteEventsRegistry
• Стан UI має синхронізуватися з сервером (не лише локально)
• Всі дії користувача мають давати візуальний feedback
• Критичні дії мають підтверджувальні діалоги

12.2. Доступність:
────────────────────────────────────────────────────────────────────────────
• Мінімальний розмір тексту: 12px
• Високий контраст між текстом та фоном
• Кнопки мають чітко видимі межі
• Hover states для інтерактивних елементів

12.3. Performance:
────────────────────────────────────────────────────────────────────────────
• Використовувати UIListLayout замість ручного позиціонування
• Уникати надмірної кількості UIStroke/UIGradient
• Ледаче завантаження для великих списків
• Пулінг для часто створюваних/видаляємих UI елементів

12.4. Responsive Design:
────────────────────────────────────────────────────────────────────────────
• Використовувати UDim2 з Scale для адаптивності
• UIAspectRatioConstraint для збереження пропорцій
• UISizeConstraint для обмеження мінімальних/максимальних розмірів
• Тестувати на різних розмірах екранів

================================================================================
📚 13. ПРИКЛАДИ КОДУ
================================================================================

13.1. Повне вікно в стилі Windows 95:
────────────────────────────────────────────────────────────────────────────
```lua
-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "ExampleGui"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Window Frame
local windowFrame = Instance.new("Frame")
windowFrame.Name = "MainWindow"
windowFrame.Size = UDim2.new(0, 400, 0, 300)
windowFrame.Position = UDim2.new(0.5, -200, 0.5, -150) -- Centered
windowFrame.BackgroundColor3 = Color3.fromRGB(192, 192, 192) -- System gray
windowFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
windowFrame.BorderSizePixel = 2
windowFrame.Parent = gui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 128) -- Active title
titleBar.BorderSizePixel = 0
titleBar.Parent = windowFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -75, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "My Window"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 23, 0, 23)
closeButton.Position = UDim2.new(1, -25, 0, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeButton.BorderSizePixel = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -45) -- Leave space for title and padding
contentFrame.Position = UDim2.new(0, 10, 0, 30)
contentFrame.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = windowFrame

-- Add your content here...
```

13.2. Кнопка з 3D ефектом та hover:
────────────────────────────────────────────────────────────────────────────
Див. секцію 3.4 вище

13.3. Toast Notification:
────────────────────────────────────────────────────────────────────────────
```lua
local function showToast(message, notificationType)
    local types = {
        success = Color3.fromRGB(0, 128, 0),
        error = Color3.fromRGB(255, 0, 0),
        warning = Color3.fromRGB(255, 255, 0),
        info = Color3.fromRGB(0, 0, 255)
    }

    local bgColor = types[notificationType] or types.info

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 200, 0, 50)
    toast.Position = UDim2.new(1, -210, 1, -60) -- Bottom-right
    toast.BackgroundColor3 = bgColor
    toast.BorderColor3 = Color3.fromRGB(0, 0, 0)
    toast.BorderSizePixel = 1
    toast.Parent = game.Players.LocalPlayer.PlayerGui:FindFirstChildOfClass("ScreenGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = notificationType == "warning"
        and Color3.fromRGB(0, 0, 0)
        or Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextWrapped = true
    label.Parent = toast

    -- Auto-dismiss after 3 seconds
    task.delay(3, function()
        toast:Destroy()
    end)
end
```

================================================================================
✅ 14. CHECKLIST ДЛЯ РОЗРОБНИКІВ
================================================================================

Перед створенням нового UI, переконайтеся:

□ Використано правильну кольорову палітру Windows 95
□ Title Bar має синій фон RGB(0, 0, 128) для активного вікна
□ Кнопки мають системний сірий фон RGB(192, 192, 192)
□ Рамки чорні RGB(0, 0, 0)
□ Текстові поля мають білий фон RGB(255, 255, 255)
□ Hover/Pressed стани реалізовані для всіх інтерактивних елементів
□ 3D ефект для кнопок та рамок (UIStroke або shadows)
□ Іменування елементів відповідає конвенції
□ RemoteEvents не створюються в UI, тільки очікуються
□ Тестовано на різних розмірах екрану
□ Шрифти: SourceSans (14px для основного тексту)
□ Відступи: 5-10px між елементами, 10px від країв
□ Feedback для всіх дій користувача

================================================================================
🔄 CHANGELOG
================================================================================

Version 4.0 (2026-01-10):
- Повністю переписано конвенцію з детальними правилами Windows 95
- Додано точну кольорову палітру з RGB значеннями
- Детальна структура вікон та елементів управління
- Приклади коду для всіх основних компонентів UI
- Додано секції про іконки, розміри, відступи
- Checklist для розробників
- Best practices для performance та accessibility

Version 3.7:
- Базова версія з загальними правилами стилю

================================================================================
END OF GUI CONVENTION v4.0
================================================================================
]]

local module = {}
module.VERSION = "4.0"
module.STATUS = "ACTIVE"

-- Кольорова палітра Windows 95 (для швидкого доступу в коді)
module.Colors = {
	-- Системні кольори
	SystemGray = Color3.fromRGB(192, 192, 192),
	HighlightGray = Color3.fromRGB(223, 223, 223),
	ShadowGray = Color3.fromRGB(128, 128, 128),
	Black = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),

	-- Кольори вікон
	ActiveTitleBar = Color3.fromRGB(0, 0, 128),
	ActiveTitleText = Color3.fromRGB(255, 255, 255),
	InactiveTitleBar = Color3.fromRGB(128, 128, 128),
	InactiveTitleText = Color3.fromRGB(192, 192, 192),

	-- Повідомлення
	Success = Color3.fromRGB(0, 128, 0),
	Error = Color3.fromRGB(255, 0, 0),
	Warning = Color3.fromRGB(255, 255, 0),
	Info = Color3.fromRGB(0, 0, 255),
}

-- Стандартні розміри
module.Sizes = {
	ButtonHeight = 23,
	ButtonMinWidth = 75,
	TitleBarHeight = 25,
	StatusBarHeight = 20,
	ScrollBarThickness = 17,
	CheckboxSize = 13,
	IconSmall = 16,
	IconLarge = 32,
}

-- Стандартні відступи
module.Spacing = {
	ElementSpacing = 5,
	WindowPadding = 10,
	ButtonSpacing = 5,
	TextPadding = 3,
}

return module
