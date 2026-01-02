import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { map } from '@kit.MapKit';
import { UIContext } from '@kit.ArkUI';

export default class SpeedVM {
  lastSpeed: number = 0;
  avgSpeed: number = 0;
  totalDistance: number = 0;
  max: number = 10;
  private totalTime: number = 0;
  private lastLocation?: geoLocationManager.Location;
  private hasPermission: boolean = false;
  private locationRequest: geoLocationManager.ContinuousLocationRequest = {
    interval: 0,
    locationScenario: geoLocationManager.UserActivityScenario.SPORT
  };
  private context?: UIContext;

  async start(context: UIContext) {
    this.context = context;

    this.hasPermission =
      this.checkLocationService() && await this.getPermission(context.getHostContext() as common.UIAbilityContext);

    if (this.hasPermission) {
      try {
        geoLocationManager.on('locationChange', this.locationRequest, (loc) => {
          this.calculate(loc);
        });
        console.info('locationChange started');
      } catch (e) {
        console.error(`location service error: ${e} | ${JSON.stringify(e)}`);
      }

    } else {
      context.getPromptAction().showToast({
        message: 'For a better experience, activate location service and grant permission.',
        duration: 2000
      });
    }
  }

  stop() {
    geoLocationManager.off('locationChange');
  }

  pause() {
    this.lastSpeed = 0;
    this.lastLocation = undefined;
    geoLocationManager.off('locationChange');
  }

  continue() {
    this.start(this.context!);
  }

  private calculate(location: geoLocationManager.Location) {
    if (this.lastLocation) {
      const time = (location.timeStamp - this.lastLocation.timeStamp) / 1000;

      console.info(`new location: ${JSON.stringify(location)}`);

      const distance = map.calculateDistance(this.lastLocation, location);
      const avgMiss = (this.lastLocation.accuracy + location.accuracy) / 2;
      console.info(`distance: ${distance.toFixed(2)}`);
      console.info(`avgMiss: ${avgMiss.toFixed(2)}`);

      if (distance > avgMiss) {
        this.totalDistance += distance;

        this.totalTime += time;

        this.lastSpeed = distance / time; // m/s
        this.avgSpeed = this.totalDistance / this.totalTime;

        console.info(`last speed: ${this.lastSpeed} | avg speed: ${this.avgSpeed}`);

        this.lastLocation = location;
      }
    } else {
      this.lastLocation = location;
    }
  }

  private checkLocationService() {
    return geoLocationManager.isLocationEnabled();
  }

  private async getPermission(context: common.UIAbilityContext) {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const permissions: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

    try {
      // request permission from user
      let granted =
        (await atManager.requestPermissionsFromUser(context, permissions)).authResults.every((res) => res === 0);

      if (!granted) {
        // request permission on settings
        granted = (await atManager.requestPermissionOnSetting(context, permissions))
          .every((res) => res === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
      }

      return granted;
    } catch (error) {
      console.error(`Failed to get bluetooth permission. Error: ${error} | ${JSON.stringify(error)}`);

      return false;
    }
  }
};