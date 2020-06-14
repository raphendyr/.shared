ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

typeset -A ZSH_HIGHLIGHT_STYLES
# #foo
#ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
# foo=bar -f --foo
ZSH_HIGHLIGHT_STYLES[assign]=fg=yellow
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=cyan
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=cyan
# if then
#ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=yellow
# $(...) <(...) $(( 1 )) `...`
#ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
#ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]=fg=cyan
#ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=magenta
# >
ZSH_HIGHLIGHT_STYLES[redirection]=fg=yellow,bold
# !foo
#ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue
# "foo" "$foo" "fo\"o"
#ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
#ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan
#ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan
# 'foo' $'foo' $'\x00' 'foo''bar'
#ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
#ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
#ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=cyan
#ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=cyan
# */*.foo  foo/exists.txt
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[path]=underline
# invalid, git, echo, alias_word, alias_for_pdf_file
#ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
#ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
ZSH_HIGHLIGHT_STYLES[builtin]=fg=green,bold
#ZSH_HIGHLIGHT_STYLES[function]=fg=green
#ZSH_HIGHLIGHT_STYLES[alias]=fg=green
#ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
