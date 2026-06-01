import CoreGraphics

// Tuple: (base, shifted, option, option+shift)
// Keys not in this map pass through to macOS unchanged.
enum KurdishKeyMap {
    static let map: [CGKeyCode: (String, String, String?, String?)] = [

        // Numbers row
        18: ("١", "!",          nil,          nil),
        19: ("٢", "@",          nil,          nil),
        20: ("٣", "#",          nil,          nil),
        21: ("٤", "$",          nil,          nil),
        23: ("٥", "%",          nil,          nil),
        22: ("٦", "\u{066A}",   nil,          nil),  // ٪ Arabic percent
        26: ("٧", "\u{066D}",   nil,          nil),  // ٭ Arabic five-pointed star
        28: ("٨", "*",          nil,          nil),
        25: ("٩", "(",          nil,          nil),  // Shift+9 = ( (Windows convention)
        29: ("٠", ")",          nil,          nil),  // Shift+0 = ) (Windows convention)
        27: ("-",  "_",          "\u{2013}",   "\u{2014}"),  // en dash / em dash
        24: ("=",  "+",          "\u{2260}",   nil),          // ≠

        // Top row
        12: ("ق", "`",           nil,          nil),
        13: ("و", "وو",          nil,          nil),
        14: ("ە", "ي",           "\u{200C}",   "\u{200D}"),  // ZWNJ / ZWJ
        15: ("ر", "ڕ",           nil,          nil),
        17: ("ت", "ط",           nil,          nil),
        16: ("ی", "ێ",           nil,          nil),
        32: ("ئ", "ء",           nil,          nil),
        34: ("ح", "ع",           nil,          nil),
        31: ("ۆ", "ؤ",           nil,          nil),
        35: ("پ", "ث",           nil,          nil),
        33: ("ش", "{",           nil,          nil),
        30: ("ط", "}",           nil,          nil),
        42: ("\\", "|",          nil,          nil),

        // Home row
        0:  ("ا", "آ",           nil,          nil),
        1:  ("س", "ش",           nil,          nil),
        2:  ("د", "ذ",           nil,          nil),
        3:  ("ف", "إ",           nil,          nil),
        5:  ("گ", "غ",           "\u{200E}",   nil),  // LRM
        4:  ("ه", "\u{200C}",    "\u{200F}",   nil),  // ZWNJ base; RLM on option
        38: ("ژ", "أ",           "\u{200D}",   nil),  // ZWJ on option
        40: ("ک", "ك",           nil,          nil),
        37: ("ل", "ڵ",           nil,          nil),
        41: ("؛", ":",           nil,          nil),  // Arabic semicolon
        39: ("ع", "غ",           nil,          nil),

        // Bottom row
        6:  ("ز", "ض",           nil,          nil),
        7:  ("خ", "ص",           nil,          nil),
        8:  ("ج", "چ",           nil,          nil),
        9:  ("ڤ", "ظ",           nil,          nil),
        11: ("ب", "ى",           nil,          nil),
        45: ("ن", "ة",           nil,          nil),
        46: ("م", "ـ",           nil,          nil),  // tatweel on shift
        43: ("،", "<",           "،",          "\u{2039}"),  // Arabic comma; ‹ on opt+shift
        47: (".", ">",           "\u{2026}",   "\u{203A}"),  // … on option; › on opt+shift
        44: ("/", "؟",           "؟",          nil),

        // Special
        49: (" ", " ",           "\u{00A0}",   "\u{00A0}"),  // NBSP on option
        50: ("ـ", "~",           nil,          nil),          // tatweel on base
    ]
}
