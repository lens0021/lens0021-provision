#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha
# date: 2025-07-12 13:47:05
array_find__0_v0() {
    local array=("${!1}")
    local value=$2
    index=0;
for element in "${array[@]}"; do
        if [ $([ "_${value}" != "_${element}" ]; echo $?) != 0 ]; then
            __AF_array_find0_v0=${index};
            return 0
fi
    (( index++ )) || true
done
    __AF_array_find0_v0=$(echo  '-' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//');
    return 0
}
array_contains__2_v0() {
    local array=("${!1}")
    local value=$2
    array_find__0_v0 array[@] "${value}";
    __AF_array_find0_v0__26_18="$__AF_array_find0_v0";
    local result="$__AF_array_find0_v0__26_18"
    __AF_array_contains2_v0=$(echo ${result} '>=' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//');
    return 0
}
replace__10_v0() {
    local source=$1
    local search=$2
    local replace=$3
    __AF_replace10_v0="${source//${search}/${replace}}";
    return 0
}
split__13_v0() {
    local text=$1
    local delimiter=$2
    __AMBER_ARRAY_0=();
    local result=("${__AMBER_ARRAY_0[@]}")
     IFS="${delimiter}" read -rd '' -a result < <(printf %s "$text") ;
    __AS=$?
    __AF_split13_v0=("${result[@]}");
    return 0
}
rpad__36_v0() {
    local text=$1
    local pad=$2
    local length=$3
    __AMBER_LEN="${text}";
    if [ $(echo ${length} '<=' "${#__AMBER_LEN}" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        __AF_rpad36_v0="${text}";
        return 0
fi
    __AMBER_LEN="${text}";
    length=$(echo "${#__AMBER_LEN}" '-' ${length} | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
    __AMBER_VAL_1=$( printf "%${length}s" "" | tr " " "${pad}" );
    __AS=$?;
    pad="${__AMBER_VAL_1}"
    __AF_rpad36_v0="${text}""${pad}";
    return 0
}
dir_exists__42_v0() {
    local path=$1
     [ -d "${path}" ] ;
    __AS=$?;
if [ $__AS != 0 ]; then
        __AF_dir_exists42_v0=0;
        return 0
fi
    __AF_dir_exists42_v0=1;
    return 0
}
file_exists__43_v0() {
    local path=$1
     [ -f "${path}" ] ;
    __AS=$?;
if [ $__AS != 0 ]; then
        __AF_file_exists43_v0=0;
        return 0
fi
    __AF_file_exists43_v0=1;
    return 0
}
symlink_create__47_v0() {
    local origin=$1
    local destination=$2
    file_exists__43_v0 "${origin}";
    __AF_file_exists43_v0__41_8="$__AF_file_exists43_v0";
    if [ "$__AF_file_exists43_v0__41_8" != 0 ]; then
         ln -s "${origin}" "${destination}" ;
        __AS=$?
        __AF_symlink_create47_v0=1;
        return 0
fi
    echo "The file ${origin} doesn't exist"'!'""
    __AF_symlink_create47_v0=0;
    return 0
}
dir_create__48_v0() {
    local path=$1
    dir_exists__42_v0 "${path}";
    __AF_dir_exists42_v0__52_12="$__AF_dir_exists42_v0";
    if [ $(echo  '!' "$__AF_dir_exists42_v0__52_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
         mkdir -p "${path}" ;
        __AS=$?
fi
}
file_chmod__49_v0() {
    local path=$1
    local mode=$2
    file_exists__43_v0 "${path}";
    __AF_file_exists43_v0__61_8="$__AF_file_exists43_v0";
    if [ "$__AF_file_exists43_v0__61_8" != 0 ]; then
         chmod "${mode}" "${path}" ;
        __AS=$?
        __AF_file_chmod49_v0=1;
        return 0
fi
    echo "The file ${path} doesn't exist"'!'""
    __AF_file_chmod49_v0=0;
    return 0
}
__AMBER_VAL_2=$( sudo -u#1000 bash -c 'echo $HOME' );
__AS=$?;
__0_user_home="${__AMBER_VAL_2}"
resolve__63_v0() {
    local path=$1
    replace__10_v0 "${path}" "~" "${__0_user_home}";
    __AF_replace10_v0__20_16="${__AF_replace10_v0}";
    __AF_resolve63_v0="${__AF_replace10_v0__20_16}";
    return 0
}
dirname__64_v0() {
    local path=$1
    __AMBER_VAL_3=$( dirname ${path} );
    __AS=$?;
    __AF_dirname64_v0="${__AMBER_VAL_3}";
    return 0
}
sym_list__65_v0() {
    __AMBER_VAL_4=$( jq -r '.sym | keys | .[]' ~/.config/declair/config.json );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_list65_v0=''
return $__AS
fi;
    split__13_v0 "${__AMBER_VAL_4}" "
";
    __AF_split13_v0__29_18=("${__AF_split13_v0[@]}");
    local srcs=("${__AF_split13_v0__29_18[@]}")
    __AMBER_VAL_5=$( jq -r '.sym | keys | .[]' ~/.config/declair/config.json | wc -L );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_list65_v0=''
return $__AS
fi;
    local longest_src_col="${__AMBER_VAL_5}"
    __AMBER_VAL_6=$( jq -r '.sym | values | .[]' ~/.config/declair/config.json | wc -L );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_list65_v0=''
return $__AS
fi;
    local longest_dist_col="${__AMBER_VAL_6}"
    for src in "${srcs[@]}"; do
        replace__10_v0 "${src}" "~" "${__0_user_home}";
        __AF_replace10_v0__33_30="${__AF_replace10_v0}";
        local resolved_src="${__AF_replace10_v0__33_30}"
        __AMBER_VAL_7=$( jq -r ".sym[\"${src}\"]" ~/.config/declair/config.json );
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_list65_v0=''
return $__AS
fi;
        local dist="${__AMBER_VAL_7}"
        replace__10_v0 "${dist}" "~" "${__0_user_home}";
        __AF_replace10_v0__35_31="${__AF_replace10_v0}";
        local resolved_dist="${__AF_replace10_v0__35_31}"
        local state="Unknown"
        file_exists__43_v0 "${resolved_dist}";
        __AF_file_exists43_v0__37_12="$__AF_file_exists43_v0";
        if [ "$__AF_file_exists43_v0__37_12" != 0 ]; then
            state="Existing"
            __AMBER_VAL_8=$( realpath ${resolved_dist} );
            __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_list65_v0=''
return $__AS
fi;
            if [ $([ "_${__AMBER_VAL_8}" != "_${resolved_src}" ]; echo $?) != 0 ]; then
                state="OK"
fi
fi
        # TODO: Colorize
        rpad__36_v0 "${src}" " " $(echo ${longest_src_col} '+' 2 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//');
        __AF_rpad36_v0__44_14="${__AF_rpad36_v0}";
        rpad__36_v0 "${dist}" " " $(echo ${longest_dist_col} '+' 2 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//');
        __AF_rpad36_v0__44_52="${__AF_rpad36_v0}";
        echo "${__AF_rpad36_v0__44_14}""${__AF_rpad36_v0__44_52}""${state}"
done
}
sym_ensure__66_v0() {
    local targets=("${!1}")
    __AMBER_VAL_9=$( jq -r '.sym | keys | .[]' ~/.config/declair/config.json );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_ensure66_v0=''
return $__AS
fi;
    split__13_v0 "${__AMBER_VAL_9}" "
";
    __AF_split13_v0__50_18=("${__AF_split13_v0[@]}");
    local srcs=("${__AF_split13_v0__50_18[@]}")
    if [ $(echo $(echo "${#targets[@]}" '==' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') '||' $(echo $(echo "${#targets[@]}" '==' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') '&&' $([ "_${targets[0]}" != "_" ]; echo $?) | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        targets=("${srcs[@]}")
fi
    for target in "${targets[@]}"; do
        if [ $([ "_${target}" != "_" ]; echo $?) != 0 ]; then
            continue
fi
        array_contains__2_v0 srcs[@] "${target}";
        __AF_array_contains2_v0__58_16="$__AF_array_contains2_v0";
        if [ $(echo  '!' "$__AF_array_contains2_v0__58_16" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
            resolve__63_v0 "${target}";
            __AF_resolve63_v0__59_22="${__AF_resolve63_v0}";
            target="${__AF_resolve63_v0__59_22}"
            echo "No ${target} declared in config.json"
            continue
fi
        resolve__63_v0 "${target}";
        __AF_resolve63_v0__63_28="${__AF_resolve63_v0}";
        file_exists__43_v0 "${__AF_resolve63_v0__63_28}";
        __AF_file_exists43_v0__63_16="$__AF_file_exists43_v0";
        if [ $(echo  '!' "$__AF_file_exists43_v0__63_16" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
            echo "TODO no ${target}"
            continue
else
            __AMBER_VAL_10=$( jq -r ".sym[\"${target}\"]" ~/.config/declair/config.json );
            __AS=$?;
if [ $__AS != 0 ]; then
__AF_sym_ensure66_v0=''
return $__AS
fi;
            resolve__63_v0 "${__AMBER_VAL_10}";
            __AF_resolve63_v0__67_26="${__AF_resolve63_v0}";
            local dist="${__AF_resolve63_v0__67_26}"
            file_exists__43_v0 "${dist}";
            __AF_file_exists43_v0__68_20="$__AF_file_exists43_v0";
            if [ $(echo  '!' "$__AF_file_exists43_v0__68_20" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
                dirname__64_v0 "${dist}";
                __AF_dirname64_v0__69_28="${__AF_dirname64_v0}";
                dir_create__48_v0 "${__AF_dirname64_v0__69_28}";
                __AF_dir_create48_v0__69_17="$__AF_dir_create48_v0";
                echo "$__AF_dir_create48_v0__69_17" > /dev/null 2>&1
                resolve__63_v0 "${target}";
                __AF_resolve63_v0__70_32="${__AF_resolve63_v0}";
                symlink_create__47_v0 "${__AF_resolve63_v0__70_32}" "${dist}";
                __AF_symlink_create47_v0__70_17="$__AF_symlink_create47_v0";
                echo "$__AF_symlink_create47_v0__70_17" > /dev/null 2>&1
fi
fi
done
}
is_command__121_v0() {
    local command=$1
     [ -x "$(command -v ${command})" ] ;
    __AS=$?;
if [ $__AS != 0 ]; then
        __AF_is_command121_v0=0;
        return 0
fi
    __AF_is_command121_v0=1;
    return 0
}
file_download__163_v0() {
    local url=$1
    local path=$2
    is_command__121_v0 "curl";
    __AF_is_command121_v0__9_9="$__AF_is_command121_v0";
    is_command__121_v0 "wget";
    __AF_is_command121_v0__12_9="$__AF_is_command121_v0";
    is_command__121_v0 "aria2c";
    __AF_is_command121_v0__15_9="$__AF_is_command121_v0";
    if [ "$__AF_is_command121_v0__9_9" != 0 ]; then
         curl -L -o "${path}" "${url}" ;
        __AS=$?
elif [ "$__AF_is_command121_v0__12_9" != 0 ]; then
         wget "${url}" -P "${path}" ;
        __AS=$?
elif [ "$__AF_is_command121_v0__15_9" != 0 ]; then
         aria2c "${url}" -d "${path}" ;
        __AS=$?
else
        __AF_file_download163_v0=0;
        return 0
fi
    __AF_file_download163_v0=1;
    return 0
}
__AMBER_VAL_11=$( sudo -u#1000 bash -c 'echo $HOME' );
__AS=$?;
__1_user_home="${__AMBER_VAL_11}"
prepare_provision__166_v0() {
    dir_exists__42_v0 "${__1_user_home}/git/lens/provision";
    __AF_dir_exists42_v0__15_12="$__AF_dir_exists42_v0";
    if [ $(echo  '!' "$__AF_dir_exists42_v0__15_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
         git clone https://github.com/lens0021/provision ${__1_user_home}/git/lens/provision ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare_provision166_v0=''
return $__AS
fi
fi
    __AMBER_VAL_12=$( git --git-dir "${__1_user_home}/git/lens/provision/.git" rev-parse --is-shallow-repository );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare_provision166_v0=''
return $__AS
fi;
    if [ $([ "_${__AMBER_VAL_12}" != "_true" ]; echo $?) != 0 ]; then
         git --git-dir "${__1_user_home}/git/lens/provision/.git" fetch --unshallow ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare_provision166_v0=''
return $__AS
fi
fi
}
setup_rbw__167_v0() {
    is_command__121_v0 "rbw";
    __AF_is_command121_v0__24_12="$__AF_is_command121_v0";
    if [ $(echo  '!' "$__AF_is_command121_v0__24_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
         sudo dnf install -y rbw ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_setup_rbw167_v0=''
return $__AS
fi
fi
     rbw config set email lorentz0021@gmail.com ;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_setup_rbw167_v0=''
return $__AS
fi
     rbw login ;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_setup_rbw167_v0=''
return $__AS
fi
}
symlink_files__168_v0() {
    file_exists__43_v0 "${__1_user_home}/.config/declair/config.json";
    __AF_file_exists43_v0__32_12="$__AF_file_exists43_v0";
    if [ $(echo  '!' "$__AF_file_exists43_v0__32_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        dir_create__48_v0 "${__1_user_home}/.config/declair";
        __AF_dir_create48_v0__33_9="$__AF_dir_create48_v0";
        echo "$__AF_dir_create48_v0__33_9" > /dev/null 2>&1
        symlink_create__47_v0 "${__1_user_home}/git/lens/provision/config/declair.json" "${__1_user_home}/.config/declair/config.json";
        __AF_symlink_create47_v0__34_9="$__AF_symlink_create47_v0";
        echo "$__AF_symlink_create47_v0__34_9" > /dev/null 2>&1
fi
    file_exists__43_v0 "${__1_user_home}/.config/bin/config.json";
    __AF_file_exists43_v0__36_12="$__AF_file_exists43_v0";
    if [ $(echo  '!' "$__AF_file_exists43_v0__36_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        symlink_create__47_v0 "${__1_user_home}/git/lens/provision/config/bin.config" "${__1_user_home}/.config/bin/config.json";
        __AF_symlink_create47_v0__37_9="$__AF_symlink_create47_v0";
        echo "$__AF_symlink_create47_v0__37_9" > /dev/null 2>&1
fi
    __AMBER_ARRAY_13=();
    sym_ensure__66_v0 __AMBER_ARRAY_13[@];
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_symlink_files168_v0=''
return $__AS
fi;
    __AF_sym_ensure66_v0__39_5="$__AF_sym_ensure66_v0";
    echo "$__AF_sym_ensure66_v0__39_5" > /dev/null 2>&1
}
install_bin__169_v0() {
    is_command__121_v0 "bin";
    __AF_is_command121_v0__43_12="$__AF_is_command121_v0";
    if [ $(echo  '!' "$__AF_is_command121_v0__43_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        file_exists__43_v0 "bin";
        __AF_file_exists43_v0__44_16="$__AF_file_exists43_v0";
        if [ $(echo  '!' "$__AF_file_exists43_v0__44_16" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
            file_download__163_v0 "https://github.com/marcosnils/bin/releases/download/v0.21.2/bin_0.21.2_linux_amd64" "bin";
            __AF_file_download163_v0__45_13="$__AF_file_download163_v0";
            echo "$__AF_file_download163_v0__45_13" > /dev/null 2>&1
fi
        file_chmod__49_v0 "bin" "+x";
        __AF_file_chmod49_v0__47_9="$__AF_file_chmod49_v0";
        echo "$__AF_file_chmod49_v0__47_9" > /dev/null 2>&1
         ./bin ensure bin ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_install_bin169_v0=''
return $__AS
fi
         rm ./bin ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_install_bin169_v0=''
return $__AS
fi
fi
}
install_fish__170_v0() {
    is_command__121_v0 "fish";
    __AF_is_command121_v0__54_12="$__AF_is_command121_v0";
    if [ $(echo  '!' "$__AF_is_command121_v0__54_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
         sudo dnf install -y fish ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_install_fish170_v0=''
return $__AS
fi
fi
    __AMBER_VAL_14=$( sudo -u#1000 bash -c 'echo $SHELL' );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_install_fish170_v0=''
return $__AS
fi;
    if [ $([ "_${__AMBER_VAL_14}" == "_/usr/bin/fish" ]; echo $?) != 0 ]; then
         chsh -s "$(which fish)" nemo ;
        __AS=$?;
if [ $__AS != 0 ]; then
__AF_install_fish170_v0=''
return $__AS
fi
fi
}
declare -r args=("$0" "$@")
    prepare_provision__166_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_prepare_provision166_v0__71_5="$__AF_prepare_provision166_v0";
    echo "$__AF_prepare_provision166_v0__71_5" > /dev/null 2>&1
    __AMBER_ARRAY_15=("${__1_user_home}/.config/bin");
    for dir in "${__AMBER_ARRAY_15[@]}"; do
        dir_create__48_v0 "${dir}";
        __AF_dir_create48_v0__73_9="$__AF_dir_create48_v0";
        echo "$__AF_dir_create48_v0__73_9" > /dev/null 2>&1
done
    symlink_files__168_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_symlink_files168_v0__75_5="$__AF_symlink_files168_v0";
    echo "$__AF_symlink_files168_v0__75_5" > /dev/null 2>&1
    install_bin__169_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_install_bin169_v0__76_5="$__AF_install_bin169_v0";
    echo "$__AF_install_bin169_v0__76_5" > /dev/null 2>&1
    setup_rbw__167_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_setup_rbw167_v0__77_5="$__AF_setup_rbw167_v0";
    echo "$__AF_setup_rbw167_v0__77_5" > /dev/null 2>&1
     bin ensure gh ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
    gh_token=""
    while :
do
        __AMBER_VAL_16=$( gh auth token );
        __AS=$?;
if [ $__AS != 0 ]; then
            echo "Sign in to bitwarden to see the Github Password"
             rbw get 356c6b3b-2dbe-4804-9918-af0700970344 ;
            __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
             gh auth login ;
            __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
fi;
        gh_token="${__AMBER_VAL_16}"
        break
done
    # TODO set GITHUB_AUTH_TOKEN
     bin ensure yazi ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
     bin ensure zellij ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
     bin ensure lazygit ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
    is_command__121_v0 "hx";
    __AF_is_command121_v0__93_12="$__AF_is_command121_v0";
    if [ $(echo  '!' "$__AF_is_command121_v0__93_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
         sudo dnf install -y helix ;
        __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi
fi
    install_fish__170_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_install_fish170_v0__96_5="$__AF_install_fish170_v0";
    echo "$__AF_install_fish170_v0__96_5" > /dev/null 2>&1
# # DNF_INSTALLED="$(dnf list --installed)"
# # dnf-install-package() {
# #   PACKAGE=$1
# 
# #   if ! echo "$DNF_INSTALLED" | grep "$PACKAGE" >/dev/null; then
# #     echo "🚀 install $PACKAGE"
# #     sudo dnf -y install "$PACKAGE"
# #   else
# #     echo "Skip install $PACKAGE"
# #   fi
# # }
# 
# # sudo -v
# 
# # LINUX_NODENAME="$(uname -n)"
# # echo "LINUX_NODENAME: $LINUX_NODENAME"
# 
# 
# 
# # # ./1st-step
# 
# # #
# # # Installs softwares
# # #
# # case $LINUX_NODENAME in
# #   "fedora")
# #     ;;
# #   "debian" | "ubuntu")
# #     sudo apt update
# #     sudo apt install -y \\
# #       mssh \\
# #       mysql-client-core-8.0 \\
# #       tree \\
# #       flatpak \\
# #       baobab \\
# #       ruby-full \\
# #       sqlite3 \\
# 
# #     # Ubuntu
# #     #  "$(check-language-support)" \\
# #     #  "$(check-language-support -l ja)" \\
# #     # sudo apt install -y \\
# #     #   evolution-data-server
# #     ;;
# # esac
# 
# # #
# # # Change the background color of grub
# # #
# # if [ "$LINUX_NODENAME" = "debian" ]; then
# #   cat <<EOF >/boot/grub/custom.cfg
# # # set color_normal=light-gray/black
# # # set color_highlight=white/cyan
# 
# # set menu_color_normal=white/black
# # set menu_color_highlight=black/white
# # EOF
# # fi
# 
# # #
# # # Gnome
# # #
# # case $LINUX_NODENAME in
# #   "fedora")
# #     ;;
# #   "debian")
# #     echo "🚀 Install Gnome stuff ($0:$LINENO)"
# #     sudo apt -t unstable install -y \\
# #       gnome-clocks \\
# #       gnome-colors \\
# #       gnome-session \\
# #       gnome-shell \\
# #       gnome-backgrounds \\
# #       gnome-applets \\
# #       gnome-control-center \\
# #       mutter \\
# #       gjs \\
# #       tracker-miner-fs \\
# #       ;
# #     ;;
# # esac
# 
# # #
# # # Python
# # #
# # # case $LINUX_NODENAME in
# # #   'fedora')
# # #     sudo dnf install -y \\
# # #       python3-pip
# # #     ;;
# # #   'ubuntu' | 'debian')
# # #     sudo apt install -y \\
# # #       python3-pip \\
# # #       python3-venv
# # #     ;;
# # # esac
# # # sudo ln -s /usr/bin/python3 /usr/bin/python || true
# # # sudo ln -s /usr/bin/pip3 /usr/bin/pip || true
# # # pip install -U \\
# # #   flake8 \\
# # #   pytest \\
# # #   wheel \\
# # #   pre-commit
# # # curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python \-
# \
# # \#
# # # Ruby
# # # TODO: asdf
# # #
# # # echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
# # # echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
# # # echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
# 
# # #
# # # Keybase
# # #
# # if ! command -v keybase >/dev/null; then
# #   echo "🚀 Install Keybase ($0:$LINENO)"\\
# \#   case $LINUX_NODENAME in
# #  \   "fedora")
# #       sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
# #       ;;
# #     "debian")
# #       curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb -o ~/Downloads/keybase_amd64.deb
# #       sudo apt install -y ~/Downloads/keybase_amd64.deb
# #       rm ~/Downloads/keybase_amd64.deb
# #       ;;
# #   esac
# # else
# #   echo 'Skip install keybase'
# # fi
# 
# # # shfmt
# # if ! command -v shfmt >/dev/null; then
# #   case $LINUX_NODENAME in
# #     "fedora")
# #       dnf-install-package shfmt
# #       ;;
# #     "debian")
# #       # TODO
# #       ;;
# #   esac
# # fi
# 
# # #
# # # ETC yarn packages
# # #
# # # YARN_INSTALLED=$(yarn global list)
# # # yarn-add() {
# # #   PACKAGE=$1
# # #
# # #   if ! echo "$YARN_INSTALLED" | grep "$PACKAGE"; then
# # #     echo "🚀 Install npm packages ($0:$LINENO)"
# # #     yarn global add "$PACKAGE"
# # #   fi
# # # }
# # # yarn-add prettier
# # # yarn-add eslint
# # # yarn-add stylelint
# 
# # #
# # # Git
# # #
# # # git config --global user.name "lens0021"
# # # git config --global user.email "lorentz0021@gmail.com"
# # # git config --global --add gitreview.username "lens0021"
# 
# # # git config --global color.status always
# # # git config --global commit.gpgsign true
# # # git config --global core.editor hx
# # # git config --global credential.credentialStore secretservice
# # # git config --global init.defaultBranch main
# # # git config --global merge.conflictstyle diff3 true
# # # git config --global pull.rebase true
# # # git config --global rebase.autostash true
# # # git config --global rerere.enabled true
# # # git config --global submodule.recurse true
# 
# # # git config --global alias.graph 'log --graph --all --decorate --oneline --color'
# 
# # # if ! grep 'GPG_TTY' "$USER_HOME/.bashrc" >/dev/null; then
# # #   # shellcheck disable=2016
# # #   echo 'GPG_TTY=$(tty); export GPG_TTY' >>"$USER_HOME/.bashrc"
# # #   mkdir -p "$USER_HOME/.gnupg"
# # #   echo 'default-cache-ttl 3600' >>"$USER_HOME/.gnupg/gpg-agent.conf"
# # # fi
# 
# # #
# # # Git Credential Manager Core
# # #
# # case $LINUX_NODENAME in
# #   "fedora")
# #     #TODO
# #     ;;
# #   "debian")
# #     echo "🚀 Install Git Credential Manager Core ($0:$LINENO)"
# #     curl -sSL https://packages.microsoft.com/config/ubuntu/21.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
# #     curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
# #     sudo apt-get update
# #     sudo apt-get install -y gcmcore
# #     git-credential-manager-core configure
# #     ;;
# # esac
# 
# # #
# # # VS Code
# # #
# # # if ! command -v code >/dev/null; then
# # #   case $LINUX_NODENAME in
# # #     "fedora")
# # #       sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# # #       sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
# # #       dnf check-update
# # #       sudo dnf install -y code
# # #       ;;
# # #     "debian" | "ubuntu")
# # #       curl -L https://update.code.visualstudio.com/latest/linux-deb-x64/stable -o ~/Downloads/code_amd64.deb
# # #       sudo dpkg -i ~/Downloads/code_amd64.deb
# # #       rm ~/Downloads/code_amd64.deb
# # #       ;;
# # #   esac
# # # fi
# 
# # #
# # # Starship
# # #
# # # sudo dnf copr enable -y atim/starship
# # # dnf-install-package starship
# 
# # #
# # # Codium
# # #
# # # if ! command -v codium >/dev/null; then
# # #   echo "🚀 Install Codium ($0:$LINENO)"
# # #   case $LINUX_NODENAME in
# # #     "fedora")
# # #       # VSCodium
# # #       sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
# # #       printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
# # #       sudo dnf install -y codium
# 
# # #   if ! echo ~/.bashrc | grep codium >/dev/null; then
# # #   echo 'alias code=codium' >> ~/.bashrc
# # #   fi
# 
# # #       ;;
# # #     "debian" | "ubuntu")
# # #       # TODO
# # #       ;;
# # #   esac
# # # fi
# 
# # #
# # # KakaoTalk
# # #
# # # if [ ! -d "$USER_HOME/.local/share/applications/wine/Programs/카카오톡" ]; then
# # #   if [ ! -e ~/Downloads/KakaoTalk_Setup.exe ]; then
# # #     echo "🚀 Install KakaoTalk ($0:$LINENO)"
# # #     curl -L http://app.pc.kakao.com/talk/win32/KakaoTalk_Setup.exe -o ~/Downloads/KakaoTalk_Setup.exe
# # #   fi
# # # else
# # #   echo 'Skip install KakaoTalk'
# # # fi
# 
# # #
# # # EC2 Instance Connect CLI
# # # Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-install
# # #
# # # if ! python -m pip list | grep ec2instanceconnectcli >/dev/null; then
# # #   echo "🚀 Install EC2 Instance Connect CLI ($0:$LINENO)"
# # #   python -m pip install ec2instanceconnectcli
# # # else
# # #   echo 'Skip install instance connect CLI'
# # # fi
# 
# # #
# # # Snap
# # #
# # # if ! command -v snap >/dev/null; then
# # #   echo "🚀 Install Snap ($0:$LINENO)"
# # #   sudo dnf install -y snapd
# # #   sudo ln -s /var/lib/snapd/snap /snap
# # #   while ! snap --version >/dev/null; do
# # #     sleep 1
# # #   done
# # # else
# # #   echo 'Skip install Snap'
# # # fi
# 
# # #
# # # Authy
# # #
# # # if ! snap list | grep authy >/dev/null; then
# # #   echo "🚀 Install Authy ($0:$LINENO)"
# # #   sudo snap install authy
# # # else
# # #   echo 'Skip install Authy'
# # # fi
# 
# # #
# # # Terraform
# # #
# # # if ! command -v terraform >/dev/null; then
# # #   echo "🚀 Install Terraform ($0:$LINENO)"
# # #   TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
# # #   curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \\
# # #     -Lo "$HOME/Downloads/terraform_linux_amd64.zip"
# # #   unzip "$HOME/Downloads/terraform_linux_amd64.zip" -d ~/Downloads
# # #   sudo mv ~/Downloads/terraform /usr/local/bin/terraform
# # #   rm "$HOME/Downloads/terraform_linux_amd64.zip"
# # #   terraform -install-autocomplete
# # # else
# # #   echo 'Skip install Terraform'
# # # fi
# 
# # #
# # # Nomad
# # #
# # # NOMAD_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r .current_version)
# # # curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \\
# # #   -Lo "$HOME/Downloads/nomad_linux_amd64.zip"
# # # unzip "$HOME/Downloads/nomad_linux_amd64.zip" -d ~/Downloads
# # # sudo mv ~/Downloads/nomad /usr/local/bin/nomad
# # # rm "$HOME/Downloads/nomad_linux_amd64.zip"
# # # nomad -autocomplete-install
# # # complete -C /usr/local/bin/nomad nomad
# 
# # #
# # # Consul
# # #
# # # CONSUL_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r .current_version)
# # # curl "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \\
# # #   -Lo "$HOME/Downloads/consul_linux_amd64.zip"
# # # unzip "$HOME/Downloads/consul_linux_amd64.zip" -d ~/Downloads
# # # sudo mv ~/Downloads/consul /usr/local/bin/consul
# # # rm "$HOME/Downloads/consul_linux_amd64.zip"
# # # consul -autocomplete-install
# # # complete -C /usr/bin/consul consul
# 
# # #
# # # Steam
# # #
# # # if ! command -v steam >/dev/null; then
# # #   echo "🚀 Install Steam ($0:$LINENO)"
# # #   case $LINUX_NODENAME in
# # #     "fedora")
# # #       sudo dnf install -y \\
# # #         https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
# # #       sudo dnf install -y steam
# # #       ;;
# # #     "debian" | 'ubuntu')
# # #       sudo apt install -y libgl1-mesa-dri:i386 libgl1:i386 steam
# # #       ;;
# # #   esac
# # # else
# # #   echo 'Skip install Steam'
# # # fi
# # # curl "https://steamcdn-a.akamaihd.net/client/installer/steam.deb" -Lo ~/Downloads/steam.deb
# # # sudo apt install ~/Downloads/steam.deb
# # # rm ~/Downloads/steam.deb
# # # rm ~/Desktop/steam.desktop || True
# 
# # #
# # # Discord
# # #
# # # sudo dnf install -y discord
# 
# # #
# # # mwcli
# # #
# # # if [ ! -x ~/go/src/gitlab.wikimedia.org/repos/releng/cli/bin/mw ]; then
# # #   echo "🚀 Install mwcli ($0:$LINENO)"
# # #   mkdir -p ~/go/src/gitlab.wikimedia.org/repos/releng
# # #   cd ~/go/src/gitlab.wikimedia.org/repos/releng/
# # #   if [ ! -d cli ]; then
# # #     git clone https://gitlab.wikimedia.org/repos/releng/cli.git
# # #   fi
# # #   cd cli
# # #   go install github.com/bwplotka/bingo@latest
# # #   asdf reshim golang
# # #   bingo get
# # #   make build
# # #   echo "alias mwdev='~/go/src/gitlab.wikimedia.org/repos/releng/cli/bin/mw'" >>~/.bashrc
# # # else
# # #   echo 'Skip install mwdev'
# # # fi
# 
# # #
# # # Caddy
# # #
# # # XCADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/xcaddy/releases/latest | jq -r .tag_name | cut -dv -f2)
# # # curl -L https://github.com/caddyserver/xcaddy/releases/download/v${XCADDY_VERSION}/xcaddy_${XCADDY_VERSION}_linux_amd64.deb \\
# # #   -o ~/Downloads/xcaddy_linux_amd64.deb
# # # sudo dpkg -i ~/Downloads/xcaddy_linux_amd64.deb
# # # rm ~/Downloads/xcaddy_linux_amd64.deb
# 
# # # update-desktop-database ~/.local/share/applications
# 
# # #
# # # Standard Notes
# # #
# 
# # # STANDARD_NOTES_VERSION=$(curl -s https://api.github.com/repos/standardnotes/app/releases/latest | jq -r .tag_name | cut -d@ -f3)
# # # sudo curl -L https://github.com/standardnotes/app/releases/download/%40standardnotes%2Fdesktop%40${STANDARD_NOTES_VERSION}/standard-notes-${STANDARD_NOTES_VERSION}-linux-x86_64.AppImage \\
# # #   -o ~/.local/bin/standard-notes.AppImage
# # # sudo chmod +x ~/.local/bin/standard-notes.AppImage
# 
# # # curl -L https://github.com/standardnotes/app/raw/main/packages/web/src/favicon/android-chrome-512x512.png -o ~/.icons/standard-notes.png
# # # touch ~/.local/share/applications/standard-notes.desktop
# # # desktop-file-edit \\
# # #   --set-name=Standard\ Notes \\
# # #   --set-key=Type --set-value=Application \\
# # #   --set-key=Terminal --set-value=false \\
# # #   --set-key=Exec --set-value=$HOME/.local/bin/standard-notes.AppImage \\
# # #   --set-key=Icon --set-value=standard-notes \\
# # #   ~/.local/share/applications/standard-notes.desktop
# 
# # # sudo desktop-file-install ~/.local/share/applications/standard-notes.desktop
# 
# # #
# # # Android studio
# # #
# # # https://developer.android.com/studio/install#64bit-libs
# # # sudo apt install -y
# # #   libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
# # # curl https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.0.16/android-studio-ide-193.6514223-linux.tar.gz -Lo ~/Downloads/android-studio-ide.tar.xz
# # # sudo tar -xzf ~/Downloads/android-studio-ide.tar.xz -C /usr/local
# # # rm ~/Downloads/android-studio-ide.tar.xz
# 
# # #
# # # Slack
# # #
# # # SLACK_URL=$(curl -sL https://slack.com/downloads/instructions/fedora | grep -oE 'https://downloads.slack-edge.com/releases/linux/.+/prod/x64/slack-.+\.x86_64\.rpm')
# # # sudo dnf install -y "$SLACK_URL"
# 
# # #
# # # GIMP
# # #
# # # sudo flatpak install -y https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref
# 
# # ################################################################################
# # # Removed
# # ################################################################################
# 
# # # #
# # # # Blender
# # # #
# # # curl https://www.blender.org/download/Blender2.82/blender-2.82a-linux64.tar.xz/ -Lo ~/Downloads/blender.tar.xz
# # # sudo tar -xvf blender.tar.xz -C /usr/local/blender
# # # rm ~/Downloads/blender.tar.xz
# # # mkdir -p ~/github
# # # git clone https://github.com/sugiany/blender_mmd_tools.git ~/github/
# # # cd ~/github/blender_mmd_tools && git checkout v0.4.5
# # # mkdir ~/.config/blender/2.82/scripts/addons
# # # ln -s ~/github/blender_mmd_tools/mmd_tools ~/.config/blender/2.82/scripts/addons/mmd_tools
# # ## TODO make a .desktop file
# 
# # # #
# # # # K3S
# # # #
# # # cat << EOF > ~/k3s-install
# # # #!/bin/bash
# # # curl -sfL https://get.k3s.io | sh -
# # # sudo chown -R $USER /etc/rancher/k3s
# # # EOF
# # # chmod +x k3s-install
# # # sudo mv ~/k3s-install /usr/local/bin/
# 
# # echo "🎉 Done installing"
