" Default GUI Colours
let s:foreground = "222222"
let s:background = "ffffff"
let s:selection  = "f8f8f8"
let s:line       = "efefef"
let s:comment    = "858585"
let s:red        = "731718"
let s:orange     = "b3520e"
let s:yellow     = "cd9731"
let s:green      = "006b1e"
let s:aqua       = "004d8d"
let s:blue       = "000080"
let s:purple     = "850075"
let s:window     = "efefef"

set background=light
hi clear
syntax reset

let g:colors_name = "light-delight"

if has("gui_running") || &t_Co == 88 || &t_Co == 256
	" Returns an approximate grey index for the given grey level
	fun <SID>grey_number(x)
		if &t_Co == 88
			if a:x < 23
				return 0
			elseif a:x < 69
				return 1
			elseif a:x < 103
				return 2
			elseif a:x < 127
				return 3
			elseif a:x < 150
				return 4
			elseif a:x < 173
				return 5
			elseif a:x < 196
				return 6
			elseif a:x < 219
				return 7
			elseif a:x < 243
				return 8
			else
				return 9
			endif
		else
			if a:x < 14
				return 0
			else
				let l:n = (a:x - 8) / 10
				let l:m = (a:x - 8) % 10
				if l:m < 5
					return l:n
				else
					return l:n + 1
				endif
			endif
		endif
	endfun

	" Returns the actual grey level represented by the grey index
	fun <SID>grey_level(n)
		if &t_Co == 88
			if a:n == 0
				return 0
			elseif a:n == 1
				return 46
			elseif a:n == 2
				return 92
			elseif a:n == 3
				return 115
			elseif a:n == 4
				return 139
			elseif a:n == 5
				return 162
			elseif a:n == 6
				return 185
			elseif a:n == 7
				return 208
			elseif a:n == 8
				return 231
			else
				return 255
			endif
		else
			if a:n == 0
				return 0
			else
				return 8 + (a:n * 10)
			endif
		endif
	endfun

	" Returns the palette index for the given grey index
	fun <SID>grey_colour(n)
		if &t_Co == 88
			if a:n == 0
				return 16
			elseif a:n == 9
				return 79
			else
				return 79 + a:n
			endif
		else
			if a:n == 0
				return 16
			elseif a:n == 25
				return 231
			else
				return 231 + a:n
			endif
		endif
	endfun

	" Returns an approximate colour index for the given colour level
	fun <SID>rgb_number(x)
		if &t_Co == 88
			if a:x < 69
				return 0
			elseif a:x < 172
				return 1
			elseif a:x < 230
				return 2
			else
				return 3
			endif
		else
			if a:x < 75
				return 0
			else
				let l:n = (a:x - 55) / 40
				let l:m = (a:x - 55) % 40
				if l:m < 20
					return l:n
				else
					return l:n + 1
				endif
			endif
		endif
	endfun

	" Returns the actual colour level for the given colour index
	fun <SID>rgb_level(n)
		if &t_Co == 88
			if a:n == 0
				return 0
			elseif a:n == 1
				return 139
			elseif a:n == 2
				return 205
			else
				return 255
			endif
		else
			if a:n == 0
				return 0
			else
				return 55 + (a:n * 40)
			endif
		endif
	endfun

	" Returns the palette index for the given R/G/B colour indices
	fun <SID>rgb_colour(x, y, z)
		if &t_Co == 88
			return 16 + (a:x * 16) + (a:y * 4) + a:z
		else
			return 16 + (a:x * 36) + (a:y * 6) + a:z
		endif
	endfun

	" Returns the palette index to approximate the given R/G/B colour levels
	fun <SID>colour(r, g, b)
		" Get the closest grey
		let l:gx = <SID>grey_number(a:r)
		let l:gy = <SID>grey_number(a:g)
		let l:gz = <SID>grey_number(a:b)

		" Get the closest colour
		let l:x = <SID>rgb_number(a:r)
		let l:y = <SID>rgb_number(a:g)
		let l:z = <SID>rgb_number(a:b)

		if l:gx == l:gy && l:gy == l:gz
			" There are two possibilities
			let l:dgr = <SID>grey_level(l:gx) - a:r
			let l:dgg = <SID>grey_level(l:gy) - a:g
			let l:dgb = <SID>grey_level(l:gz) - a:b
			let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
			let l:dr = <SID>rgb_level(l:gx) - a:r
			let l:dg = <SID>rgb_level(l:gy) - a:g
			let l:db = <SID>rgb_level(l:gz) - a:b
			let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
			if l:dgrey < l:drgb
				" Use the grey
				return <SID>grey_colour(l:gx)
			else
				" Use the colour
				return <SID>rgb_colour(l:x, l:y, l:z)
			endif
		else
			" Only one possibility
			return <SID>rgb_colour(l:x, l:y, l:z)
		endif
	endfun

	" Returns the palette index to approximate the 'rrggbb' hex string
	fun <SID>rgb(rgb)
		let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
		let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
		let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

		return <SID>colour(l:r, l:g, l:b)
	endfun

	" Sets the highlighting for the given group
	fun <SID>X(group, fg, bg, attr)
		if a:fg != ""
			exec "hi " . a:group . " guifg=#" . a:fg . " ctermfg=" . <SID>rgb(a:fg)
		endif
		if a:bg != ""
			exec "hi " . a:group . " guibg=#" . a:bg . " ctermbg=" . <SID>rgb(a:bg)
		endif
		if a:attr != ""
			exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
		endif
	endfun

	" Vim Highlighting
	call <SID>X("Normal", s:foreground, s:background, "")
  highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
	call <SID>X("NonText", s:selection, "", "")
	call <SID>X("SpecialKey", s:selection, "", "")
	call <SID>X("Search", s:foreground, s:selection, "")
	call <SID>X("Error", s:background, s:red, "")
	call <SID>X("ErrorMsg", s:background, s:red, "")
	call <SID>X("TabLine", s:foreground, s:background, "reverse")
	call <SID>X("StatusLine", s:window, s:blue, "reverse")
	call <SID>X("StatusLineNC", s:window, s:foreground, "reverse")
	call <SID>X("VertSplit", s:window, s:window, "none")
	call <SID>X("Visual", "", s:selection, "")
	call <SID>X("Directory", s:blue, "", "")
	call <SID>X("ModeMsg", s:green, "", "")
	call <SID>X("MoreMsg", s:green, "", "")
	call <SID>X("Question", s:green, "", "")
	call <SID>X("WarningMsg", s:red, "", "")
	call <SID>X("MatchParen", "", s:selection, "")
	call <SID>X("Folded", s:comment, s:background, "")
	call <SID>X("FoldColumn", "", s:background, "")
	if version >= 700
		call <SID>X("CursorLine", "", s:line, "none")
		call <SID>X("CursorColumn", "", s:line, "none")
		call <SID>X("PMenu", s:foreground, s:selection, "none")
		call <SID>X("PMenuSel", s:foreground, s:selection, "reverse")
	end
	if version >= 703
		call <SID>X("ColorColumn", "", s:line, "none")
	end

	call <SID>X("Comment", s:comment, "", "")
	call <SID>X("Todo", s:comment, s:background, "")
	call <SID>X("Title", s:comment, "", "")
	call <SID>X("Identifier", s:foreground, "", "none")
	call <SID>X("Statement", s:foreground, "", "")
	call <SID>X("Conditional", s:foreground, "", "")
	call <SID>X("Repeat", s:foreground, "", "")
	call <SID>X("Structure", s:purple, "", "")
	call <SID>X("Function", s:aqua, "", "")
	call <SID>X("Constant", s:blue, "", "")
	call <SID>X("Number", s:green, "", "")
	call <SID>X("String", s:red, "", "")
	call <SID>X("Special", s:foreground, "", "")
	call <SID>X("PreProc", s:blue, "", "")
	call <SID>X("Operator", s:blue, "", "none")
	call <SID>X("Type", s:purple, "", "none")
	call <SID>X("Define", s:foreground, "", "none")
	call <SID>X("Include", s:blue, "", "")
	call <SID>X("SpellBad", "", s:background, "underline")
	call <SID>X("SpellCap", "", s:background, "underline")
	call <SID>X("SpellRare", "", s:background, "underline")
	call <SID>X("SpellLocal", "", s:background, "underline")
	call <SID>X("Keyword", s:blue, "", "none")

  " YCM remove anoing error colors from the text
  call <SID>X("YcmErrorSection", s:foreground, "", "")

  " YCM remove anoing error colors from the text
	call <SID>X("ALEError",s:background, s:red, "")

  "NERDTree slashes in nice blue color
	call <SID>X("NERDTreeDirSlash",s:blue, "", "")
  "NERDTree Flags are same color as dirs
	call <SID>X("NERDTreeFlags",s:blue, "", "")

	" Fix jsx bug (different color on closing tag)
	hi link xmlEndTag xmlTag

	" Python Highlighting
	call <SID>X("pythonInclude", s:blue, "", "")
	call <SID>X("pythonStatement", s:blue, "", "")
	call <SID>X("pythonConditional", s:blue, "", "")
	call <SID>X("pythonSelf", s:blue, "", "")
	call <SID>X("pythonFunction", s:aqua, "", "")
	call <SID>X("pythonFunctionCall", s:aqua, "", "")
	call <SID>X("pythonStrFormat", s:green, "", "")
	call <SID>X("pythonClass", s:purple, "", "")
	call <SID>X("pythonBuiltinType", s:purple, "", "")
	call <SID>X("pythonBuiltinObj", s:blue, "", "")
	call <SID>X("pythonRepeat", s:blue, "", "")
	call <SID>X("pythonException", s:blue, "", "")
	call <SID>X("pythonClassVar", s:blue, "", "")

	" JavaScript Highlighting
  call <SID>X("jsFunction", s:blue, "", "")
	call <SID>X("jsConditional", s:blue, "", "")
	call <SID>X("jsUndefined", s:blue, "", "")
	call <SID>X("jsStatement", s:blue, "", "")
	call <SID>X("jsLabel", s:blue, "", "")
	call <SID>X("jsSuper", s:blue, "", "")
	call <SID>X("jsReturn", s:blue, "", "")
	call <SID>X("jsThis", s:blue, "", "")
	call <SID>X("jsNull", s:blue, "", "")
	call <SID>X("jsRepeat", s:blue, "", "")
  call <SID>X("jsException", s:blue, "", "")
  call <SID>X("jsExceptions", s:purple, "", "")
	call <SID>X("jsStorageClass", s:blue, "", "")
	call <SID>X("jsBooleanFalse", s:blue, "", "")
	call <SID>X("jsBooleanTrue", s:blue, "", "")
	call <SID>X("jsArrowFunction", s:blue, "", "")
	call <SID>X("jsClassDefinition", s:purple, "", "")
	call <SID>X("jsGlobalObjects", s:purple, "", "")
	call <SID>X("jsGlobalNodeObjects", s:purple, "", "")
	call <SID>X("jsExportDefault", s:blue, "", "")
	call <SID>X("jsTemplateBraces", s:green, "", "")
	call <SID>X("jsRegexpString", s:orange, "", "")
	call <SID>X("jsxAttrib", s:blue, "", "")
	call <SID>X("jsxTagName", s:green, "", "")

  " C Highlighting
	call <SID>X("cRepeat", s:blue, "", "")
	call <SID>X("cStatement", s:blue, "", "")
	call <SID>X("cConditional", s:blue, "", "")
	call <SID>X("cLabel", s:blue, "", "")

  "Clojure Highlighting
	call <SID>X("clojureSpecial", s:blue, "", "")
	call <SID>X("clojureDefine", s:blue, "", "")

  " Bash Highlight
	call <SID>X("shConditional", s:blue, "", "")
	call <SID>X("shLoop", s:blue, "", "")
	call <SID>X("shDerefSimple", s:blue, "", "")
	call <SID>X("shDerefSimple", s:aqua, "", "")


  " Vim Script Highlighting
  call <SID>X("vimCommand", s:blue, "", "")
  call <SID>X("vimOper", s:foreground, "", "")

	" HTML Highlighting
	call <SID>X("htmlTag", s:comment, "", "")
	call <SID>X("htmlEndTag", s:comment, "", "")
	call <SID>X("htmlTagName", s:green, "", "")
	call <SID>X("htmlArg", s:blue, "", "")
	call <SID>X("htmlScriptTag", s:red, "", "")
	call <SID>X("htmlTitle", s:orange, "", "")
	call <SID>X("htmlH1", s:orange, "", "")

  " CSS Highlighting
	call <SID>X("cssTagName", s:blue, "", "")
	call <SID>X("cssBraces", s:foreground, "", "")
	call <SID>X("cssProp", s:foreground, "", "")

	" XML Highlighting
	call <SID>X("xmlTag", s:comment, "", "")
	call <SID>X("xmlTagName", s:green, "", "")
	call <SID>X("xmlAttrib", s:blue, "", "")
	call <SID>X("xmlEndTag", s:comment, "", "")

  " Yaml Hightlighting
	call <SID>X("yamlKey", s:blue, "", "")

  " Markdown Hightlighting
	call <SID>X("mkdHeading", s:blue, "", "")
	call <SID>X("mkdCode", s:foreground, "", "")

  " Vim Highlighting
  call <SID>X("vimFunction", s:aqua, "", "")
  call <SID>X("vimUserFunc", s:aqua, "", "")
  call <SID>X("vimNotation", s:aqua, "", "")
  call <SID>X("vimFuncSID", s:aqua, "", "")

  " Diff Highlighting
	call <SID>X("DiffAdd", s:green, "", "")
	call <SID>X("DiffDelete", s:red, "", "")
	call <SID>X("DiffChange", s:yellow, "", "")
	call <SID>X("DiffText", s:foreground, "", "")

	call <SID>X("diffAdded", s:green, "", "")
	call <SID>X("diffRemoved", s:red, "", "")
	call <SID>X("diffChanged", s:yellow, "", "")

  " GitGutter
	call <SID>X("GitGutterAdd", s:green, "", "")
	call <SID>X("GitGutterChange", s:aqua, "", "")
	call <SID>X("GitGutterDelete", s:red, "", "")

  " Coc
  call <SID>X("CocFloating", s:foreground, s:selection, "")
  call <SID>X("CocHoverRange", s:foreground, s:selection, "")
  call <SID>X("CocCursorRange", s:foreground, s:selection, "")

  " Spellunker
  call <SID>X("SpellunkerSpellBad", "", "", "underline")

  " Vim Menu
  call <SID>X("PMenu", s:foreground, s:selection, "")
  call <SID>X("PMenuSel", s:foreground, s:selection, "")

	" Delete Functions
	delf <SID>X
	delf <SID>rgb
	delf <SID>colour
	delf <SID>rgb_colour
	delf <SID>rgb_level
	delf <SID>rgb_number
	delf <SID>grey_colour
	delf <SID>grey_level
	delf <SID>grey_number
endif
