import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class HeartRateService {
  private static instance: HeartRateService;
  private isSubscribed: boolean = false;
  private callbacks: Set<(data: sensor.HeartRateResponse) => void> = new Set();

  private constructor() {
  }

  public static getInstance(): HeartRateService {
    if (!HeartRateService.instance) {
      HeartRateService.instance = new HeartRateService();
    }
    return HeartRateService.instance;
  }

  public subscribeToHeartRate(
    callback: (data: sensor.HeartRateResponse) => void,
    interval: number = 200000000
  ): void {
    try {
      this.callbacks.add(callback);

      if (!this.isSubscribed) {
        sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
          this.notifyAllCallbacks(data);
        }, { interval });

        this.isSubscribed = true;
        console.info('Successfully subscribed to heart rate sensor');
      }
    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`Failed to subscribe to heart rate. Code: ${e.code}, message: ${e.message}`);
    }
  }

  public unsubscribeFromHeartRate(callback?: (data: sensor.HeartRateResponse) => void): void {
    try {
      if (callback) {
        this.callbacks.delete(callback);
        // If no more callbacks, unsubscribe from sensor
        if (this.callbacks.size === 0 && this.isSubscribed) {
          sensor.off(sensor.SensorId.HEART_RATE);
          this.isSubscribed = false;
          console.info('Unsubscribed from heart rate sensor (no more callbacks)');
        }
      } else {
        this.callbacks.clear();
        if (this.isSubscribed) {
          sensor.off(sensor.SensorId.HEART_RATE);
          this.isSubscribed = false;
          console.info('Unsubscribed from heart rate sensor (all callbacks removed)');
        }
      }
    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`Failed to unsubscribe from heart rate. Code: ${e.code}, message: ${e.message}`);
    }
  }

  public isSubscribedToHeartRate(): boolean {
    return this.isSubscribed;
  }

  public getCallbackCount(): number {
    return this.callbacks.size;
  }

  private notifyAllCallbacks(data: sensor.HeartRateResponse): void {
    this.callbacks.forEach(callback => {
      try {
        callback(data);
      } catch (error) {
        console.error('Error in heart rate callback:', error);
      }
    });
  }

  public cleanup(): void {
    this.unsubscribeFromHeartRate();
    this.callbacks.clear();
  }
}

export const heartRateService = HeartRateService.getInstance();