--
-- polyglossia-cjk-spacing.lua
-- part of polyglossia v2.8 -- 2025/09/22
--

local glyph_id = node.id"glyph"
local hbox_id  = node.id"hlist"
local vbox_id  = node.id"vlist"
local glue_id  = node.id"glue"
local penalty_id = node.id"penalty"
local whatsit_id = node.id"whatsit"
local math_id  = node.id"math"
local localpar_id = node.id"local_par"
local ins_id = node.id"ins"
local vadjust_id = node.id"adjust"
local mark_id = node.id"mark"

--
-- attr_cjk: variant = plain: 0, JP/classic: 1, KR/modern: 2, SC: 3, TC: 4
--
local attr_cjk = luatexbase.attributes["xpg@attr@cjkspacing"]
--
-- attr_josa: ONLY For Korean. DO NOT declare \newattribute for other langs
--
local attr_josa = luatexbase.attributes["xpg@attr@autojosa"]

--
-- characters after which linebreak is not allowed
--
local nobr_after = {
    [0x28] = 1, -- ( LEFT PARENTHESIS
    [0x3C] = 1, -- < LESS-THAN SIGN
    [0x5B] = 1, -- [ LEFT SQUARE BRACKET
    [0x5C] = 1, -- \ REVERSE SOLIDUS
    [0x60] = 1, -- ` GRAVE ACCENT
    [0x7B] = 1, -- { LEFT CURLY BRACKET
    [0xA1] = 1, -- ¡ INVERTED EXCLAMATION MARK
    [0xAB] = 1, -- « LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    [0xBF] = 1, -- ¿ INVERTED QUESTION MARK
    [0x2018] = 1, -- ‘ LEFT SINGLE QUOTATION MARK
    [0x201C] = 1, -- “ LEFT DOUBLE QUOTATION MARK
    [0x2329] = 1, -- 〈 LEFT-POINTING ANGLE BRACKET
    [0x3008] = 1, -- 〈 LEFT ANGLE BRACKET
    [0x300A] = 1, -- 《 LEFT DOUBLE ANGLE BRACKET
    [0x300C] = 1, -- 「 LEFT CORNER BRACKET
    [0x300E] = 1, -- 『 LEFT WHITE CORNER BRACKET
    [0x3010] = 1, -- 【 LEFT BLACK LENTICULAR BRACKET
    [0x3014] = 1, -- 〔 LEFT TORTOISE SHELL BRACKET
    [0x3016] = 1, -- 〖 LEFT WHITE LENTICULAR BRACKET
    [0x3018] = 1, -- 〘 LEFT WHITE TORTOISE SHELL BRACKET
    [0x301A] = 1, -- 〚 LEFT WHITE SQUARE BRACKET
    [0x301D] = 1, -- 〝 REVERSED DOUBLE PRIME QUOTATION MARK
    [0xFE17] = 1, -- ︗ PRESENTATION FORM FOR VERTICAL LEFT WHITE LENTICULAR BRACKET
    [0xFE35] = 1, -- ︵ PRESENTATION FORM FOR VERTICAL LEFT PARENTHESIS
    [0xFE37] = 1, -- ︷ PRESENTATION FORM FOR VERTICAL LEFT CURLY BRACKET
    [0xFE39] = 1, -- ︹ PRESENTATION FORM FOR VERTICAL LEFT TORTOISE SHELL BRACKET
    [0xFE3B] = 1, -- ︻ PRESENTATION FORM FOR VERTICAL LEFT BLACK LENTICULAR BRACKET
    [0xFE3D] = 1, -- ︽ PRESENTATION FORM FOR VERTICAL LEFT DOUBLE ANGLE BRACKET
    [0xFE3F] = 1, -- ︿ PRESENTATION FORM FOR VERTICAL LEFT ANGLE BRACKET
    [0xFE41] = 1, -- ﹁ PRESENTATION FORM FOR VERTICAL LEFT CORNER BRACKET
    [0xFE43] = 1, -- ﹃ PRESENTATION FORM FOR VERTICAL LEFT WHITE CORNER BRACKET
    [0xFE47] = 1, -- ﹇ PRESENTATION FORM FOR VERTICAL LEFT SQUARE BRACKET
    [0xFE59] = 1, -- ﹙ SMALL LEFT PARENTHESIS
    [0xFE5B] = 1, -- ﹛ SMALL LEFT CURLY BRACKET
    [0xFF03] = 1, -- ＃ FULLWIDTH NUMBER SIGN
    [0xFF04] = 1, -- ＄ FULLWIDTH DOLLAR SIGN
    [0xFE5D] = 1, -- ﹝ SMALL LEFT TORTOISE SHELL BRACKET
    [0xFF08] = 1, -- （ FULLWIDTH LEFT PARENTHESIS
    [0xFF3B] = 1, -- ［ FULLWIDTH LEFT SQUARE BRACKET
    [0xFF40] = 1, -- ｀ FULLWIDTH GRAVE ACCENT
    [0xFF5B] = 1, -- ｛ FULLWIDTH LEFT CURLY BRACKET
    [0xFF5F] = 1, -- ｟ FULLWIDTH LEFT WHITE PARENTHESIS
    [0xFF62] = 1, -- ｢ HALFWIDTH LEFT CORNER BRACKET
    [0xFFE5] = 1, -- ￥ FULLWIDTH YEN SIGN
    [0xFFE6] = 1, -- ￦ FULLWIDTH WON SIGN
}

--
-- characters before which linebreak is not allowed
--   (currently, not much differences among the followings)
--   1: normal chars
--   2: hangul jamo vowels and trailing consonants plus combinings
--   3: kana small letters
--   0: dashes (suppress visible spacing after this char)
--
local nobr_before = setmetatable({
    [0x21] = 1, -- ! EXCLAMATION MARK
    [0x22] = 1, -- " QUOTATION MARK
    [0x27] = 1, -- ' APOSTROPHE
    [0x29] = 1, -- ) RIGHT PARENTHESIS
    [0x2C] = 1, -- , COMMA
    [0x2D] = 0, -- - HYPHEN-MINUS
    [0x2E] = 1, -- . FULL STOP
    [0x2F] = 1, -- / SOLIDUS
    [0x3A] = 1, -- : COLON
    [0x3B] = 1, -- ; SEMICOLON
    [0x3E] = 1, -- > GREATER-THAN SIGN
    [0x3F] = 1, -- ? QUESTION MARK
    [0x5D] = 1, -- ] RIGHT SQUARE BRACKET
    [0x7D] = 1, -- } RIGHT CURLY BRACKET
    [0x7E] = 1, -- ~ TILDE
    [0xAA] = 1, -- ª FEMININE ORDINAL INDICATOR
    [0xB0] = 1, -- ° DEGREE SIGN
    [0xB2] = 1, -- ² SUPERSCRIPT TWO
    [0xB3] = 1, -- ³ SUPERSCRIPT THREE
    [0xB7] = 1, -- · MIDDLE DOT
    [0xB9] = 1, -- ¹ SUPERSCRIPT ONE
    [0xBA] = 1, -- º MASCULINE ORDINAL INDICATOR
    [0xBB] = 1, -- » RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    [0x2013] = 0, -- – EN DASH
    [0x2014] = 0, -- — EM DASH
    [0x2015] = 0, -- ― HORIZONTAL BAR
    [0x2019] = 1, -- ’ RIGHT SINGLE QUOTATION MARK
    [0x201D] = 1, -- ” RIGHT DOUBLE QUOTATION MARK
    [0x2025] = 0, -- ‥ TWO DOT LEADER
    [0x2026] = 0, -- … HORIZONTAL ELLIPSIS
    [0x232A] = 1, -- 〉 RIGHT-POINTING ANGLE BRACKET
    [0x3001] = 1, -- 、 IDEOGRAPHIC COMMA
    [0x3002] = 1, -- 。 IDEOGRAPHIC FULL STOP
    [0x3005] = 1, -- 々 IDEOGRAPHIC ITERATION MARK
    [0x3009] = 1, -- 〉 RIGHT ANGLE BRACKET
    [0x300B] = 1, -- 》 RIGHT DOUBLE ANGLE BRACKET
    [0x300D] = 1, -- 」 RIGHT CORNER BRACKET
    [0x300F] = 1, -- 』 RIGHT WHITE CORNER BRACKET
    [0x3011] = 1, -- 】 RIGHT BLACK LENTICULAR BRACKET
    [0x3015] = 1, -- 〕 RIGHT TORTOISE SHELL BRACKET
    [0x3017] = 1, -- 〗 RIGHT WHITE LENTICULAR BRACKET
    [0x3019] = 1, -- 〙 RIGHT WHITE TORTOISE SHELL BRACKET
    [0x301B] = 1, -- 〛 RIGHT WHITE SQUARE BRACKET
    [0x301C] = 1, -- 〜 WAVE DASH
    [0x301E] = 1, -- 〞 DOUBLE PRIME QUOTATION MARK
    [0x301F] = 1, -- 〟 LOW DOUBLE PRIME QUOTATION MARK
    [0x3035] = 1, -- 〵 VERTICAL KANA REPEAT MARK LOWER HALF
    [0x303B] = 1, -- 〻 VERTICAL IDEOGRAPHIC ITERATION MARK
    [0x303C] = 1, -- 〼 MASU MARK
    [0x3041] = 3, -- ぁ HIRAGANA LETTER SMALL A
    [0x3043] = 3, -- ぃ HIRAGANA LETTER SMALL I
    [0x3045] = 3, -- ぅ HIRAGANA LETTER SMALL U
    [0x3047] = 3, -- ぇ HIRAGANA LETTER SMALL E
    [0x3049] = 3, -- ぉ HIRAGANA LETTER SMALL O
    [0x3063] = 3, -- っ HIRAGANA LETTER SMALL TU
    [0x3083] = 3, -- ゃ HIRAGANA LETTER SMALL YA
    [0x3085] = 3, -- ゅ HIRAGANA LETTER SMALL YU
    [0x3087] = 3, -- ょ HIRAGANA LETTER SMALL YO
    [0x308E] = 3, -- ゎ HIRAGANA LETTER SMALL WA
    [0x3095] = 3, -- ゕ HIRAGANA LETTER SMALL KA
    [0x3096] = 3, -- ゖ HIRAGANA LETTER SMALL KE
    [0x3099] = 2, --  COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK
    [0x309A] = 2, --  COMBINING KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
    [0x309B] = 2, -- ゛ KATAKANA-HIRAGANA VOICED SOUND MARK
    [0x309C] = 2, -- ゜ KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
    [0x309D] = 1, -- ゝ HIRAGANA ITERATION MARK
    [0x309E] = 1, -- ゞ HIRAGANA VOICED ITERATION MARK
    [0x30A0] = 1, -- ゠ KATAKANA-HIRAGANA DOUBLE HYPHEN
    [0x30A1] = 3, -- ァ KATAKANA LETTER SMALL A
    [0x30A3] = 3, -- ィ KATAKANA LETTER SMALL I
    [0x30A5] = 3, -- ゥ KATAKANA LETTER SMALL U
    [0x30A7] = 3, -- ェ KATAKANA LETTER SMALL E
    [0x30A9] = 3, -- ォ KATAKANA LETTER SMALL O
    [0x30C3] = 3, -- ッ KATAKANA LETTER SMALL TU
    [0x30E3] = 3, -- ャ KATAKANA LETTER SMALL YA
    [0x30E5] = 3, -- ュ KATAKANA LETTER SMALL YU
    [0x30E7] = 3, -- ョ KATAKANA LETTER SMALL YO
    [0x30EE] = 3, -- ヮ KATAKANA LETTER SMALL WA
    [0x30F5] = 3, -- ヵ KATAKANA LETTER SMALL KA
    [0x30F6] = 3, -- ヶ KATAKANA LETTER SMALL KE
    [0x30FB] = 1, -- ・ KATAKANA MIDDLE DOT
    [0x30FC] = 1, -- ー KATAKANA-HIRAGANA PROLONGED SOUND MARK
    [0x30FD] = 1, -- ヽ KATAKANA ITERATION MARK
    [0x30FE] = 1, -- ヾ KATAKANA VOICED ITERATION MARK
    [0xFE30] = 0, -- ︰ PRESENTATION FORM FOR VERTICAL TWO DOT LEADER
    [0xFE31] = 0, -- ︱ PRESENTATION FORM FOR VERTICAL EM DASH
    [0xFE32] = 0, -- ︲ PRESENTATION FORM FOR VERTICAL EN DASH
    [0xFE36] = 1, -- ︶ PRESENTATION FORM FOR VERTICAL RIGHT PARENTHESIS
    [0xFE38] = 1, -- ︸ PRESENTATION FORM FOR VERTICAL RIGHT CURLY BRACKET
    [0xFE3A] = 1, -- ︺ PRESENTATION FORM FOR VERTICAL RIGHT TORTOISE SHELL BRACKET
    [0xFE3C] = 1, -- ︼ PRESENTATION FORM FOR VERTICAL RIGHT BLACK LENTICULAR BRACKET
    [0xFE3E] = 1, -- ︾ PRESENTATION FORM FOR VERTICAL RIGHT DOUBLE ANGLE BRACKET
    [0xFE40] = 1, -- ﹀ PRESENTATION FORM FOR VERTICAL RIGHT ANGLE BRACKET
    [0xFE42] = 1, -- ﹂ PRESENTATION FORM FOR VERTICAL RIGHT CORNER BRACKET
    [0xFE44] = 1, -- ﹄ PRESENTATION FORM FOR VERTICAL RIGHT WHITE CORNER BRACKET
    [0xFE48] = 1, -- ﹈ PRESENTATION FORM FOR VERTICAL RIGHT SQUARE BRACKET
    [0xFE5A] = 1, -- ﹚ SMALL RIGHT PARENTHESIS
    [0xFE5C] = 1, -- ﹜ SMALL RIGHT CURLY BRACKET
    [0xFE5E] = 1, -- ﹞ SMALL RIGHT TORTOISE SHELL BRACKET
    [0xFF01] = 1, -- ！ FULLWIDTH EXCLAMATION MARK
    [0xFF09] = 1, -- ） FULLWIDTH RIGHT PARENTHESIS
    [0xFF0C] = 1, -- ， FULLWIDTH COMMA
    [0xFF0E] = 1, -- ． FULLWIDTH FULL STOP
    [0xFF1A] = 1, -- ： FULLWIDTH COLON
    [0xFF1B] = 1, -- ； FULLWIDTH SEMICOLON
    [0xFF1F] = 1, -- ？ FULLWIDTH QUESTION MARK
    [0xFF3D] = 1, -- ］ FULLWIDTH RIGHT SQUARE BRACKET
    [0xFF5D] = 1, -- ｝ FULLWIDTH RIGHT CURLY BRACKET
    [0xFF5E] = 1, -- ～ FULLWIDTH TILDE
    [0xFF60] = 1, -- ｠ FULLWIDTH RIGHT WHITE PARENTHESIS
    [0xFF61] = 1, -- ｡ HALFWIDTH IDEOGRAPHIC FULL STOP
    [0xFF63] = 1, -- ｣ HALFWIDTH RIGHT CORNER BRACKET
    [0xFF64] = 1, -- ､ HALFWIDTH IDEOGRAPHIC COMMA
    [0xFF65] = 1, -- ･ HALFWIDTH KATAKANA MIDDLE DOT
    [0xFF9E] = 2, -- ﾞ HALFWIDTH KATAKANA VOICED SOUND MARK
    [0xFF9F] = 2, -- ﾟ HALFWIDTH KATAKANA SEMI-VOICED SOUND MARK
}, { __index = function(_,c)
        if c >= 0x1160  and c <= 0x11FF  then return 2 end
        if c >= 0xD7B0  and c <= 0xD7FF  then return 2 end
        if c >= 0x302A  and c <= 0x302F  then return 2 end -- tone marks
        if c >= 0x31F0  and c <= 0x31FF  then return 3 end
        if c >= 0xFF67  and c <= 0xFF70  then return 3 end
        if c >= 0xFE00  and c <= 0xFE0F  then return 2 end -- variation selectors
        if c >= 0xFE10  and c <= 0xFE19 and not (c == 0xFE17) then return 1 end
        if c >= 0xFE50  and c <= 0xFE58  then return 1 end
        if c >= 0xE0100 and c <= 0xE01EF then return 2 end -- variation selecters
    end
})

--
-- characters before/after which zero-width glue will be inserted
--      except nobr_before == 0
--
local zero_spacing = {
    [0x23] = 1, -- # NUMBER SIGN
    [0x24] = 1, -- $ DOLLAR SIGN
    [0x25] = 1, -- % PERCENT SIGN
    [0x26] = 1, -- & AMPERSAND
    [0x2A] = 1, -- * ASTERISK
    [0x2B] = 1, -- + PLUS SIGN
    [0x2F] = 1, -- / SOLIDUS
    [0x3C] = 1, -- < LESS-THAN SIGN
    [0x3D] = 1, -- = EQUALS SIGN
    [0x3E] = 1, -- > GREATER-THAN SIGN
    [0x40] = 1, -- @ COMMERCIAL AT
    [0x5C] = 1, -- \ REVERSE SOLIDUS
    [0x5E] = 1, -- ^ CIRCUMFLEX ACCENT
    [0x5F] = 1, -- _ LOW LINE
    [0x7C] = 1, -- | VERTICAL LINE
    [0x7E] = 1, -- ~ TILDE
    [0xA5] = 1, -- ¥ YEN SIGN
    [0xB1] = 1, -- ± PLUS-MINUS SIGN
    [0x2030] = 1, -- ‰ PER MILLE SIGN
    [0x20A9] = 1, -- ₩ WON SIGN
    [0x2103] = 1, -- ℃ DEGREE CELSIUS
    [0x2109] = 1, -- ℉ DEGREE FAHRENHEIT
    [0x223C] = 1, -- ∼ TILDE OPERATOR
    [0x301C] = 1, -- 〜 WAVE DASH
    [0xFF03] = 1, -- ＃ FULLWIDTH NUMBER SIGN
    [0xFF04] = 1, -- ＄ FULLWIDTH DOLLAR SIGN
    [0xFF05] = 1, -- ％ FULLWIDTH PERCENT SIGN
    [0xFF5E] = 1, -- ～ FULLWIDTH TILDE
    [0xFFE5] = 1, -- ￥ FULLWIDTH YEN SIGN
    [0xFFE6] = 1, -- ￦ FULLWIDTH WON SIGN
}

--
-- whether 'c' is a cjk character
--
local function is_cjk (c)
    return c >= 0xAC00  and c <= 0xD7FF
    or     c >= 0x1100  and c <= 0x11FF
    or     c >= 0xA960  and c <= 0xA97F
    or     c >= 0x2E80  and c <= 0x9FFF
    or     c >= 0xF900  and c <= 0xFAFF
    or     c >= 0xFE10  and c <= 0xFE1F
    or     c >= 0xFE30  and c <= 0xFE6F
    or     c >= 0xFF00  and c <= 0xFFEF
    or     c >= 0x1F100 and c <= 0x1F2FF
    or     c >= 0x20000 and c <= 0x3347F
    or     nobr_after[c]  and c > 0x2014
    or     nobr_before[c] and c > 0x2014
end

--
-- classify cjk characters
--   1: openings
--   2: closings
--   3: centered chars
--   4: full stops
--   5: ellipses
--   6: exclamation and question marks
--   0: all others
--
local charclass = setmetatable({
    [0x2018] = 1, [0x201C] = 1, [0x2329] = 1, [0x3008] = 1,
    [0x300A] = 1, [0x300C] = 1, [0x300E] = 1, [0x3010] = 1,
    [0x3014] = 1, [0x3016] = 1, [0x3018] = 1, [0x301A] = 1,
    [0x301D] = 1, [0xFE17] = 1, [0xFE35] = 1, [0xFE37] = 1,
    [0xFE39] = 1, [0xFE3B] = 1, [0xFE3D] = 1, [0xFE3F] = 1,
    [0xFE41] = 1, [0xFE43] = 1, [0xFE47] = 1, [0xFF08] = 1,
    [0xFF3B] = 1, [0xFF5B] = 1, [0xFF5F] = 1, [0xFF62] = 1,
    [0x2019] = 2, [0x201D] = 2, [0x232A] = 2, [0x3001] = 2,
    [0x3009] = 2, [0x300B] = 2, [0x300D] = 2, [0x300F] = 2,
    [0x3011] = 2, [0x3015] = 2, [0x3017] = 2, [0x3019] = 2,
    [0x301B] = 2, [0x301E] = 2, [0x301F] = 2, [0xFE10] = 2,
    [0xFE11] = 2, [0xFE18] = 2, [0xFE36] = 2, [0xFE38] = 2,
    [0xFE3A] = 2, [0xFE3C] = 2, [0xFE3E] = 2, [0xFE40] = 2,
    [0xFE42] = 2, [0xFE44] = 2, [0xFE48] = 2, [0xFF09] = 2,
    [0xFF0C] = 2, [0xFF3D] = 2, [0xFF5D] = 2, [0xFF60] = 2,
    [0xFF63] = 2, [0xFF64] = 2, [0x00B7] = 3, [0x30FB] = 3,
    [0xFF1A] = 3, [0xFF1B] = 3, [0xFF65] = 3, [0x3002] = 4,
    [0xFE12] = 4, [0xFF0E] = 4, [0xFF61] = 4, [0x2015] = 5,
    [0x2025] = 5, [0x2026] = 5, [0xFE19] = 5, [0xFE30] = 5,
    [0xFE31] = 5, [0xFE15] = 6, [0xFE16] = 6, [0xFF01] = 6,
    [0xFF1F] = 6,
}, { __index = function() return 0 end })

--
-- get character class
--      var : variant = plain, JP/classic, KR/modern, SC, TC
--      c   : codepoint
--
local function get_charclass (var, c)
    if var < 3 then
        return charclass[c]
    elseif var == 3 then
        -- SC : these are left aligned
        return (c == 0xFF01 or c == 0xFF1F) and 4 -- FULLWIDTH EXCLAMATION/QUESTION MARK
        or     (c == 0xFF1A or c == 0xFF1B) and 2 -- FULLWIDTH COLON/SEMICOLON
        or     charclass[c]
    end
    -- TC : these are center aligned
    return (c == 0x3001 or c == 0xFF0C) and 3 -- IDEOGRAPHIC/FULLWIDTH COMMA
    or     (c == 0x3002 or c == 0xFF0E) and 3 -- IDEOGRAPHIC/FULLWIDTH FULL STOP -- 5 ?
    or     charclass[c]
end

--
-- table for spacing between char classes
--   1 stands for 0.5*fontsize when variant = JP/classic or SC or TC
--
local intercharclass = { [0] =
    { [0] = nil,    {1,1},  nil,    {.5,.5} },
    { [0] = nil,    nil,    nil,    {.5,.5} },
    { [0] = {1,1},  {1,1},  nil,    {.5,.5}, nil,    {1,1},  {1,1} },
    { [0] = {.5,.5},{.5,.5},{.5,.5},{1,.5},  {.5,.5},{.5,.5},{.5,.5} },
    { [0] = {1,0},  {1,0},  nil,    {1.5,.5},nil,    {1,0},  {1,0} },
    { [0] = nil,    {1,1},  nil,    {.5,.5} },
    { [0] = {1,1},  {1,1},  nil,    {.5,.5} },
}

--
-- get a new penalty node
--
local function get_new_penalty (p)
    local penalty = node.new("penalty")
    penalty.penalty = p
    return penalty
end

--
-- get a new glue node
--
local function get_new_glue (...)
    local glue = node.new("glue")
    node.setglue(glue, ...)
    return glue
end

--
-- return 0.5*fontsize of given fontid
--   space: true if variant=KR/modern; then 0.5*interword_space
--
local function get_font_size (fid, space)
    local size = font.getparameters(fid)
    if space then
        size = size and size.space or 196608
    else
        size = size and size.quad  or 655360
    end
    return size/2
end

--
-- charclass 1 thru 4 will be packed in \hbox to 0.5em{\hss? curr \hss?}
--   when variant ~= plain
--
local function glyph_to_box (head, curr, class)
    local g, h = curr
    local size = get_font_size(g.font)
    head, curr = node.remove(head, curr)
    g.next, g.prev = nil, nil
    local hss = get_new_glue(0, 65536, 65536, 2, 2)
    if class == 1 then
        h, hss.next, g.prev = hss, g, hss
    elseif class == 2 or class == 4 then
        h, g.next, hss.prev = g, hss, g
    else
        local hss2 = node.copy(hss)
        h, hss.next, g.prev, g.next, hss2.prev = hss, g, hss, hss2, g
    end
    h = nodes.simple_font_handler(h)
    local box = node.hpack(h, size, "exactly")
    if curr then
        head, curr = node.insert_before(head, curr, box)
    else
        head, curr = node.insert_after(head, node.tail(head), box)
    end
    return head, curr
end

--
-- insert spacing defined as charclass[a][b] between a and b
--   f:    fontid
--   var:  variant = plain, JP/classic, KR/modern, SC, TC
--   cc:   charclass of current char
--   nc:   charclass of next char
--   nobr: linebreak is not allowed
--
local function insert_cjk_penalty_glue (head, curr, f, var, cc, nc, nobr)
    if nobr or cc == 1 or nc > 1 then
        local penalty = get_new_penalty(10000)
        head, curr = node.insert_after(head, curr, penalty)
    end
    local factor = get_font_size(f, var == 2)
    local t = intercharclass[cc][nc]
    local glue = get_new_glue(t[1]*factor, nil, t[2]*factor)
    head, curr = node.insert_after(head, curr, glue)
    return head, curr
end

--
-- insert inter-character spacing in other normal cases
--   f:    fontid
--   var:  variant = plain, JP/classic, KR/modern, SC, TC
--   nobr: no linebreak
--   x:    true between cjk and non-cjk (a little more spacing)
--
local function insert_penalty_glue (head, curr, f, var, nobr, x)
    if nobr then
        local penalty = get_new_penalty(10000)
        head, curr = node.insert_after(head, curr, penalty)
    elseif curr.id ~= penalty_id then
        local penalty = (var == 0 or var == 2) and 50 or not f and 0
        if penalty then
            head, curr = node.insert_after(head, curr, get_new_penalty(penalty))
        end
    end
    if not f then return head, curr end
    local size, glue = get_font_size(f, x and var == 2)
    if x then
        glue = get_new_glue(size/2, size/4, size/8)
    elseif var == 0 or var == 2 then
        glue = get_new_glue(0, size/10, size/50)
    else
        glue = get_new_glue(0, size/5, size/50)
    end
    head, curr = node.insert_after(head, curr, glue)
    return head, curr
end

--
-- overwrite \inhibitglue which suppresses inter-character glue
--
local inhibitglue_attr  = luatexbase.new_attribute"polyglossia_inhibitglue_attr"
local inhibitglue_index = luatexbase.new_luafunction"polyglossia_inhibitglue_func"
lua.get_functions_table()[inhibitglue_index] = function ()
    local s = get_font_size(font.current())
    local n = get_new_glue(0, s/5, s/50)
    node.set_attribute(n, inhibitglue_attr, 1)
    node.write(n)
end
token.set_lua("inhibitglue", inhibitglue_index, "global", "protected")

--
-- helper functions for cjk_break
--
local is_skippable = {
    [whatsit_id] = true,
    [penalty_id] = true,
    [vadjust_id] = true,
    [ins_id]     = true,
    [mark_id]    = true,
}
local function is_skippable_node(n)
    return is_skippable[n.id]
        or n.kern and n.subtype ~= 1 -- non-user kern
        or n.list and n.next and n.next.id == ins_id -- footnote. TODO: mpfootnote
end
local function get_glyph_in_box (n, first)
    local getnext = first and node.getnext or node.getprev
    local curr = first and n.list or node.slide(n.list)
    while curr do
        if curr.char and node.has_attribute(curr, attr_cjk) then
            return curr.char, curr.font
        elseif curr.list then -- intentionally put before is_skippable_node
            return get_glyph_in_box(curr, first)
        elseif is_skippable_node(curr) then -- skip
        else
            return 1 -- 1 indicates non-glyph box
        end
        curr = getnext(curr)
    end
    return 1
end
local function is_glue_to_skip(n)
    return n.id == glue_id and
        (n.subtype >= 13 and n.subtype <= 15 or node.has_attribute(n, inhibitglue_attr))
end
local function is_normal_box(n)
    return (n.id == hbox_id or n.id == vbox_id) and (n.subtype == 0 or n.subtype == 2)
end
local function is_math_onoff(n, onoff)
    return n and n.id == math_id and n.subtype == onoff -- TODO: $\vcenter{...}$
end

--
-- main process for linebreak and inter-character spacing
--
local function cjk_break (head)
    local curr = head

    while curr do
        local var = node.has_attribute(curr, attr_cjk)
        if var and (curr.id == glyph_id or is_math_onoff(curr, 1) or is_normal_box(curr)) then

            local c, f
            if curr.id == hbox_id or curr.id == vbox_id then
                c, f = get_glyph_in_box(curr)
            else
                c, f = curr.char or 0, curr.font
            end
            local cc = get_charclass(var, c)

            -- compress cjk punctuations when charclass is 1 thru 4
            if curr.char and var > 0 and cc > 0 and cc < 5 then
                head, curr = glyph_to_box(head, curr, cc)
            end

            local next = node.getnext(curr)
            while next and is_skippable_node(next) do
                -- skip whatsit/penalty/ins/vadjust/mark/normal footnote/non-user kern
                curr, next = next, node.getnext(next)
            end
            if not next then break end

            local nvar = node.has_attribute(next, attr_cjk)
            if nvar and (next.id == glyph_id or is_math_onoff(next, 0) or is_normal_box(next)) then

                local n, f2
                if next.id == hbox_id or next.id == vbox_id then
                    n, f2 = get_glyph_in_box(next, true)
                else
                    n, f2 = next.char or 0, next.font
                end
                if not (f or f2) then goto skip_combining end

                -- skip combining. or dash+dash case to suppress stretching
                if nobr_before[n] == 2 or (nobr_before[c] == 0 and nobr_before[n] == 0) then
                    goto skip_combining
                end

                local nc = get_charclass(nvar, n)
                local nobr = nobr_before[n] or nobr_after[c]

                f = nc > 0 and nvar ~= 2 and f2 or f or f2 -- priority to cjk punctuation font
                if f == f2 then var = nvar end

                -- insert spacing as of intercharclass
                if var > 0 and intercharclass[cc][nc] then
                    head, curr = insert_cjk_penalty_glue(head, curr, f, var, cc, nc, nobr)

                else
                    local cjkc, cjkn = is_cjk(c), is_cjk(n)

                    -- if curr or next is cjk char
                    if cjkc or cjkn then
                        if c == 1 or n == 1 then -- non-glyph box: penalty only
                            head, curr = insert_penalty_glue(head, curr, false, var, nobr)

                        -- plain variant / cjk+cjk / nobr cjk+noncjk / around dash : 0pt glue
                        elseif var == 0 or (cjkc and cjkn) or nobr or nobr_before[c] == 0
                            or zero_spacing[c] or zero_spacing[n] then
                            head, curr = insert_penalty_glue(head, curr, f, var, nobr)

                        else -- other cases: insert a small glue
                            head, curr = insert_penalty_glue(head, curr, f, var, nobr, true)
                        end
                    end
                end

            elseif var > 0 and intercharclass[cc][0] then
                if is_glue_to_skip(next) then
                    -- skip spaceskip, xspaceskkp, parfillskip, inhibitglue
                else
                    -- insert glue between cjk_punct and non-glyph node
                    head, curr = insert_cjk_penalty_glue(head, curr, f, var, cc, 0, false)
                end
            end
        elseif curr.id == localpar_id
            or curr.id == hbox_id and curr.subtype == 3 -- indentbox
            or is_glue_to_skip(curr) then
            -- skip
        else
            local n = node.getnext(curr)
            if n and n.id == glyph_id then
                local var = node.has_attribute(n, attr_cjk)
                if var and var > 0 then
                    local nc = get_charclass(var, n.char)
                    if intercharclass[0][nc] then
                        -- insert glue between non-glyph node and cjk_punct
                        head, curr = insert_cjk_penalty_glue(head, curr, n.font, var, 0, nc, false)
                    end
                end
            end
        end
        ::skip_combining::
        curr = node.getnext(curr)
        if is_math_onoff(curr, 0) then curr = node.end_of_math(curr) end
    end
    return head
end

--
-- automatic josa selection
--
local josa_table = {
    --          consonant ㄹ, vowel,  other consonants
    [0xAC00] = {0xC774,       0xAC00, 0xC774}, -- 가 => 이, 가, 이
    [0xC740] = {0xC740,       0xB294, 0xC740}, -- 은 => 은, 는, 은
    [0xC744] = {0xC744,       0xB97C, 0xC744}, -- 을 => 을, 를, 을
    [0xC640] = {0xACFC,       0xC640, 0xACFC}, -- 와 => 과, 와, 과
    [0xC73C] = {nil,          nil,    0xC73C}, -- 으(로) =>   ,  , 으
    [0xC774] = {0xC774,       nil,    0xC774}, -- 이(라) => 이,  , 이
}

--
-- helper functions for josa_code
--
local function josa_char_num (t, c, diff)
    local j = t[(c - diff) % 10 + 0x30] or 2
    t[c] = j; return j
end
local function josa_char_alph (t, c, diff)
    local j = t[c - diff + 0x61] or 2
    t[c] = j; return j
end
local function josa_char_jamo (t, c)
    if c >= 0x1160 and c <= 0x11A7 or c >= 0xD7B0 and c <= 0xD7C6 then
        t[c] = 2; return 2 -- HJF (0x1160) is in the main table below
    end
    t[c] = 3; return 3 -- ㄹ (0x1105, 0x11AF) is in the main table below
end

--
-- decide josa selection
--
local josa_code = setmetatable({
    [0x30] = 3, [0x31] = 1, [0x33] = 3, [0x36] = 3, [0x37] = 1,
    [0x38] = 1, [0x4C] = 1, [0x4D] = 3, [0x4E] = 3, [0x6C] = 1,
    [0x6D] = 3, [0x6E] = 3, [0xFB02] = 1, [0xFB04] = 1,
    [0x1105] = 1, [0x1160] = false, [0x11AF] = 1, [0x3139] = 1,
    [0x3203] = 1, [0x321D] = 3, [0x3263] = 1,
},{ __index = function(t,c)
    if c >= 0x30 and c <= 0x39 or c >= 0x41 and c <= 0x5A or c >= 0x61 and c <= 0x7A
        or c >= 0xFB00 and c <= 0xFB06 then
        t[c] = 2; return 2 -- 0, 1, 3, 6, 7, 8, M, N, L, m, n, l, fl, ffl in the main table
    elseif c >= 0xAC00 and c <= 0xD7A3 then
        local j = josa_char_jamo(t, (c - 0xAC00) % 28 + 0x11A7)
        t[c] = j; return j
    elseif c >= 0x1100 and c <= 0x11FF
        or c >= 0xA960 and c <= 0xA97C
        or c >= 0xD7B0 and c <= 0xD7FB then
        return josa_char_jamo(t, c)
    elseif c >= 0x3131 and c <= 0x318E then
        if c >= 0x314F and c <= 0x3163 or c >= 0x3187 then t[c] = 2; return 2 end
        t[c] = 3; return 3 -- ㄹ (0x3139) is in the main table
    elseif c >= 0x3200 and c <= 0x321E then
        if c >= 0x320E then t[c] = 2; return 2 end -- ㈝ (0x321D) is in the main table
        t[c] = 3; return 3 -- ㈃ (0x3203) is in the main table
    elseif c >= 0x3260 and c <= 0x327F then
        if c >= 0x326E then t[c] = 2; return 2 end
        t[c] = 3; return 3 -- ㉣ (0x3263) is in the main table
    elseif c >= 0x2160 and c <= 0x217F then
        if     c <= 0x216B then return josa_char_num(t, c, 0x215F)
        elseif c <= 0x216F then t[c] = 3; return 3
        elseif c <= 0x217B then return josa_char_num(t, c, 0x216F)
        else                    t[c] = 3; return 3
        end
    elseif c >= 0x2460 and c <= 0x24E9 then
        if     c <= 0x2473 then return josa_char_num(t, c, 0x245F)
        elseif c <= 0x2487 then return josa_char_num(t, c, 0x2473)
        elseif c <= 0x249B then return josa_char_num(t, c, 0x2487)
        elseif c <= 0x24B5 then return josa_char_alph(t, c, 0x249C)
        elseif c <= 0x24CF then return josa_char_alph(t, c, 0x24B6)
        else                    return josa_char_alph(t, c, 0x24D0)
        end
    elseif c >= 0xFF10 and c <= 0xFF19 then return josa_char_num(t, c, 0xFF10)
    elseif c >= 0xFF21 and c <= 0xFF3A then return josa_char_alph(t, c, 0xFF21)
    elseif c >= 0xFF41 and c <= 0xFF5A then return josa_char_alph(t, c, 0xFF41)
    elseif c >= 0x3400 and c <= 0x9FFF
        or c >= 0xF900 and c <= 0xFAFF
        or c >= 0x20000 and c <= 0x3347F then
        t[c] = 2; return 2; -- TODO: need to parse UniHan database
    end
end
})

--
-- obtain char that comes just before the josa
--
local function get_prev_josa_type (p)
    while p do
        if p.char then
            local j = josa_code[p.char]
            if j then return j end
        elseif p.list then
            local j = get_prev_josa_type(node.slide(p.list))
            if j then return j end
        end
        p = node.getprev(p)
    end
end

--
-- main process of josa selection
--
local function auto_josa (head)
    local curr, tofree = head, {}
    while curr do
        if curr.id == glyph_id then
            local var = node.has_attribute(curr, attr_cjk)
            if var and var <= 2 then
                local josa = node.has_attribute(curr, attr_josa)
                if josa then
                    if josa == 0 then
                        josa = get_prev_josa_type(node.getprev(curr)) or 2
                    end
                    local cc = curr.char or 0
                    if cc == 0xC774 then
                        local n = node.getnext(curr)
                        if n and n.char and n.char >= 0xAC00 and n.char <= 0xD7A3 then
                        else
                            cc = 0xAC00
                        end
                    end
                    local new = josa_table[cc]
                    if new then
                        cc = new[josa]
                        if cc then
                            curr.char = cc
                        else
                            head = node.remove(head, curr)
                            table.insert(tofree, curr)
                        end
                    end
                    node.unset_attribute(curr, attr_josa)
                end
            end
        end
        curr = node.getnext(curr)
    end
    for _,v in ipairs(tofree) do node.free(v) end
    return head
end

--
-- now register to luatex callbacks
--   As char value of glyphs can be changed by opentype GSUB process,
--   we have to occupy the first position among callback functions.
--
luatexbase.add_to_callback( "pre_shaping_filter",
function(head)
    if attr_josa then head = auto_josa(head) end
    head = cjk_break(head)
    return head
end,
"polyglossia.lang_cjk_spacing")

-- vim:ft=lua:tw=0:sw=4:ts=4:expandtab
