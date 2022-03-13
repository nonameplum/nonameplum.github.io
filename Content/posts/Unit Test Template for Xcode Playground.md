---
date: 2021-09-05 11:56
description: Unit Test Template for Xcode Playground
tags: Xcode
tagColors: Xcode=006b75
---
# How to add custom template useful for the Unit Test directly in the Xcode Playgroud

Custom template that allows to write unit tests directly in the Xcode Playgroud with nice error/success messages:
![Screenshot 2021-09-05 at 14 11 30](https://user-images.githubusercontent.com/1753816/132126336-c6ac9414-e57d-4394-a3cb-65d0fac46d79.png)
![Screenshot 2021-09-05 at 14 14 28](https://user-images.githubusercontent.com/1753816/132126405-a568738a-75dd-4e79-9d65-5e8ef0092baf.png)

## Installation
### Manual

Download and unzip
[Unit Test.xctemplate.zip](https://github.com/nonameplum/blog/files/7111526/Unit.Test.xctemplate.zip)
Copy `Unit Test.xctemplate` directory to `~/Library/Developer/Xcode/Templates/File Templates/Playground/` (create the folder if doesn't exits yet)

### Bash script

```bash
mkdir ./Unit_Test.xctemplate
curl --show-error --location https://github.com/nonameplum/blog/files/7111526/Unit.Test.xctemplate.zip | tar -xf - -C ./Unit_Test.xctemplate
cd ./Unit_Test.xctemplate
mkdir -p ~/Library/Developer/Xcode/Templates/File\ Templates/Playground
cp -R "./Unit Test.xctemplate" ~/Library/Developer/Xcode/Templates/File\ Templates/Playground
```

Once you restart Xcode you should be able to see the _Unit Test_ template for a new playgroud:
![Screenshot 2021-09-05 at 14 05 01](https://user-images.githubusercontent.com/1753816/132126129-744ff2e0-228d-4f24-b73d-8be984ad0abf.png)
