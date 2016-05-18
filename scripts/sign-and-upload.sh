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

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"
RELEASE_FILE = "$OUTPUTDIR/$APP_NAME.app.RELEASE_DATE.dSYM.zip"

zip -r -9 "$RELEASE_FILE" "$OUTPUTDIR/$APP_NAME.app"

sftp -o stricthostkeychecking=no $DEPLOY_USER@$DEPLOY_HOST
expect "upworksio@72.47.236.47's password: "
send "$DEPLOY_PASS\r"
expect "sftp>"
send "cd $DEPLOY_PATH"
expect "sftp>"
send "put $RELEASE_FILE"
expect "sftp>"
send "bye\r"
EOD