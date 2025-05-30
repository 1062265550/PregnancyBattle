using System;

namespace PregnancyBattle.Domain.Services
{
    public static class PregnancyCalculator
    {
        /// <summary>
        /// Calculates pregnancy progress based on LMP (Last Menstrual Period) or Due Date.
        /// Prioritizes DueDate if both are provided and valid.
        /// </summary>
        /// <param name="lmpDate">Last Menstrual Period date.</param>
        /// <param name="dueDate">Estimated Due Date.</param>
        /// <param name="currentDate">The date for which to calculate progress (usually DateTime.UtcNow).</param>
        /// <returns>A tuple containing (currentWeek, currentDayInWeek, remainingDaysToDueDate).</returns>
        public static (int CurrentWeek, int CurrentDayInWeek, int RemainingDaysToDueDate) CalculatePregnancyProgress(
            DateTime? lmpDate, 
            DateTime? dueDate, 
            DateTime currentDate)
        {
            const int totalPregnancyDays = 280; // 40 weeks

            if (dueDate.HasValue && dueDate.Value > DateTime.MinValue)
            {
                if (currentDate > dueDate.Value)
                {
                    // Past due date
                    return (40, 0, 0); // Or some other indicator for past due
                }

                TimeSpan timeUntilDueDate = dueDate.Value - currentDate;
                int remainingDays = (int)timeUntilDueDate.TotalDays;
                if (remainingDays < 0) remainingDays = 0;

                int daysPregnant = totalPregnancyDays - remainingDays;
                if (daysPregnant < 0) daysPregnant = 0; // Should not happen if currentDate <= dueDate

                int currentWeek = daysPregnant / 7;
                int currentDayInWeek = daysPregnant % 7;
                
                // Ensure week is at least 1 if pregnant for a few days but less than a full week
                if (daysPregnant > 0 && currentWeek == 0) currentWeek = 1;
                // if day is 0 and week is > 0, it means it's the last day of the previous week from a 0-indexed perspective
                // User usually sees 1st day of week X, not 0th day.
                // If daysPregnant is a multiple of 7, it's the end of a week.
                // E.g., 7 days = end of week 1 (or start of week 2, day 0). We'll show week 1, day 7 (or week 2, day 0)
                // Let's make day 1-7 for user display
                if (currentDayInWeek == 0 && daysPregnant > 0) 
                {
                    currentDayInWeek = 7;
                    currentWeek = Math.Max(1, currentWeek -1); // if it was week 1 day 0 -> week 0 day 7, make it week 1 day 7
                                                          // if it was week N day 0 (N>1) -> week N-1 day 7.
                }
                 if (currentWeek == 0 && daysPregnant > 0) currentWeek =1; // if 0 days preg, week 0 day 0, if 1 day preg, week 1 day 1


                return (currentWeek, currentDayInWeek, remainingDays);
            }
            else if (lmpDate.HasValue && lmpDate.Value > DateTime.MinValue)
            {
                if (currentDate < lmpDate.Value)
                {
                    return (0, 0, totalPregnancyDays); // Not yet started
                }

                TimeSpan timeSinceLmp = currentDate - lmpDate.Value;
                int daysPregnant = (int)timeSinceLmp.TotalDays;
                if (daysPregnant < 0) daysPregnant = 0;

                int currentWeek = daysPregnant / 7;
                int currentDayInWeek = daysPregnant % 7;

                DateTime calculatedDueDate = lmpDate.Value.AddDays(totalPregnancyDays);
                TimeSpan timeUntilCalculatedDueDate = calculatedDueDate - currentDate;
                int remainingDays = (int)timeUntilCalculatedDueDate.TotalDays;
                if (remainingDays < 0) remainingDays = 0;

                if (currentDayInWeek == 0 && daysPregnant > 0)
                {
                    currentDayInWeek = 7;
                    currentWeek = Math.Max(1, currentWeek -1);
                }
                if (currentWeek == 0 && daysPregnant > 0) currentWeek =1;

                return (currentWeek, currentDayInWeek, remainingDays);
            }

            // Not enough information
            return (0, 0, totalPregnancyDays);
        }
    }
} 