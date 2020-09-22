# git-commiter-changer
## Overview
Gitのauthor/commiterを変更するツールです。  
既にpushしてしまった歴史を改竄します。  
破壊的変更を行う為、利用には注意が必要。

git repositoryのお引っ越しや名前/email変更時の補助ツールとして利用できます。

## Usage
```shell
# Usage
  git-commiter-changer.sh <target_dir> [-h|--help|--usage]
    [--old-name <old_name>] [--old-email <old_email>]
    [--name <name>] [--email <email>]

# Parameters
  <target_dir>
    Target git directory path.

# Options
  -h, --help, --usage
    Show this usage.

  --old-name <old_name>
    Specify replace target old author/commiter name.

  --old-email <old_email>
    Specify replace target old author/commiter email.

  --name <name>
    Specify new author/commiter name.

  --email <email>
    Specify new author/commiter email.
```

- オプションパラメーターを指定しない場合、必要なパラメーターを対話式で入力します。
- 全branchを対象に書き換えを実行します。
- tagの書き換えも行います。

このツールでは`author.name`, `author.email`, `committer.name`, `committer.email`の書き換えのみを実施します。  
書き換え内容をご自身の目で確認の上、pushしてください。

```shell
$ git push --force
$ git push --force --tags
```
