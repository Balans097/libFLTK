
# 📖 Справочник по обёртке `nimFLTK.nim`

Полная привязка языка **Nim** к C++-библиотеке **FLTK 1.3/1.4**.  
Поддерживает сборку на **Linux** и **Windows (MSYS2/UCRT64)**.

---

## 🛠 Компиляция и зависимости

```bash
# Linux
sudo apt install libfltk1.3-dev   # или соберите FLTK 1.4 из исходников
# MSYS2 / Windows
pacman -S mingw-w64-ucrt-x86_64-fltk

# Сборка
nim cpp -d:release your_app.nim
```
> 💡 Флаги компилятора и линковщика подтягиваются автоматически через `fltk-config`. Утилита должна быть в `PATH`.

---

## 🧱 Типовая система

| Тип Nim | Описание |
|:---|:---|
| `FlColor`, `FlFont`, `FlFontsize`, `FlAlign`, `FlBoxtype`, `FlWhen` | Псевдонимы C-типов (`cuint`, `cint`) для констант FLTK |
| `ptr FlWidget`, `ptr FlWindow`, `ptr FlGroup`, ... | Непрозрачные указатели на C++-объекты |
| `FlCallback` | `proc(w: ptr FlWidget, data: pointer) {.cdecl.}` |
| `FlTimeoutHandler` / `FlIdleHandler` | `proc(data: pointer) {.cdecl.}` |

### 🔹 Приведение типов
Для вызова базовых методов (`setColor`, `redraw`, `callback` и т.д.) используется хелпер:
```nim
asWidget*(w: ptr FlXXX): ptr FlWidget
```
> ⚠️ Nim не выполняет автоматическое приведение `ptr` к родителю в `importcpp`. Всегда оборачивайте виджет в `asWidget()`, если передаёте его в базовую процедуру.

---

## 🎨 Константы

### Цвета (`FlColor`)
`FL_BLACK`, `FL_WHITE`, `FL_RED`, `FL_GREEN`, `FL_BLUE`, `FL_YELLOW`, `FL_CYAN`, `FL_MAGENTA`, `FL_GRAY`, `FL_BACKGROUND_COLOR`, `FL_SELECTION_COLOR` и палитра `FL_DARK*` / `FL_LIGHT*`.  
Функции смешивания: `fl_rgb_color(r,g,b)`, `fl_color_average(c1,c2,w)`, `fl_lighter(c)`, `fl_darker(c)`, `fl_contrast(fg,bg)`.

### Шрифты (`FlFont`)
`FL_HELVETICA`, `FL_COURIER`, `FL_TIMES`, `FL_SYMBOL`, `FL_SCREEN`, `FL_ZAPF_DINGBATS` и их модификаторы (`_BOLD`, `_ITALIC`).

### Выравнивание (`FlAlign`)
`FL_ALIGN_CENTER`, `FL_ALIGN_TOP`, `FL_ALIGN_BOTTOM`, `FL_ALIGN_LEFT`, `FL_ALIGN_RIGHT`, `FL_ALIGN_INSIDE`, `FL_ALIGN_CLIP`, `FL_ALIGN_WRAP`.  
Комбинирование через `or`: `FL_ALIGN_TOP_LEFT = FL_ALIGN_TOP or FL_ALIGN_LEFT`.

### Типы рамок (`FlBoxtype`)
`FL_NO_BOX`, `FL_FLAT_BOX`, `FL_UP_BOX`, `FL_DOWN_BOX`, `FL_ENGRAVED_BOX`, `FL_EMBOSSED_BOX`, `FL_BORDER_BOX`, `FL_SHADOW_BOX`, `FL_ROUNDED_BOX`, `FL_PLASTIC_*`, `FL_GTK_*` и др.

### События и триггеры
- **События:** `FL_PUSH`, `FL_RELEASE`, `FL_KEYBOARD`, `FL_FOCUS`, `FL_SHORTCUT`, `FL_CLOSE`...
- **Fl_When:** `FL_WHEN_NEVER`, `FL_WHEN_CHANGED`, `FL_WHEN_RELEASE`, `FL_WHEN_ENTER_KEY`...
- **Клавиши:** `FK_BackSpace`, `FK_Tab`, `FK_Enter`, `FK_Escape`, `FK_Fn` (`FK_F+1` = F1), модификаторы `FK_ShiftL`, `FK_ControlL`...

---

## 🔄 Главный цикл и настройки приложения

| Процедура | Описание |
|:---|:---|
| `flRun(): cint` | Запускает event loop. Возвращает при закрытии всех окон. |
| `flCheck(): cint` | Обрабатывает отложенные события без блокировки. |
| `flWait(): cint` | Блокирует до следующего события. |
| `flWaitFor(time: cdouble): cdouble` | Ожидает событие не дольше `time` секунд. |
| `flScheme(name: cstring): cint` | Устанавливает тему: `"gtk+"`, `"gleam"`, `"plastic"`, `"base"`. |
| `flBackground(r,g,b)`, `flForeground(...)`, `flBackground2(...)` | Глобальная палитра приложения. |
| `flAddTimeout(t, cb, data)`, `flRemoveTimeout(cb, data)` | Таймеры с однократным/периодическим вызовом. |
| `flAddIdle(cb, data)`, `flRemoveIdle(cb, data)` | Обработчики простоя (вызываются, когда очередь пуста). |

### Запросы событий
`flEventX()`, `flEventY()`, `flEventButton()`, `flEventKey()`, `flEventText()`, `flEventState()`, `flEventClicks()`, `flEventDx()`, `flEventDy()`.

---

## 🧩 Базовые методы виджетов (`Fl_Widget`)

Все методы принимают `ptr FlWidget` или приведённый через `asWidget()` указатель.

| Метод | Сигнатура | Описание |
|:---|:---|:---|
| Геометрия | `x(w)`, `y(w)`, `ww(w)`, `wh(w)` | Возвращают координаты и размеры |
| | `resize(w, x, y, ww, hh)` | Изменяет положение и размер |
| | `position(w, x, y)`, `size(w, ww, hh)` | Частные случаи `resize` |
| Метки | `label(w): cstring`, `setLabel(w, s)` | Текст на виджете |
| | `copyLabel(w, s)` | Копирует строку во внутреннюю память FLTK |
| | `labelfont(w)`, `setLabelfont(w, f)` | Шрифт метки |
| | `labelsize(w)`, `setLabelsize(w, s)` | Размер шрифта |
| | `labelcolor(w)`, `setLabelcolor(w, c)` | Цвет метки |
| Цвета | `color(w)`, `setColor(w, c)` | Основной цвет |
| | `selectionColor(w)`, `setSelectionColor(w, c)` | Цвет выделения/фона |
| Поведение | `callback(w, cb, data=nil)` | Привязка обработчика |
| | `when(w, v: FlWhen)`, `getWhen(w)` | Триггер колбэка |
| | `show(w)`, `hide(w)` | Видимость |
| | `activate(w)`, `deactivate(w)`, `active(w)` | Доступность |
| | `redraw(w)`, `redrawLabel(w)` | Принудительная перерисовка |
| | `tooltip(w)`, `setTooltip(w, s)` | Всплывающая подсказка |
| Состояние | `visible(w)`, `visibleR(w)` | Видимость (локальная/рекурсивная) |
| | `changed(w)`, `setChanged(w)`, `clearChanged(w)` | Флаг изменения значения |
| | `takeFocus(w): cint` | Передача фокуса ввода |

---

## 📦 Контейнеры и иерархия

### `FlWindow`
- `newFlWindow(x,y,w,h,label)`, `newFlWindow(w,h,label)`
- `show(win)`, `hide(win)`, `shown(win)`
- `resizable(win, widget)` – виджет, растягивающийся с окном
- `beginGroup(win)`, `endGroup(win)`
- `fullscreen(win)`, `fullscreenOff(...)`, `iconize(win)`, `border(win, flag)`
- `setSizeRange(win, minw, minh, maxw, maxh)`

### `FlGroup`, `FlTabs`, `FlScroll`, `FlPack`, `FlTile`
- `beginGroup(g)`, `endGroup(g)`
- `resizable(g, w)`
- `children(g)`, `child(g, n)`, `addWidget(g, w)`, `removeWidget(g, w)`, `clear(g)`
- **Tabs:** `value(tabs)`, `setValue(tabs, widget)`
- **Scroll:** `scrollTo(s, x, y)`
- **Pack:** `spacing(p, s)`, `setType(p, FL_PACK_VERTICAL/FL_PACK_HORIZONTAL)`

### 📝 Удобные шаблоны
Автоматически вызывают `beginGroup()` / `endGroup()`:
```nim
withWindow(win): body
withGroup(grp): body
withTabs(tabs): body
withScroll(scrl): body
withPack(pack): body
withTile(tile): body
```

---

## 🖼 Конкретные виджеты

### Кнопки (`FlButton`, `FlCheckButton`, `FlRadioRoundButton`, `FlToggleButton`, `FlReturnButton`)
- Конструкторы: `newFlButton(...)`, `newFlCheckButton(...)` и т.д.
- `value(b)`, `setValue(b, v: cint)`
- `set(b)`, `clear(b)` – альтернатива `setValue` для кнопок

### Поля ввода (`FlInput`, `FlOutput`, `FlMultilineInput`, `FlFloatInput`, `FlIntInput`)
- Конструкторы: `newFlInput(...)`, `newFlOutput(...)`, `newFlMultilineInput(...)`
- `getValue(inp): cstring`, `setValue(inp, s: cstring): cint`
- `readonly(inp, v)`, `getReadonly(inp)`
- `textfont(inp)`, `setTextfont(inp, f)`, `textsize(...)`, `textcolor(...)`

### Списки и меню (`FlChoice`, `FlMenuBar`, `FlMenuButton`)
- `add(c, s)`, `clear(c)`, `text(c): cstring`
- `value(c)`, `setValue(c, v)`
- `add(mb, label, shortcut, cb, data, flags)` – для меню с `&` и `\t`
- `popup(mb): ptr FlWidget`

### Валюаторы (`FlValueSlider`, `FlHorValueSlider`, `FlSlider`, `FlDial`, `FlProgress`, `FlSpinner`, `FlCounter`)
- `value(s): cdouble/cfloat`, `setValue(s, v)`
- `bounds(s, min, max)`, `minimum(s)`, `maximum(s)`, `step(s, v)`
- `setType(s, t: uint8)` – тип отображения слайдера
- `angles(d, a1, a2)` – углы начала/конца дуги для Dial
- `setMinimum(p)`, `setMaximum(p)` – отдельно для `FlProgress`

### Текст (`FlTextBuffer`, `FlTextDisplay`, `FlTextEditor`)
- `newFlTextBuffer(reqSize, prefGap)`
- `text(buf)`, `setText(buf, s)`, `append(buf, s)`, `insert(buf, pos, s)`, `remove(buf, start, end)`
- `setBuffer(td/te, buf)`, `getBuffer(td/te)`
- `textfont/size/color(td/te, ...)`
- `linenumberWidth(te, w)`

### Дерево (`FlTree`, `FlTreeItem`)
- `add(t, path)` – автоматически создаёт ветки по `/`
- `first(t)`, `next(t, item)`, `root(t)`
- `label(item)`, `setLabel(item, s)`
- `isSelected(item)`, `selectAll(t)`, `deselectAll(t)`
- `showRoot(t, v)`, `openAll(t, item)`

---

## 💬 Диалоги

| Функция | Описание |
|:---|:---|
| `flMessage(fmt)` | Информационное окно с кнопкой OK |
| `flAlert(fmt)` | Предупреждение |
| `flAsk(fmt): cint` | Да/Нет (возвращает 1/0) |
| `flChoiceDlg(msg, b0, b1, b2): cint` | Выбор из 3 кнопок |
| `flInputDlg(label, deflt): cstring` | Ввод строки |
| `flPassword(label, deflt): cstring` | Ввод пароля (звёздочки) |
| `flColorChooser(name, r, g, b, cmode): cint` | Палитра (модифицирует `r,g,b` по ссылке) |
| `flFileChooser(message, pattern, fname, relative): cstring` | Открытие файла |

---

## 🎨 Рисование (`fl_draw`)

Используются в кастомных `handle()` или `draw()` колбэках.

| Функция | Описание |
|:---|:---|
| `flDrawSetColor(c)`, `flDrawGetColor()` | Текущий цвет кисти |
| `flLineStyle(style, width, dashes)` | Стиль линий (сплошная, пунктир) |
| Примитивы | `flPoint(x,y)`, `flLine(x1,y1,x2,y2)`, `flRect(x,y,w,h)`, `flRectf(...)` |
| Дуги/Круги | `flArc(...)`, `flPie(...)`, `flCircle(x,y,r)` |
| Полилинии | `flBeginLine()`, `flVertex(x,y)`, `flEndLine()`<br>`flBeginLoop()` / `flBeginPolygon()` |
| Текст | `flSetFont(f, s)`, `flDraw(s, x, y)`, `flMeasure(s, w, h)`<br>`flWidth(s)`, `flHeight()`, `flDescent()` |
| Клиппинг | `flPushClip(x,y,w,h)`, `flPopClip()`, `flPushNoClip()` |
| Offscreen | `flBeginOffscreen(buf)`, `flEndOffscreen()` |
| Курсор | `flCursorColor(c)` |

---

## ⚠️ Важные замечания

1. **Управление памятью:** FLTK автоматически удаляет виджеты при закрытии родительского окна. Исключение: `Fl_Text_Buffer`. Для явного удаления используйте `deleteFlTextBuffer(buf)`, если буфер не привязан к отображаемому виджету.
2. **`discard` для статусов:** Многие функции возвращают `cint` (код ошибки или флаг). В Nim при `-d:release` или строгом режиме требуется явно писать `discard funcName(...)`, если результат не используется.
3. **Строгие типы координат:** Параметры `x, y, w, h` имеют тип `cint`. Арифметика с обычными `int` (64-бит на Linux) вызывает ошибку компиляции. Оборачивайте выражения: `cint(x + w*2)`.
4. **Ключевое слово `when`:** В Nim `when` зарезервировано. В обёртке вызов триггера колбэка оформлен как `` `when`(w, FL_WHEN_ENTER_KEY) ``.
5. **Кодировка строк:** FLTK ожидает UTF-8. Nim `string` автоматически конвертируется в `cstring` при передаче в `importcpp`.

---
*Документация разработана на основе `nimFLTK.nim` для Nim v2.2.8 + FLTK 1.3/1.4*



