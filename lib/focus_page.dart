/// The top-level destinations in FocusFlow.
///
/// The shell (in `main.dart`) renders one of these pages at a time. The bottom
/// navigation exposes the four primary tabs; [FocusPage.coach] is opened from
/// the Home screen's quick actions.
enum FocusPage {
  home,
  planner,
  focus,
  profile,
  coach,
}