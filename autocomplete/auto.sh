#/usr/bin/env bash

# copy this file to the bpftrace's executable folder and run 'source auto.sh' to activate

_words_complete()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-l -e -p -v -d -dd"
    probes="kprobe kretprobe uprobe uretprobe tracepoint usdt profile interval software hardware"

    local no_quote_cur=$(echo "${cur}" | sed 's/\x27//g')

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    elif [[ ${cur} =~ kprobe* || ${cur} =~ tracepoint* ]] ; then
        local kprobe_list=$(./bpftrace -l | grep "${no_quote_cur}")
        COMPREPLY=( $(compgen -W "${kprobe_list}" -- ${cur}) )
        return 0
    elif [[ ${cur} =~ kretprobe* ]] ; then
        local replaced_cur=$(echo "${no_quote_cur}" | sed 's/kretprobe/kprobe/g')
        local kretprobe_list=$(./bpftrace -l | grep "${replaced_cur}")
        local comp=$(compgen -W "${kretprobe_list}" -- ${replaced_cur})
        COMPREPLY=$( echo "${comp}" | sed 's/kprobe/kretprobe/g' )
        return 0
    elif [[ ${cur} =~ uprobe* ]] ; then
        local no_probe_cur=$(echo "${no_quote_cur}" | sed -E 's/uprobe://g')
        COMPREPLY=( $(compgen -P uprobe: -G "${no_probe_cur}*") )
        return 0
    elif [[ ${cur} =~ uretprobe* ]] ; then
        local no_probe_cur=$(echo "${no_quote_cur}" | sed -E 's/uretprobe://g')
        COMPREPLY=( $(compgen -P uretprobe: -G "${no_probe_cur}*") )
        return 0
    elif [[ ${cur} =~ usdt* ]] ; then
        local no_probe_cur=$(echo "${no_quote_cur}" | sed -E 's/usdt://g')
        COMPREPLY=( $(compgen -P usdt: -G "${no_probe_cur}*") )
        return 0
    else
        COMPREPLY=( $(compgen -W "${probes}" -- ${cur}) )
        return 0
    fi
}
complete -o nospace -F _words_complete bpftrace
