---
date: 2021-02-11 13:49
description: Plum's Xcode themes
tags: Xcode
tagColors: Xcode=006b75
---
# Xcode theme (light & dark)

## Installation
### Manual

Download and unzip
[Plum_Xcode_Themes.zip](https://github.com/nonameplum/blog/files/5965669/Plum_Xcode_Themes.zip)
Copy `*.xccolortheme` files to `~/Library/Developer/Xcode/UserData/FontAndColorThemes/` (create the folder if doesn't exits yet)

### Bash script

```bash
mkdir ./Plum_Xcode_Themes
curl --show-error --location https://github.com/nonameplum/blog/files/5965669/Plum_Xcode_Themes.zip | tar -xf - -C ./Plum_Xcode_Themes
cd ./Plum_Xcode_Themes
mkdir ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
cp ./*.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
```

## Light
![Screenshot 2021-02-11 at 14 44 27](https://user-images.githubusercontent.com/1753816/107644512-cf508200-6c77-11eb-8a93-4a8715c81bea.png)

## Dark
![Screenshot 2021-02-11 at 14 45 04](https://user-images.githubusercontent.com/1753816/107644503-ccee2800-6c77-11eb-88fd-bbeb417544f1.png)