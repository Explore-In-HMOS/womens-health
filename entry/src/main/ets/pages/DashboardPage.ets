import { CalendarService } from '../services/CalendarService';

@Component
export struct DashboardPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageLink('lastPeriodDate') lastPeriodTimestamp: number = 0;
  @StorageLink('cycleLength') cycleLength: number = 28;
  @StorageLink('periodDuration') periodDuration: number = 5;
  @State currentDayOfCycle: number = 1;
  @State daysLeft: number = 0;
  private colorPeriod: string = '#FF595E';
  private colorFollicular: string = '#8AC926';

  aboutToAppear() {
    this.calculateCycleData();
  }

  calculateCycleData() {
    const today = new Date().getTime();
    const lastPeriod = this.lastPeriodTimestamp || today;

    const diffTime = Math.abs(today - lastPeriod);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    this.currentDayOfCycle = (diffDays % this.cycleLength) || 1;
    this.daysLeft = this.cycleLength - this.currentDayOfCycle;
  }

  async syncCalendar() {
    if (this.lastPeriodTimestamp > 0) {
      console.info('Starting calendar synchronization...');
      await CalendarService.addPeriodEvent(
        this.lastPeriodTimestamp,
        this.cycleLength,
        this.periodDuration
      );
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {

        Progress({ value: 100, total: 100, type: ProgressType.Ring })
          .width('90%')
          .height('90%')
          .color('#262626')
          .style({ strokeWidth: 15 })

        Progress({ value: this.currentDayOfCycle, total: this.cycleLength, type: ProgressType.Ring })
          .width('90%')
          .height('90%')
          .color(this.currentDayOfCycle <= this.periodDuration ? this.colorPeriod : this.colorFollicular)
          .style({ strokeWidth: 15 })

        Column() {
          Text('Cycle')
            .fontSize(14)
            .fontColor(Color.Gray)

          Text(`${this.currentDayOfCycle}. Day`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.daysLeft === 0 ? 'Today!' : `${this.daysLeft} days remaining`)
            .fontSize(16)
            .fontColor('#FFD700')
            .margin({ top: 5 })

          Button('Process To Calendar')
            .height(30)
            .fontSize(12)
            .backgroundColor('rgba(255,255,255,0.2)')
            .margin({ top: 10 })
            .onClick(() => {
              this.syncCalendar();

              console.info('Calendar updated!');
            })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
  }
}