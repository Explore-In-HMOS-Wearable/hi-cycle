import { ControlPage } from '../components/ControlPage';
import { NavigationService } from '../service/NavigationService';

@Entry
@Component
struct Index {
  navigationService: NavigationService = NavigationService.getInstance();

  @Builder
  routeMap(name: string) {
    NavDestination() {
      if (name === 'ControlPage') {
        ControlPage();
      }
    }
    .onBackPressed(() => true)
    .hideTitleBar(true);
  }

  build() {
    Navigation(this.navigationService.pageInfos) {
      Column() {
        Image($r('app.media.cycling'))
          .width(50)
          .height(40)
          .objectFit(ImageFit.Contain);

        Text('HiCycle!')
          .fontSize(28)
          .fontColor('#ff752bff')
          .fontWeight(FontWeight.Bold);

        Text('GO')
          .height(80)
          .width(80)
          .backgroundColor('#3242880d')
          .borderRadius(80)
          .borderWidth(0.5)
          .borderColor('#ff42880d')
          .fontSize(26)
          .fontColor(Color.Green)
          .onClick(() => {
            this.navigationService.pageInfos.pushPath({ name: 'ControlPage' });
          })
          .margin({ top: 15 });

      }.width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center);
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.routeMap)
    .ignoreLayoutSafeArea()
    .hideTitleBar(true)
    .width('100%')
    .height('100%');
  }
}