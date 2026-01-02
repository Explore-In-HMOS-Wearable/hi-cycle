import { batteryInfo } from '@kit.BasicServicesKit';

@Observed
export default class BatteryVM {
  level: number;
  private intervalId?: number;

  constructor() {
    this.level = batteryInfo.batterySOC;
  }

  getIcon() {
    if (this.level >= 95) {
      return $r('sys.symbol.battery_100percent');
    } else if (this.level >= 85) {
      return $r('sys.symbol.battery_90percent');
    } else if (this.level >= 75) {
      return $r('sys.symbol.battery_80percent');
    } else if (this.level >= 65) {
      return $r('sys.symbol.battery_70percent');
    } else if (this.level >= 55) {
      return $r('sys.symbol.battery_60percent');
    } else if (this.level >= 45) {
      return $r('sys.symbol.battery_50percent');
    } else if (this.level >= 35) {
      return $r('sys.symbol.battery_40percent');
    } else if (this.level >= 25) {
      return $r('sys.symbol.battery_30percent');
    } else if (this.level >= 15) {
      return $r('sys.symbol.battery_20percent');
    } else if (this.level >= 5) {
      return $r('sys.symbol.battery_10percent');
    } else {
      return $r('sys.symbol.battery');
    }
  }

  getColor() {
    if (this.level >= 70) {
      return Color.Green;
    } else if (this.level >= 30) {
      return Color.Yellow;
    } else {
      return Color.Red;
    }
  }

  start() {
    this.intervalId = setInterval(() => {
      this.level = batteryInfo.batterySOC;
    }, 60000);
  }

  stop() {
    clearInterval(this.intervalId);
  }
}