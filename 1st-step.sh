#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha-32-ge03db06
# date: 2025-07-12 10:23:54
# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
dir_exists__34_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_dir_exists34_v0=0
        return 0
    fi
    __ret_dir_exists34_v0=1
    return 0
}

file_exists__35_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_file_exists35_v0=0
        return 0
    fi
    __ret_file_exists35_v0=1
    return 0
}

symlink_create__39_v0() {
    local origin=$1
    local destination=$2
    file_exists__35_v0 "${origin}"
    __ret_file_exists35_v0__41_8="${__ret_file_exists35_v0}"
    if [ "${__ret_file_exists35_v0__41_8}" != 0 ]; then
        ln -s "${origin}" "${destination}"
        __ret_symlink_create39_v0=1
        return 0
    fi
    echo "The file ${origin} doesn't exist"'!'""
    __ret_symlink_create39_v0=0
    return 0
}

dir_create__40_v0() {
    local path=$1
    dir_exists__34_v0 "${path}"
    __ret_dir_exists34_v0__52_12="${__ret_dir_exists34_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists34_v0__52_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        mkdir -p "${path}"
    fi
}

file_chmod__43_v0() {
    local path=$1
    local mode=$2
    file_exists__35_v0 "${path}"
    __ret_file_exists35_v0__96_8="${__ret_file_exists35_v0}"
    if [ "${__ret_file_exists35_v0__96_8}" != 0 ]; then
        chmod "${mode}" "${path}"
        __ret_file_chmod43_v0=1
        return 0
    fi
    echo "The file ${path} doesn't exist"'!'""
    __ret_file_chmod43_v0=0
    return 0
}

is_command__103_v0() {
    local command=$1
    [ -x "$(command -v "${command}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_is_command103_v0=0
        return 0
    fi
    __ret_is_command103_v0=1
    return 0
}

file_download__147_v0() {
    local url=$1
    local path=$2
    is_command__103_v0 "curl"
    __ret_is_command103_v0__9_9="${__ret_is_command103_v0}"
    is_command__103_v0 "wget"
    __ret_is_command103_v0__12_9="${__ret_is_command103_v0}"
    is_command__103_v0 "aria2c"
    __ret_is_command103_v0__15_9="${__ret_is_command103_v0}"
    if [ "${__ret_is_command103_v0__9_9}" != 0 ]; then
        curl -L -o "${path}" "${url}"
    elif [ "${__ret_is_command103_v0__12_9}" != 0 ]; then
        wget "${url}" -P "${path}"
    elif [ "${__ret_is_command103_v0__15_9}" != 0 ]; then
        aria2c "${url}" -d "${path}"
    else
        __ret_file_download147_v0=0
        return 0
    fi
    __ret_file_download147_v0=1
    return 0
}

__0_command="$(sudo -u#1000 bash -c 'echo $HOME')"
__status=$?
__3_user_home="${__0_command}"
prepare_provision__150_v0() {
    dir_exists__34_v0 "${__3_user_home}/git/lens/provision"
    __ret_dir_exists34_v0__14_12="${__ret_dir_exists34_v0}"
    if [ "$(echo  '!' "${__ret_dir_exists34_v0__14_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        git clone https://github.com/lens0021/provision ${__3_user_home}/git/lens/provision
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_prepare_provision150_v0=''
            return "${__status}"
        fi
    fi
    __1_command="$(git --git-dir "${__3_user_home}/git/lens/provision/.git" rev-parse --is-shallow-repository)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_prepare_provision150_v0=''
        return "${__status}"
    fi
    if [ "$([ "_${__1_command}" != "_true" ]; echo $?)" != 0 ]; then
        git --git-dir "${__3_user_home}/git/lens/provision/.git" fetch --unshallow
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_prepare_provision150_v0=''
            return "${__status}"
        fi
    fi
}

setup_rbw__151_v0() {
    is_command__103_v0 "rbw"
    __ret_is_command103_v0__23_12="${__ret_is_command103_v0}"
    if [ "$(echo  '!' "${__ret_is_command103_v0__23_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        sudo dnf install -y rbw
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_setup_rbw151_v0=''
            return "${__status}"
        fi
    fi
    rbw config set email lorentz0021@gmail.com
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_setup_rbw151_v0=''
        return "${__status}"
    fi
    rbw login
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_setup_rbw151_v0=''
        return "${__status}"
    fi
}

symlink_files__152_v0() {
    file_exists__35_v0 "${__3_user_home}/.config/bin/config.json"
    __ret_file_exists35_v0__31_12="${__ret_file_exists35_v0}"
    if [ "$(echo  '!' "${__ret_file_exists35_v0__31_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        symlink_create__39_v0 "${__3_user_home}/git/lens/provision/config/bin.config" "${__3_user_home}/.config/bin/config.json"
    fi
}

install_bin__153_v0() {
    is_command__103_v0 "bin"
    __ret_is_command103_v0__37_12="${__ret_is_command103_v0}"
    if [ "$(echo  '!' "${__ret_is_command103_v0__37_12}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
        file_exists__35_v0 "bin"
        __ret_file_exists35_v0__38_16="${__ret_file_exists35_v0}"
        if [ "$(echo  '!' "${__ret_file_exists35_v0__38_16}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')" != 0 ]; then
            file_download__147_v0 "https://github.com/marcosnils/bin/releases/download/v0.21.2/bin_0.21.2_linux_amd64" "bin"
        fi
        file_chmod__43_v0 "bin" "+x"
        ./bin ensure bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_bin153_v0=''
            return "${__status}"
        fi
        rm ./bin
        __status=$?
        if [ "${__status}" != 0 ]; then
            __ret_install_bin153_v0=''
            return "${__status}"
        fi
    fi
}

install_hx__154_v0() {
    bin ensure hx
    __status=$?
    if [ "${__status}" != 0 ]; then
        __ret_install_hx154_v0=''
        return "${__status}"
    fi
    echo "todo"
}

declare -r args=("$0" "$@")
prepare_provision__150_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
__2_array=("${__3_user_home}/.config/bin")
for dir in "${__2_array[@]}"; do
    dir_create__40_v0 "${dir}"
done
symlink_files__152_v0 
install_bin__153_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
setup_rbw__151_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
bin ensure gh
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
while :
do
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Sign in to bitwarden to see the Github Password"
        rbw get 356c6b3b-2dbe-4804-9918-af0700970344
        __status=$?
        if [ "${__status}" != 0 ]; then
            exit "${__status}"
        fi
        gh auth login
        __status=$?
        if [ "${__status}" != 0 ]; then
            exit "${__status}"
        fi
    fi
    break
done
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
install_hx__154_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi