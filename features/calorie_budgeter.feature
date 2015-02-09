Feature: Calculate Remaining Daily Calories

  So that I know how much more I should eat today in order to hit my weekly calorie goal,
  As a dieter,
  I want to see my remaining calories for the day, taking into account what I have already consumed this week

  Scenario Outline: Maintain Weight
    Given my RMR is <daily_rmr> calories per day
    And my weekly calorie goal is <weekly_goal> calories
    And I have consumed <prev_days_cal> net calories on prior days this week
    And it is the <day> day of the week
    And I have consumed <consumed> calories today
    And I have burned <burned> calories with exercise today

    When I calculate my remaining calories for the day

    Then I see that my net calorie consumption for the day is <net>
    And I see that I should consume <remaining> more calories today
    And I see that I should burn <to_burn> more calories by exercising today

    Examples: RMR 1500
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      1500 |       10500 |             0 | 1st |        0 |      0 |    0 |      1500 |       0 |
      |      1500 |       10500 |             0 | 1st |      500 |      0 |  500 |      1000 |       0 |
      |      1500 |       10500 |             0 | 1st |     1500 |      0 | 1500 |         0 |       0 |
      |      1500 |       10500 |             0 | 1st |     1501 |      0 | 1501 |         0 |       1 |

    Examples: RMR 1500 - with exercise
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      1500 |       10500 |             0 | 1st |        0 |    100 | -100 |      1600 |       0 |
      |      1500 |       10500 |             0 | 1st |      500 |    100 |  400 |      1100 |       0 |
      |      1500 |       10500 |             0 | 1st |     1600 |    100 | 1500 |         0 |       0 |
      |      1500 |       10500 |             0 | 1st |     1601 |    100 | 1501 |         0 |       1 |

    Examples: RMR 1500 - 2nd day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      1500 |       10500 |          1500 | 2nd |        0 |      0 |    0 |      1500 |       0 |
      |      1500 |       10500 |          1503 | 2nd |        0 |      0 |    0 |      1500 |       0 |
      |      1500 |       10500 |          1504 | 2nd |        0 |      0 |    0 |      1500 |       1 |
      |      1500 |       10500 |          1504 | 2nd |      500 |    100 |  400 |      1099 |       0 |
      |      1500 |       10500 |          1504 | 2nd |     1500 |      0 | 1500 |         0 |       1 |
      |      1500 |       10500 |          1504 | 2nd |     1600 |    100 | 1500 |         0 |       1 |

    Examples: RMR 2000
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |             0 | 1st |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |             0 | 1st |      500 |      0 |  500 |      1500 |       0 |
      |      2000 |       14000 |             0 | 1st |     2000 |      0 | 2000 |         0 |       0 |
      |      2000 |       14000 |             0 | 1st |     2001 |      0 | 2001 |         0 |       1 |

    Examples: RMR 2000 - with exercise
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |             0 | 1st |        0 |    100 | -100 |      2100 |       0 |
      |      2000 |       14000 |             0 | 1st |      500 |    100 |  400 |      1600 |       0 |
      |      2000 |       14000 |             0 | 1st |     2100 |    100 | 2000 |         0 |       0 |
      |      2000 |       14000 |             0 | 1st |     2101 |    100 | 2001 |         0 |       1 |

    Examples: RMR 2000 - 2nd day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |          1997 | 2nd |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |          1998 | 2nd |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          2000 | 2nd |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          2003 | 2nd |        0 |      0 |    0 |      2000 |       0 |
      # must consume at lease RMR every day and you should exercise off the overage
      |      2000 |       14000 |          2004 | 2nd |        0 |      0 |    0 |      2000 |       1 |
      |      2000 |       14000 |          2004 | 2nd |      500 |    100 |  400 |      1599 |       0 |
      |      2000 |       14000 |          2004 | 2nd |     2000 |      0 | 2000 |         0 |       1 |
      |      2000 |       14000 |          2004 | 2nd |     2100 |    100 | 2000 |         0 |       1 |

    Examples: 3rd day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |          3997 | 3rd |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |          3998 | 3rd |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          4000 | 3rd |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          4002 | 3rd |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          4003 | 3rd |        0 |      0 |    0 |      2000 |       1 |

    Examples: 4th day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |          5998 | 4th |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |          5999 | 4th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          6000 | 4th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          6002 | 4th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          6003 | 4th |        0 |      0 |    0 |      2000 |       1 |

    Examples: 5th day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |          7998 | 5th |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |          7999 | 5th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          8000 | 5th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          8001 | 5th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |          8002 | 5th |        0 |      0 |    0 |      2000 |       1 |

    Examples: 6th day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |          9997 | 6th |        0 |      0 |    0 |      2002 |       0 |
      |      2000 |       14000 |          9998 | 6th |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |          9999 | 6th |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |         10000 | 6th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |         10001 | 6th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |         10002 | 6th |        0 |      0 |    0 |      2000 |       1 |

    Examples: 7th day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       14000 |         11999 | 7th |        0 |      0 |    0 |      2001 |       0 |
      |      2000 |       14000 |         12000 | 7th |        0 |      0 |    0 |      2000 |       0 |
      |      2000 |       14000 |         12001 | 7th |        0 |      0 |    0 |      2000 |       1 |

  Scenario Outline: Lose Weight - must consume at least RMR daily
    Given my RMR is <daily_rmr> calories per day
    And my weekly calorie goal is <weekly_goal> calories
    And I have consumed <prev_days_cal> net calories on prior days this week
    And it is the <day> day of the week
    And I have consumed <consumed> calories today
    And I have burned <burned> calories with exercise today

    When I calculate my remaining calories for the day

    Then I see that my net calorie consumption for the day is <net>
    And I see that I should consume <remaining> more calories today
    And I see that I should burn <to_burn> more calories by exercising today

    Examples: RMR 2000
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       10500 |             0 | 1st |        0 |      0 |    0 |      2000 |     500 |
      |      2000 |       10500 |             0 | 1st |      500 |      0 |  500 |      1500 |     500 |
      |      2000 |       10500 |             0 | 1st |     2000 |      0 | 2000 |         0 |     500 |
      |      2000 |       10500 |             0 | 1st |     2001 |      0 | 2001 |         0 |     501 |

    Examples: RMR 2000 - with exercise
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       10500 |             0 | 1st |        0 |    100 | -100 |      2000 |     400 |
      |      2000 |       10500 |             0 | 1st |      500 |    100 |  400 |      1500 |     400 |
      |      2000 |       10500 |             0 | 1st |     2100 |    100 | 2000 |         0 |     500 |
      |      2000 |       10500 |             0 | 1st |     2101 |    100 | 2001 |         0 |     501 |
      |      2000 |       10500 |             0 | 1st |     2000 |    500 | 1500 |         0 |       0 |
      |      2000 |       10500 |             0 | 1st |        0 |    500 | -500 |      2000 |       0 |

    Examples: 3rd day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       10500 |          3000 | 3rd |        0 |      0 |    0 |      2000 |     500 |
      |      2000 |       10500 |          3997 | 3rd |        0 |      0 |    0 |      2000 |     699 |
      |      2000 |       10500 |          3998 | 3rd |        0 |      0 |    0 |      2000 |     700 |
      |      2000 |       10500 |          4000 | 3rd |        0 |      0 |    0 |      2000 |     700 |
      |      2000 |       10500 |          4002 | 3rd |        0 |      0 |    0 |      2000 |     700 |
      |      2000 |       10500 |          4003 | 3rd |        0 |      0 |    0 |      2000 |     701 |
      |      2000 |       10500 |          4000 | 3rd |     2000 |      0 | 2000 |         0 |     700 |
      |      2000 |       10500 |          4000 | 3rd |     2000 |    700 | 1300 |         0 |       0 |

  Scenario Outline: Gain Weight
    Given my RMR is <daily_rmr> calories per day
    And my weekly calorie goal is <weekly_goal> calories
    And I have consumed <prev_days_cal> net calories on prior days this week
    And it is the <day> day of the week
    And I have consumed <consumed> calories today
    And I have burned <burned> calories with exercise today

    When I calculate my remaining calories for the day

    Then I see that my net calorie consumption for the day is <net>
    And I see that I should consume <remaining> more calories today
    And I see that I should burn <to_burn> more calories by exercising today

    Examples: RMR 2000
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       17500 |             0 | 1st |        0 |      0 |    0 |      2500 |       0 |
      |      2000 |       17500 |             0 | 1st |      500 |      0 |  500 |      2000 |       0 |
      |      2000 |       17500 |             0 | 1st |     2500 |      0 | 2500 |         0 |       0 |
      |      2000 |       17500 |             0 | 1st |     2501 |      0 | 2501 |         0 |       1 |

    Examples: RMR 2000 - with exercise
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       17500 |             0 | 1st |        0 |    500 | -500 |      3000 |       0 |
      |      2000 |       17500 |             0 | 1st |     2500 |    500 | 2000 |       500 |       0 |
      |      2000 |       17500 |             0 | 1st |     3001 |    500 | 2501 |         0 |       1 |

    Examples: 3rd day of week
      | daily_rmr | weekly_goal | prev_days_cal | day | consumed | burned |  net | remaining | to_burn |
      |      2000 |       17500 |          4997 | 3rd |        0 |      0 |    0 |      2501 |       0 |
      |      2000 |       17500 |          5000 | 3rd |        0 |      0 |    0 |      2500 |       0 |
      |      2000 |       17500 |          5003 | 3rd |        0 |      0 |    0 |      2499 |       0 |
