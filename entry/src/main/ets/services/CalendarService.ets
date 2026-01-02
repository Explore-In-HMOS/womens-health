import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
// 1. Change the import to the Class we created previously
import { GlobalContext } from '../entryability/EntryAbility';

const CALENDAR_NAME = 'WomensHealthCalendar';

export class CalendarService {
  static async getOrCreateCalendar(): Promise<calendarManager.Calendar | undefined> {
    // 2. Access the manager via the static class property
    if (!GlobalContext.calendarMgr) {
      console.error('Calendar Manager has not been started.');
      return undefined;
    }

    const calendarAccount: calendarManager.CalendarAccount = {
      name: CALENDAR_NAME,
      type: calendarManager.CalendarType.LOCAL,
      displayName: 'WomensHealth'
    };

    try {
      // 3. Update usage here
      const calendar = await GlobalContext.calendarMgr.createCalendar(calendarAccount);

      const config: calendarManager.CalendarConfig = {
        enableReminder: true,
        color: '#FF595E'
      };
      await calendar.setConfig(config);
      return calendar;

    } catch (error) {
      try {
        // 4. Update usage here
        return await GlobalContext.calendarMgr.getCalendar(calendarAccount);
      } catch (err) {
        const error = err as BusinessError;
        console.error(`Calendar Error: ${error.message}`);
        return undefined;
      }
    }
  }

  static async addPeriodEvent(startDate: number, cycleLength: number, periodDuration: number = 5) {
    const calendar = await CalendarService.getOrCreateCalendar();
    if (!calendar) {
      return;
    }

    const oneDay = 24 * 60 * 60 * 1000;
    const durationTime = periodDuration * oneDay;

    const event: calendarManager.Event = {
      title: 'Menstrual Period',
      type: calendarManager.EventType.NORMAL,
      startTime: startDate,
      endTime: startDate + durationTime,

      reminderTime: [1440], // Remind 1 day before

      recurrenceRule: {
        recurrenceFrequency: calendarManager.RecurrenceFrequency.DAILY,
        interval: cycleLength,
        count: 12 // Create events for the next year (approx)
      },

      service: {
        type: calendarManager.ServiceType.TRIP,
        uri: 'store://app',
        description: 'Loop Tracking App'
      }
    };

    try {
      const eventId = await calendar.addEvent(event);
      console.info(`Engraved in calendar! Event ID: ${eventId}`);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to add event: ${err.message}`);
    }
  }
}