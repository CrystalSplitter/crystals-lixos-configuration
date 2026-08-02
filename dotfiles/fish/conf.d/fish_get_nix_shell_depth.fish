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
