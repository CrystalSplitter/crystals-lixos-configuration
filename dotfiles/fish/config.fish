fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
set -x DEFAULT_BROWSER "firefox"

function fish_get_nix_shell_depth --description 'Predict how many shells deep we are'
    set -f ps_output (ps -o 'comm= ppid=' $fish_pid | string trim)
    set -f proc_name (echo -- $ps_output | awk '{print $1}')
    set -f proc_ppid (echo -- $ps_output | awk '{print $2}')
    set -f depth 0
    while test $proc_name = 'fish' > /dev/null
        set ps_output (ps -o 'comm= ppid=' $proc_ppid | string trim)
        set proc_name (echo -- $ps_output | awk '{print $1}')
        set proc_ppid (echo -- $ps_output | awk '{print $2}')
        set depth (math $depth + 1)
    end
    printf "%s" $depth
end

function fish_prompt --description 'Custom fish prompt'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status red

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix (string repeat (fish_get_nix_shell_depth) '>')
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
end
