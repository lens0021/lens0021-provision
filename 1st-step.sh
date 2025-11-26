#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha-79-g03cd7e4
array_find__0_v0() {
    local array=("${!1}")
    local value=$2
    index_21=0;
    for element_20 in "${array[@]}"; do
        if [ "$([ "_${value}" != "_${element_20}" ]; echo $?)" != 0 ]; then
            ret_array_find0_v0="${index_21}"
            return 0
        fi
        (( index_21++ )) || true
    done
    ret_array_find0_v0=-1
    return 0
}

array_contains__2_v0() {
    local array=("${!1}")
    local value=$2
    array_find__0_v0 array[@] "${value}"
    result_22="${ret_array_find0_v0}"
    ret_array_contains2_v0="$(( ${result_22} >= 0 ))"
    return 0
}

# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
bash_version__11_v0() {
    major_11="$(echo "${BASH_VERSINFO[0]}")"
    minor_12="$(echo "${BASH_VERSINFO[1]}")"
    patch_13="$(echo "${BASH_VERSINFO[2]}")"
    ret_bash_version11_v0=("${major_11}" "${minor_12}" "${patch_13}")
    return 0
}

replace__12_v0() {
    local source=$1
    local search=$2
    local replace=$3
    # Here we use a command to avoid #646
    result_10=""
    bash_version__11_v0 
    left_comp=("${ret_bash_version11_v0[@]}")
    right_comp=(4 3)
    comp="$(
        # Compare if left array >= right array
        len_comp="$( (( "${#left_comp[@]}" < "${#right_comp[@]}" )) && echo "${#left_comp[@]}"|| echo "${#right_comp[@]}")"
        for (( i=0; i<len_comp; i++ )); do
            left="${left_comp[i]:-0}"
            right="${right_comp[i]:-0}"
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
    if [ "${comp}" != 0 ]; then
        result_10="${source//"${search}"/"${replace}"}"
    else
        result_10="${source//"${search}"/${replace}}"
    fi
    ret_replace12_v0="${result_10}"
    return 0
}

split__16_v0() {
    local text=$1
    local delimiter=$2
    result_5=()
    IFS="${delimiter}" read -rd '' -a result_5 < <(printf %s "$text")
    ret_split16_v0=("${result_5[@]}")
    return 0
}

text_contains__28_v0() {
    local source=$1
    local search=$2
    result_27="$(if [[ "${source}" == *"${search}"* ]]; then
    echo 1
  fi)"
    ret_text_contains28_v0="$([ "_${result_27}" != "_1" ]; echo $?)"
    return 0
}

rpad__40_v0() {
    local text=$1
    local pad=$2
    local length=$3
    __length_7="${text}"
    if [ "$(( ${length} <= ${#__length_7} ))" != 0 ]; then
        ret_rpad40_v0="${text}"
        return 0
    fi
    __length_8="${text}"
    length="$(( ${#__length_8} - ${length} ))"
    pad="$(printf "%${length}s" "" | tr " " "${pad}")"
    ret_rpad40_v0="${text}""${pad}"
    return 0
}

dir_exists__47_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    ret_dir_exists47_v0="$(( ${__status} == 0 ))"
    return 0
}

file_exists__48_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    ret_file_exists48_v0="$(( ${__status} == 0 ))"
    return 0
}

file_read__49_v0() {
    local path=$1
    command_10="$(< "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_read49_v0=''
        return "${__status}"
    fi
    ret_file_read49_v0="${command_10}"
    return 0
}

file_write__50_v0() {
    local path=$1
    local content=$2
    command_11="$(echo "${content}" > "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_write50_v0=''
        return "${__status}"
    fi
    ret_file_write50_v0="${command_11}"
    return 0
}

file_append__51_v0() {
    local path=$1
    local content=$2
    command_12="$(echo "${content}" >> "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_file_append51_v0=''
        return "${__status}"
    fi
    ret_file_append51_v0="${command_12}"
    return 0
}

symlink_create__52_v0() {
    local origin=$1
    local destination=$2
    file_exists__48_v0 "${origin}"
    ret_file_exists48_v0__37_8="${ret_file_exists48_v0}"
    if [ "${ret_file_exists48_v0__37_8}" != 0 ]; then
        ln -s "${origin}" "${destination}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_symlink_create52_v0=''
            return "${__status}"
        fi
        ret_symlink_create52_v0=''
        return 0
    fi
    echo "The file ${origin} doesn't exist"'!'""
    ret_symlink_create52_v0=''
    return 1
}

dir_create__53_v0() {
    local path=$1
    dir_exists__47_v0 "${path}"
    ret_dir_exists47_v0__48_12="${ret_dir_exists47_v0}"
    if [ "$(( ! ${ret_dir_exists47_v0__48_12} ))" != 0 ]; then
        mkdir -p "${path}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_dir_create53_v0=''
            return "${__status}"
        fi
    fi
}

file_chmod__56_v0() {
    local path=$1
    local mode=$2
    file_exists__48_v0 "${path}"
    ret_file_exists48_v0__104_8="${ret_file_exists48_v0}"
    if [ "${ret_file_exists48_v0__104_8}" != 0 ]; then
        chmod "${mode}" "${path}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_file_chmod56_v0=''
            return "${__status}"
        fi
        ret_file_chmod56_v0=''
        return 0
    fi
    echo "The file ${path} doesn't exist"'!'""
    ret_file_chmod56_v0=''
    return 1
}

command_13="$(sudo -u#1000 bash -c 'echo $HOME')"
__status=$?
user_home_3="${command_13}"
resolve__70_v0() {
    local path=$1
    replace__12_v0 "${path}" "~" "${user_home_3}"
    ret_resolve70_v0="${ret_replace12_v0}"
    return 0
}

dirname__71_v0() {
    local path=$1
    command_14="$(dirname ${path})"
    __status=$?
    ret_dirname71_v0="${command_14}"
    return 0
}

sym_list__72_v0() {
    command_15="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_sym_list72_v0=''
        return "${__status}"
    fi
    split__16_v0 "${command_15}" "
"
    srcs_6=("${ret_split16_v0[@]}")
    command_16="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json | wc -L)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_sym_list72_v0=''
        return "${__status}"
    fi
    longest_src_col_7="${command_16}"
    command_17="$(jq -r '.sym | values | .[]' ~/.config/declair/config.json | wc -L)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_sym_list72_v0=''
        return "${__status}"
    fi
    longest_dist_col_8="${command_17}"
    for src_9 in "${srcs_6[@]}"; do
        replace__12_v0 "${src_9}" "~" "${user_home_3}"
        resolved_src_14="${ret_replace12_v0}"
        command_18="$(jq -r '.sym["'"${src_9}"'"]' ~/.config/declair/config.json)"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_sym_list72_v0=''
            return "${__status}"
        fi
        dist_15="${command_18}"
        replace__12_v0 "${dist_15}" "~" "${user_home_3}"
        resolved_dist_16="${ret_replace12_v0}"
        state_17="Unknown"
        file_exists__48_v0 "${resolved_dist_16}"
        ret_file_exists48_v0__37_12="${ret_file_exists48_v0}"
        if [ "${ret_file_exists48_v0__37_12}" != 0 ]; then
            state_17="Existing"
            command_19="$(realpath ${resolved_dist_16})"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_sym_list72_v0=''
                return "${__status}"
            fi
            if [ "$([ "_${command_19}" != "_${resolved_src_14}" ]; echo $?)" != 0 ]; then
                state_17="OK"
            fi
        fi
        # TODO: Colorize
        rpad__40_v0 "${src_9}" " " "$(( ${longest_src_col_7} + 2 ))"
        ret_rpad40_v0__44_14="${ret_rpad40_v0}"
        rpad__40_v0 "${dist_15}" " " "$(( ${longest_dist_col_8} + 2 ))"
        ret_rpad40_v0__44_52="${ret_rpad40_v0}"
        echo "${ret_rpad40_v0__44_14}""${ret_rpad40_v0__44_52}""${state_17}"
    done
}

sym_ensure__73_v0() {
    local targets=("${!1}")
    command_20="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_sym_ensure73_v0=''
        return "${__status}"
    fi
    split__16_v0 "${command_20}" "
"
    srcs_18=("${ret_split16_v0[@]}")
    __length_21=("${targets[@]}")
    __length_22=("${targets[@]}")
    if [ "$(( $(( ${#__length_21[@]} == 0 )) || $(( $(( ${#__length_22[@]} == 1 )) && $([ "_${targets[0]}" != "_" ]; echo $?) )) ))" != 0 ]; then
        targets=("${srcs_18[@]}")
    fi
    for target_19 in "${targets[@]}"; do
        if [ "$([ "_${target_19}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        array_contains__2_v0 srcs_18[@] "${target_19}"
        ret_array_contains2_v0__58_16="${ret_array_contains2_v0}"
        if [ "$(( ! ${ret_array_contains2_v0__58_16} ))" != 0 ]; then
            resolve__70_v0 "${target_19}"
            target_19="${ret_resolve70_v0}"
            echo "No ${target_19} declared in config.json"
            continue
        fi
        resolve__70_v0 "${target_19}"
        ret_resolve70_v0__63_28="${ret_resolve70_v0}"
        file_exists__48_v0 "${ret_resolve70_v0__63_28}"
        ret_file_exists48_v0__63_16="${ret_file_exists48_v0}"
        if [ "$(( ! ${ret_file_exists48_v0__63_16} ))" != 0 ]; then
            echo "no ${target_19}, skipping"
            continue
        else
            command_23="$(jq -r '.sym["'"${target_19}"'"]' ~/.config/declair/config.json)"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_sym_ensure73_v0=''
                return "${__status}"
            fi
            resolve__70_v0 "${command_23}"
            dist_23="${ret_resolve70_v0}"
            file_exists__48_v0 "${dist_23}"
            ret_file_exists48_v0__68_20="${ret_file_exists48_v0}"
            if [ "$(( ! ${ret_file_exists48_v0__68_20} ))" != 0 ]; then
                dirname__71_v0 "${dist_23}"
                ret_dirname71_v0__69_28="${ret_dirname71_v0}"
                dir_create__53_v0 "${ret_dirname71_v0__69_28}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_sym_ensure73_v0=''
                    return "${__status}"
                fi
                resolve__70_v0 "${target_19}"
                ret_resolve70_v0__70_32="${ret_resolve70_v0}"
                symlink_create__52_v0 "${ret_resolve70_v0__70_32}" "${dist_23}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_sym_ensure73_v0=''
                    return "${__status}"
                fi
            fi
        fi
    done
}

env_var_get__132_v0() {
    local name=$1
    command_24="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get132_v0=''
        return "${__status}"
    fi
    ret_env_var_get132_v0="${command_24}"
    return 0
}

is_command__134_v0() {
    local command=$1
    [ -x "$(command -v "${command}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_command134_v0=0
        return 0
    fi
    ret_is_command134_v0=1
    return 0
}

file_download__178_v0() {
    local url=$1
    local path=$2
    is_command__134_v0 "curl"
    ret_is_command134_v0__9_9="${ret_is_command134_v0}"
    is_command__134_v0 "wget"
    ret_is_command134_v0__12_9="${ret_is_command134_v0}"
    is_command__134_v0 "aria2c"
    ret_is_command134_v0__15_9="${ret_is_command134_v0}"
    if [ "${ret_is_command134_v0__9_9}" != 0 ]; then
        curl -L -o "${path}" "${url}" >/dev/null 2>&1
        __status=$?
    elif [ "${ret_is_command134_v0__12_9}" != 0 ]; then
        wget "${url}" -P "${path}" >/dev/null 2>&1
        __status=$?
    elif [ "${ret_is_command134_v0__15_9}" != 0 ]; then
        aria2c "${url}" -d "${path}" >/dev/null 2>&1
        __status=$?
    else
        ret_file_download178_v0=''
        return 1
    fi
}

command_25="$(sudo -u#1000 bash -c 'echo $HOME')"
__status=$?
user_home_24="${command_25}"
prepare_provision_repo__182_v0() {
    dir_exists__47_v0 "${user_home_24}/git/lens/provision"
    ret_dir_exists47_v0__19_12="${ret_dir_exists47_v0}"
    if [ "$(( ! ${ret_dir_exists47_v0__19_12} ))" != 0 ]; then
        git clone https://github.com/lens0021/provision ${user_home_24}/git/lens/provision
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_prepare_provision_repo182_v0=''
            return "${__status}"
        fi
    fi
    command_26="$(git --git-dir "${user_home_24}/git/lens/provision/.git" rev-parse --is-shallow-repository)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare_provision_repo182_v0=''
        return "${__status}"
    fi
    if [ "$([ "_${command_26}" != "_true" ]; echo $?)" != 0 ]; then
        git --git-dir "${user_home_24}/git/lens/provision/.git" fetch --unshallow
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_prepare_provision_repo182_v0=''
            return "${__status}"
        fi
    fi
}

setup_rbw__183_v0() {
    is_command__134_v0 "rbw"
    ret_is_command134_v0__28_12="${ret_is_command134_v0}"
    if [ "$(( ! ${ret_is_command134_v0__28_12} ))" != 0 ]; then
        sudo dnf install -y rbw
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_rbw183_v0=''
            return "${__status}"
        fi
    fi
    rbw config set email lorentz0021@gmail.com
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_rbw183_v0=''
        return "${__status}"
    fi
    rbw login
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_rbw183_v0=''
        return "${__status}"
    fi
}

post_prepare_provision__184_v0() {
    file_exists__48_v0 "${user_home_24}/.config/declair/config.json"
    ret_file_exists48_v0__36_12="${ret_file_exists48_v0}"
    if [ "$(( ! ${ret_file_exists48_v0__36_12} ))" != 0 ]; then
        dir_create__53_v0 "${user_home_24}/.config/declair"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision184_v0=''
            return "${__status}"
        fi
        symlink_create__52_v0 "${user_home_24}/git/lens/provision/config/declair.json" "${user_home_24}/.config/declair/config.json"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision184_v0=''
            return "${__status}"
        fi
    fi
    dir_exists__47_v0 "${user_home_24}/.config/bin"
    ret_dir_exists47_v0__40_12="${ret_dir_exists47_v0}"
    if [ "$(( ! ${ret_dir_exists47_v0__40_12} ))" != 0 ]; then
        dir_create__53_v0 "${user_home_24}/.config/bin"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision184_v0=''
            return "${__status}"
        fi
    fi
    file_exists__48_v0 "${user_home_24}/.config/bin/config.json"
    ret_file_exists48_v0__43_12="${ret_file_exists48_v0}"
    if [ "$(( ! ${ret_file_exists48_v0__43_12} ))" != 0 ]; then
        symlink_create__52_v0 "${user_home_24}/git/lens/provision/config/bin.config" "${user_home_24}/.config/bin/config.json"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_post_prepare_provision184_v0=''
            return "${__status}"
        fi
    fi
}

install_bin__185_v0() {
    is_command__134_v0 "bin"
    ret_is_command134_v0__49_12="${ret_is_command134_v0}"
    if [ "$(( ! ${ret_is_command134_v0__49_12} ))" != 0 ]; then
        file_exists__48_v0 "bin"
        ret_file_exists48_v0__50_16="${ret_file_exists48_v0}"
        if [ "$(( ! ${ret_file_exists48_v0__50_16} ))" != 0 ]; then
            file_download__178_v0 "https://github.com/marcosnils/bin/releases/download/v0.21.2/bin_0.21.2_linux_amd64" "bin"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_install_bin185_v0=''
                return "${__status}"
            fi
        fi
        file_chmod__56_v0 "bin" "+x"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin185_v0=''
            return "${__status}"
        fi
        ./bin ensure bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin185_v0=''
            return "${__status}"
        fi
        rm ./bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_bin185_v0=''
            return "${__status}"
        fi
    fi
}

install_fish__186_v0() {
    is_command__134_v0 "fish"
    ret_is_command134_v0__60_12="${ret_is_command134_v0}"
    if [ "$(( ! ${ret_is_command134_v0__60_12} ))" != 0 ]; then
        sudo dnf install -y fish
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_fish186_v0=''
            return "${__status}"
        fi
    fi
    command_27="$(sudo -u#1000 bash -c 'echo $SHELL')"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_install_fish186_v0=''
        return "${__status}"
    fi
    if [ "$([ "_${command_27}" == "_/usr/bin/fish" ]; echo $?)" != 0 ]; then
        chsh -s "$(which fish)" nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_fish186_v0=''
            return "${__status}"
        fi
    fi
    fish -c "functions -q fisher"
    __status=$?
    if [ "${__status}" != 0 ]; then
        fisher_url_30="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
        curl -sL ${fisher_url_30} | source && fisher install jorgebucaran/fisher
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_fish186_v0=''
            return "${__status}"
        fi
    fi
}

setup_sudoer__187_v0() {
    # https://github.com/amber-lang/amber/issues/220
    dir_exists__47_v0 "/etc/sudoers.d/"
    ret_dir_exists47_v0__74_12="${ret_dir_exists47_v0}"
    if [ "$(( ! ${ret_dir_exists47_v0__74_12} ))" != 0 ]; then
        # dir_create("/etc/sudoersh.d")
        sudo mkdir -p /etc/sudoers.d/
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer187_v0=''
            return "${__status}"
        fi
    fi
    file_exists__48_v0 "/etc/sudoers.d/nemo"
    ret_file_exists48_v0__78_8="${ret_file_exists48_v0}"
    if [ "${ret_file_exists48_v0__78_8}" != 0 ]; then
        file_read__49_v0 "/etc/sudoers.d/nemo"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer187_v0=''
            return "${__status}"
        fi
        content_26="${ret_file_read49_v0}"
        text_contains__28_v0 "${content_26}" "nemo ALL=(ALL:ALL) NOPASSWD: ALL"
        ret_text_contains28_v0__80_16="${ret_text_contains28_v0}"
        if [ "$(( ! ${ret_text_contains28_v0__80_16} ))" != 0 ]; then
            file_append__51_v0 "/etc/sudoers.d/nemo" "nemo ALL=(ALL:ALL) NOPASSWD: ALL
"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_setup_sudoer187_v0=''
                return "${__status}"
            fi
        fi
    else
        sudo touch /etc/sudoers.d/nemo
        __status=$?
        file_write__50_v0 "/tmp/sudoer-nemo" "nemo ALL=(ALL:ALL) NOPASSWD: ALL
"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer187_v0=''
            return "${__status}"
        fi
        sudo chown -R root:root /tmp/sudoer-nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer187_v0=''
            return "${__status}"
        fi
        sudo mv /tmp/sudoer-nemo /etc/sudoers.d/nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_setup_sudoer187_v0=''
            return "${__status}"
        fi
    fi
    sudo chmod u+s /usr/bin/sudo
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_sudoer187_v0=''
        return "${__status}"
    fi
}

install_wavebox__188_v0() {
    sudo rpm --import https://download.wavebox.app/static/wavebox_repo.key
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_install_wavebox188_v0=''
        return "${__status}"
    fi
    dir_exists__47_v0 "/etc/yum.repos.d/wavebox.repo"
    ret_dir_exists47_v0__94_12="${ret_dir_exists47_v0}"
    if [ "$(( ! ${ret_dir_exists47_v0__94_12} ))" != 0 ]; then
        sudo wget -P /etc/yum.repos.d/ https://download.wavebox.app/stable/linux/rpm/wavebox.repo
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_install_wavebox188_v0=''
            return "${__status}"
        fi
    fi
    sudo dnf install -y Wavebox
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_install_wavebox188_v0=''
        return "${__status}"
    fi
}

setup_bin__189_v0() {
    bin ensure gh
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_setup_bin189_v0=''
        return "${__status}"
    fi
    while :
    do
        done_28=1
        gh auth token
        __status=$?
        if [ "${__status}" != 0 ]; then
            done_28=0
            echo "Sign in to bitwarden to see the Github Password"
            rbw get 356c6b3b-2dbe-4804-9918-af0700970344
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_setup_bin189_v0=''
                return "${__status}"
            fi
            gh auth login
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_setup_bin189_v0=''
                return "${__status}"
            fi
        fi
        if [ "${done_28}" != 0 ]; then
            break
        fi
    done
    while :
    do
        done_29=1
        env_var_get__132_v0 "GITHUB_AUTH_TOKEN"
        __status=$?
        if [ "${__status}" != 0 ]; then
            done_29=0
            echo "Visit https://github.com/settings/personal-access-tokens and copy the token."
        fi
        if [ "${done_29}" != 0 ]; then
            break
        fi
    done
}

declare -r args_25=("$0" "$@")
sudo -v
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_sudoer__187_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
prepare_provision_repo__182_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
post_prepare_provision__184_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
array_29=()
sym_ensure__73_v0 array_29[@]
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_bin__185_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_rbw__183_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_bin__189_v0 
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
is_command__134_v0 "hx"
ret_is_command134_v0__138_12="${ret_is_command134_v0}"
if [ "$(( ! ${ret_is_command134_v0__138_12} ))" != 0 ]; then
    sudo dnf install -y helix
    __status=$?
    if [ "${__status}" != 0 ]; then
        exit "${__status}"
    fi
fi
install_fish__186_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_wavebox__188_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
