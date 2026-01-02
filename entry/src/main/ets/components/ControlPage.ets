import { NavigationService } from '../service/NavigationService';
import BatteryVM from '../viewmodel/BatteryVM';
import { HeartRateVM } from '../viewmodel/HeartRateVM';
import SpeedVM from '../viewmodel/SpeedVM';
import TimerVM from '../viewmodel/TimerVM';
import { ArcSwiper } from '@kit.ArkUI';

@Component
export struct ControlPage {
  @State speedVM: SpeedVM = new SpeedVM();
  @State batteryVM: BatteryVM = new BatteryVM();
  @State timerVM: TimerVM = new TimerVM();
  @State heartFontSize: number = 64;
  @State heartRateVM: HeartRateVM = new HeartRateVM();
  navigationService: NavigationService = NavigationService.getInstance();
  @State isPaused: boolean = true;

  aboutToAppear(): void {
    this.speedVM.start(this.getUIContext()).then(() => {
      this.batteryVM.start();
      this.timerVM.start();
      this.heartRateVM.subscribeToSensors();
    });
  }

  aboutToDisappear(): void {
    this.speedVM.stop();
    this.batteryVM.stop();
    this.timerVM.stop();
  }

  build() {
    ArcSwiper() {
      Column() {
        Row() {
          TextClock().format('HH:mm');

          Row() {
            SymbolGlyph(this.batteryVM.getIcon()).fontSize(24).fontColor([this.batteryVM.getColor()]);
            Text(this.batteryVM.level.toString()).margin({ left: 4 });
          }.margin({ left: 7 });
        }
        .justifyContent(FlexAlign.Center)
        .size({ height: '22%', width: '100%' });


        Column() {
          Row() {
            Gauge({
              max: this.speedVM.lastSpeed > this.speedVM.max ? this.speedVM.lastSpeed : this.speedVM.max,
              value: this.speedVM.lastSpeed,
              min: 0
            }) {
              Text(`${this.speedVM.lastSpeed.toFixed(1)} m/s`);
            }
            .startAngle(225)
            .endAngle(135)
            .strokeWidth(8)
            .width('50%')
            .colors(new LinearGradient([
              { color: Color.Green, offset: 0 },
              { color: Color.Yellow, offset: 0.5 },
              { color: Color.Red, offset: 1 }
            ]));

            Stack() {
              SymbolGlyph($r('sys.symbol.heart_fill'))
                .fontColor([Color.Red])
                .fontSize(this.heartFontSize)
                .animation({
                  duration: 1000,
                  curve: Curve.Linear,
                  iterations: -1,
                  playMode: PlayMode.Alternate
                })
                .onAppear(() => {
                  this.heartFontSize = 80;
                });
              Text(this.heartRateVM.heartRateData !== -1 ? `${this.heartRateVM.heartRateData}` : '0');
            }
            .size({ height: '100%', width: '50%' });
          }
          .size({ height: '52%', width: '100%' });

          Column() {
            Row() {
              Column() {
                Text('Avg (m/s)').width('100%');
                Text(`${this.speedVM.avgSpeed.toFixed(1)} `).width('100%');
              }
              .size({ height: '100%', width: '50%' })
              .justifyContent(FlexAlign.Center);

              Column() {
                Text('Total (m)').width('100%');
                Text(`${this.speedVM.totalDistance.toFixed(1)}`).width('100%');
              }
              .size({ height: '100%', width: '50%' })
              .justifyContent(FlexAlign.Center);
            }
            .alignItems(VerticalAlign.Center)
            .size({ height: '67%', width: '100%' });

            Column() {
              Text(this.timerVM.formattedTime).fontSize(16);
            }
            .justifyContent(FlexAlign.Center)
            .size({ height: '33%', width: '100%' });
          }
          .size({ height: '48%', width: '100%' });

        }
        .size({ height: '70%', width: '70%' });
      }
      .alignItems(HorizontalAlign.Center)
      .size({ height: '100%', width: '100%' });

      Row() {
        Column() {
          Image($r('app.media.cross'))
            .height(80)
            .width(80)
            .backgroundColor('#34db4c24')
            .padding(20)
            .borderRadius(20)
            .borderWidth(0.5)
            .borderColor('#ffdb4c24')
            .onClick(() => {
              this.heartRateVM.unsubscribeFromSensors();
              this.navigationService.pageInfos.pop();
            });
          Text('Finish')
            .margin({ top: 3 });
        };

        Column() {
          Image(this.isPaused ? $r('app.media.pause') : $r('app.media.forward'))
            .height(80)
            .width(80)
            .backgroundColor('#3e5b2dca')
            .padding(20)
            .borderRadius(20)
            .borderWidth(0.5)
            .borderColor('#ff5b2dca')
            .onClick(() => {
              if (this.isPaused) {
                this.speedVM.pause();
                this.batteryVM.stop();
                this.timerVM.pause();
                this.heartRateVM.unsubscribeFromSensors();
              } else {
                this.speedVM.continue();
                this.batteryVM.start();
                this.timerVM.start();
                this.heartRateVM.subscribeToSensors();
              }
              this.isPaused = !this.isPaused;
            });
          Text(this.isPaused ? 'Pause' : 'Continue')
            .margin({ top: 3 });
        };
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly);
    };
  }
}