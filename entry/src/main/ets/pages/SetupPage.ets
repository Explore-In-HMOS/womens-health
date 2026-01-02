@Component
export struct SetupPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private selectedDate: Date = new Date();
  private cycleLength: number = 28;

  build() {
    NavDestination() {
      Column() {
        Text('When?')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 10, top: 20 })

        DatePicker({
          start: new Date('2023-01-01'),
          end: new Date(),
          selected: this.selectedDate
        })
          .height(120)
          .textStyle({ color: Color.Gray, font: { size: '14fp' } })
          .selectedTextStyle({ color: '#FF595E', font: { size: '18fp', weight: FontWeight.Bold } })
          .onDateChange((value: Date) => {
            this.selectedDate = value;
          })

        Button('Save and Start')
          .type(ButtonType.Capsule)
          .backgroundColor('#FF595E')
          .width('80%')
          .margin({ top: 20 })
          .onClick(() => {
            AppStorage.setOrCreate('lastPeriodDate', this.selectedDate.getTime());
            AppStorage.setOrCreate('cycleLength', this.cycleLength);

            this.pageStack.replacePath({ name: 'Dashboard' });
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return true;
    })
  }
}