#!/bin/bash
#==================================================================================
# git-commiter-changer.sh
#==================================================================================
# Gitのauthor/commiterを変更するツールです。
# 既にpushしてしまった歴史を改竄します。
# 破壊的変更を行う為、利用には注意が必要。
#==================================================================================
set -eu

# スクリプト終了時にカレントディレクトリに戻る
CURRENT_DIR="$(pwd)"
trap "cd ${CURRENT_DIR}" 1 2 3 15

TARGET_GIT_DIRECTORY="$(pwd)"
OLD_GIT_NAME=""
OLD_GIT_EMAIL=""
NEW_GIT_NAME=""
NEW_GIT_EMAIL=""

# 対象ディレクトリの存在チェック
function check_directory(){
    if [ ! -d "${TARGET_GIT_DIRECTORY}" ]; then
        echo -e "\e[0;31m[ERROR] ${TARGET_GIT_DIRECTORY} is not directory.\e[m"
        return 1
    fi
    return 0
}

# gitディレクトリであるかを確認
function check_git_directory(){
    local GIT_DIRECTORY="${TARGET_GIT_DIRECTORY%/}/.git"
    if [ ! -e ".git" ]; then
        echo -e "\e[0;31m[ERROR] ${GIT_DIRECTORY} is not git directory.\e[m"
        return 1
    fi
    return 0
}

# めいん関数
function main(){
    check_directory || exit 1
    check_git_directory || exit 1

    # 引数の指定が無い場合は対話式で入力
    if [ "${OLD_GIT_NAME}" = "" ]; then
        echo -ne "Please input old git name  > " 1>&2
        read OLD_GIT_NAME
    fi
    # 空文字列はNG
    if [ "${OLD_GIT_NAME}" = "" ]; then
        echo -e "\e[0;31m[ERROR] old git name is required.\e[m"
        exit 1
    fi

    # 引数の指定が無い場合は対話式で入力
    if [ "${OLD_GIT_EMAIL}" = "" ]; then
        echo -ne "Please input new git email > " 1>&2
        read OLD_GIT_EMAIL
    fi
    # 空文字列はNG
    if [ "${OLD_GIT_EMAIL}" = "" ]; then
        echo -e "\e[0;31m[ERROR] new git email is required.\e[m"
        exit 1
    fi

    # 引数の指定が無い場合は対話式で入力
    if [ "${NEW_GIT_NAME}" = "" ]; then
        echo -ne "Please input new git name  > " 1>&2
        read NEW_GIT_NAME
    fi
    # 空文字列はNG
    if [ "${NEW_GIT_NAME}" = "" ]; then
        echo -e "\e[0;31m[ERROR] new git name is required.\e[m"
        exit 1
    fi

    # 引数の指定が無い場合は対話式で入力
    if [ "${NEW_GIT_EMAIL}" = "" ]; then
        echo -ne "Please input new git email > " 1>&2
        read NEW_GIT_EMAIL
    fi
    # 空文字列はNG
    if [ "${NEW_GIT_EMAIL}" = "" ]; then
        echo -e "\e[0;31m[ERROR] new git email is required.\e[m"
        exit 1
    fi

    # ユーザー確認
    echo -e "-------------------------------------------------------------"
    echo -e "Target directory : ${TARGET_GIT_DIRECTORY}"
    echo -e "Old git name     : ${OLD_GIT_NAME}"
    echo -e "Old git email    : ${OLD_GIT_EMAIL}"
    echo -e "New git name     : ${NEW_GIT_NAME}"
    echo -e "New git email    : ${NEW_GIT_EMAIL}"
    echo -e "-------------------------------------------------------------"
    echo -ne "Is it ok? [y/n] > "
    local IS_IT_OK=""
    read IS_IT_OK
    if [ "${IS_IT_OK}" != "y" ]; then
        echo "Cancel processing."
        exit 0
    fi
    echo ""

    # dispatch
    cd "${TARGET_GIT_DIRECTORY}"
    local ENV_FILTER_SCRIPT="
        if [ "\${GIT_AUTHOR_NAME}" = '"${OLD_GIT_NAME}"' ]; then
            GIT_AUTHOR_NAME='"${NEW_GIT_NAME}"'
        fi
        if [ "\${GIT_COMMITTER_NAME}" = '"${OLD_GIT_NAME}"' ]; then
            GIT_COMMITTER_NAME='"${NEW_GIT_NAME}"'
        fi
        if [ "\${GIT_AUTHOR_EMAIL}" = '"${OLD_GIT_EMAIL}"' ]; then
            GIT_AUTHOR_EMAIL='"${NEW_GIT_EMAIL}"'
        fi
        if [ "\${GIT_COMMITTER_EMAIL}" = '"${OLD_GIT_EMAIL}"' ]; then
            GIT_COMMITTER_EMAIL='"${NEW_GIT_EMAIL}"'
        fi
    "

    git filter-branch --force --env-filter "${ENV_FILTER_SCRIPT}" --tag-name-filter cat -- --all

    echo ""
    echo "Please check git log and push remote repository."
    echo "  git push --force"
    echo "  git push --tags --force"
}

function usage(){
    echo -e "-------------------------------------------------------------"
    echo -e "${0#./}"
    echo -e "-------------------------------------------------------------"
    echo -e "# Usage"
    echo -e "  ${0#./} <target_dir> [-h|--help|--usage]"
    echo -e "    [--old-name <old_name>] [--old-email <old_email>]"
    echo -e "    [--name <name>] [--email <email>]"
    echo -e ""
    echo -e "# Parameters"
    echo -e "  <target_dir>"
    echo -e "    Target git directory path."
    echo -e ""
    echo -e "# Options"
    echo -e "  -h, --help, --usage"
    echo -e "    Show this usage."
    echo -e ""
    echo -e "  --old-name <old_name>"
    echo -e "    Specify replace target old author/commiter name."
    echo -e ""
    echo -e "  --old-email <old_email>"
    echo -e "    Specify replace target old author/commiter email."
    echo -e ""
    echo -e "  --name <name>"
    echo -e "    Specify new author/commiter name."
    echo -e ""
    echo -e "  --email <email>"
    echo -e "    Specify new author/commiter email."
    echo -e "-------------------------------------------------------------"
    echo -e ""
}

while [ ${#} -ge 1 ]; do
    case "${1}" in
        "-h" | "--help" | "--usage" )
            usage
            exit 0
            ;;
        "--old-name" )
            OLD_GIT_NAME="${2}"
            shift 1
            ;;
        "--old-email" )
            OLD_GIT_EMAIL="${2}"
            shift 1
            ;;
        "--name" )
            NEW_GIT_NAME="${2}"
            shift 1
            ;;
        "--email" )
            NEW_GIT_EMAIL="${2}"
            shift 1
            ;;
        * )
            TARGET_GIT_DIRECTORY="${1}"
            ;;
    esac
    shift 1
done

main
exit 0
