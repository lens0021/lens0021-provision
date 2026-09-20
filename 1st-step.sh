#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.6.0-alpha
[ "$EUID" -ne 0 ] && { { command -v sudo >/dev/null 2>&1 && __sudo=sudo; } || { command -v doas >/dev/null 2>&1 && __sudo=doas; }; }
if [ -n "$ZSH_VERSION" ]; then
    EXEC_SHELL="zsh"
    IFS='.' read -A EXEC_SHELL_VERSION <<< "$ZSH_VERSION"
elif [ -n "$KSH_VERSION" ]; then
    EXEC_SHELL="ksh"
    __exec_shell_version="${.sh.version##*/}"
    IFS='.' read -a EXEC_SHELL_VERSION <<< "${__exec_shell_version%% *}"
else
    EXEC_SHELL="bash"
    EXEC_SHELL_VERSION=("${BASH_VERSINFO[0]}" "${BASH_VERSINFO[1]}" "${BASH_VERSINFO[2]}")
fi
# array_find(array: [Text], value: Text)
array_find__0_v0() {
    local array_114=("${!1}")
    local value_115="${2}"
    index_117=0;
    for element_116 in "${array_114[@]}"; do
        if [ "$([ "_${value_115}" != "_${element_116}" ]; echo $?)" != 0 ]; then
            ret_array_find0_v0="${index_117}"
            return 0
        fi
        (( index_117++ )) || true
    done
    ret_array_find0_v0=-1
    return 0
}

# array_contains(array: [Text], value: Text)
array_contains__2_v0() {
    local array_112=("${!1}")
    local value_113="${2}"
    array_find__0_v0 array_112[@] "${value_113}"
    local result_118="${ret_array_find0_v0}"
    ret_array_contains2_v0="$(( result_118 >= 0 ))"
    return 0
}

# replace(source: Text, search: Text, replace: Text)
replace__13_v0() {
    local source_120="${1}"
    local search_121="${2}"
    local replace_122="${3}"
    # Here we use a command to avoid #646
    local result_123=""
    left_comp=("${EXEC_SHELL_VERSION[@]}")
    right_comp=(4 3)
    local comp
    comp="$(
        # Compare if left array >= right array
        len_comp="$( (( "${#left_comp[@]}" < "${#right_comp[@]}" )) && echo "${#left_comp[@]}"|| echo "${#right_comp[@]}")"
        for (( i=0; i<len_comp; i++ )); do
            left="${left_comp[i]?"Index out of bounds (at unknown)"}"
            right="${right_comp[i]?"Index out of bounds (at unknown)"}"
            if (( "${left}" > "${right}" )); then
                echo 1
                exit
            elif (( "${left}" < "${right}" )); then
                echo 0
                exit
            fi
        done
        (( "${#left_comp[@]}" == "${#right_comp[@]}" || "${#left_comp[@]}" > "${#right_comp[@]}" )) && echo 1 || echo 0
)"
    if [ "$(( $([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?) || $(( $([ "_${EXEC_SHELL}" != "_bash" ]; echo $?) && comp )) ))" != 0 ]; then
        result_123="${source_120//"${search_121}"/"${replace_122}"}"
        __status=$?
    else
        result_123="${source_120//"${search_121}"/${replace_122}}"
        __status=$?
    fi
    ret_replace13_v0="${result_123}"
    return 0
}

# split(text: Text, delimiter: Text)
split__17_v0() {
    local text_107="${1}"
    local delimiter_108="${2}"
    local result_109=()
    # zsh uses -A for array, bash uses -a, ksh is VERY bad at splitting anything
    if [ "$([ "_${EXEC_SHELL}" != "_zsh" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_108}" read -rd '' -A result_109 < <(printf %s "$text_107")
        __status=$?
    elif [ "$([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?)" != 0 ]; then
        if [ "$([ "_${delimiter_108}" != "_
" ]; echo $?)" != 0 ]; then
            while read -r -d $'\n'; do result_109+=("$REPLY"); done < <(echo "$text_107")
            __status=$?
        else
            IFS="${delimiter_108}" read -rd '' -a result_109 < <(printf %s "$text_107")
            __status=$?
        fi
    elif [ "$([ "_${EXEC_SHELL}" != "_bash" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_108}" read -rd '' -a result_109 < <(printf %s "$text_107")
        __status=$?
    fi
    ret_split17_v0=("${result_109[@]}")
    return 0
}

# text_contains(source: Text, search: Text)
text_contains__29_v0() {
    local source_29="${1}"
    local search_30="${2}"
    [[ "${source_29}" == *"${search_30}"* ]]
    __status=$?
    ret_text_contains29_v0="$(( __status == 0 ))"
    return 0
}

# dir_exists(path: Text)
dir_exists__51_v0() {
    local path_25="${1}"
    [ -d "${path_25}" ]
    __status=$?
    ret_dir_exists51_v0="$(( __status == 0 ))"
    return 0
}

# file_exists(path: Text)
file_exists__52_v0() {
    local path_26="${1}"
    [ -f "${path_26}" ]
    __status=$?
    ret_file_exists52_v0="$(( __status == 0 ))"
    return 0
}

# file_read(path: Text)
file_read__53_v0() {
    local path_27="${1}"
    local command_4
    command_4="$(< "${path_27}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_read53_v0=''
        return "${__status}"
    fi
    ret_file_read53_v0="${command_4}"
    return 0
}

# file_write(path: Text, content: Text)
file_write__54_v0() {
    local path_33="${1}"
    local content_34="${2}"
    local command_5
    command_5="$(printf '%s
' "${content_34}" > "${path_33}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_write54_v0=''
        return "${__status}"
    fi
    ret_file_write54_v0="${command_5}"
    return 0
}

# file_append(path: Text, content: Text)
file_append__55_v0() {
    local path_31="${1}"
    local content_32="${2}"
    local command_6
    command_6="$(printf '%s
' "${content_32}" >> "${path_31}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_append55_v0=''
        return "${__status}"
    fi
    ret_file_append55_v0="${command_6}"
    return 0
}

# symlink_create(origin: Text, destination: Text)
symlink_create__56_v0() {
    local origin_45="${1}"
    local destination_46="${2}"
    file_exists__52_v0 "${origin_45}"
    local ret_file_exists52_v0__71_8="${ret_file_exists52_v0}"
    if [ "${ret_file_exists52_v0__71_8}" != 0 ]; then
        ln -fs "${origin_45}" "${destination_46}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_symlink_create56_v0=''
            return "${__status}"
        fi
        ret_symlink_create56_v0=''
        return 0
    fi
    echo "The file ${origin_45} doesn't exist"'!'""
    ret_symlink_create56_v0=''
    return 1
}

# dir_create(path: Text)
dir_create__57_v0() {
    local path_44="${1}"
    dir_exists__51_v0 "${path_44}"
    local ret_dir_exists51_v0__87_12="${ret_dir_exists51_v0}"
    if [ "$(( ! ret_dir_exists51_v0__87_12 ))" != 0 ]; then
        mkdir -p "${path_44}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_dir_create57_v0=''
            return "${__status}"
        fi
    fi
}

# file_chmod(path: Text, mode: Text)
file_chmod__60_v0() {
    local path_145="${1}"
    local mode_146="${2}"
    file_exists__52_v0 "${path_145}"
    local ret_file_exists52_v0__153_8="${ret_file_exists52_v0}"
    if [ "${ret_file_exists52_v0__153_8}" != 0 ]; then
        chmod "${mode_146}" "${path_145}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_file_chmod60_v0=''
            return "${__status}"
        fi
        ret_file_chmod60_v0=''
        return 0
    fi
    echo "The file ${path_145} doesn't exist"'!'""
    ret_file_chmod60_v0=''
    return 1
}

command_7="$(sudo -u#1000 bash -c 'echo $HOME')"
__status=$?
user_home_3="${command_7}"
# resolve(path: Text)
resolve__74_v0() {
    local path_119="${1}"
    replace__13_v0 "${path_119}" "~" "${user_home_3}"
    ret_resolve74_v0="${ret_replace13_v0}"
    return 0
}

# dirname(path: Text)
dirname__75_v0() {
    local path_125="${1}"
    local command_8
    command_8="$(dirname ${path_125})"
    __status=$?
    ret_dirname75_v0="${command_8}"
    return 0
}

# sym_ensure(targets: [Text])
sym_ensure__77_v0() {
    local targets_106=("${!1}")
    local command_9
    command_9="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_sym_ensure77_v0=''
        return "${__status}"
    fi
    split__17_v0 "${command_9}" "
"
    local srcs_110=("${ret_split17_v0[@]}")
    local __length_10=("${targets_106[@]}")
    local __length_11=("${targets_106[@]}")
    if [ "$(( $(( ${#__length_10[@]} == 0 )) || $(( $(( ${#__length_11[@]} == 1 )) && $([ "_${targets_106[0]?"Index out of bounds (at /home/nemo/git/lens/provision/amber/sym.ab:51:60)"}" != "_" ]; echo $?) )) ))" != 0 ]; then
        targets_106=("${srcs_110[@]}")
    fi
    for target_111 in "${targets_106[@]}"; do
        if [ "$([ "_${target_111}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        array_contains__2_v0 srcs_110[@] "${target_111}"
        local ret_array_contains2_v0__58_16="${ret_array_contains2_v0}"
        if [ "$(( ! ret_array_contains2_v0__58_16 ))" != 0 ]; then
            resolve__74_v0 "${target_111}"
            target_111="${ret_resolve74_v0}"
            echo "No ${target_111} declared in config.json"
            continue
        fi
        resolve__74_v0 "${target_111}"
        local ret_resolve74_v0__63_28="${ret_resolve74_v0}"
        file_exists__52_v0 "${ret_resolve74_v0__63_28}"
        local ret_file_exists52_v0__63_16="${ret_file_exists52_v0}"
        if [ "$(( ! ret_file_exists52_v0__63_16 ))" != 0 ]; then
            echo "no ${target_111}, skipping"
            continue
        else
            local command_14
            command_14="$(jq -r '.sym["'"${target_111}"'"]' ~/.config/declair/config.json)"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_sym_ensure77_v0=''
                return "${__status}"
            fi
            resolve__74_v0 "${command_14}"
            local dist_124="${ret_resolve74_v0}"
            file_exists__52_v0 "${dist_124}"
            local ret_file_exists52_v0__68_20="${ret_file_exists52_v0}"
            if [ "$(( ! ret_file_exists52_v0__68_20 ))" != 0 ]; then
                dirname__75_v0 "${dist_124}"
                local ret_dirname75_v0__69_28="${ret_dirname75_v0}"
                dir_create__57_v0 "${ret_dirname75_v0__69_28}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_sym_ensure77_v0=''
                    return "${__status}"
                fi
                resolve__74_v0 "${target_111}"
                local ret_resolve74_v0__70_32="${ret_resolve74_v0}"
                symlink_create__56_v0 "${ret_resolve74_v0__70_32}" "${dist_124}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_sym_ensure77_v0=''
                    return "${__status}"
                fi
            fi
        fi
    done
}

# env_var_get(name: Text)
env_var_get__143_v0() {
    local name_153="${1}"
    if [ "$([ "_${EXEC_SHELL}" != "_bash" ]; echo $?)" != 0 ]; then
        local command_15
        command_15="$(printf "%s
" "${!name_153}")"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_env_var_get143_v0=''
            return "${__status}"
        fi
        ret_env_var_get143_v0="${command_15}"
        return 0
    elif [ "$([ "_${EXEC_SHELL}" != "_zsh" ]; echo $?)" != 0 ]; then
        local command_16
        command_16="$(printf "%s
" "${(P)name_153}")"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_env_var_get143_v0=''
            return "${__status}"
        fi
        ret_env_var_get143_v0="${command_16}"
        return 0
    elif [ "$([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?)" != 0 ]; then
        local command_17
        command_17="$(eval "echo \${$name_153}")"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_env_var_get143_v0=''
            return "${__status}"
        fi
        ret_env_var_get143_v0="${command_17}"
        return 0
    fi
}

# is_command(command: Text)
is_command__145_v0() {
    local command_142="${1}"
    [ -x "$(command -v "${command_142}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_command145_v0=0
        return 0
    fi
    ret_is_command145_v0=1
    return 0
}

# file_download(url: Text, path: Text)
file_download__257_v0() {
    local url_143="${1}"
    local path_144="${2}"
    is_command__145_v0 "curl"
    local ret_is_command145_v0__15_9="${ret_is_command145_v0}"
    is_command__145_v0 "wget"
    local ret_is_command145_v0__18_9="${ret_is_command145_v0}"
    is_command__145_v0 "aria2c"
    local ret_is_command145_v0__21_9="${ret_is_command145_v0}"
    if [ "${ret_is_command145_v0__15_9}" != 0 ]; then
        curl -L -o "${path_144}" "${url_143}">/dev/null 2>&1
        __status=$?
    elif [ "${ret_is_command145_v0__18_9}" != 0 ]; then
        wget "${url_143}" -P "${path_144}">/dev/null 2>&1
        __status=$?
    elif [ "${ret_is_command145_v0__21_9}" != 0 ]; then
        aria2c "${url_143}" -d "${path_144}">/dev/null 2>&1
        __status=$?
    else
        ret_file_download257_v0=''
        return 1
    fi
}

command_18="$(sudo -u#1000 bash -c 'echo $HOME')"
__status=$?
user_home_4="${command_18}"
# prepare_provision_repo()
prepare_provision_repo__262_v0() {
    dir_exists__51_v0 "${user_home_4}/git/lens/provision"
    local ret_dir_exists51_v0__19_12="${ret_dir_exists51_v0}"
    if [ "$(( ! ret_dir_exists51_v0__19_12 ))" != 0 ]; then
        git clone https://github.com/lens0021/provision ${user_home_4}/git/lens/provision
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_prepare_provision_repo262_v0=''
            return "${__status}"
        fi
    fi
    local command_19
    command_19="$(git --git-dir "${user_home_4}/git/lens/provision/.git" rev-parse --is-shallow-repository)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare_provision_repo262_v0=''
        return "${__status}"
    fi
    if [ "$([ "_${command_19}" != "_true" ]; echo $?)" != 0 ]; then
        git --git-dir "${user_home_4}/git/lens/provision/.git" fetch --unshallow
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_prepare_provision_repo262_v0=''
            return "${__status}"
        fi
    fi
}

# setup_rbw()
setup_rbw__263_v0() {
    is_command__145_v0 "rbw"
    local ret_is_command145_v0__28_12="${ret_is_command145_v0}"
    if [ "$(( ! ret_is_command145_v0__28_12 ))" != 0 ]; then
        sudo dnf install -y rbw
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_rbw263_v0=''
            return "${__status}"
        fi
    fi
    rbw config set email lorentz0021@gmail.com
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_rbw263_v0=''
        return "${__status}"
    fi
    rbw login
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_rbw263_v0=''
        return "${__status}"
    fi
}

# post_prepare_provision()
post_prepare_provision__264_v0() {
    file_exists__52_v0 "${user_home_4}/.config/declair/config.json"
    local ret_file_exists52_v0__36_12="${ret_file_exists52_v0}"
    if [ "$(( ! ret_file_exists52_v0__36_12 ))" != 0 ]; then
        dir_create__57_v0 "${user_home_4}/.config/declair"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision264_v0=''
            return "${__status}"
        fi
        symlink_create__56_v0 "${user_home_4}/git/lens/provision/config/declair.json" "${user_home_4}/.config/declair/config.json"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision264_v0=''
            return "${__status}"
        fi
    fi
    dir_exists__51_v0 "${user_home_4}/.config/bin"
    local ret_dir_exists51_v0__40_12="${ret_dir_exists51_v0}"
    if [ "$(( ! ret_dir_exists51_v0__40_12 ))" != 0 ]; then
        dir_create__57_v0 "${user_home_4}/.config/bin"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision264_v0=''
            return "${__status}"
        fi
    fi
    file_exists__52_v0 "${user_home_4}/.config/bin/config.json"
    local ret_file_exists52_v0__43_12="${ret_file_exists52_v0}"
    if [ "$(( ! ret_file_exists52_v0__43_12 ))" != 0 ]; then
        symlink_create__56_v0 "${user_home_4}/git/lens/provision/config/bin.config" "${user_home_4}/.config/bin/config.json"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision264_v0=''
            return "${__status}"
        fi
    fi
}

# install_bin()
install_bin__265_v0() {
    is_command__145_v0 "bin"
    local ret_is_command145_v0__49_12="${ret_is_command145_v0}"
    if [ "$(( ! ret_is_command145_v0__49_12 ))" != 0 ]; then
        file_exists__52_v0 "bin"
        local ret_file_exists52_v0__50_16="${ret_file_exists52_v0}"
        if [ "$(( ! ret_file_exists52_v0__50_16 ))" != 0 ]; then
            file_download__257_v0 "https://github.com/marcosnils/bin/releases/download/v0.21.2/bin_0.21.2_linux_amd64" "bin"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_install_bin265_v0=''
                return "${__status}"
            fi
        fi
        file_chmod__60_v0 "bin" "+x"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin265_v0=''
            return "${__status}"
        fi
        mkdir -p ${user_home_4}/.local/bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin265_v0=''
            return "${__status}"
        fi
        ./bin ensure bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin265_v0=''
            return "${__status}"
        fi
        rm ./bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin265_v0=''
            return "${__status}"
        fi
    fi
}

# install_fish()
install_fish__266_v0() {
    is_command__145_v0 "fish"
    local ret_is_command145_v0__61_12="${ret_is_command145_v0}"
    if [ "$(( ! ret_is_command145_v0__61_12 ))" != 0 ]; then
        sudo dnf install -y fish
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_fish266_v0=''
            return "${__status}"
        fi
    fi
    fish -c "functions -q fisher"
    __status=$?
    if [ "${__status}" != 0 ]; then
        local fisher_url_155="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
        fish -c "curl -sL ${fisher_url_155} | source && fisher install jorgebucaran/fisher"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_fish266_v0=''
            return "${__status}"
        fi
    fi
}

# setup_sudoer()
setup_sudoer__267_v0() {
    # https://github.com/amber-lang/amber/issues/220
    dir_exists__51_v0 "/etc/sudoers.d/"
    local ret_dir_exists51_v0__73_12="${ret_dir_exists51_v0}"
    if [ "$(( ! ret_dir_exists51_v0__73_12 ))" != 0 ]; then
        # dir_create("/etc/sudoersh.d")
        sudo mkdir -p /etc/sudoers.d/
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer267_v0=''
            return "${__status}"
        fi
    fi
    file_exists__52_v0 "/etc/sudoers.d/nemo"
    local ret_file_exists52_v0__77_8="${ret_file_exists52_v0}"
    if [ "${ret_file_exists52_v0__77_8}" != 0 ]; then
        file_read__53_v0 "/etc/sudoers.d/nemo"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer267_v0=''
            return "${__status}"
        fi
        local content_28="${ret_file_read53_v0}"
        text_contains__29_v0 "${content_28}" "nemo ALL=(ALL:ALL) NOPASSWD: ALL"
        local ret_text_contains29_v0__79_16="${ret_text_contains29_v0}"
        if [ "$(( ! ret_text_contains29_v0__79_16 ))" != 0 ]; then
            file_append__55_v0 "/etc/sudoers.d/nemo" "nemo ALL=(ALL:ALL) NOPASSWD: ALL
"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_setup_sudoer267_v0=''
                return "${__status}"
            fi
        fi
    else
        sudo touch /etc/sudoers.d/nemo
        __status=$?
        file_write__54_v0 "/tmp/sudoer-nemo" "nemo ALL=(ALL:ALL) NOPASSWD: ALL
"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer267_v0=''
            return "${__status}"
        fi
        sudo chown -R root:root /tmp/sudoer-nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer267_v0=''
            return "${__status}"
        fi
        sudo mv /tmp/sudoer-nemo /etc/sudoers.d/nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer267_v0=''
            return "${__status}"
        fi
    fi
    sudo chmod 0440 /usr/bin/sudo
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_sudoer267_v0=''
        return "${__status}"
    fi
}

# setup_bin()
setup_bin__269_v0() {
    while :
    do
        local done_151=1
        gh auth token
        __status=$?
        if [ "${__status}" != 0 ]; then
            done_151=0
            echo "Sign in to bitwarden to see the Github Password"
            rbw get 356c6b3b-2dbe-4804-9918-af0700970344
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_setup_bin269_v0=''
                return "${__status}"
            fi
            gh auth login
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_setup_bin269_v0=''
                return "${__status}"
            fi
        fi
        if [ "${done_151}" != 0 ]; then
            break
        fi
    done
    while :
    do
        local done_152=1
        env_var_get__143_v0 "GITHUB_AUTH_TOKEN"
        __status=$?
        if [ "${__status}" != 0 ]; then
            done_152=0
            echo "Visit https://github.com/settings/personal-access-tokens and copy the token."
        fi
        if [ "${done_152}" != 0 ]; then
            break
        fi
    done
}

# setup_gh()
setup_gh__270_v0() {
    is_command__145_v0 "gh"
    local ret_is_command145_v0__125_12="${ret_is_command145_v0}"
    if [ "$(( ! ret_is_command145_v0__125_12 ))" != 0 ]; then
        sudo dnf install -y gh
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_gh270_v0=''
            return "${__status}"
        fi
    fi
}

typeset -r args_5=("$0" "$@")
sudo -v
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_sudoer__267_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
prepare_provision_repo__262_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
post_prepare_provision__264_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
array_21=()
sym_ensure__77_v0 array_21[@]
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_bin__265_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_rbw__263_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_gh__270_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_bin__269_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
bin ensure yazi
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
bin ensure zellij
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
bin ensure lazygit
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
is_command__145_v0 "hx"
ret_is_command145_v0__143_12="${ret_is_command145_v0}"
if [ "$(( ! ret_is_command145_v0__143_12 ))" != 0 ]; then
    sudo dnf install -y helix
    __status=$?
    if [ "${__status}" != 0 ]; then
        exit "${__status}"
    fi
fi
install_fish__266_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
# install_wavebox()?
