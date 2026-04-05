## FLTK_program.nim
## Demo application showcasing major FLTK widgets wrapped via nimFLTK.nim.
##
## Compile:
##   nim cpp -d:release FLTK_program.nim
##
## Requires FLTK 1.3/1.4 development libraries:
##   Linux:  sudo apt install libfltk1.3-dev  (or build FLTK 1.4 from source)
##   MSYS2:  pacman -S mingw-w64-ucrt-x86_64-fltk

import nimFLTK
import strutils

# ---------------------------------------------------------------------------
# Global widget references used in callbacks
# ---------------------------------------------------------------------------

var
  gWindow      : ptr FlWindow
  gOutput      : ptr FlOutput
  gSlider      : ptr FlHorValueSlider
  gProgress    : ptr FlProgress
  gCounter     : ptr FlCounter
  gTextBuf     : ptr FlTextBuffer
  gTree        : ptr FlTree
  gSpinner     : ptr FlSpinner
  gCheck1      : ptr FlCheckButton
  gCheck2      : ptr FlCheckButton
  gRadio1      : ptr FlRadioRoundButton
  gRadio2      : ptr FlRadioRoundButton
  gChoice      : ptr FlChoice
  gDial        : ptr FlDial

# ---------------------------------------------------------------------------
# Helper: write a line to the output widget
# ---------------------------------------------------------------------------

proc logMsg(msg: string) =
  discard setValue(gOutput, cstring(msg))
  redraw(asWidget(gOutput))

# ---------------------------------------------------------------------------
# Callbacks
# ---------------------------------------------------------------------------

proc cbButton(w: ptr FlWidget, data: pointer) {.cdecl.} =
  logMsg("Button clicked!")

proc cbToggle(w: ptr FlWidget, data: pointer) {.cdecl.} =
  let btn = cast[ptr FlToggleButton](w)
  if value(btn) != 0:
    logMsg("Toggle: ON")
  else:
    logMsg("Toggle: OFF")

proc cbCheck(w: ptr FlWidget, data: pointer) {.cdecl.} =
  var msg = "Checkboxes: "
  if value(gCheck1) != 0:
    msg.add("Alpha ")
  if value(gCheck2) != 0:
    msg.add("Beta ")
  logMsg(msg)

proc cbRadio(w: ptr FlWidget, data: pointer) {.cdecl.} =
  if value(gRadio1) != 0:
    logMsg("Radio: Option A selected")
  else:
    logMsg("Radio: Option B selected")

proc cbSlider(w: ptr FlWidget, data: pointer) {.cdecl.} =
  let v = value(gSlider)
  setValue(gProgress, cfloat(v))
  logMsg("Slider: " & formatFloat(v, ffDecimal, 2))
  redraw(asWidget(gProgress))

proc cbCounter(w: ptr FlWidget, data: pointer) {.cdecl.} =
  logMsg("Counter: " & formatFloat(value(gCounter), ffDecimal, 0))

proc cbSpinner(w: ptr FlWidget, data: pointer) {.cdecl.} =
  logMsg("Spinner: " & formatFloat(value(gSpinner), ffDecimal, 1))

proc cbDial(w: ptr FlWidget, data: pointer) {.cdecl.} =
  logMsg("Dial: " & formatFloat(value(gDial), ffDecimal, 1))

proc cbChoice(w: ptr FlWidget, data: pointer) {.cdecl.} =
  logMsg("Choice: " & $text(gChoice))

proc cbInput(w: ptr FlWidget, data: pointer) {.cdecl.} =
  let inp = cast[ptr FlInput](w)
  logMsg("Input: " & $getValue(inp))

proc cbAppendText(w: ptr FlWidget, data: pointer) {.cdecl.} =
  append(gTextBuf, "\nLine appended at runtime.")
  logMsg("Text appended.")

proc cbClearText(w: ptr FlWidget, data: pointer) {.cdecl.} =
  setText(gTextBuf, "")
  logMsg("Text cleared.")

proc cbColorPick(w: ptr FlWidget, data: pointer) {.cdecl.} =
  var r, g, b: uint8 = 128
  if flColorChooser("Pick a Color", r, g, b) != 0:
    setColor(asWidget(gWindow), fl_rgb_color(r, g, b))
    logMsg("Color: rgb(" & $r & "," & $g & "," & $b & ")")
    redraw(asWidget(gWindow))

proc cbFileOpen(w: ptr FlWidget, data: pointer) {.cdecl.} =
  let fname = flFileChooser("Open File", "*", nil)
  if fname != nil:
    logMsg("File: " & $fname)

proc cbAbout(w: ptr FlWidget, data: pointer) {.cdecl.} =
  flMessage("FLTK Demo written in Nim\nUsing nimFLTK.nim wrapper\n\nhttps://www.fltk.org")

proc cbQuit(w: ptr FlWidget, data: pointer) {.cdecl.} =
  hide(gWindow)   # closing the last window exits Fl::run()

proc cbWindowClose(w: ptr FlWidget, data: pointer) {.cdecl.} =
  hide(gWindow)

proc cbTreeSelect(w: ptr FlWidget, data: pointer) {.cdecl.} =
  # Walk tree items and log selected one
  var item = first(gTree)
  while item != nil:
    if isSelected(item) != 0:
      logMsg("Tree selected: " & $label(item))
      return
    item = next(gTree, item)

# ---------------------------------------------------------------------------
# Build the GUI
# ---------------------------------------------------------------------------

proc buildGui() =
  # ---- Main window --------------------------------------------------------
  gWindow = newFlWindow(900, 620, "FLTK Demo — Nim wrapper")
  callback(gWindow, cbWindowClose)

  # ---- Menu bar -----------------------------------------------------------
  let mbar = newFlMenuBar(0, 0, 900, 25)
  discard add(mbar, "&File/&Open\t",     0, cbFileOpen)
  discard add(mbar, "&File/&Quit\t",     0, cbQuit)
  discard add(mbar, "&Help/&About\t",    0, cbAbout)

  # ---- Status output (single-line, read-only) -----------------------------
  gOutput = newFlOutput(0, 595, 900, 25, nil)
  discard setValue(gOutput, "Ready.")

  # ---- Tabs ---------------------------------------------------------------
  let tabs = newFlTabs(0, 25, 900, 568)
  beginGroup(tabs)

  # ===== Tab 1: Buttons & Checks ===========================================
  let tabButtons = newFlGroup(0, 50, 900, 543, "  Buttons  ")
  beginGroup(tabButtons)

  # Standard button
  let btn = newFlButton(20, 70, 140, 35, "Click Me")
  callback(asWidget(btn), cbButton)
  setTooltip(asWidget(btn), "A standard push button")

  # Return button (responds to Enter key)
  let rbtn = newFlReturnButton(180, 70, 160, 35, "Return Button")
  callback(asWidget(rbtn), cbButton)

  # Toggle button
  let tbtn = newFlToggleButton(360, 70, 140, 35, "Toggle")
  callback(asWidget(tbtn), cbToggle)

  # Check buttons
  gCheck1 = newFlCheckButton(20, 120, 140, 30, "Alpha")
  callback(asWidget(gCheck1), cbCheck)
  gCheck2 = newFlCheckButton(20, 155, 140, 30, "Beta")
  callback(asWidget(gCheck2), cbCheck)

  # Radio buttons
  let grpRadio = newFlGroup(180, 145, 200, 90, "Radio Group")
  setBox(asWidget(grpRadio), FL_ENGRAVED_FRAME)
  beginGroup(grpRadio)
  gRadio1 = newFlRadioRoundButton(190, 155, 170, 30, "Option A")
  setValue(gRadio1, 1)   # default selected
  callback(asWidget(gRadio1), cbRadio)
  gRadio2 = newFlRadioRoundButton(190, 190, 170, 30, "Option B")
  callback(asWidget(gRadio2), cbRadio)
  endGroup(grpRadio)

  # Choice (combo)
  gChoice = newFlChoice(420, 120, 200, 30, "Choice:")
  discard add(gChoice, "Apples")
  discard add(gChoice, "Bananas")
  discard add(gChoice, "Cherries")
  discard add(gChoice, "Dates")
  discard setValue(gChoice, 0)
  callback(asWidget(gChoice), cbChoice)

  # Input
  let inp = newFlInput(420, 165, 200, 30, "Input:")
  callback(asWidget(inp), cbInput)
  setTooltip(asWidget(inp), "Type something and press Enter")
  `when`(asWidget(inp), FL_WHEN_ENTER_KEY)

  # Box for decoration
  let box1 = newFlBox(FL_ENGRAVED_BOX, 650, 65, 230, 145, "Decorated Box\n(FL_ENGRAVED_BOX)")
  setLabelfont(asWidget(box1), FL_HELVETICA_ITALIC)

  endGroup(tabButtons)

  # ===== Tab 2: Sliders & Valuators ========================================
  let tabValuators = newFlGroup(0, 50, 900, 543, "  Valuators  ")
  beginGroup(tabValuators)

  # Horizontal value slider → drives progress bar
  let boxSlider = newFlBox(FL_NO_BOX, 20, 68, 1, 1, "Slider (drives progress):")
  setAlign(asWidget(boxSlider), FL_ALIGN_RIGHT)

  gSlider = newFlHorValueSlider(20, 85, 500, 35, "")
  bounds(gSlider, 0.0, 100.0)
  discard setValue(gSlider, 40.0)
  step(gSlider, 0.5)
  callback(asWidget(gSlider), cbSlider)
  setColor(asWidget(gSlider), FL_BLUE)

  # Progress bar
  let boxProg = newFlBox(FL_NO_BOX, 20, 128, 1, 1, "Progress:")
  setAlign(asWidget(boxProg), FL_ALIGN_RIGHT)

  gProgress = newFlProgress(20, 145, 500, 30, "Progress Bar")
  setMinimum(gProgress, 0.0)
  setMaximum(gProgress, 100.0)
  setValue(gProgress, cfloat(40.0))
  setColor(asWidget(gProgress), FL_GREEN)
  setSelectionColor(asWidget(gProgress), FL_BACKGROUND_COLOR)

  # Counter
  gCounter = newFlCounter(20, 200, 250, 35, "Counter:")
  bounds(gCounter, -50.0, 50.0)
  discard setValue(gCounter, 0.0)
  callback(asWidget(gCounter), cbCounter)

  # Spinner
  gSpinner = newFlSpinner(400, 200, 120, 35, "Spinner:")
  setMinimum(gSpinner, 0.0)
  setMaximum(gSpinner, 99.0)
  setValue(gSpinner, 10.0)
  step(gSpinner, 0.5)
  callback(asWidget(gSpinner), cbSpinner)

  # Dial
  gDial = newFlDial(20, 260, 120, 120, "Dial")
  bounds(gDial, 0.0, 360.0)
  discard setValue(gDial, 90.0)
  angles(gDial, 0, 360)
  callback(asWidget(gDial), cbDial)

  # Vertical value slider
  let vslider = newFlValueSlider(200, 255, 40, 130, "V-Slider")
  bounds(vslider, 0.0, 100.0)
  discard setValue(vslider, 50.0)
  step(vslider, 1.0)
  setAlign(asWidget(vslider), FL_ALIGN_BOTTOM)

  endGroup(tabValuators)

  # ===== Tab 3: Text Editor ================================================
  let tabText = newFlGroup(0, 50, 900, 543, "  Text Editor  ")
  beginGroup(tabText)

  gTextBuf = newFlTextBuffer()
  setText(gTextBuf,
    "Welcome to the FLTK Text Editor demo!\n" &
    "This uses Fl_Text_Editor backed by Fl_Text_Buffer.\n\n" &
    "Features:\n" &
    "  • Full keyboard editing\n" &
    "  • Cut/Copy/Paste (Ctrl+X/C/V)\n" &
    "  • Undo (Ctrl+Z)\n" &
    "  • Line numbers\n\n" &
    "Edit freely below ↓\n")

  let editor = newFlTextEditor(10, 60, 880, 440)
  setBuffer(editor, gTextBuf)
  textfont(editor, FL_COURIER)
  textsize(editor, 14)
  linenumberWidth(editor, 60)

  let btnAppend = newFlButton(10, 510, 160, 28, "Append Line")
  callback(asWidget(btnAppend), cbAppendText)

  let btnClear = newFlButton(180, 510, 120, 28, "Clear All")
  callback(asWidget(btnClear), cbClearText)

  endGroup(tabText)

  # ===== Tab 4: Tree =======================================================
  let tabTree = newFlGroup(0, 50, 900, 543, "  Tree  ")
  beginGroup(tabTree)

  gTree = newFlTree(10, 60, 400, 470, "Directory Tree")
  setBox(asWidget(gTree), FL_DOWN_BOX)
  callback(asWidget(gTree), cbTreeSelect)
  setShowRoot(gTree, 0)

  discard add(gTree, "Documents/Reports/Q1_2026.pdf")
  discard add(gTree, "Documents/Reports/Q2_2026.pdf")
  discard add(gTree, "Documents/Contracts/NDA.docx")
  discard add(gTree, "Pictures/Vacation/beach.jpg")
  discard add(gTree, "Pictures/Work/screenshot.png")
  discard add(gTree, "Music/Favorites/track01.mp3")
  discard add(gTree, "Music/Favorites/track02.mp3")

  let boxTreeHelp = newFlBox(FL_FLAT_BOX, 430, 60, 450, 470,
    "Click a leaf node to select it.\n\n" &
    "The selected item name\nappears in the status bar\nat the bottom of the window.\n\n" &
    "The tree is backed by\nFl_Tree + Fl_Tree_Item.")
  setAlign(asWidget(boxTreeHelp), FL_ALIGN_WRAP or FL_ALIGN_LEFT or FL_ALIGN_INSIDE)
  setBox(asWidget(boxTreeHelp), FL_ENGRAVED_BOX)

  endGroup(tabTree)

  # ===== Tab 5: Colors & Theme =============================================
  let tabMisc = newFlGroup(0, 50, 900, 543, "  Colors/Misc  ")
  beginGroup(tabMisc)

  let btnColor = newFlButton(20, 70, 200, 35, "Pick Background Color")
  callback(asWidget(btnColor), cbColorPick)

  let btnFile = newFlButton(20, 120, 200, 35, "Open File Dialog")
  callback(asWidget(btnFile), cbFileOpen)

  let btnAbout = newFlButton(20, 170, 200, 35, "About Dialog")
  callback(asWidget(btnAbout), cbAbout)

  # Color swatches
  let swatchLabels = ["FL_RED", "FL_GREEN", "FL_BLUE",
                      "FL_YELLOW", "FL_CYAN", "FL_MAGENTA",
                      "FL_WHITE", "FL_BLACK", "FL_GRAY"]
  let swatchColors: array[9, FlColor] = [
    FL_RED, FL_GREEN, FL_BLUE,
    FL_YELLOW, FL_CYAN, FL_MAGENTA,
    FL_WHITE, FL_BLACK, FL_GRAY]

  for i in 0 ..< 9:
    let col = cint(i mod 3)
    let row = cint(i div 3)
    let bx  = newFlBox(FL_FLAT_BOX,
      250 + col * 220,
      70  + row * 80,
      200, 60,
      cstring(swatchLabels[i]))
    setColor(asWidget(bx), swatchColors[i])
    if swatchColors[i] == FL_BLACK:
      setLabelcolor(asWidget(bx), FL_WHITE)

  let btnQuit = newFlButton(700, 500, 160, 35, "Quit")
  callback(asWidget(btnQuit), cbQuit)

  endGroup(tabMisc)

  # ---- Close tabs group ---------------------------------------------------
  endGroup(tabs)

  # Make the window resizable with the tab widget filling it
  resizable(gWindow, asWidget(tabs))

  endGroup(gWindow)
  show(gWindow)

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

proc main() =
  discard flScheme("gtk+")  # nice modern look; try "gleam", "plastic", "base"
  buildGui()
  discard flRun()

main()
