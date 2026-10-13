/// Context and predefined problem categories for user problem reports.
enum ProblemArea {
  account([
    "The code didn't arrive",
    'My passcode is not accepted',
    "I can't sign in",
    'App froze',
    'Something else',
  ]),

  verification([
    "Camera won't focus",
    'Passport not recognised',
    "Chip won't scan",
    'Video keeps failing',
    'App froze',
    'Something else',
  ]),

  browsing([
    "A page won't open",
    'A price looks wrong',
    'Search found nothing',
    'App froze',
    'Something else',
  ]),

  booking([
    "I can't choose my dates",
    'No rooms are shown',
    'The price looks wrong',
    "My card won't go through",
    'App froze',
    'Something else',
  ]),

  checkIn([
    "I can't add my visa",
    "A guest can't verify",
    "Check-in won't finish",
    "My pass won't show",
    'App froze',
    'Something else',
  ]),

  anywhere([
    'My hotel is not listed',
    'The hotel has not replied',
    'The details sent were wrong',
    'App froze',
    'Something else',
  ]),

  dispute([
    "I can't add photos",
    "I can't send my description",
    'Nothing happened after I sent it',
    'App froze',
    'Something else',
  ]),

  general([
    "A page won't open",
    'Something looks wrong',
    'App froze',
    'Something else',
  ]);

  const ProblemArea(this.problems);

  final List<String> problems;

  int get somethingElseIndex => problems.length - 1;
}

/// Identifies where in the application a problem was reported from.
class ProblemReportContext {
  const ProblemReportContext({required this.area, required this.screen});

  final ProblemArea area;
  final String screen;
}
