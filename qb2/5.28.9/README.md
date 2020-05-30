# Building resource file

First make sure your have also the tsc-images (https://github.com/ToonSoftwareCollective/tsc-images.git)  and tscSettings (https://github.com/ToonSoftwareCollective/tscSettings.git) repo cloned to your local machine.
Als make sure you have the QT5 resource compiler (https://doc.qt.io/qt-5/rcc.html) installed.

If you add new QML files, add them accordingly to the tsc.qrc file.

Then run this command in the current directory:
```
rcc --format-version 2 -binary -compress 9 -threshold 0 tsc.qrc -o /tmp/my-new-resource-file.rcc
```

You can then copy the new resource file to your Toon under /qmf/qml/resource-static-base.rcc (or make a symlink to your new file) and after a restart of qt-gui your modifications should be visible.
