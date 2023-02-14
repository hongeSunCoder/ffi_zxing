project="ffi_zxing"

zxing_version="2.0.0"

projectPath="../../$project"
zxingPath="$projectPath/cpp/zxing"
zxingSrcPath="$zxingPath/core/src"
iosZxingSrcPath="$projectPath/ios/Classes/src/zxing"

mkdir -p download
cd download

wget -O "zxing-cpp-$zxing_version.zip" "https://github.com/nu-book/zxing-cpp/archive/refs/tags/v$zxing_version.zip"
unzip "zxing-cpp-$zxing_version.zip"

rm -R "$zxingPath"
cp -R "zxing-cpp-$zxing_version/" "$zxingPath"



rm -rf $iosZxingSrcPath
mkdir -p $iosZxingSrcPath

rsync -av "$zxingSrcPath/" "$iosZxingSrcPath/"


echo "ZXing $zxing_version has been successfully installed"

rm -R ../download
