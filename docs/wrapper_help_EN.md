# 📖 `nimFLTK.nim` Wrapper Reference

Complete Nim binding for the C++ **FLTK** (Fast Light Toolkit) library.  
Supports compilation on **Linux** and **Windows (MSYS2/UCRT64)**.

---

## 🛠 Compilation & Dependencies

```bash
# Linux
sudo apt install libfltk1.3-dev   # or build FLTK 1.4 from source
# MSYS2 / Windows
pacman -S mingw-w64-ucrt-x86_64-fltk

# Build
nim cpp -d:release your_app.nim
```
> 💡 Compiler and linker flags are automatically resolved via `fltk-config`. Ensure the utility is in your `PATH`.

---

## 🧱 Type System

| Nim Type | Description |
|:---|:---|
| `FlColor`, `FlFont`, `FlFontsize`, `FlAlign`, `FlBoxtype`, `FlWhen` | Type aliases for FLTK enumerations (`cuint` / `cint`) |
| `ptr FlWidget`, `ptr FlWindow`, `ptr FlGroup`, ... | Opaque pointers to C++ objects |
| `FlCallback` | `proc(w: ptr FlWidget, data: pointer) {.cdecl.}` |
| `FlTimeoutHandler` / `FlIdleHandler` | `proc( pointer) {.cdecl.}` |

### 🔹 Type Casting
To call base methods (`setColor`, `redraw`, `callback`, etc.), use the `asWidget` helper:
```nim
asWidget*(w: ptr FlXXX): ptr FlWidget
```
> ⚠️ Nim does not automatically upcast pointers to parent types in `importcpp`. Always wrap derived widgets in `asWidget()` when passing them to base procedures.

---

## 🎨 Constants

### Colors (`FlColor`)
`FL_BLACK`, `FL_WHITE`, `FL_RED`, `FL_GREEN`, `FL_BLUE`, `FL_YELLOW`, `FL_CYAN`, `FL_MAGENTA`, `FL_GRAY`, `FL_BACKGROUND_COLOR`, `FL_SELECTION_COLOR`, and the `FL_DARK*` / `FL_LIGHT*` palette.  
Utility functions: `fl_rgb_color(r,g,b)`, `fl_color_average(c1,c2,w)`, `fl_lighter(c)`, `fl_darker(c)`, `fl_contrast(fg,bg)`.

### Fonts (`FlFont`)
`FL_HELVETICA`, `FL_COURIER`, `FL_TIMES`, `FL_SYMBOL`, `FL_SCREEN`, `FL_ZAPF_DINGBATS` and their modifiers (`_BOLD`, `_ITALIC`).

### Alignments (`FlAlign`)
`FL_ALIGN_CENTER`, `FL_ALIGN_TOP`, `FL_ALIGN_BOTTOM`, `FL_ALIGN_LEFT`, `FL_ALIGN_RIGHT`, `FL_ALIGN_INSIDE`, `FL_ALIGN_CLIP`, `FL_ALIGN_WRAP`.  
Combine via `or`: `FL_ALIGN_TOP_LEFT = FL_ALIGN_TOP or FL_ALIGN_LEFT`.

### Box Types (`FlBoxtype`)
`FL_NO_BOX`, `FL_FLAT_BOX`, `FL_UP_BOX`, `FL_DOWN_BOX`, `FL_ENGRAVED_BOX`, `FL_EMBOSSED_BOX`, `FL_BORDER_BOX`, `FL_SHADOW_BOX`, `FL_ROUNDED_BOX`, `FL_PLASTIC_*`, `FL_GTK_*`, etc.

### Events & Triggers
- **Events:** `FL_PUSH`, `FL_RELEASE`, `FL_KEYBOARD`, `FL_FOCUS`, `FL_SHORTCUT`, `FL_CLOSE`...
- **Fl_When:** `FL_WHEN_NEVER`, `FL_WHEN_CHANGED`, `FL_WHEN_RELEASE`, `FL_WHEN_ENTER_KEY`...
- **Keys:** `FK_BackSpace`, `FK_Tab`, `FK_Enter`, `FK_Escape`, `FK_Fn` (`FK_F+1` = F1), modifiers `FK_ShiftL`, `FK_ControlL`...

---

## 🔄 Main Loop & Application Settings

| Procedure | Description |
|:---|:---|
| `flRun(): cint` | Starts the event loop. Returns when all windows are closed. |
| `flCheck(): cint` | Processes pending events without blocking. |
| `flWait(): cint` | Blocks until the next event arrives. |
| `flWaitFor(time: cdouble): cdouble` | Waits for an event up to `time` seconds. |
| `flScheme(name: cstring): cint` | Sets the GUI theme: `"gtk+"`, `"gleam"`, `"plastic"`, `"base"`. |
| `flBackground(r,g,b)`, `flForeground(...)`, `flBackground2(...)` | Global application palette setters. |
| `flAddTimeout(t, cb, data)`, `flRemoveTimeout(cb, data)` | One-shot or periodic timers. |
| `flAddIdle(cb, data)`, `flRemoveIdle(cb, data)` | Idle handlers (called when the event queue is empty). |

### Event Query
`flEventX()`, `flEventY()`, `flEventButton()`, `flEventKey()`, `flEventText()`, `flEventState()`, `flEventClicks()`, `flEventDx()`, `flEventDy()`.

---

## 🧩 Base Widget Methods (`Fl_Widget`)

All methods expect `ptr FlWidget` or a pointer cast via `asWidget()`.

| Method | Signature | Description |
|:---|:---|:---|
| Geometry | `x(w)`, `y(w)`, `ww(w)`, `wh(w)` | Returns position & size |
| | `resize(w, x, y, ww, hh)` | Changes position & dimensions |
| | `position(w, x, y)`, `size(w, ww, hh)` | Shortcuts for `resize` |
| Labels | `label(w): cstring`, `setLabel(w, s)` | Widget text |
| | `copyLabel(w, s)` | Copies string into FLTK's internal memory |
| | `labelfont(w)`, `setLabelfont(w, f)` | Label font |
| | `labelsize(w)`, `setLabelsize(w, s)` | Font size |
| | `labelcolor(w)`, `setLabelcolor(w, c)` | Font color |
| Colors | `color(w)`, `setColor(w, c)` | Primary color |
| | `selectionColor(w)`, `setSelectionColor(w, c)` | Highlight/background color |
| Behavior | `callback(w, cb, data=nil)` | Attach event handler |
| | `` `when`(w, v: FlWhen) ``, `getWhen(w)` | Callback trigger condition |
| | `show(w)`, `hide(w)` | Visibility |
| | `activate(w)`, `deactivate(w)`, `active(w)` | Enabled state |
| | `redraw(w)`, `redrawLabel(w)` | Force repaint |
| | `tooltip(w)`, `setTooltip(w, s)` | Hover hint |
| State | `visible(w)`, `visibleR(w)` | Visibility (local/recursive) |
| | `changed(w)`, `setChanged(w)`, `clearChanged(w)` | Value-modified flag |
| | `takeFocus(w): cint` | Transfer input focus |

---

## 📦 Containers & Hierarchy

### `FlWindow`
- Constructors: `newFlWindow(x,y,w,h,label)`, `newFlWindow(w,h,label)`
- `show(win)`, `hide(win)`, `shown(win)`
- `resizable(win, widget)` – Widget that stretches with the window
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

### 📝 Convenience Templates
Automatically wrap `beginGroup()` / `endGroup()`:
```nim
withWindow(win): body
withGroup(grp): body
withTabs(tabs): body
withScroll(scrl): body
withPack(pack): body
withTile(tile): body
```

---

## 🖼 Specific Widgets

### Buttons (`FlButton`, `FlCheckButton`, `FlRadioRoundButton`, `FlToggleButton`, `FlReturnButton`)
- Constructors: `newFlButton(...)`, `newFlCheckButton(...)`, etc.
- `value(b)`, `setValue(b, v: cint)`
- `set(b)`, `clear(b)` – Toggle shortcuts

### Inputs (`FlInput`, `FlOutput`, `FlMultilineInput`, `FlFloatInput`, `FlIntInput`)
- Constructors: `newFlInput(...)`, `newFlOutput(...)`, `newFlMultilineInput(...)`
- `getValue(inp): cstring`, `setValue(inp, s: cstring): cint`
- `readonly(inp, v)`, `getReadonly(inp)`
- `textfont(inp)`, `setTextfont(inp, f)`, `textsize(...)`, `textcolor(...)`

### Lists & Menus (`FlChoice`, `FlMenuBar`, `FlMenuButton`)
- `add(c, s)`, `clear(c)`, `text(c): cstring`
- `value(c)`, `setValue(c, v)`
- `add(mb, label, shortcut, cb, data, flags)` – Menu items with `&` and `\t`
- `popup(mb): ptr FlWidget`

### Valuators (`FlValueSlider`, `FlHorValueSlider`, `FlSlider`, `FlDial`, `FlProgress`, `FlSpinner`, `FlCounter`)
- `value(s): cdouble/cfloat`, `setValue(s, v)`
- `bounds(s, min, max)`, `minimum(s)`, `maximum(s)`, `step(s, v)`
- `setType(s, t: uint8)` – Slider visual type
- `angles(d, a1, a2)` – Dial arc start/end angles
- `setMinimum(p)`, `setMaximum(p)` – Specific to `FlProgress`

### Text (`FlTextBuffer`, `FlTextDisplay`, `FlTextEditor`)
- `newFlTextBuffer(reqSize, prefGap)`
- `text(buf)`, `setText(buf, s)`, `append(buf, s)`, `insert(buf, pos, s)`, `remove(buf, start, end)`
- `setBuffer(td/te, buf)`, `getBuffer(td/te)`
- `textfont/size/color(td/te, ...)`
- `linenumberWidth(te, w)`

### Tree (`FlTree`, `FlTreeItem`)
- `add(t, path)` – Auto-creates branches on `/`
- `first(t)`, `next(t, item)`, `root(t)`
- `label(item)`, `setLabel(item, s)`
- `isSelected(item)`, `selectAll(t)`, `deselectAll(t)`
- `showRoot(t, v)`, `openAll(t, item)`

---

## 💬 Dialogs

| Function | Description |
|:---|:---|
| `flMessage(fmt)` | Information window with OK |
| `flAlert(fmt)` | Warning alert |
| `flAsk(fmt): cint` | Yes/No prompt (returns 1/0) |
| `flChoiceDlg(msg, b0, b1, b2): cint` | 3-button choice dialog |
| `flInputDlg(label, deflt): cstring` | Single-line text input |
| `flPassword(label, deflt): cstring` | Password input (masked) |
| `flColorChooser(name, r, g, b, cmode): cint` | Color picker (modifies `r,g,b` by ref) |
| `flFileChooser(message, pattern, fname, relative): cstring` | File open dialog |

---

## 🎨 Drawing (`fl_draw`)

Used inside custom `handle()` or `draw()` callbacks.

| Function | Description |
|:---|:---|
| `flDrawSetColor(c)`, `flDrawGetColor()` | Current pen color |
| `flLineStyle(style, width, dashes)` | Line style (solid, dashed, etc.) |
| Primitives | `flPoint(x,y)`, `flLine(x1,y1,x2,y2)`, `flRect(x,y,w,h)`, `flRectf(...)` |
| Arcs/Circles | `flArc(...)`, `flPie(...)`, `flCircle(x,y,r)` |
| Polylines | `flBeginLine()`, `flVertex(x,y)`, `flEndLine()`<br>`flBeginLoop()` / `flBeginPolygon()` |
| Text | `flSetFont(f, s)`, `flDraw(s, x, y)`, `flMeasure(s, w, h)`<br>`flWidth(s)`, `flHeight()`, `flDescent()` |
| Clipping | `flPushClip(x,y,w,h)`, `flPopClip()`, `flPushNoClip()` |
| Offscreen | `flBeginOffscreen(buf)`, `flEndOffscreen()` |
| Cursor | `flCursorColor(c)` |

---

## ⚠️ Important Notes

1. **Memory Management:** FLTK automatically deletes child widgets when their parent window is closed. Exception: `Fl_Text_Buffer`. Explicitly call `deleteFlTextBuffer(buf)` only if the buffer is detached from any display widget.
2. **`discard` for Return Values:** Many wrappers return `cint` (status codes or flags). In Nim's strict/release modes, you must explicitly write `discard funcName(...)` if the result is unused.
3. **Strict Coordinate Types:** Geometry parameters `x, y, w, h` require `cint`. Standard Nim `int` (64-bit on Linux) triggers compiler errors. Wrap expressions: `cint(x + w*2)`.
4. **Reserved Keyword `when`:** Nim reserves `when`. The wrapper exposes the callback trigger as `` `when`(w, FL_WHEN_ENTER_KEY) ``.
5. **String Encoding:** FLTK expects UTF-8. Nim `string` automatically converts to `cstring` during `importcpp` calls.

---
*Documentation created from `nimFLTK.nim` for Nim v2.2.8 + FLTK 1.3/1.4*
