#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  exit 0
fi

# Thanks @djacobs https://gist.github.com/djacobs/2411095
# Thanks @johanneswuerbach https://gist.github.com/johanneswuerbach/5559514

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

echo "***************************"
echo "*        Signing          *"
echo "***************************"
xcrun -log -v -sdk iphoneos9.2 PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

echo "$OUTPUTDIR/$APP_NAME.app.dSYM.zip"
ls -al "$OUTPUTDIR/$APP_NAME.app.dSYM.zip"
echo "$OUTPUTDIR/$APP_NAME.app"
ls -al "$OUTPUTDIR/$APP_NAME.app"

zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app"

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

export SSHPASS="$DEPLOY_PASS"
sshpass -e -o sftp "$DEPLOY_USER"@"$DEPLOY_HOST":"$DEPLOY_PATH" <<< $'put "$OUTPUTDIR/$APP_NAME.app.dSYM.zip"'