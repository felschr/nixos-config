if did_filetype()
  finish
endif
if getline(1) =~ '^#!.*nix-shell'
  let s:matches = matchlist(getline(2), '^#!.*nix-shell -i \([^ \t\n]\+\)')
  let s:command = s:matches[1]
  echo s:command
  if s:command != ''
    if s:command =~# '^\(bash\d*\|\|ksh\d*\|sh\)\>'
      call dist#ft#SetFileTypeSH(s:command)
    elseif s:command == 'zsh'
      set ft=zsh
    elseif s:command =~ '^gnumake\d*\>'
      set ft=make
    elseif s:command =~ '^nodejs'
      set ft=javascript
    elseif s:command =~ '^ghc'
      set ft=haskell
    elseif s:command =~ '^python'
      set ft=python
    endif
  endif
endif
