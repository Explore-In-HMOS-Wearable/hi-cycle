import { heartRateService } from '../service/HeartRateService';
import { sensor } from '@kit.SensorServiceKit';

@Observed
export class HeartRateVM {
  @Track
  heartRateData: number = -1

  async subscribeToSensors(): Promise<void> {
    heartRateService.subscribeToHeartRate(
      (data: sensor.HeartRateResponse) => this.handleHeartRateData(data),
      200000000
    );
  }

  unsubscribeFromSensors(): void {
    heartRateService.unsubscribeFromHeartRate();
  }

  private handleHeartRateData(data: sensor.HeartRateResponse): void {
    if (data.heartRate === 255) {
      this.heartRateData = 0
    } else {
      this.heartRateData = data.heartRate
    }

  }

  getHeartRate(): number {
    return this.heartRateData;
  }
}
