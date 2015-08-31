#import "SnapshotHelper.js"

var target = UIATarget.localTarget();

target.delay(3);
captureLocalizedScreenshot("0-AllArtists");

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(3);
captureLocalizedScreenshot("1-GratefulDead");

target.frontMostApp().tabBar().buttons()["Top Shows"].tap();
target.delay(3);
captureLocalizedScreenshot("2-GratefulDeadTopShows");

target.frontMostApp().mainWindow().tableViews()[0].cells()["1977-05-08"].tap();
target.delay(3);
captureLocalizedScreenshot("3-GratefulDeadBartonHall");

target.frontMostApp().mainWindow().tableViews()[0].cells().firstWithPredicate("name contains 'Listen to this source'").tap();
target.delay(3);
captureLocalizedScreenshot("4-GratefulDeadFourth");
