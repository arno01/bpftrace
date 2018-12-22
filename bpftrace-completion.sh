#/usr/bin/env bash

# To activate:
# 1. copy this file to '/etc/bash_completion.d'
# 2. copy this file to the bpftrace's executable folder and run 'source bpftrace-completion.sh'

_words_complete()
{
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    opts="-l -e -p -v -d -dd"
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    # list of words to match
    probes="kprobe kretprobe uprobe uretprobe tracepoint usdt profile interval software hardware"
    variables="count hist lhist nsecs stack ustack"
    functions="printf time join str sym usym kaddr uaddr reg system exit cgroupid min max stats"
    word_list="$probes $variables $functions $opts"

    local cur_word cur_match cur_match_size cur_line

    # everything inside quotes is treated as one thing so we need to break it manually
    cur_size=$(echo "$cur" | wc -w)
    no_quote_cur=$(echo "${cur}" | sed 's/\x27//g')

    word_arr=($no_quote_cur)
    last_word="${word_arr[cur_size-1]}"
    cur_line=$(echo "${no_quote_cur}" | sed '1{s/[^ ]\+\s*$//}')

    if [[ ${cur_size} > 1 ]] ; then
        cur_word=$last_word
    else
        cur_word=$no_quote_cur
    fi

    # probe completion
    if [[ ${cur_word} =~ kprobe* || ${cur_word} =~ tracepoint* ]] ; then
        kprobe_list=$(bpftrace -l | grep "${cur_word}")
        cur_match=$(compgen -W "${kprobe_list}" -- ${cur_word})

    elif [[ ${cur_word} =~ kretprobe* ]] ; then
        replaced_cur=$(echo "${cur_word}" | sed 's/kretprobe/kprobe/g')
        kretprobe_list=$(bpftrace -l | grep "${replaced_cur}")
        comp=$(compgen -W "${kretprobe_list}" -- ${replaced_cur})
        cur_match=$( echo "${comp}" | sed 's/kprobe/kretprobe/g' )

    elif [[ ${cur_word} =~ uprobe* ]] ; then
        no_probe_cur=$(echo "${cur_word}" | sed -E 's/uprobe://g')
        cur_match=( $(compgen -P uprobe: -G "${no_probe_cur}*") )

    elif [[ ${cur_word} =~ uretprobe* ]] ; then
        no_probe_cur=$(echo "${cur_word}" | sed -E 's/uretprobe://g')
        cur_match=( $(compgen -P uretprobe: -G "${no_probe_cur}*") )

    elif [[ ${cur_word} =~ usdt* ]] ; then
        local no_probe_cur=$(echo "${cur_word}" | sed -E 's/usdt://g')
        cur_match=( $(compgen -P usdt: -G "${no_probe_cur}*") )

    else
        # single word completion
        cur_match=( $(compgen -W "${word_list}" -- ${cur_word}) )

    fi

    cur_match_size=$(echo "$cur_match" | wc -w)

    if [[ ${cur_match_size} == 1 ]] ; then
        COMPREPLY=( "'$cur_line$cur_match" )
        return 0
    else
       COMPREPLY=( $cur_match )
        return 0
    fi
}

complete -F _words_complete bpftrace
