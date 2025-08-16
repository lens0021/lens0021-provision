#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha-32-ge03db06
# date: 2025-08-16 17:16:31
array_find__0_v0() {
    local array=("${!1}")
    local value=$2
    index=0;
    for element in "${array[@]}"; do
        if [ "$([ "_${value}" != "_${element}" ]; echo $?)" != 0 ]; then
            __ret_array_find0_v0="${index}"
            return 0
        fi
        (( index++ )) || true
    done
    __ret_array_find0_v0="$(echo  '-' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
    return 0
}

array_contains__2_v0() {
    local array=("${!1}")
    local value=$2
    array_find__0_v0 array[@] "${value}"
    __ret_array_find0_v0__26_18="${__ret_array_find0_v0}"
    result="${__ret_array_find0_v0__26_18}"
    __ret_array_contains2_v0="$(echo "${result}" '>=' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
    return 0
}

# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
bash_version__10_v0() {
    __0_command="$(echo "${BASH_VERSINFO[0]}")"
    major="${__0_command}"
    __1_command="$(echo "${BASH_VERSINFO[1]}")"
    minor="${__1_command}"
    __2_command="$(echo "${BASH_VERSINFO[2]}")"
    patch="${__2_command}"
    __3_array=("${major}" "${minor}" "${patch}")
    __ret_bash_version10_v0=("${__3_array[@]}")
    return 0
}

replace__11_v0() {
    local source=$1
    local search=$2
    local replace=$3
    # Here we use a command to avoid #646
    result=""
    bash_version__10_v0 
    __ret_bash_version10_v0__15_8=("${__ret_bash_version10_v0[@]}")
    __left_comp=("${__ret_bash_version10_v0__15_8[@]}")
    __4_array=(4 3)
    __right_comp=("${__4_array[@]}")
    __comp="$(
        # Compare if left array >= right array
        __len_comp="$( (( "${#__left_comp[@]}" < "${#__right_comp[@]}" )) && echo "${#__left_comp[@]}"|| echo "${#__right_comp[@]}")"
        for (( __i=0; __i<__len_comp; __i++ )); do
            __left="${__left_comp[__i]:-0}"
            __right="${__right_comp[__i]:-0}"
            if (( "${__left}" > "${__right}" )); then
                echo 1
                exit
            elif (( "${__left}" < "${__right}" )); then
                echo 0
                exit
            fi
        done
        (( "${#__left_comp[@]}" == "${#__right_comp[@]}" || "${#__left_comp[@]}" > "${#__right_comp[@]}" )) && echo 1 || echo 0
)"
    if [ "${__comp}" != 0 ]; then
        result="${source//"${search}"/"${replace}"}"
    else
        result="${source//"${search}"/${replace}}"
    fi
    __ret_replace11_v0="${result}"
    return 0
}

split__15_v0() {
    local text=$1
    local delimiter=$2
    __5_array=()
    result=("${__5_array[@]}")
    IFS="${delimiter}" read -rd '' -a result < <(printf %s "$text")
    __ret_split15_v0=("${result[@]}")
    return 0
}

text_contains__26_v0() {
    local text=$1
    local phrase=$2
    __6_command="$(if [[ "${text}" == *"${phrase}"* ]]; then
    echo 1
  fi)"
    result="${__6_command}"
    __ret_text_contains26_v0="$([ "_${result}" != "_1" ]; echo $?)"
    return 0
}

rpad__38_v0() {
    local text=$1
    local pad=$2
    local length=$3
    __7_length="${text}"
    if [ "$(echo "${length}" '<=' "${#__7_length}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        __ret_rpad38_v0="${text}"
        return 0
    fi
    __8_length="${text}"
    length="$(echo "${#__8_length}" '-' "${length}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
    __9_command="$(printf "%${length}s" "" | tr " " "${pad}")"
    pad="${__9_command}"
    __ret_rpad38_v0="${text}""${pad}"
    return 0
}

dir_exists__44_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_dir_exists44_v0=0
        return 0
    fi
    __ret_dir_exists44_v0=1
    return 0
}

file_exists__45_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_file_exists45_v0=0
        return 0
    fi
    __ret_file_exists45_v0=1
    return 0
}

file_read__46_v0() {
    local path=$1
    __10_command="$(< "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_file_read46_v0=''
        return "${__status}"
    fi
    __ret_file_read46_v0="${__10_command}"
    return 0
}

file_write__47_v0() {
    local path=$1
    local content=$2
    __11_command="$(echo "${content}" > "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_file_write47_v0=''
        return "${__status}"
    fi
    __ret_file_write47_v0="${__11_command}"
    return 0
}

file_append__48_v0() {
    local path=$1
    local content=$2
    __12_command="$(echo "${content}" >> "${path}")"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_file_append48_v0=''
        return "${__status}"
    fi
    __ret_file_append48_v0="${__12_command}"
    return 0
}

symlink_create__49_v0() {
    local origin=$1
    local destination=$2
    file_exists__45_v0 "${origin}"
    __ret_file_exists45_v0__41_8="${__ret_file_exists45_v0}"
    if [ "${__ret_file_exists45_v0__41_8}" != 0 ]; then
        ln -s "${origin}" "${destination}"
        __ret_symlink_create49_v0=1
        return 0
    fi
    echo "The file ${origin} doesn't exist"'!'""
    __ret_symlink_create49_v0=0
    return 0
}

dir_create__50_v0() {
    local path=$1
    dir_exists__44_v0 "${path}"
    __ret_dir_exists44_v0__52_12="${__ret_dir_exists44_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists44_v0__52_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        mkdir -p "${path}"
    fi
}

file_chmod__53_v0() {
    local path=$1
    local mode=$2
    file_exists__45_v0 "${path}"
    __ret_file_exists45_v0__96_8="${__ret_file_exists45_v0}"
    if [ "${__ret_file_exists45_v0__96_8}" != 0 ]; then
        chmod "${mode}" "${path}"
        __ret_file_chmod53_v0=1
        return 0
    fi
    echo "The file ${path} doesn't exist"'!'""
    __ret_file_chmod53_v0=0
    return 0
}

__13_command="$(sudo -u#1000 bash -c 'echo $HOME')"
__3_user_home="${__13_command}"
resolve__67_v0() {
    local path=$1
    replace__11_v0 "${path}" "~" "${__3_user_home}"
    __ret_replace11_v0__20_16="${__ret_replace11_v0}"
    __ret_resolve67_v0="${__ret_replace11_v0__20_16}"
    return 0
}

dirname__68_v0() {
    local path=$1
    __14_command="$(dirname ${path})"
    __ret_dirname68_v0="${__14_command}"
    return 0
}

sym_list__69_v0() {
    __15_command="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_sym_list69_v0=''
        return "${__status}"
    fi
    split__15_v0 "${__15_command}" "
"
    __ret_split15_v0__29_18=("${__ret_split15_v0[@]}")
    srcs=("${__ret_split15_v0__29_18[@]}")
    __16_command="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json | wc -L)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_sym_list69_v0=''
        return "${__status}"
    fi
    longest_src_col="${__16_command}"
    __17_command="$(jq -r '.sym | values | .[]' ~/.config/declair/config.json | wc -L)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_sym_list69_v0=''
        return "${__status}"
    fi
    longest_dist_col="${__17_command}"
    for src in "${srcs[@]}"; do
        replace__11_v0 "${src}" "~" "${__3_user_home}"
        __ret_replace11_v0__33_30="${__ret_replace11_v0}"
        resolved_src="${__ret_replace11_v0__33_30}"
        __18_command="$(jq -r ".sym[\"${src}\"]" ~/.config/declair/config.json)"
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_sym_list69_v0=''
            return "${__status}"
        fi
        dist="${__18_command}"
        replace__11_v0 "${dist}" "~" "${__3_user_home}"
        __ret_replace11_v0__35_31="${__ret_replace11_v0}"
        resolved_dist="${__ret_replace11_v0__35_31}"
        state="Unknown"
        file_exists__45_v0 "${resolved_dist}"
        __ret_file_exists45_v0__37_12="${__ret_file_exists45_v0}"
        if [ "${__ret_file_exists45_v0__37_12}" != 0 ]; then
            state="Existing"
            __19_command="$(realpath ${resolved_dist})"
            __status=$?
            if [ "${__status}" != 0 ]; then
                __ret_sym_list69_v0=''
                return "${__status}"
            fi
            if [ "$([ "_${__19_command}" != "_${resolved_src}" ]; echo $?)" != 0 ]; then
                state="OK"
            fi
        fi
        # TODO: Colorize
        rpad__38_v0 "${src}" " " "$(echo "${longest_src_col}" '+' 2 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
        __ret_rpad38_v0__44_14="${__ret_rpad38_v0}"
        rpad__38_v0 "${dist}" " " "$(echo "${longest_dist_col}" '+' 2 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
        __ret_rpad38_v0__44_52="${__ret_rpad38_v0}"
        echo "${__ret_rpad38_v0__44_14}""${__ret_rpad38_v0__44_52}""${state}"
    done
}

sym_ensure__70_v0() {
    local targets=("${!1}")
    __20_command="$(jq -r '.sym | keys | .[]' ~/.config/declair/config.json)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_sym_ensure70_v0=''
        return "${__status}"
    fi
    split__15_v0 "${__20_command}" "
"
    __ret_split15_v0__50_18=("${__ret_split15_v0[@]}")
    srcs=("${__ret_split15_v0__50_18[@]}")
    __21_length=("${targets[@]}")
    __22_length=("${targets[@]}")
    if [ "$(echo "$(echo ${#__21_length[@]} '==' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" '||' "$(echo "$(echo ${#__22_length[@]} '==' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" '&&' "$([ "_${targets[0]}" != "_" ]; echo $?)" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        targets=("${srcs[@]}")
    fi
    for target in "${targets[@]}"; do
        if [ "$([ "_${target}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        array_contains__2_v0 srcs[@] "${target}"
        __ret_array_contains2_v0__58_16="${__ret_array_contains2_v0}"
        if [ "$(echo  '!' "${__ret_array_contains2_v0__58_16}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
            resolve__67_v0 "${target}"
            __ret_resolve67_v0__59_22="${__ret_resolve67_v0}"
            target="${__ret_resolve67_v0__59_22}"
            echo "No ${target} declared in config.json"
            continue
        fi
        resolve__67_v0 "${target}"
        __ret_resolve67_v0__63_28="${__ret_resolve67_v0}"
        file_exists__45_v0 "${__ret_resolve67_v0__63_28}"
        __ret_file_exists45_v0__63_16="${__ret_file_exists45_v0}"
        if [ "$(echo  '!' "${__ret_file_exists45_v0__63_16}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
            echo "no ${target}, skipping"
            continue
        else
            __23_command="$(jq -r ".sym[\"${target}\"]" ~/.config/declair/config.json)"
            __status=$?
            if [ "${__status}" != 0 ]; then
                __ret_sym_ensure70_v0=''
                return "${__status}"
            fi
            resolve__67_v0 "${__23_command}"
            __ret_resolve67_v0__67_26="${__ret_resolve67_v0}"
            dist="${__ret_resolve67_v0__67_26}"
            file_exists__45_v0 "${dist}"
            __ret_file_exists45_v0__68_20="${__ret_file_exists45_v0}"
            if [ "$(echo  '!' "${__ret_file_exists45_v0__68_20}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
                dirname__68_v0 "${dist}"
                __ret_dirname68_v0__69_28="${__ret_dirname68_v0}"
                dir_create__50_v0 "${__ret_dirname68_v0__69_28}"
                resolve__67_v0 "${target}"
                __ret_resolve67_v0__70_32="${__ret_resolve67_v0}"
                symlink_create__49_v0 "${__ret_resolve67_v0__70_32}" "${dist}"
            fi
        fi
    done
}

env_var_get__128_v0() {
    local name=$1
    __24_command="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_env_var_get128_v0=''
        return "${__status}"
    fi
    __ret_env_var_get128_v0="${__24_command}"
    return 0
}

is_command__130_v0() {
    local command=$1
    [ -x "$(command -v "${command}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_is_command130_v0=0
        return 0
    fi
    __ret_is_command130_v0=1
    return 0
}

file_download__174_v0() {
    local url=$1
    local path=$2
    is_command__130_v0 "curl"
    __ret_is_command130_v0__9_9="${__ret_is_command130_v0}"
    is_command__130_v0 "wget"
    __ret_is_command130_v0__12_9="${__ret_is_command130_v0}"
    is_command__130_v0 "aria2c"
    __ret_is_command130_v0__15_9="${__ret_is_command130_v0}"
    if [ "${__ret_is_command130_v0__9_9}" != 0 ]; then
        curl -L -o "${path}" "${url}"
    elif [ "${__ret_is_command130_v0__12_9}" != 0 ]; then
        wget "${url}" -P "${path}"
    elif [ "${__ret_is_command130_v0__15_9}" != 0 ]; then
        aria2c "${url}" -d "${path}"
    else
        __ret_file_download174_v0=0
        return 0
    fi
    __ret_file_download174_v0=1
    return 0
}

__25_command="$(sudo -u#1000 bash -c 'echo $HOME')"
__status=$?
__4_user_home="${__25_command}"
prepare_provision_repo__178_v0() {
    dir_exists__44_v0 "${__4_user_home}/git/lens/provision"
    __ret_dir_exists44_v0__19_12="${__ret_dir_exists44_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists44_v0__19_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        git clone https://github.com/lens0021/provision ${__4_user_home}/git/lens/provision
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_prepare_provision_repo178_v0=''
            return "${__status}"
        fi
    fi
    __26_command="$(git --git-dir "${__4_user_home}/git/lens/provision/.git" rev-parse --is-shallow-repository)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_prepare_provision_repo178_v0=''
        return "${__status}"
    fi
    if [ "$([ "_${__26_command}" != "_true" ]; echo $?)" != 0 ]; then
        git --git-dir "${__4_user_home}/git/lens/provision/.git" fetch --unshallow
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_prepare_provision_repo178_v0=''
            return "${__status}"
        fi
    fi
}

setup_rbw__179_v0() {
    is_command__130_v0 "rbw"
    __ret_is_command130_v0__28_12="${__ret_is_command130_v0}"
    if [ "$(echo  '!' "${__ret_is_command130_v0__28_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        sudo dnf install -y rbw
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_rbw179_v0=''
            return "${__status}"
        fi
    fi
    rbw config set email lorentz0021@gmail.com
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_setup_rbw179_v0=''
        return "${__status}"
    fi
    rbw login
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_setup_rbw179_v0=''
        return "${__status}"
    fi
}

post_prepare_provision__180_v0() {
    file_exists__45_v0 "${__4_user_home}/.config/declair/config.json"
    __ret_file_exists45_v0__36_12="${__ret_file_exists45_v0}"
    if [ "$(echo  '!' "${__ret_file_exists45_v0__36_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        dir_create__50_v0 "${__4_user_home}/.config/declair"
        symlink_create__49_v0 "${__4_user_home}/git/lens/provision/config/declair.json" "${__4_user_home}/.config/declair/config.json"
    fi
    dir_exists__44_v0 "${__4_user_home}/.config/bin"
    __ret_dir_exists44_v0__40_12="${__ret_dir_exists44_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists44_v0__40_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        dir_create__50_v0 "${__4_user_home}/.config/bin"
    fi
    file_exists__45_v0 "${__4_user_home}/.config/bin/config.json"
    __ret_file_exists45_v0__43_12="${__ret_file_exists45_v0}"
    if [ "$(echo  '!' "${__ret_file_exists45_v0__43_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        symlink_create__49_v0 "${__4_user_home}/git/lens/provision/config/bin.config" "${__4_user_home}/.config/bin/config.json"
    fi
}

install_bin__181_v0() {
    is_command__130_v0 "bin"
    __ret_is_command130_v0__49_12="${__ret_is_command130_v0}"
    if [ "$(echo  '!' "${__ret_is_command130_v0__49_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        file_exists__45_v0 "bin"
        __ret_file_exists45_v0__50_16="${__ret_file_exists45_v0}"
        if [ "$(echo  '!' "${__ret_file_exists45_v0__50_16}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
            file_download__174_v0 "https://github.com/marcosnils/bin/releases/download/v0.21.2/bin_0.21.2_linux_amd64" "bin"
        fi
        file_chmod__53_v0 "bin" "+x"
        ./bin ensure bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_bin181_v0=''
            return "${__status}"
        fi
        rm ./bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_bin181_v0=''
            return "${__status}"
        fi
    fi
}

install_fish__182_v0() {
    is_command__130_v0 "fish"
    __ret_is_command130_v0__60_12="${__ret_is_command130_v0}"
    if [ "$(echo  '!' "${__ret_is_command130_v0__60_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        sudo dnf install -y fish
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_fish182_v0=''
            return "${__status}"
        fi
    fi
    __27_command="$(sudo -u#1000 bash -c 'echo $SHELL')"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_install_fish182_v0=''
        return "${__status}"
    fi
    if [ "$([ "_${__27_command}" == "_/usr/bin/fish" ]; echo $?)" != 0 ]; then
        chsh -s "$(which fish)" nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_fish182_v0=''
            return "${__status}"
        fi
    fi
    fish -c "functions -q fisher"
    __status=$?
    if [ "${__status}" != 0 ]; then
        fisher_url="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
        curl -sL ${fisher_url} | source && fisher install jorgebucaran/fisher
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_fish182_v0=''
            return "${__status}"
        fi
    fi
}

setup_sudoer__183_v0() {
    # https://github.com/amber-lang/amber/issues/220
    dir_exists__44_v0 "/etc/sudoers.d/"
    __ret_dir_exists44_v0__74_12="${__ret_dir_exists44_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists44_v0__74_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        # dir_create("/etc/sudoersh.d")
        sudo mkdir -p /etc/sudoers.d/
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_sudoer183_v0=''
            return "${__status}"
        fi
    fi
    file_exists__45_v0 "/etc/sudoers.d/nemo"
    __ret_file_exists45_v0__78_8="${__ret_file_exists45_v0}"
    if [ "${__ret_file_exists45_v0__78_8}" != 0 ]; then
        file_read__46_v0 "/etc/sudoers.d/nemo"
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_sudoer183_v0=''
            return "${__status}"
        fi
        __ret_file_read46_v0__79_25="${__ret_file_read46_v0}"
        content="${__ret_file_read46_v0__79_25}"
        text_contains__26_v0 "${content}" "nemo ALL=(ALL:ALL) NOPASSWD: ALL"
        __ret_text_contains26_v0__80_16="${__ret_text_contains26_v0}"
        if [ "$(echo  '!' "${__ret_text_contains26_v0__80_16}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
            file_append__48_v0 "/etc/sudoers.d/nemo" "nemo ALL=(ALL:ALL) NOPASSWD: ALL
"
            __status=$?
            if [ "${__status}" != 0 ]; then
                __ret_setup_sudoer183_v0=''
                return "${__status}"
            fi
        fi
    else
        sudo touch /etc/sudoers.d/nemo
        file_write__47_v0 "/tmp/sudoer-nemo" "nemo ALL=(ALL:ALL) NOPASSWD: ALL
"
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_sudoer183_v0=''
            return "${__status}"
        fi
        sudo chown -R root:root /tmp/sudoer-nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_sudoer183_v0=''
            return "${__status}"
        fi
        sudo mv /tmp/sudoer-nemo /etc/sudoers.d/nemo
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_sudoer183_v0=''
            return "${__status}"
        fi
    fi
    sudo chmod u+s /usr/bin/sudo
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_setup_sudoer183_v0=''
        return "${__status}"
    fi
}

install_wavebox__184_v0() {
    sudo rpm --import https://download.wavebox.app/static/wavebox_repo.key
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_install_wavebox184_v0=''
        return "${__status}"
    fi
    dir_exists__44_v0 "/etc/yum.repos.d/wavebox.repo"
    __ret_dir_exists44_v0__94_12="${__ret_dir_exists44_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists44_v0__94_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        sudo wget -P /etc/yum.repos.d/ https://download.wavebox.app/stable/linux/rpm/wavebox.repo
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_wavebox184_v0=''
            return "${__status}"
        fi
    fi
    sudo dnf install -y Wavebox
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_install_wavebox184_v0=''
        return "${__status}"
    fi
}

setup_bin__185_v0() {
    bin ensure gh
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_setup_bin185_v0=''
        return "${__status}"
    fi
    while :
    do
        done=1
        gh auth token
        __status=$?
        if [ "${__status}" != 0 ]; then
            done=0
            echo "Sign in to bitwarden to see the Github Password"
            rbw get 356c6b3b-2dbe-4804-9918-af0700970344
            __status=$?
            if [ "${__status}" != 0 ]; then
                __ret_setup_bin185_v0=''
                return "${__status}"
            fi
            gh auth login
            __status=$?
            if [ "${__status}" != 0 ]; then
                __ret_setup_bin185_v0=''
                return "${__status}"
            fi
        fi
        if [ "${done}" != 0 ]; then
            break
        fi
    done
    while :
    do
        done=1
        env_var_get__128_v0 "GITHUB_AUTH_TOKEN"
        __status=$?
        if [ "${__status}" != 0 ]; then
            done=0
            echo "Visit https://github.com/settings/personal-access-tokens and copy the token."
        fi
        if [ "${done}" != 0 ]; then
            break
        fi
    done
}

declare -r args=("$0" "$@")
sudo -v
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_sudoer__183_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
prepare_provision_repo__178_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
post_prepare_provision__180_v0 
__28_array=()
sym_ensure__70_v0 __28_array[@]
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_bin__181_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_rbw__179_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_bin__185_v0 
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
is_command__130_v0 "hx"
__ret_is_command130_v0__138_12="${__ret_is_command130_v0}"
if [ "$(echo  '!' "${__ret_is_command130_v0__138_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
    sudo dnf install -y helix
    __status=$?
    if [ "${__status}" != 0 ]; then
        exit "${__status}"
    fi
fi
install_fish__182_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_wavebox__184_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi