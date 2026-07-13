package com.example.journal_trend_analyzer;

import androidx.test.rule.ActivityTestRule;
import pl.leancode.patrol.PatrolTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(PatrolTestRunner.class)
public class MainActivityTest {
    @Rule
    public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class, true, false);
}
