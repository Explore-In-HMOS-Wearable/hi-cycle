export default class TimerVM {
  private intervalId?: number;
  private count: number = 0;
  formattedTime: string = '00:00:00';

  start() {
    this.intervalId = setInterval(() => {
      this.count++;

      this.formattedTime = this.formatTime();
    }, 1000);
  }

  stop() {
    clearInterval(this.intervalId);
    this.count = 0;
    this.formattedTime = '00:00:00';
  }

  pause() {
    clearInterval(this.intervalId);
  }

  private formatTime() {
    const seconds = this.count % 60;
    const minutes = (this.count - seconds) / 60;
    const hours = (this.count - minutes * 60 - seconds) / 3600;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString()
      .padStart(2, '0')}`;
  }
};