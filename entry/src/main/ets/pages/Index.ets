import { SetupPage } from './SetupPage'
import { DashboardPage } from './DashboardPage'


PersistentStorage.persistProp('lastPeriodDate', 0);

PersistentStorage.persistProp('cycleLength', 28);


@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @StorageLink('lastPeriodDate') lastPeriodDate: number = 0;

  aboutToAppear() {
    if (this.lastPeriodDate > 0) {
      this.pageStack.pushPath({ name: 'Dashboard' }, false);
    } else {
      this.pageStack.pushPath({ name: 'Setup' }, false);
    }
  }

  @Builder
  PageMap(name: string) {
    if (name === 'Setup') {
      SetupPage()
    } else if (name === 'Dashboard') {
      DashboardPage()
    }
  }

  build() {
    Navigation(this.pageStack) {
    }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}