" skeletons.vim - Manage skeleton files for different filetypes.
" Maintainer:   Jonas Kuball <jkuball@tzi.de>
" Version:      0.1

" Supply the :Skeleton command which searches in
" $HOME/.vim/skeleton/<filetype> for .skel files,
" lets you choose one and inserts them into the buffer (ontop).
" Also evaluates vimscript code in the skeletons that is enclosed by <{ and }>.
function! InsertSkeleton()
  let files = glob("$HOME/.vim/skeleton/" . expand(&ft) . "/*.skel", 0, 1)
  if len(files) <= 0
    echohl WarningMsg | echo "No skeleton files specified for " . expand(&ft) | echohl None
  else
    if len(files) == 1
      exec "0read " . files[0]
      %s/<{\(.\{-}\)}>/\=eval(submatch(1))/ge
      normal 0d1
      normal G
    else
      let skeletons = map(copy(files), "fnamemodify(v:val, ':t:r')")
      for idx in range(len(skeletons))
        let skeletons[idx] = (idx + 1) . ": " . skeletons[idx]
      endfor
      call insert(skeletons, "Select skeleton (empty cancels)", 0)
      let index = inputlist(skeletons) - 1
      try
        if index < 0
          throw 1
        endif
        exec "0read " . files[index]
        %s/<{\(.\{-}\)}>/\=eval(submatch(1))/ge
        normal 0d1
        normal G
      catch
        echohl WarningMsg | echo "\nInvalid selection" | echohl None
      endtry
    endif
  endif
endfunction
command! -nargs=0 Skeleton call InsertSkeleton()

" When opening skeleton files, load the correct filetype by looking at
" the folder name.
augroup SkeletonFiles
  au!
  au BufReadPost *.skel let &l:ft = fnamemodify(expand('%:p:h'), ':t')
  au BufReadPost *.skel highlight SkeletonCode ctermfg=29 ctermbg=255 guifg=#22863a guibg=#fafbfc
  au BufReadPost *.skel highlight SkeletonCodeDelim ctermfg=250 ctermbg=255 guifg=#babbbc guibg=#fafbfc
  au BufReadPost *.skel call matchadd("SkeletonCodeDelim", "<{.\\{-\}}>")
  au BufReadPost *.skel call matchadd("SkeletonCode", "<{\\zs.\\{-\}\\ze}>")
augroup END
