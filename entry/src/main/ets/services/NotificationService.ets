import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Want, wantAgent } from '@kit.AbilityKit';

export class NotificationService {
  static async scheduleCycleReminder(nextPeriodDate: number) {

    const oneDayMs = 24 * 60 * 60 * 1000;
    const reminderTime = nextPeriodDate - oneDayMs;
    const dateObj = new Date(reminderTime);

    const targetDateTime: reminderAgentManager.LocalDateTime = {
      year: dateObj.getFullYear(),
      month: dateObj.getMonth() + 1,
      day: dateObj.getDate(),
      hour: 9,
      minute: 0
    };

    const reminder: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      dateTime: targetDateTime,

      actionButton: [
        {
          title: 'Im ready',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        },
        {
          title: 'Postpone',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_SNOOZE
        }
      ],

      title: 'Loop Reminder',
      content: 'The cycle is expected to start tomorrow.',
      snoozeTimes: 1,
      timeInterval: 5 * 60,
      ringDuration: 10
    };

    try {
      const reminderId = await reminderAgentManager.publishReminder(reminder);
      console.info(`Reminder set! ID: ${reminderId}`);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Reminder not set: ${error.code} - ${error.message}`);
    }
  }


  static async sendDailyLogRequest() {
    const notificationRequest: notificationManager.NotificationRequest = {
      id: 1001,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: 'How do you feel today?',
          text: 'Entering data in the diary makes the calendar smarter.',
          additionalText: 'Log Symptom'
        }
      },
      actionButtons: [
        {
          title: 'I\'m fine ',
          wantAgent: await NotificationService.createWantAgent('ACTION_FEEL_GOOD')
        },
        {
          title: 'I Have Pain',
          wantAgent: await NotificationService.createWantAgent('ACTION_FEEL_PAIN')
        }
      ]
    };

    try {
      await notificationManager.publish(notificationRequest);
      console.info('Logging notification sent.');
    } catch (err) {
      console.error(`Notification failure: ${err}`);
    }
  }

  private static async createWantAgent(action: string): Promise<Object> {

    const want: Want = {
      bundleName: 'com.hmosdemos.wearable.womens_health',
      abilityName: 'EntryAbility',
      parameters: {
        'actionType': action
      }
    };

    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [want],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
    };

    return await wantAgent.getWantAgent(wantAgentInfo);
  }
}