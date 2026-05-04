#!/usr/bin/env bash

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo $default_value
    else
        echo $option_value
    fi
}

normalize_padding() {
    percent_len=${#1}
    max_len=${2:-4}
    let diff_len=$max_len-$percent_len
    # if the diff_len is even, left will have 1 more space than right
    let left_spaces=($diff_len + 1)/2
    let right_spaces=($diff_len)/2
    printf "%${left_spaces}s%s%${right_spaces}s\n" "" $1 ""
}

get_pane_dir() {
    nextone="false"
    ret=""
    for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
        [ "$i" == "1" ] && nextone="true" && continue
        [ "$i" == "0" ] && nextone="false"
        [ "$nextone" == "true" ] && ret+="$i "
    done
    echo "${ret%?}"
}

get_pywal_colors() {
    local colors_file="$HOME/.cache/wal/colors"
    local colors=()
    if [[ -f "$colors_file" ]]; then
        while IFS= read -r line; do
            colors+=("$line")
        done <"$colors_file"
    fi
    local n=${#colors[@]}
    if [[ $n -eq 0 ]]; then
        return
    fi
    # Output 24 colors; for indices beyond available colors, wrap from index 1
    for i in $(seq 0 23); do
        if [[ $i -lt $n ]]; then
            echo "${colors[$i]}"
        else
            echo "${colors[$(( (i - n) % (n - 1) + 1 ))]}"
        fi
    done
}
