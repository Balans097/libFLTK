## nimFLTK.nim
## Full Nim wrapper for the FLTK (Fast Light Toolkit) C++ library.
## Supports Linux and Windows (MSYS2/UCRT64).
##
## Compile your app with:
##   nim cpp -d:release your_app.nim
##
## Required libraries (install via package manager):
##   Linux:  sudo apt install libfltk1.3-dev   (or fltk 1.4 from source)
##   MSYS2:  pacman -S mingw-w64-ucrt-x86_64-fltk
##
## Usage note:
##   Per project style, functions are called as  funcName(arg1, arg2)
##   and dots are used only for field/method access on objects.

{.experimental: "codeReordering".}

# ---------------------------------------------------------------------------
# Compiler / linker configuration
# ---------------------------------------------------------------------------

when defined(windows):
  # MSYS2 UCRT64 – fltk-config output is embedded here for convenience.
  # Adjust paths if your FLTK lives elsewhere.
  {.passC: gorge("fltk-config --cxxflags").}
  {.passL: gorge("fltk-config --ldflags --use-images").}
  {.passC:"-fno-lto".}
  # {.passC: "-Wno-stringop-overflow".}
  # {.passC:"-U_FORTIFY_SOURCE".}
else:
  # Linux / macOS – rely on fltk-config being on PATH
  {.passC: gorge("fltk-config --cxxflags").}
  {.passL: gorge("fltk-config --ldflags --use-images").}
  {.passC:"-fno-lto".}
  # {.passC: "-Wno-stringop-overflow".}
  # {.passC:"-U_FORTIFY_SOURCE".}

# ---------------------------------------------------------------------------
# C++ headers we reference
# ---------------------------------------------------------------------------

{.emit: """
#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Check_Button.H>
#include <FL/Fl_Radio_Round_Button.H>
#include <FL/Fl_Toggle_Button.H>
#include <FL/Fl_Return_Button.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Pack.H>
#include <FL/Fl_Scroll.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Float_Input.H>
#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Multiline_Input.H>
#include <FL/Fl_Output.H>
#include <FL/Fl_Multiline_Output.H>
#include <FL/Fl_Choice.H>
#include <FL/Fl_Menu_Bar.H>
#include <FL/Fl_Menu_Button.H>
#include <FL/Fl_Value_Slider.H>
#include <FL/Fl_Hor_Value_Slider.H>
#include <FL/Fl_Slider.H>
#include <FL/Fl_Dial.H>
#include <FL/Fl_Progress.H>
#include <FL/Fl_Spinner.H>
#include <FL/Fl_Counter.H>
#include <FL/Fl_Roller.H>
#include <FL/Fl_Color_Chooser.H>
#include <FL/Fl_File_Chooser.H>
/* #include <FL/Fl_Message.H> */
#include <FL/fl_ask.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Tabs.H>
#include <FL/Fl_Tile.H>
#include <FL/Fl_Text_Buffer.H>
#include <FL/Fl_Text_Editor.H>
#include <FL/Fl_Text_Display.H>
#include <FL/Fl_Tree.H>
#include <FL/Fl_Table.H>
#include <string.h>
#include <stdlib.h>
""".}

# ---------------------------------------------------------------------------
# Basic type aliases
# ---------------------------------------------------------------------------

type
  FlColor*   = cuint       ## Fl_Color
  FlFont*    = cint        ## Fl_Font
  FlFontsize* = cint       ## Fl_Fontsize
  FlAlign*   = cuint       ## Fl_Align
  FlBoxtype* = cint        ## Fl_Boxtype
  FlWhen*    = cint        ## Fl_When (callback trigger)

  ## Opaque pointers to C++ objects
  FlWidget*  {.importcpp: "Fl_Widget", header: "<FL/Fl_Widget.H>", inheritable.} = object
  FlWindow*  {.importcpp: "Fl_Window", header: "<FL/Fl_Window.H>", inheritable.} = object
  FlGroup*   {.importcpp: "Fl_Group",  header: "<FL/Fl_Group.H>",  inheritable.} = object
  FlBox*     {.importcpp: "Fl_Box",    header: "<FL/Fl_Box.H>".}    = object
  FlButton*  {.importcpp: "Fl_Button", header: "<FL/Fl_Button.H>".} = object
  FlCheckButton* {.importcpp: "Fl_Check_Button",       header: "<FL/Fl_Check_Button.H>".}  = object
  FlRadioRoundButton* {.importcpp: "Fl_Radio_Round_Button", header: "<FL/Fl_Radio_Round_Button.H>".} = object
  FlToggleButton* {.importcpp: "Fl_Toggle_Button",     header: "<FL/Fl_Toggle_Button.H>".} = object
  FlReturnButton* {.importcpp: "Fl_Return_Button",     header: "<FL/Fl_Return_Button.H>".} = object
  FlInput*   {.importcpp: "Fl_Input",  header: "<FL/Fl_Input.H>".}  = object
  FlFloatInput* {.importcpp: "Fl_Float_Input", header: "<FL/Fl_Float_Input.H>".} = object
  FlIntInput* {.importcpp: "Fl_Int_Input", header: "<FL/Fl_Int_Input.H>".} = object
  FlMultilineInput* {.importcpp: "Fl_Multiline_Input", header: "<FL/Fl_Multiline_Input.H>".} = object
  FlOutput*  {.importcpp: "Fl_Output", header: "<FL/Fl_Output.H>".} = object
  FlMultilineOutput* {.importcpp: "Fl_Multiline_Output", header: "<FL/Fl_Multiline_Output.H>".} = object
  FlChoice*  {.importcpp: "Fl_Choice", header: "<FL/Fl_Choice.H>".} = object
  FlMenuBar* {.importcpp: "Fl_Menu_Bar", header: "<FL/Fl_Menu_Bar.H>".} = object
  FlMenuButton* {.importcpp: "Fl_Menu_Button", header: "<FL/Fl_Menu_Button.H>".} = object
  FlValueSlider* {.importcpp: "Fl_Value_Slider",     header: "<FL/Fl_Value_Slider.H>".} = object
  FlHorValueSlider* {.importcpp: "Fl_Hor_Value_Slider", header: "<FL/Fl_Hor_Value_Slider.H>".} = object
  FlSlider*  {.importcpp: "Fl_Slider", header: "<FL/Fl_Slider.H>".} = object
  FlDial*    {.importcpp: "Fl_Dial",   header: "<FL/Fl_Dial.H>".}   = object
  FlProgress* {.importcpp: "Fl_Progress", header: "<FL/Fl_Progress.H>".} = object
  FlSpinner* {.importcpp: "Fl_Spinner", header: "<FL/Fl_Spinner.H>".} = object
  FlCounter* {.importcpp: "Fl_Counter", header: "<FL/Fl_Counter.H>".} = object
  FlRoller*  {.importcpp: "Fl_Roller", header: "<FL/Fl_Roller.H>".} = object
  FlTabs*    {.importcpp: "Fl_Tabs",   header: "<FL/Fl_Tabs.H>".}   = object
  FlTile*    {.importcpp: "Fl_Tile",   header: "<FL/Fl_Tile.H>".}   = object
  FlScroll*  {.importcpp: "Fl_Scroll", header: "<FL/Fl_Scroll.H>".} = object
  FlPack*    {.importcpp: "Fl_Pack",   header: "<FL/Fl_Pack.H>".}   = object
  FlTextBuffer* {.importcpp: "Fl_Text_Buffer", header: "<FL/Fl_Text_Buffer.H>".} = object
  FlTextDisplay* {.importcpp: "Fl_Text_Display", header: "<FL/Fl_Text_Display.H>".} = object
  FlTextEditor* {.importcpp: "Fl_Text_Editor", header: "<FL/Fl_Text_Editor.H>".} = object
  FlTree*    {.importcpp: "Fl_Tree",   header: "<FL/Fl_Tree.H>".}   = object
  FlTreeItem* {.importcpp: "Fl_Tree_Item", header: "<FL/Fl_Tree.H>".} = object

  ## Callback signature: proc(widget: ptr FlWidget, data: pointer)
  FlCallback* = proc(w: ptr FlWidget, data: pointer) {.cdecl.}
  FlTimeoutHandler* = proc(data: pointer) {.cdecl.}
  FlIdleHandler* = proc(data: pointer) {.cdecl.}

# ---------------------------------------------------------------------------
# Color constants
# ---------------------------------------------------------------------------

const
  FL_FOREGROUND_COLOR* : FlColor = 0
  FL_BACKGROUND2_COLOR*: FlColor = 7
  FL_INACTIVE_COLOR*   : FlColor = 8
  FL_SELECTION_COLOR*  : FlColor = 15
  FL_GRAY0*            : FlColor = 32
  FL_DARK3*            : FlColor = 39
  FL_DARK2*            : FlColor = 45
  FL_DARK1*            : FlColor = 47
  FL_BACKGROUND_COLOR* : FlColor = 49
  FL_LIGHT1*           : FlColor = 50
  FL_LIGHT2*           : FlColor = 52
  FL_LIGHT3*           : FlColor = 54
  FL_BLACK*            : FlColor = 56
  FL_RED*              : FlColor = 88
  FL_GREEN*            : FlColor = 63
  FL_YELLOW*           : FlColor = 95
  FL_BLUE*             : FlColor = 216
  FL_MAGENTA*          : FlColor = 248
  FL_CYAN*             : FlColor = 223
  FL_DARK_RED*         : FlColor = 72
  FL_DARK_GREEN*       : FlColor = 60
  FL_DARK_YELLOW*      : FlColor = 76
  FL_DARK_BLUE*        : FlColor = 136
  FL_DARK_MAGENTA*     : FlColor = 152
  FL_DARK_CYAN*        : FlColor = 140
  FL_WHITE*            : FlColor = 255
  FL_GRAY*             : FlColor = 49   # == FL_BACKGROUND_COLOR

proc fl_rgb_color*(r, g, b: uint8): FlColor {.importcpp: "fl_rgb_color(@)", header: "<FL/Enumerations.H>".}
proc fl_color_average*(c1, c2: FlColor, weight: cfloat): FlColor {.importcpp: "fl_color_average(@)", header: "<FL/Enumerations.H>".}
proc fl_lighter*(c: FlColor): FlColor {.importcpp: "fl_lighter(@)", header: "<FL/Enumerations.H>".}
proc fl_darker*(c: FlColor): FlColor  {.importcpp: "fl_darker(@)",  header: "<FL/Enumerations.H>".}
proc fl_contrast*(fg, bg: FlColor): FlColor {.importcpp: "fl_contrast(@)", header: "<FL/Enumerations.H>".}

# ---------------------------------------------------------------------------
# Font constants
# ---------------------------------------------------------------------------

const
  FL_HELVETICA*             : FlFont = 0
  FL_HELVETICA_BOLD*        : FlFont = 1
  FL_HELVETICA_ITALIC*      : FlFont = 2
  FL_HELVETICA_BOLD_ITALIC* : FlFont = 3
  FL_COURIER*               : FlFont = 4
  FL_COURIER_BOLD*          : FlFont = 5
  FL_COURIER_ITALIC*        : FlFont = 6
  FL_COURIER_BOLD_ITALIC*   : FlFont = 7
  FL_TIMES*                 : FlFont = 8
  FL_TIMES_BOLD*            : FlFont = 9
  FL_TIMES_ITALIC*          : FlFont = 10
  FL_TIMES_BOLD_ITALIC*     : FlFont = 11
  FL_SYMBOL*                : FlFont = 12
  FL_SCREEN*                : FlFont = 13
  FL_SCREEN_BOLD*           : FlFont = 14
  FL_ZAPF_DINGBATS*         : FlFont = 15

# ---------------------------------------------------------------------------
# Align constants
# ---------------------------------------------------------------------------

const
  FL_ALIGN_CENTER*          : FlAlign = 0x0000
  FL_ALIGN_TOP*             : FlAlign = 0x0001
  FL_ALIGN_BOTTOM*          : FlAlign = 0x0002
  FL_ALIGN_LEFT*            : FlAlign = 0x0004
  FL_ALIGN_RIGHT*           : FlAlign = 0x0008
  FL_ALIGN_INSIDE*          : FlAlign = 0x0010
  FL_ALIGN_CLIP*            : FlAlign = 0x0040
  FL_ALIGN_WRAP*            : FlAlign = 0x0080
  FL_ALIGN_TOP_LEFT*        : FlAlign = FL_ALIGN_TOP or FL_ALIGN_LEFT
  FL_ALIGN_TOP_RIGHT*       : FlAlign = FL_ALIGN_TOP or FL_ALIGN_RIGHT
  FL_ALIGN_BOTTOM_LEFT*     : FlAlign = FL_ALIGN_BOTTOM or FL_ALIGN_LEFT
  FL_ALIGN_BOTTOM_RIGHT*    : FlAlign = FL_ALIGN_BOTTOM or FL_ALIGN_RIGHT

# ---------------------------------------------------------------------------
# Box type constants
# ---------------------------------------------------------------------------

const
  FL_NO_BOX*          : FlBoxtype = 0
  FL_FLAT_BOX*        : FlBoxtype = 1
  FL_UP_BOX*          : FlBoxtype = 2
  FL_DOWN_BOX*        : FlBoxtype = 3
  FL_UP_FRAME*        : FlBoxtype = 4
  FL_DOWN_FRAME*      : FlBoxtype = 5
  FL_THIN_UP_BOX*     : FlBoxtype = 6
  FL_THIN_DOWN_BOX*   : FlBoxtype = 7
  FL_THIN_UP_FRAME*   : FlBoxtype = 8
  FL_THIN_DOWN_FRAME* : FlBoxtype = 9
  FL_ENGRAVED_BOX*    : FlBoxtype = 10
  FL_EMBOSSED_BOX*    : FlBoxtype = 11
  FL_ENGRAVED_FRAME*  : FlBoxtype = 12
  FL_EMBOSSED_FRAME*  : FlBoxtype = 13
  FL_BORDER_BOX*      : FlBoxtype = 14
  FL_SHADOW_BOX*      : FlBoxtype = 15
  FL_BORDER_FRAME*    : FlBoxtype = 16
  FL_SHADOW_FRAME*    : FlBoxtype = 17
  FL_ROUNDED_BOX*     : FlBoxtype = 18
  FL_RSHADOW_BOX*     : FlBoxtype = 19
  FL_ROUNDED_FRAME*   : FlBoxtype = 20
  FL_RFLAT_BOX*       : FlBoxtype = 21
  FL_ROUND_UP_BOX*    : FlBoxtype = 22
  FL_ROUND_DOWN_BOX*  : FlBoxtype = 23
  FL_DIAMOND_UP_BOX*  : FlBoxtype = 24
  FL_DIAMOND_DOWN_BOX*: FlBoxtype = 25
  FL_OVAL_BOX*        : FlBoxtype = 26
  FL_OSHADOW_BOX*     : FlBoxtype = 27
  FL_OVAL_FRAME*      : FlBoxtype = 28
  FL_OFLAT_BOX*       : FlBoxtype = 29
  FL_PLASTIC_UP_BOX*  : FlBoxtype = 30
  FL_PLASTIC_DOWN_BOX*: FlBoxtype = 31
  FL_PLASTIC_UP_FRAME*: FlBoxtype = 32
  FL_PLASTIC_DOWN_FRAME*: FlBoxtype = 33
  FL_PLASTIC_THIN_UP_BOX*: FlBoxtype = 34
  FL_PLASTIC_THIN_DOWN_BOX*: FlBoxtype = 35
  FL_PLASTIC_ROUND_UP_BOX*: FlBoxtype = 38
  FL_PLASTIC_ROUND_DOWN_BOX*: FlBoxtype = 39
  FL_GTK_UP_BOX*      : FlBoxtype = 40
  FL_GTK_DOWN_BOX*    : FlBoxtype = 41
  FL_GTK_UP_FRAME*    : FlBoxtype = 42
  FL_GTK_DOWN_FRAME*  : FlBoxtype = 43
  FL_GTK_THIN_UP_BOX* : FlBoxtype = 44
  FL_GTK_THIN_DOWN_BOX*: FlBoxtype = 45
  FL_GTK_THIN_UP_FRAME*: FlBoxtype = 46
  FL_GTK_THIN_DOWN_FRAME*: FlBoxtype = 47
  FL_GTK_ROUND_UP_BOX*: FlBoxtype = 48
  FL_GTK_ROUND_DOWN_BOX*: FlBoxtype = 49

# ---------------------------------------------------------------------------
# Event constants
# ---------------------------------------------------------------------------

const
  FL_NO_EVENT*   = 0
  FL_PUSH*       = 1
  FL_RELEASE*    = 2
  FL_ENTER*      = 3
  FL_LEAVE*      = 4
  FL_DRAG*       = 5
  FL_FOCUS*      = 6
  FL_UNFOCUS*    = 7
  FL_KEYBOARD*   = 8
  FL_KEYDOWN*    = 8
  FL_KEYUP*      = 9
  FL_CLOSE*      = 10
  FL_MOVE*       = 11
  FL_SHORTCUT*   = 12
  FL_DEACTIVATE* = 13
  FL_ACTIVATE*   = 14
  FL_HIDE*       = 15
  FL_SHOW*       = 16
  FL_PASTE*      = 17
  FL_SELECTIONCLEAR* = 18
  FL_MOUSEWHEEL* = 19
  FL_DND_ENTER*  = 20
  FL_DND_DRAG*   = 21
  FL_DND_LEAVE*  = 22
  FL_DND_RELEASE* = 23
  FL_SCREEN_CONFIGURATION_CHANGED* = 24
  FL_FULLSCREEN* = 25

# Fl_When
const
  FL_WHEN_NEVER*       : FlWhen = 0
  FL_WHEN_CHANGED*     : FlWhen = 1
  FL_WHEN_NOT_CHANGED* : FlWhen = 2
  FL_WHEN_RELEASE*     : FlWhen = 4
  FL_WHEN_RELEASE_ALWAYS*: FlWhen = 6
  FL_WHEN_ENTER_KEY*   : FlWhen = 8
  FL_WHEN_ENTER_KEY_ALWAYS*: FlWhen = 10

# ---------------------------------------------------------------------------
# Key constants (subset of most useful)
# ---------------------------------------------------------------------------

# Key constants use FK_ prefix to avoid Nim case-insensitive clashes
# with FL_ event/widget names (Nim treats FL_Enter == FL_ENTER == flenter etc.)
const
  FK_Button*     = 0xfee8  ## Mouse button base (FK_Button + n = mouse button n)
  FK_BackSpace*  = 0xff08
  FK_Tab*        = 0xff09
  FK_Enter*      = 0xff0d  ## Enter / Return key
  FK_Pause*      = 0xff13
  FK_ScrollLock* = 0xff14
  FK_Escape*     = 0xff1b
  FK_Home*       = 0xff50
  FK_Left*       = 0xff51
  FK_Up*         = 0xff52
  FK_Right*      = 0xff53
  FK_Down*       = 0xff54
  FK_PageUp*     = 0xff55
  FK_PageDown*   = 0xff56
  FK_End*        = 0xff57
  FK_Print*      = 0xff61
  FK_Insert*     = 0xff63
  FK_Menu*       = 0xff67
  FK_Delete*     = 0xffff
  FK_F*          = 0xffbd  ## FK_F + n = Fn key  (e.g. FK_F+1 = F1)
  FK_ShiftL*     = 0xffe1
  FK_ShiftR*     = 0xffe2
  FK_ControlL*   = 0xffe3
  FK_ControlR*   = 0xffe4
  FK_CapsLock*   = 0xffe5
  FK_MetaL*      = 0xffe7
  FK_MetaR*      = 0xffe8
  FK_AltL*       = 0xffe9
  FK_AltR*       = 0xffea
  FK_KP*         = 0xff80  ## FK_KP + n = keypad digit n

# ---------------------------------------------------------------------------
# Fl (main application namespace) – free functions
# ---------------------------------------------------------------------------

proc flRun*(): cint {.importcpp: "Fl::run()", header: "<FL/Fl.H>".}
  ## Run the FLTK event loop. Returns when all windows are closed.

proc flCheck*(): cint {.importcpp: "Fl::check()", header: "<FL/Fl.H>".}
  ## Process pending events. Returns non-zero if any windows remain open.

proc flWait*(): cint {.importcpp: "Fl::wait()", header: "<FL/Fl.H>".}
  ## Wait for an event and process it.

proc flWaitFor*(time: cdouble): cdouble {.importcpp: "Fl::wait(@)", header: "<FL/Fl.H>".}
  ## Wait up to `time` seconds for an event.

proc flReady*(): cint {.importcpp: "Fl::ready()", header: "<FL/Fl.H>".}
  ## Returns true if any events are pending.

proc flVersion*(): cdouble {.importcpp: "Fl::version()", header: "<FL/Fl.H>".}

proc flScheme*(name: cstring): cint {.importcpp: "Fl::scheme(@)", header: "<FL/Fl.H>".}
  ## Set color scheme: "gtk+", "gleam", "plastic", "base", "oxy", or nil for default.

proc flGetScheme*(): cstring {.importcpp: "Fl::scheme()", header: "<FL/Fl.H>".}

proc flBackground*(r, g, b: uint8) {.importcpp: "Fl::background(@)", header: "<FL/Fl.H>".}
proc flForeground*(r, g, b: uint8) {.importcpp: "Fl::foreground(@)", header: "<FL/Fl.H>".}
proc flBackground2*(r, g, b: uint8) {.importcpp: "Fl::background2(@)", header: "<FL/Fl.H>".}
proc flGetSystemColors*() {.importcpp: "Fl::get_system_colors()", header: "<FL/Fl.H>".}

proc flAddTimeout*(t: cdouble, cb: FlTimeoutHandler, data: pointer = nil) {.importcpp: "Fl::add_timeout(@)", header: "<FL/Fl.H>".}
proc flRepeatTimeout*(t: cdouble, cb: FlTimeoutHandler, data: pointer = nil) {.importcpp: "Fl::repeat_timeout(@)", header: "<FL/Fl.H>".}
proc flRemoveTimeout*(cb: FlTimeoutHandler, data: pointer = nil) {.importcpp: "Fl::remove_timeout(@)", header: "<FL/Fl.H>".}
proc flHasTimeout*(cb: FlTimeoutHandler, data: pointer = nil): cint {.importcpp: "Fl::has_timeout(@)", header: "<FL/Fl.H>".}

proc flAddIdle*(cb: FlIdleHandler, data: pointer = nil) {.importcpp: "Fl::add_idle(@)", header: "<FL/Fl.H>".}
proc flRemoveIdle*(cb: FlIdleHandler, data: pointer = nil) {.importcpp: "Fl::remove_idle(@)", header: "<FL/Fl.H>".}
proc flHasIdle*(cb: FlIdleHandler, data: pointer = nil): cint {.importcpp: "Fl::has_idle(@)", header: "<FL/Fl.H>".}

proc flEventX*(): cint    {.importcpp: "Fl::event_x()",    header: "<FL/Fl.H>".}
proc flEventY*(): cint    {.importcpp: "Fl::event_y()",    header: "<FL/Fl.H>".}
proc flEventXRoot*(): cint {.importcpp: "Fl::event_x_root()", header: "<FL/Fl.H>".}
proc flEventYRoot*(): cint {.importcpp: "Fl::event_y_root()", header: "<FL/Fl.H>".}
proc flEventButton*(): cint {.importcpp: "Fl::event_button()", header: "<FL/Fl.H>".}
proc flEventKey*(): cint  {.importcpp: "Fl::event_key()",  header: "<FL/Fl.H>".}
proc flEventText*(): cstring {.importcpp: "Fl::event_text()", header: "<FL/Fl.H>".}
proc flEventLength*(): cint {.importcpp: "Fl::event_length()", header: "<FL/Fl.H>".}
proc flEventState*(): cint  {.importcpp: "Fl::event_state()", header: "<FL/Fl.H>".}
proc flEventClicks*(): cint {.importcpp: "Fl::event_clicks()", header: "<FL/Fl.H>".}
proc flEventIsClick*(): cint {.importcpp: "Fl::event_is_click()", header: "<FL/Fl.H>".}
proc flEventDx*(): cint   {.importcpp: "Fl::event_dx()",   header: "<FL/Fl.H>".}
proc flEventDy*(): cint   {.importcpp: "Fl::event_dy()",   header: "<FL/Fl.H>".}

proc flPushed*(): ptr FlWidget   {.importcpp: "Fl::pushed()",     header: "<FL/Fl.H>".}
proc flGetFocusWidget*(): ptr FlWidget {.importcpp: "Fl::focus()", header: "<FL/Fl.H>".}
proc flBelowmouse*(): ptr FlWidget {.importcpp: "Fl::belowmouse()", header: "<FL/Fl.H>".}

proc flVisibleFocus*(v: cint) {.importcpp: "Fl::visible_focus(@)", header: "<FL/Fl.H>".}
proc flGetVisibleFocus*(): cint {.importcpp: "Fl::visible_focus()", header: "<FL/Fl.H>".}

proc flDndTextOps*(v: cint) {.importcpp: "Fl::dnd_text_ops(@)", header: "<FL/Fl.H>".}
proc flGetDndTextOps*(): cint {.importcpp: "Fl::dnd_text_ops()", header: "<FL/Fl.H>".}

proc flScrollbarSize*(): cint {.importcpp: "Fl::scrollbar_size()", header: "<FL/Fl.H>".}
proc flSetScrollbarSize*(w: cint) {.importcpp: "Fl::scrollbar_size(@)", header: "<FL/Fl.H>".}

proc flCopyToClipboard*(stuff: cstring, len: cint, clipboard: cint = 1) {.importcpp: "Fl::copy(@)", header: "<FL/Fl.H>".}
proc flPasteFromClipboard*(receiver: ptr FlWidget, clipboard: cint = 1) {.importcpp: "Fl::paste(@)", header: "<FL/Fl.H>".}

# Screen geometry
proc flScreenCount*(): cint {.importcpp: "Fl::screen_count()", header: "<FL/Fl.H>".}
proc flScreenWorkArea*(x, y, w, h: var cint, mx, my: cint) {.importcpp: "Fl::screen_work_area(@)", header: "<FL/Fl.H>".}
proc flScreenXywh*(x, y, w, h: var cint, mx, my: cint) {.importcpp: "Fl::screen_xywh(@)", header: "<FL/Fl.H>".}
proc flScreenDpi*(h: var cfloat, v: var cfloat, n: cint = 0) {.importcpp: "Fl::screen_dpi(@)", header: "<FL/Fl.H>".}
proc flScreenScale*(n: cint): cfloat {.importcpp: "Fl::screen_scale(@)", header: "<FL/Fl.H>".}
proc flSetScreenScale*(n: cint, f: cfloat) {.importcpp: "Fl::screen_scale(@)", header: "<FL/Fl.H>".}

# ---------------------------------------------------------------------------
# Fl_Widget – base methods (via pointer)
# ---------------------------------------------------------------------------

proc x*(w: ptr FlWidget): cint  {.importcpp: "#->x()", header: "<FL/Fl_Widget.H>".}
proc y*(w: ptr FlWidget): cint  {.importcpp: "#->y()", header: "<FL/Fl_Widget.H>".}
proc ww*(w: ptr FlWidget): cint {.importcpp: "#->w()", header: "<FL/Fl_Widget.H>".}
proc wh*(w: ptr FlWidget): cint {.importcpp: "#->h()", header: "<FL/Fl_Widget.H>".}

proc resize*(w: ptr FlWidget, x, y, ww, hh: cint) {.importcpp: "#->resize(@)", header: "<FL/Fl_Widget.H>".}
proc position*(w: ptr FlWidget, x, y: cint) {.importcpp: "#->position(@)", header: "<FL/Fl_Widget.H>".}
proc size*(w: ptr FlWidget, ww, hh: cint) {.importcpp: "#->size(@)", header: "<FL/Fl_Widget.H>".}

proc label*(w: ptr FlWidget): cstring {.importcpp: "#->label()", header: "<FL/Fl_Widget.H>".}
proc setLabel*(w: ptr FlWidget, s: cstring) {.importcpp: "#->label(@)", header: "<FL/Fl_Widget.H>".}
proc copyLabel*(w: ptr FlWidget, s: cstring) {.importcpp: "#->copy_label(@)", header: "<FL/Fl_Widget.H>".}

proc color*(w: ptr FlWidget): FlColor {.importcpp: "#->color()", header: "<FL/Fl_Widget.H>".}
proc setColor*(w: ptr FlWidget, c: FlColor) {.importcpp: "#->color(@)", header: "<FL/Fl_Widget.H>".}
proc setColor2*(w: ptr FlWidget, c, sc: FlColor) {.importcpp: "#->color(@, @)", header: "<FL/Fl_Widget.H>".}
proc selectionColor*(w: ptr FlWidget): FlColor {.importcpp: "#->selection_color()", header: "<FL/Fl_Widget.H>".}
proc setSelectionColor*(w: ptr FlWidget, c: FlColor) {.importcpp: "#->selection_color(@)", header: "<FL/Fl_Widget.H>".}

proc labeltype*(w: ptr FlWidget): cint {.importcpp: "#->labeltype()", header: "<FL/Fl_Widget.H>".}
proc setLabeltype*(w: ptr FlWidget, t: cint) {.importcpp: "#->labeltype(@)", header: "<FL/Fl_Widget.H>".}
proc labelfont*(w: ptr FlWidget): FlFont {.importcpp: "#->labelfont()", header: "<FL/Fl_Widget.H>".}
proc setLabelfont*(w: ptr FlWidget, f: FlFont) {.importcpp: "#->labelfont(@)", header: "<FL/Fl_Widget.H>".}
proc labelsize*(w: ptr FlWidget): FlFontsize {.importcpp: "#->labelsize()", header: "<FL/Fl_Widget.H>".}
proc setLabelsize*(w: ptr FlWidget, s: FlFontsize) {.importcpp: "#->labelsize(@)", header: "<FL/Fl_Widget.H>".}
proc labelcolor*(w: ptr FlWidget): FlColor {.importcpp: "#->labelcolor()", header: "<FL/Fl_Widget.H>".}
proc setLabelcolor*(w: ptr FlWidget, c: FlColor) {.importcpp: "#->labelcolor(@)", header: "<FL/Fl_Widget.H>".}

proc align*(w: ptr FlWidget): FlAlign  {.importcpp: "#->align()", header: "<FL/Fl_Widget.H>".}
proc setAlign*(w: ptr FlWidget, a: FlAlign) {.importcpp: "#->align(@)", header: "<FL/Fl_Widget.H>".}
proc box*(w: ptr FlWidget): FlBoxtype  {.importcpp: "#->box()", header: "<FL/Fl_Widget.H>".}
proc setBox*(w: ptr FlWidget, b: FlBoxtype) {.importcpp: "#->box(@)", header: "<FL/Fl_Widget.H>".}

proc callback*(w: ptr FlWidget, cb: FlCallback, data: pointer = nil) {.importcpp: "#->callback(@)", header: "<FL/Fl_Widget.H>".}
# proc callback*(w: ptr FlWidget, cb: FlCallback) {.importcpp: "#->callback(@)", header: "<FL/Fl_Widget.H>".}
proc userData*(w: ptr FlWidget): pointer {.importcpp: "#->user_data()", header: "<FL/Fl_Widget.H>".}
proc setUserData*(w: ptr FlWidget, data: pointer) {.importcpp: "#->user_data(@)", header: "<FL/Fl_Widget.H>".}
proc `when`*(w: ptr FlWidget, v: FlWhen) {.importcpp: "#->when(@)", header: "<FL/Fl_Widget.H>".}
proc getWhen*(w: ptr FlWidget): FlWhen  {.importcpp: "#->when()", header: "<FL/Fl_Widget.H>".}

proc redraw*(w: ptr FlWidget)    {.importcpp: "#->redraw()", header: "<FL/Fl_Widget.H>".}
proc redrawLabel*(w: ptr FlWidget) {.importcpp: "#->redraw_label()", header: "<FL/Fl_Widget.H>".}
proc show*(w: ptr FlWidget)      {.importcpp: "#->show()", header: "<FL/Fl_Widget.H>".}
proc hide*(w: ptr FlWidget)      {.importcpp: "#->hide()", header: "<FL/Fl_Widget.H>".}
proc activate*(w: ptr FlWidget)  {.importcpp: "#->activate()", header: "<FL/Fl_Widget.H>".}
proc deactivate*(w: ptr FlWidget){.importcpp: "#->deactivate()", header: "<FL/Fl_Widget.H>".}
proc active*(w: ptr FlWidget): cint {.importcpp: "#->active()", header: "<FL/Fl_Widget.H>".}
proc visible*(w: ptr FlWidget): cint {.importcpp: "#->visible()", header: "<FL/Fl_Widget.H>".}
proc visibleR*(w: ptr FlWidget): cint {.importcpp: "#->visible_r()", header: "<FL/Fl_Widget.H>".}
proc takeFocus*(w: ptr FlWidget): cint {.importcpp: "#->take_focus()", header: "<FL/Fl_Widget.H>".}
proc changed*(w: ptr FlWidget): cint {.importcpp: "#->changed()", header: "<FL/Fl_Widget.H>".}
proc setChanged*(w: ptr FlWidget) {.importcpp: "#->set_changed()", header: "<FL/Fl_Widget.H>".}
proc clearChanged*(w: ptr FlWidget) {.importcpp: "#->clear_changed()", header: "<FL/Fl_Widget.H>".}
proc doCallback*(w: ptr FlWidget) {.importcpp: "#->do_callback()", header: "<FL/Fl_Widget.H>".}
proc tooltip*(w: ptr FlWidget): cstring {.importcpp: "#->tooltip()", header: "<FL/Fl_Widget.H>".}
proc setTooltip*(w: ptr FlWidget, s: cstring) {.importcpp: "#->tooltip(@)", header: "<FL/Fl_Widget.H>".}
proc damage*(w: ptr FlWidget): uint8 {.importcpp: "#->damage()", header: "<FL/Fl_Widget.H>".}
proc setDamage*(w: ptr FlWidget, mask: uint8) {.importcpp: "#->damage(@)", header: "<FL/Fl_Widget.H>".}

# Cast helpers – convert derived pointer to base
proc asWidget*(w: ptr FlWindow): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlButton): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlInput): ptr FlWidget  = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlBox): ptr FlWidget    = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlOutput): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlMultilineOutput): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlGroup): ptr FlWidget  = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlChoice): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlCheckButton): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlRadioRoundButton): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlToggleButton): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlReturnButton): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlMenuBar): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlValueSlider): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlHorValueSlider): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlSlider): ptr FlWidget  = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlDial): ptr FlWidget    = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlProgress): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlSpinner): ptr FlWidget  = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlCounter): ptr FlWidget  = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlTabs): ptr FlWidget     = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlScroll): ptr FlWidget   = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlPack): ptr FlWidget     = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlTextEditor): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlTextDisplay): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlTree): ptr FlWidget     = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlMultilineInput): ptr FlWidget = cast[ptr FlWidget](w)
proc asWidget*(w: ptr FlMenuButton): ptr FlWidget = cast[ptr FlWidget](w)

# ---------------------------------------------------------------------------
# Fl_Window
# ---------------------------------------------------------------------------

proc newFlWindow*(x, y, w, h: cint, label: cstring = nil): ptr FlWindow {.
  importcpp: "new Fl_Window(@)", header: "<FL/Fl_Window.H>".}

proc newFlWindow*(w, h: cint, label: cstring = nil): ptr FlWindow {.
  importcpp: "new Fl_Window(@)", header: "<FL/Fl_Window.H>".}

proc show*(win: ptr FlWindow)   {.importcpp: "#->show()", header: "<FL/Fl_Window.H>".}
proc hide*(win: ptr FlWindow)   {.importcpp: "#->hide()", header: "<FL/Fl_Window.H>".}
proc showWindow*(win: ptr FlWindow, argc: cint, argv: cstringArray) {.importcpp: "#->show(@)", header: "<FL/Fl_Window.H>".}
proc resizable*(win: ptr FlWindow, w: ptr FlWidget) {.importcpp: "#->resizable(@)", header: "<FL/Fl_Window.H>".}
proc resizable*(win: ptr FlWindow, w: ptr FlGroup) {.importcpp: "#->resizable(@)", header: "<FL/Fl_Window.H>".}
proc beginGroup*(win: ptr FlWindow) {.importcpp: "#->begin()", header: "<FL/Fl_Window.H>".}
proc endGroup*(win: ptr FlWindow)   {.importcpp: "#->end()",   header: "<FL/Fl_Window.H>".}
proc setModal*(win: ptr FlWindow)   {.importcpp: "#->set_modal()", header: "<FL/Fl_Window.H>".}
proc setNonModal*(win: ptr FlWindow) {.importcpp: "#->set_non_modal()", header: "<FL/Fl_Window.H>".}
proc modal*(win: ptr FlWindow): cint {.importcpp: "#->modal()", header: "<FL/Fl_Window.H>".}
proc border*(win: ptr FlWindow, b: cint) {.importcpp: "#->border(@)", header: "<FL/Fl_Window.H>".}
proc getBorder*(win: ptr FlWindow): cint {.importcpp: "#->border()", header: "<FL/Fl_Window.H>".}
proc fullscreen*(win: ptr FlWindow) {.importcpp: "#->fullscreen()", header: "<FL/Fl_Window.H>".}
proc fullscreenOff*(win: ptr FlWindow, x, y, w, h: cint) {.importcpp: "#->fullscreen_off(@)", header: "<FL/Fl_Window.H>".}
proc iconize*(win: ptr FlWindow)    {.importcpp: "#->iconize()", header: "<FL/Fl_Window.H>".}
proc shown*(win: ptr FlWindow): cint {.importcpp: "#->shown()", header: "<FL/Fl_Window.H>".}
proc makeCurrentWindow*(win: ptr FlWindow) {.importcpp: "#->make_current()", header: "<FL/Fl_Window.H>".}
proc setCursor*(win: ptr FlWindow, c: cint) {.importcpp: "#->cursor(@)", header: "<FL/Fl_Window.H>".}
proc copyLabel*(win: ptr FlWindow, s: cstring) {.importcpp: "#->copy_label(@)", header: "<FL/Fl_Window.H>".}
proc label*(win: ptr FlWindow): cstring {.importcpp: "#->label()", header: "<FL/Fl_Window.H>".}
proc setLabel*(win: ptr FlWindow, s: cstring) {.importcpp: "#->label(@)", header: "<FL/Fl_Window.H>".}
proc setSize*(win: ptr FlWindow, w, h: cint) {.importcpp: "#->size(@)", header: "<FL/Fl_Window.H>".}
proc setSizeRange*(win: ptr FlWindow, minw, minh, maxw, maxh: cint) {.importcpp: "#->size_range(@)", header: "<FL/Fl_Window.H>".}
proc callback*(win: ptr FlWindow, cb: FlCallback, data: pointer = nil) {.importcpp: "#->callback(@)", header: "<FL/Fl_Window.H>".}
# proc callback*(win: ptr FlWindow, cb: FlCallback) {.importcpp: "#->callback(@)", header: "<FL/Fl_Window.H>".}
proc xclass*(win: ptr FlWindow, c: cstring) {.importcpp: "#->xclass(@)", header: "<FL/Fl_Window.H>".}

# ---------------------------------------------------------------------------
# Fl_Group
# ---------------------------------------------------------------------------

proc newFlGroup*(x, y, w, h: cint, label: cstring = nil): ptr FlGroup {.
  importcpp: "new Fl_Group(@)", header: "<FL/Fl_Group.H>".}

proc beginGroup*(g: ptr FlGroup) {.importcpp: "#->begin()", header: "<FL/Fl_Group.H>".}
proc endGroup*(g: ptr FlGroup)   {.importcpp: "#->end()",   header: "<FL/Fl_Group.H>".}
proc resizable*(g: ptr FlGroup, w: ptr FlWidget) {.importcpp: "#->resizable(@)", header: "<FL/Fl_Group.H>".}
proc children*(g: ptr FlGroup): cint {.importcpp: "#->children()", header: "<FL/Fl_Group.H>".}
proc child*(g: ptr FlGroup, n: cint): ptr FlWidget {.importcpp: "#->child(@)", header: "<FL/Fl_Group.H>".}
proc addWidget*(g: ptr FlGroup, w: ptr FlWidget) {.importcpp: "#->add(@)", header: "<FL/Fl_Group.H>".}
proc removeWidget*(g: ptr FlGroup, w: ptr FlWidget) {.importcpp: "#->remove(@)", header: "<FL/Fl_Group.H>".}
proc clear*(g: ptr FlGroup)      {.importcpp: "#->clear()",  header: "<FL/Fl_Group.H>".}

# ---------------------------------------------------------------------------
# Fl_Box
# ---------------------------------------------------------------------------

proc newFlBox*(x, y, w, h: cint, label: cstring = nil): ptr FlBox {.
  importcpp: "new Fl_Box(@)", header: "<FL/Fl_Box.H>".}

proc newFlBox*(boxtype: FlBoxtype, x, y, w, h: cint, label: cstring = nil): ptr FlBox {.
  importcpp: "new Fl_Box(@)", header: "<FL/Fl_Box.H>".}

# ---------------------------------------------------------------------------
# Fl_Button and variants
# ---------------------------------------------------------------------------

proc newFlButton*(x, y, w, h: cint, label: cstring = nil): ptr FlButton {.
  importcpp: "new Fl_Button(@)", header: "<FL/Fl_Button.H>".}

proc newFlCheckButton*(x, y, w, h: cint, label: cstring = nil): ptr FlCheckButton {.
  importcpp: "new Fl_Check_Button(@)", header: "<FL/Fl_Check_Button.H>".}

proc newFlRadioRoundButton*(x, y, w, h: cint, label: cstring = nil): ptr FlRadioRoundButton {.
  importcpp: "new Fl_Radio_Round_Button(@)", header: "<FL/Fl_Radio_Round_Button.H>".}

proc newFlToggleButton*(x, y, w, h: cint, label: cstring = nil): ptr FlToggleButton {.
  importcpp: "new Fl_Toggle_Button(@)", header: "<FL/Fl_Toggle_Button.H>".}

proc newFlReturnButton*(x, y, w, h: cint, label: cstring = nil): ptr FlReturnButton {.
  importcpp: "new Fl_Return_Button(@)", header: "<FL/Fl_Return_Button.H>".}

proc value*(b: ptr FlButton): cint     {.importcpp: "#->value()", header: "<FL/Fl_Button.H>".}
proc setValue*(b: ptr FlButton, v: cint) {.importcpp: "#->value(@)", header: "<FL/Fl_Button.H>".}
proc set*(b: ptr FlButton)             {.importcpp: "#->set()",   header: "<FL/Fl_Button.H>".}
proc clear*(b: ptr FlButton)           {.importcpp: "#->clear()", header: "<FL/Fl_Button.H>".}

proc value*(b: ptr FlCheckButton): cint {.importcpp: "#->value()", header: "<FL/Fl_Check_Button.H>".}
proc setValue*(b: ptr FlCheckButton, v: cint) {.importcpp: "#->value(@)", header: "<FL/Fl_Check_Button.H>".}
proc value*(b: ptr FlRadioRoundButton): cint {.importcpp: "#->value()", header: "<FL/Fl_Radio_Round_Button.H>".}
proc setValue*(b: ptr FlRadioRoundButton, v: cint) {.importcpp: "#->value(@)", header: "<FL/Fl_Radio_Round_Button.H>".}
proc value*(b: ptr FlToggleButton): cint {.importcpp: "#->value()", header: "<FL/Fl_Toggle_Button.H>".}

# ---------------------------------------------------------------------------
# Fl_Input and variants
# ---------------------------------------------------------------------------

proc newFlInput*(x, y, w, h: cint, label: cstring = nil): ptr FlInput {.
  importcpp: "new Fl_Input(@)", header: "<FL/Fl_Input.H>".}

proc newFlFloatInput*(x, y, w, h: cint, label: cstring = nil): ptr FlFloatInput {.
  importcpp: "new Fl_Float_Input(@)", header: "<FL/Fl_Float_Input.H>".}

proc newFlIntInput*(x, y, w, h: cint, label: cstring = nil): ptr FlIntInput {.
  importcpp: "new Fl_Int_Input(@)", header: "<FL/Fl_Int_Input.H>".}

proc newFlMultilineInput*(x, y, w, h: cint, label: cstring = nil): ptr FlMultilineInput {.
  importcpp: "new Fl_Multiline_Input(@)", header: "<FL/Fl_Multiline_Input.H>".}

proc newFlOutput*(x, y, w, h: cint, label: cstring = nil): ptr FlOutput {.
  importcpp: "new Fl_Output(@)", header: "<FL/Fl_Output.H>".}

proc newFlMultilineOutput*(x, y, w, h: cint, label: cstring = nil): ptr FlMultilineOutput {.
  importcpp: "new Fl_Multiline_Output(@)", header: "<FL/Fl_Multiline_Output.H>".}

proc getValue*(inp: ptr FlInput): cstring {.importcpp: "#->value()", header: "<FL/Fl_Input.H>".}
proc setValue*(inp: ptr FlInput, s: cstring): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Input.H>".}
proc setValue*(inp: ptr FlInput, s: cstring, len: cint): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Input.H>".}
proc readonly*(inp: ptr FlInput, v: cint) {.importcpp: "#->readonly(@)", header: "<FL/Fl_Input.H>".}
proc getReadonly*(inp: ptr FlInput): cint {.importcpp: "#->readonly()", header: "<FL/Fl_Input.H>".}
proc maxSize*(inp: ptr FlInput): cint    {.importcpp: "#->maximum_size()", header: "<FL/Fl_Input.H>".}
proc setMaxSize*(inp: ptr FlInput, m: cint) {.importcpp: "#->maximum_size(@)", header: "<FL/Fl_Input.H>".}
proc textfont*(inp: ptr FlInput): FlFont {.importcpp: "#->textfont()", header: "<FL/Fl_Input.H>".}
proc setTextfont*(inp: ptr FlInput, f: FlFont) {.importcpp: "#->textfont(@)", header: "<FL/Fl_Input.H>".}
proc textsize*(inp: ptr FlInput): FlFontsize {.importcpp: "#->textsize()", header: "<FL/Fl_Input.H>".}
proc setTextsize*(inp: ptr FlInput, s: FlFontsize) {.importcpp: "#->textsize(@)", header: "<FL/Fl_Input.H>".}
proc textcolor*(inp: ptr FlInput): FlColor {.importcpp: "#->textcolor()", header: "<FL/Fl_Input.H>".}
proc setTextcolor*(inp: ptr FlInput, c: FlColor) {.importcpp: "#->textcolor(@)", header: "<FL/Fl_Input.H>".}

proc getValue*(inp: ptr FlMultilineInput): cstring {.importcpp: "#->value()", header: "<FL/Fl_Multiline_Input.H>".}
proc setValue*(inp: ptr FlMultilineInput, s: cstring): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Multiline_Input.H>".}

proc getValue*(inp: ptr FlOutput): cstring {.importcpp: "#->value()", header: "<FL/Fl_Output.H>".}
proc setValue*(inp: ptr FlOutput, s: cstring): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Output.H>".}

# ---------------------------------------------------------------------------
# Fl_Choice (dropdown)
# ---------------------------------------------------------------------------

proc newFlChoice*(x, y, w, h: cint, label: cstring = nil): ptr FlChoice {.
  importcpp: "new Fl_Choice(@)", header: "<FL/Fl_Choice.H>".}

proc add*(c: ptr FlChoice, s: cstring): cint {.importcpp: "#->add(@)", header: "<FL/Fl_Choice.H>".}
proc value*(c: ptr FlChoice): cint     {.importcpp: "#->value()", header: "<FL/Fl_Choice.H>".}
proc setValue*(c: ptr FlChoice, v: cint): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Choice.H>".}
proc text*(c: ptr FlChoice): cstring   {.importcpp: "#->text()", header: "<FL/Fl_Choice.H>".}
proc clear*(c: ptr FlChoice)           {.importcpp: "#->clear()", header: "<FL/Fl_Choice.H>".}
proc textfont*(c: ptr FlChoice): FlFont {.importcpp: "#->textfont()", header: "<FL/Fl_Choice.H>".}
proc setTextfont*(c: ptr FlChoice, f: FlFont) {.importcpp: "#->textfont(@)", header: "<FL/Fl_Choice.H>".}
proc textsize*(c: ptr FlChoice): FlFontsize {.importcpp: "#->textsize()", header: "<FL/Fl_Choice.H>".}
proc setTextsize*(c: ptr FlChoice, s: FlFontsize) {.importcpp: "#->textsize(@)", header: "<FL/Fl_Choice.H>".}

# ---------------------------------------------------------------------------
# Fl_Menu_Bar
# ---------------------------------------------------------------------------

proc newFlMenuBar*(x, y, w, h: cint, label: cstring = nil): ptr FlMenuBar {.
  importcpp: "new Fl_Menu_Bar(@)", header: "<FL/Fl_Menu_Bar.H>".}

proc add*(mb: ptr FlMenuBar, label: cstring, shortcut: cint, cb: FlCallback,
          data: pointer = nil, flags: cint = 0): cint {.
  importcpp: "#->add(@)", header: "<FL/Fl_Menu_Bar.H>".}

proc add*(mb: ptr FlMenuBar, label: cstring): cint {.
  importcpp: "#->add(@)", header: "<FL/Fl_Menu_Bar.H>".}

proc textsize*(mb: ptr FlMenuBar): FlFontsize {.importcpp: "#->textsize()", header: "<FL/Fl_Menu_Bar.H>".}
proc setTextsize*(mb: ptr FlMenuBar, s: FlFontsize) {.importcpp: "#->textsize(@)", header: "<FL/Fl_Menu_Bar.H>".}

# ---------------------------------------------------------------------------
# Fl_Menu_Button (popup menu)
# ---------------------------------------------------------------------------

proc newFlMenuButton*(x, y, w, h: cint, label: cstring = nil): ptr FlMenuButton {.
  importcpp: "new Fl_Menu_Button(@)", header: "<FL/Fl_Menu_Button.H>".}

proc add*(mb: ptr FlMenuButton, label: cstring, shortcut: cint, cb: FlCallback,
          data: pointer = nil, flags: cint = 0): cint {.
  importcpp: "#->add(@)", header: "<FL/Fl_Menu_Button.H>".}

proc popup*(mb: ptr FlMenuButton): ptr FlWidget {.
  importcpp: "#->popup()", header: "<FL/Fl_Menu_Button.H>".}

# ---------------------------------------------------------------------------
# Fl_Value_Slider / Fl_Hor_Value_Slider / Fl_Slider
# ---------------------------------------------------------------------------

proc newFlValueSlider*(x, y, w, h: cint, label: cstring = nil): ptr FlValueSlider {.
  importcpp: "new Fl_Value_Slider(@)", header: "<FL/Fl_Value_Slider.H>".}

proc newFlHorValueSlider*(x, y, w, h: cint, label: cstring = nil): ptr FlHorValueSlider {.
  importcpp: "new Fl_Hor_Value_Slider(@)", header: "<FL/Fl_Hor_Value_Slider.H>".}

proc newFlSlider*(x, y, w, h: cint, label: cstring = nil): ptr FlSlider {.
  importcpp: "new Fl_Slider(@)", header: "<FL/Fl_Slider.H>".}

proc value*(s: ptr FlValueSlider): cdouble {.importcpp: "#->value()", header: "<FL/Fl_Value_Slider.H>".}
proc setValue*(s: ptr FlValueSlider, v: cdouble): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Value_Slider.H>".}
proc minimum*(s: ptr FlValueSlider): cdouble {.importcpp: "#->minimum()", header: "<FL/Fl_Value_Slider.H>".}
proc setMinimum*(s: ptr FlValueSlider, v: cdouble) {.importcpp: "#->minimum(@)", header: "<FL/Fl_Value_Slider.H>".}
proc maximum*(s: ptr FlValueSlider): cdouble {.importcpp: "#->maximum()", header: "<FL/Fl_Value_Slider.H>".}
proc setMaximum*(s: ptr FlValueSlider, v: cdouble) {.importcpp: "#->maximum(@)", header: "<FL/Fl_Value_Slider.H>".}
proc step*(s: ptr FlValueSlider, v: cdouble) {.importcpp: "#->step(@)", header: "<FL/Fl_Value_Slider.H>".}
proc bounds*(s: ptr FlValueSlider, a, b: cdouble) {.importcpp: "#->bounds(@)", header: "<FL/Fl_Value_Slider.H>".}
proc setType*(s: ptr FlValueSlider, t: uint8) {.importcpp: "#->type(@)", header: "<FL/Fl_Value_Slider.H>".}

proc value*(s: ptr FlHorValueSlider): cdouble {.importcpp: "#->value()", header: "<FL/Fl_Hor_Value_Slider.H>".}
proc setValue*(s: ptr FlHorValueSlider, v: cdouble): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Hor_Value_Slider.H>".}
proc setMinimum*(s: ptr FlHorValueSlider, v: cdouble) {.importcpp: "#->minimum(@)", header: "<FL/Fl_Hor_Value_Slider.H>".}
proc setMaximum*(s: ptr FlHorValueSlider, v: cdouble) {.importcpp: "#->maximum(@)", header: "<FL/Fl_Hor_Value_Slider.H>".}
proc step*(s: ptr FlHorValueSlider, v: cdouble) {.importcpp: "#->step(@)", header: "<FL/Fl_Hor_Value_Slider.H>".}
proc bounds*(s: ptr FlHorValueSlider, a, b: cdouble) {.importcpp: "#->bounds(@)", header: "<FL/Fl_Hor_Value_Slider.H>".}

proc value*(s: ptr FlSlider): cdouble  {.importcpp: "#->value()", header: "<FL/Fl_Slider.H>".}
proc setValue*(s: ptr FlSlider, v: cdouble): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Slider.H>".}
proc bounds*(s: ptr FlSlider, a, b: cdouble) {.importcpp: "#->bounds(@)", header: "<FL/Fl_Slider.H>".}
proc step*(s: ptr FlSlider, v: cdouble) {.importcpp: "#->step(@)", header: "<FL/Fl_Slider.H>".}
proc setType*(s: ptr FlSlider, t: uint8) {.importcpp: "#->type(@)", header: "<FL/Fl_Slider.H>".}

# ---------------------------------------------------------------------------
# Fl_Dial
# ---------------------------------------------------------------------------

proc newFlDial*(x, y, w, h: cint, label: cstring = nil): ptr FlDial {.
  importcpp: "new Fl_Dial(@)", header: "<FL/Fl_Dial.H>".}

proc value*(d: ptr FlDial): cdouble  {.importcpp: "#->value()", header: "<FL/Fl_Dial.H>".}
proc setValue*(d: ptr FlDial, v: cdouble): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Dial.H>".}
proc bounds*(d: ptr FlDial, a, b: cdouble) {.importcpp: "#->bounds(@)", header: "<FL/Fl_Dial.H>".}
proc angles*(d: ptr FlDial, a, b: cshort) {.importcpp: "#->angles(@)", header: "<FL/Fl_Dial.H>".}

# ---------------------------------------------------------------------------
# Fl_Progress
# ---------------------------------------------------------------------------

proc newFlProgress*(x, y, w, h: cint, label: cstring = nil): ptr FlProgress {.
  importcpp: "new Fl_Progress(@)", header: "<FL/Fl_Progress.H>".}

proc value*(p: ptr FlProgress): cfloat {.importcpp: "#->value()", header: "<FL/Fl_Progress.H>".}
proc setValue*(p: ptr FlProgress, v: cfloat) {.importcpp: "#->value(@)", header: "<FL/Fl_Progress.H>".}
proc minimum*(p: ptr FlProgress): cfloat {.importcpp: "#->minimum()", header: "<FL/Fl_Progress.H>".}
proc setMinimum*(p: ptr FlProgress, v: cfloat) {.importcpp: "#->minimum(@)", header: "<FL/Fl_Progress.H>".}
proc maximum*(p: ptr FlProgress): cfloat {.importcpp: "#->maximum()", header: "<FL/Fl_Progress.H>".}
proc setMaximum*(p: ptr FlProgress, v: cfloat) {.importcpp: "#->maximum(@)", header: "<FL/Fl_Progress.H>".}

# ---------------------------------------------------------------------------
# Fl_Spinner
# ---------------------------------------------------------------------------

proc newFlSpinner*(x, y, w, h: cint, label: cstring = nil): ptr FlSpinner {.
  importcpp: "new Fl_Spinner(@)", header: "<FL/Fl_Spinner.H>".}

proc value*(s: ptr FlSpinner): cdouble  {.importcpp: "#->value()", header: "<FL/Fl_Spinner.H>".}
proc setValue*(s: ptr FlSpinner, v: cdouble) {.importcpp: "#->value(@)", header: "<FL/Fl_Spinner.H>".}
proc minimum*(s: ptr FlSpinner): cdouble {.importcpp: "#->minimum()", header: "<FL/Fl_Spinner.H>".}
proc setMinimum*(s: ptr FlSpinner, v: cdouble) {.importcpp: "#->minimum(@)", header: "<FL/Fl_Spinner.H>".}
proc maximum*(s: ptr FlSpinner): cdouble {.importcpp: "#->maximum()", header: "<FL/Fl_Spinner.H>".}
proc setMaximum*(s: ptr FlSpinner, v: cdouble) {.importcpp: "#->maximum(@)", header: "<FL/Fl_Spinner.H>".}
proc step*(s: ptr FlSpinner, v: cdouble) {.importcpp: "#->step(@)", header: "<FL/Fl_Spinner.H>".}

# ---------------------------------------------------------------------------
# Fl_Counter / Fl_Roller
# ---------------------------------------------------------------------------

proc newFlCounter*(x, y, w, h: cint, label: cstring = nil): ptr FlCounter {.
  importcpp: "new Fl_Counter(@)", header: "<FL/Fl_Counter.H>".}

proc value*(c: ptr FlCounter): cdouble  {.importcpp: "#->value()", header: "<FL/Fl_Counter.H>".}
proc setValue*(c: ptr FlCounter, v: cdouble): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Counter.H>".}
proc bounds*(c: ptr FlCounter, a, b: cdouble) {.importcpp: "#->bounds(@)", header: "<FL/Fl_Counter.H>".}

proc newFlRoller*(x, y, w, h: cint, label: cstring = nil): ptr FlRoller {.
  importcpp: "new Fl_Roller(@)", header: "<FL/Fl_Roller.H>".}

proc value*(r: ptr FlRoller): cdouble  {.importcpp: "#->value()", header: "<FL/Fl_Roller.H>".}

# ---------------------------------------------------------------------------
# Fl_Tabs
# ---------------------------------------------------------------------------

proc newFlTabs*(x, y, w, h: cint, label: cstring = nil): ptr FlTabs {.
  importcpp: "new Fl_Tabs(@)", header: "<FL/Fl_Tabs.H>".}

proc beginGroup*(t: ptr FlTabs) {.importcpp: "#->begin()", header: "<FL/Fl_Tabs.H>".}
proc endGroup*(t: ptr FlTabs)   {.importcpp: "#->end()",   header: "<FL/Fl_Tabs.H>".}
proc value*(t: ptr FlTabs): ptr FlWidget {.importcpp: "#->value()", header: "<FL/Fl_Tabs.H>".}
proc setValue*(t: ptr FlTabs, w: ptr FlWidget): cint {.importcpp: "#->value(@)", header: "<FL/Fl_Tabs.H>".}

# ---------------------------------------------------------------------------
# Fl_Scroll
# ---------------------------------------------------------------------------

proc newFlScroll*(x, y, w, h: cint, label: cstring = nil): ptr FlScroll {.
  importcpp: "new Fl_Scroll(@)", header: "<FL/Fl_Scroll.H>".}

proc beginGroup*(s: ptr FlScroll) {.importcpp: "#->begin()", header: "<FL/Fl_Scroll.H>".}
proc endGroup*(s: ptr FlScroll)   {.importcpp: "#->end()",   header: "<FL/Fl_Scroll.H>".}
proc scrollTo*(s: ptr FlScroll, x, y: cint) {.importcpp: "#->scroll_to(@)", header: "<FL/Fl_Scroll.H>".}

# ---------------------------------------------------------------------------
# Fl_Pack
# ---------------------------------------------------------------------------

proc newFlPack*(x, y, w, h: cint, label: cstring = nil): ptr FlPack {.
  importcpp: "new Fl_Pack(@)", header: "<FL/Fl_Pack.H>".}

proc beginGroup*(p: ptr FlPack) {.importcpp: "#->begin()", header: "<FL/Fl_Pack.H>".}
proc endGroup*(p: ptr FlPack)   {.importcpp: "#->end()",   header: "<FL/Fl_Pack.H>".}
proc spacing*(p: ptr FlPack, s: cint) {.importcpp: "#->spacing(@)", header: "<FL/Fl_Pack.H>".}
proc getSpacing*(p: ptr FlPack): cint {.importcpp: "#->spacing()", header: "<FL/Fl_Pack.H>".}
proc setType*(p: ptr FlPack, t: uint8) {.importcpp: "#->type(@)", header: "<FL/Fl_Pack.H>".}

const
  FL_PACK_VERTICAL*  : uint8 = 0
  FL_PACK_HORIZONTAL*: uint8 = 1

# ---------------------------------------------------------------------------
# Fl_Tile
# ---------------------------------------------------------------------------

proc newFlTile*(x, y, w, h: cint, label: cstring = nil): ptr FlTile {.
  importcpp: "new Fl_Tile(@)", header: "<FL/Fl_Tile.H>".}

proc beginGroup*(t: ptr FlTile) {.importcpp: "#->begin()", header: "<FL/Fl_Tile.H>".}
proc endGroup*(t: ptr FlTile)   {.importcpp: "#->end()",   header: "<FL/Fl_Tile.H>".}

# ---------------------------------------------------------------------------
# Fl_Text_Buffer / Fl_Text_Display / Fl_Text_Editor
# ---------------------------------------------------------------------------

proc newFlTextBuffer*(requestedSize: cint = 0, preferredGapSize: cint = 1024): ptr FlTextBuffer {.
  importcpp: "new Fl_Text_Buffer(@)", header: "<FL/Fl_Text_Buffer.H>".}

proc deleteFlTextBuffer*(buf: ptr FlTextBuffer) {.
  importcpp: "delete @", header: "<FL/Fl_Text_Buffer.H>".}

proc text*(buf: ptr FlTextBuffer): cstring {.importcpp: "#->text()", header: "<FL/Fl_Text_Buffer.H>".}
proc setText*(buf: ptr FlTextBuffer, s: cstring) {.importcpp: "#->text(@)", header: "<FL/Fl_Text_Buffer.H>".}
proc append*(buf: ptr FlTextBuffer, s: cstring)  {.importcpp: "#->append(@)", header: "<FL/Fl_Text_Buffer.H>".}
proc insert*(buf: ptr FlTextBuffer, pos: cint, s: cstring) {.importcpp: "#->insert(@)", header: "<FL/Fl_Text_Buffer.H>".}
proc remove*(buf: ptr FlTextBuffer, start, finish: cint) {.importcpp: "#->remove(@)", header: "<FL/Fl_Text_Buffer.H>".}
proc length*(buf: ptr FlTextBuffer): cint {.importcpp: "#->length()", header: "<FL/Fl_Text_Buffer.H>".}

proc newFlTextDisplay*(x, y, w, h: cint, label: cstring = nil): ptr FlTextDisplay {.
  importcpp: "new Fl_Text_Display(@)", header: "<FL/Fl_Text_Display.H>".}

proc setBuffer*(td: ptr FlTextDisplay, buf: ptr FlTextBuffer) {.importcpp: "#->buffer(@)", header: "<FL/Fl_Text_Display.H>".}
proc getBuffer*(td: ptr FlTextDisplay): ptr FlTextBuffer {.importcpp: "#->buffer()", header: "<FL/Fl_Text_Display.H>".}
proc textfont*(td: ptr FlTextDisplay, f: FlFont) {.importcpp: "#->textfont(@)", header: "<FL/Fl_Text_Display.H>".}
proc textsize*(td: ptr FlTextDisplay, s: FlFontsize) {.importcpp: "#->textsize(@)", header: "<FL/Fl_Text_Display.H>".}
proc textcolor*(td: ptr FlTextDisplay, c: FlColor) {.importcpp: "#->textcolor(@)", header: "<FL/Fl_Text_Display.H>".}
proc scrollTo*(td: ptr FlTextDisplay, topLine, horizOffset: cint) {.importcpp: "#->scroll(@)", header: "<FL/Fl_Text_Display.H>".}

proc newFlTextEditor*(x, y, w, h: cint, label: cstring = nil): ptr FlTextEditor {.
  importcpp: "new Fl_Text_Editor(@)", header: "<FL/Fl_Text_Editor.H>".}

proc setBuffer*(te: ptr FlTextEditor, buf: ptr FlTextBuffer) {.importcpp: "#->buffer(@)", header: "<FL/Fl_Text_Editor.H>".}
proc getBuffer*(te: ptr FlTextEditor): ptr FlTextBuffer {.importcpp: "#->buffer()", header: "<FL/Fl_Text_Editor.H>".}
proc textfont*(te: ptr FlTextEditor, f: FlFont) {.importcpp: "#->textfont(@)", header: "<FL/Fl_Text_Editor.H>".}
proc textsize*(te: ptr FlTextEditor, s: FlFontsize) {.importcpp: "#->textsize(@)", header: "<FL/Fl_Text_Editor.H>".}
proc textcolor*(te: ptr FlTextEditor, c: FlColor) {.importcpp: "#->textcolor(@)", header: "<FL/Fl_Text_Editor.H>".}
proc linenumberWidth*(te: ptr FlTextEditor, w: cint) {.importcpp: "#->linenumber_width(@)", header: "<FL/Fl_Text_Editor.H>".}

# ---------------------------------------------------------------------------
# Fl_Tree
# ---------------------------------------------------------------------------

proc newFlTree*(x, y, w, h: cint, label: cstring = nil): ptr FlTree {.
  importcpp: "new Fl_Tree(@)", header: "<FL/Fl_Tree.H>".}

proc add*(t: ptr FlTree, path: cstring): ptr FlTreeItem {.importcpp: "#->add(@)", header: "<FL/Fl_Tree.H>".}
proc remove*(t: ptr FlTree, item: ptr FlTreeItem): cint {.importcpp: "#->remove(@)", header: "<FL/Fl_Tree.H>".}
proc clear*(t: ptr FlTree) {.importcpp: "#->clear()", header: "<FL/Fl_Tree.H>".}
proc root*(t: ptr FlTree): ptr FlTreeItem {.importcpp: "#->root()", header: "<FL/Fl_Tree.H>".}
proc first*(t: ptr FlTree): ptr FlTreeItem {.importcpp: "#->first()", header: "<FL/Fl_Tree.H>".}
proc next*(t: ptr FlTree, item: ptr FlTreeItem): ptr FlTreeItem {.importcpp: "#->next(@)", header: "<FL/Fl_Tree.H>".}
proc selectAll*(t: ptr FlTree, docallback: cint = 0): cint {.importcpp: "#->select_all(@)", header: "<FL/Fl_Tree.H>".}
proc deselectAll*(t: ptr FlTree, docallback: cint = 0): cint {.importcpp: "#->deselect_all(@)", header: "<FL/Fl_Tree.H>".}
proc showSelf*(t: ptr FlTree) {.importcpp: "#->show_self()", header: "<FL/Fl_Tree.H>".}
proc openAll*(t: ptr FlTree, item: ptr FlTreeItem = nil) {.importcpp: "#->open_toggle(@)", header: "<FL/Fl_Tree.H>".}
proc setShowRoot*(t: ptr FlTree, v: cint) {.importcpp: "#->showroot(@)", header: "<FL/Fl_Tree.H>".}

proc label*(item: ptr FlTreeItem): cstring {.importcpp: "#->label()", header: "<FL/Fl_Tree.H>".}
proc setLabel*(item: ptr FlTreeItem, s: cstring) {.importcpp: "#->label(@)", header: "<FL/Fl_Tree.H>".}
proc isSelected*(item: ptr FlTreeItem): cint {.importcpp: "#->is_selected()", header: "<FL/Fl_Tree.H>".}

# ---------------------------------------------------------------------------
# Dialog functions
# ---------------------------------------------------------------------------

proc flMessage*(fmt: cstring) {.importcpp: "fl_message(@)", header: "<FL/fl_ask.H>".}
proc flAlert*(fmt: cstring)   {.importcpp: "fl_alert(@)",   header: "<FL/fl_ask.H>".}
proc flAsk*(fmt: cstring): cint {.importcpp: "fl_ask(@)",   header: "<FL/fl_ask.H>".}
proc flChoiceDlg*(msg, b0, b1, b2: cstring): cint {.importcpp: "fl_choice(@)", header: "<FL/fl_ask.H>".}
proc flInputDlg*(label: cstring, deflt: cstring = nil): cstring {.importcpp: "fl_input(@)", header: "<FL/fl_ask.H>".}
proc flPassword*(label: cstring, deflt: cstring = nil): cstring {.importcpp: "fl_password(@)", header: "<FL/fl_ask.H>".}

proc flColorChooser*(name: cstring, r, g, b: var uint8, cmode: cint = 0): cint {.
  importcpp: "fl_color_chooser(@)", header: "<FL/Fl_Color_Chooser.H>".}

proc flColorChooserDouble*(name: cstring, r, g, b: var cdouble, cmode: cint = 0): cint {.
  importcpp: "fl_color_chooser(@)", header: "<FL/Fl_Color_Chooser.H>".}

proc flFileChooser*(message, pattern, fname: cstring, relative: cint = 0): cstring {.
  importcpp: "fl_file_chooser(@)", header: "<FL/Fl_File_Chooser.H>".}

# ---------------------------------------------------------------------------
# Drawing functions (fl_draw)
# ---------------------------------------------------------------------------

proc flDrawSetColor*(c: FlColor) {.importcpp: "fl_color(@)", header: "<FL/fl_draw.H>".}
proc flDrawGetColor*(): FlColor  {.importcpp: "fl_color()", header: "<FL/fl_draw.H>".}
proc flLineStyle*(style, width: cint, dashes: cstring = nil) {.importcpp: "fl_line_style(@)", header: "<FL/fl_draw.H>".}
proc flPoint*(x, y: cint)        {.importcpp: "fl_point(@)",    header: "<FL/fl_draw.H>".}
proc flLine*(x1, y1, x2, y2: cint) {.importcpp: "fl_line(@)",  header: "<FL/fl_draw.H>".}
proc flRect*(x, y, w, h: cint)   {.importcpp: "fl_rect(@)",    header: "<FL/fl_draw.H>".}
proc flRectf*(x, y, w, h: cint)  {.importcpp: "fl_rectf(@)",   header: "<FL/fl_draw.H>".}
proc flRectf*(x, y, w, h: cint, c: FlColor) {.importcpp: "fl_rectf(@)", header: "<FL/fl_draw.H>".}
proc flArc*(x, y, w, h: cint, a1, a2: cdouble) {.importcpp: "fl_arc(@)", header: "<FL/fl_draw.H>".}
proc flPie*(x, y, w, h: cint, a1, a2: cdouble) {.importcpp: "fl_pie(@)", header: "<FL/fl_draw.H>".}
proc flCircle*(x, y: cdouble, r: cdouble) {.importcpp: "fl_circle(@)", header: "<FL/fl_draw.H>".}
proc flBeginLine*()  {.importcpp: "fl_begin_line()",  header: "<FL/fl_draw.H>".}
proc flEndLine*()    {.importcpp: "fl_end_line()",    header: "<FL/fl_draw.H>".}
proc flBeginLoop*()  {.importcpp: "fl_begin_loop()",  header: "<FL/fl_draw.H>".}
proc flEndLoop*()    {.importcpp: "fl_end_loop()",    header: "<FL/fl_draw.H>".}
proc flBeginPolygon*() {.importcpp: "fl_begin_polygon()", header: "<FL/fl_draw.H>".}
proc flEndPolygon*() {.importcpp: "fl_end_polygon()", header: "<FL/fl_draw.H>".}
proc flVertex*(x, y: cdouble)    {.importcpp: "fl_vertex(@)",  header: "<FL/fl_draw.H>".}
proc flSetFont*(f: FlFont, s: FlFontsize) {.importcpp: "fl_font(@)", header: "<FL/fl_draw.H>".}
proc flGetFont*(): FlFont        {.importcpp: "fl_font()", header: "<FL/fl_draw.H>".}
proc flGetFontsize*(): FlFontsize {.importcpp: "fl_size()", header: "<FL/fl_draw.H>".}
proc flDraw*(s: cstring, x, y: cint) {.importcpp: "fl_draw(@)", header: "<FL/fl_draw.H>".}
proc flDraw*(s: cstring, n: cint, x, y: cint) {.importcpp: "fl_draw(@)", header: "<FL/fl_draw.H>".}
proc flDrawBox*(t: FlBoxtype, x, y, w, h: cint, c: FlColor) {.importcpp: "fl_draw_box(@)", header: "<FL/fl_draw.H>".}
proc flMeasure*(s: cstring, w, h: var cint, draw_symbols: cint = 1) {.importcpp: "fl_measure(@)", header: "<FL/fl_draw.H>".}
proc flWidth*(s: cstring): cdouble {.importcpp: "fl_width(@)", header: "<FL/fl_draw.H>".}
proc flHeight*(): cint           {.importcpp: "fl_height()", header: "<FL/fl_draw.H>".}
proc flDescent*(): cint          {.importcpp: "fl_descent()", header: "<FL/fl_draw.H>".}
proc flPushClip*(x, y, w, h: cint) {.importcpp: "fl_push_clip(@)", header: "<FL/fl_draw.H>".}
proc flPopClip*()                {.importcpp: "fl_pop_clip()", header: "<FL/fl_draw.H>".}
proc flPushNoClip*()             {.importcpp: "fl_push_no_clip()", header: "<FL/fl_draw.H>".}
proc flNotClipped*(x, y, w, h: cint): cint {.importcpp: "fl_not_clipped(@)", header: "<FL/fl_draw.H>".}
proc flBeginOffscreen*(b: pointer) {.importcpp: "fl_begin_offscreen(@)", header: "<FL/fl_draw.H>".}
proc flEndOffscreen*()           {.importcpp: "fl_end_offscreen()", header: "<FL/fl_draw.H>".}
proc flOverlayRect*(x, y, w, h: cint) {.importcpp: "fl_overlay_rect(@)", header: "<FL/fl_draw.H>".}
proc flOverlayClear*()           {.importcpp: "fl_overlay_clear()", header: "<FL/fl_draw.H>".}
proc flCursorColor*(c: FlColor)  {.importcpp: "fl_cursor(@)", header: "<FL/fl_draw.H>".}

# ---------------------------------------------------------------------------
# Convenience: Nim-style constructors that also call end()
# ---------------------------------------------------------------------------
# NOTE: FLTK requires all widgets created between begin()/end() to be
# children of the current group. The helpers below manage that correctly.

template withWindow*(win: ptr FlWindow, body: untyped): untyped =
  beginGroup(win)
  body
  endGroup(win)
  show(win)

template withGroup*(grp: ptr FlGroup, body: untyped): untyped =
  beginGroup(grp)
  body
  endGroup(grp)

template withTabs*(tabs: ptr FlTabs, body: untyped): untyped =
  beginGroup(tabs)
  body
  endGroup(tabs)

template withScroll*(scrl: ptr FlScroll, body: untyped): untyped =
  beginGroup(scrl)
  body
  endGroup(scrl)

template withPack*(pack: ptr FlPack, body: untyped): untyped =
  beginGroup(pack)
  body
  endGroup(pack)

template withTile*(tile: ptr FlTile, body: untyped): untyped =
  beginGroup(tile)
  body
  endGroup(tile)
