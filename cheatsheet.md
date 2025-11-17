# NixOS

## Files

/etc/nixos/configuration.nix

## Commands

sudo nixos-rebuild [--bootloader-install] <switch|boot>
nixos-rebuild list-generations
sudo nix-collect-garbage [-d]
  -d deletes old configurations

# Tmux
> C-b   send-prefix

> "     split-window
> %     split-window -h
> !     break-pane
> x     kill-pane
> q     display-panes
> ;     last-pane
> o     select-pane
> {     swap-pane -U
> }     swap-pane -D
> Up    select-pane -U
> Down  select-pane -D
> Left  select-pane -L
> Right select-pane -R
> z     resize-pane
> M-Up  resize-pane -U 5
> C-Up  resize-pane -U

> c     new-window
> 0-9   select-window
> '     select-window
> ,     rename-window
> l     last-window
> n     next-window
> p     previous-window
> C-o   rotate-window
> f     find-window

> C-z   suspend-client
> Space next-layout
> \#     list-buffers
> &     kill-window (confirming)
> \-     delete-buffer
> .     move-window
> :     command-prompt
> [     copy-mode
> ]     paste-buffer

