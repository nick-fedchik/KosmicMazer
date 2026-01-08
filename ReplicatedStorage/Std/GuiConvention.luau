--[[
================================================================================
KOSMICMAZER — GUI Convention
================================================================================
Мета: уніфікований підхід до GUI (Windows 3.1/95 стилістика).
Версія: 3.7
Статус: ACTIVE

1) Стиль
- Сірий фон, чорна рамка, плоскі кнопки.
- Заголовки у темно-синіх панелях.
- Крупні читабельні шрифти (SourceSans).

2) Іменування
- ScreenGui: <Name>Gui
- Frame: <Name>Frame / <Name>Panel
- TextLabel: <Name>Label
- TextButton: <Name>Button
- ImageLabel: <Name>Image

3) Повідомлення/Toast
- Стандартизовані кольори:
  Success: #27ae60
  Error:   #e74c3c
  Warning: #f1c40f
  Info:    #3498db

4) UX правила
- GUI не має створювати RemoteEvents.
- Всі RemoteEvents очікуються через WaitForChild.
- Стан UI має синхронізуватися з сервером (не лише локально).

================================================================================
]]

local module = {}
module.VERSION = "3.7"
module.STATUS = "ACTIVE"

return module