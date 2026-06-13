class FollowRefreshProgress {
  final bool active;
  final String stage;
  final int current;
  final int total;
  final bool automatic;
  final String scopeKey;
  final bool completed;
  final bool background;

  const FollowRefreshProgress({
    this.active = false,
    this.stage = "",
    this.current = 0,
    this.total = 0,
    this.automatic = false,
    this.scopeKey = "",
    this.completed = false,
    this.background = false,
  });

  const FollowRefreshProgress.idle() : this();

  double get percent {
    if (total <= 0) {
      return 0;
    }
    return (current / total).clamp(0, 1).toDouble();
  }

  String get displayText {
    if (total > 0) {
      return "$stage $current/$total";
    }
    return stage;
  }

  FollowRefreshProgress copyWith({
    bool? active,
    String? stage,
    int? current,
    int? total,
    bool? automatic,
    String? scopeKey,
    bool? completed,
    bool? background,
  }) {
    return FollowRefreshProgress(
      active: active ?? this.active,
      stage: stage ?? this.stage,
      current: current ?? this.current,
      total: total ?? this.total,
      automatic: automatic ?? this.automatic,
      scopeKey: scopeKey ?? this.scopeKey,
      completed: completed ?? this.completed,
      background: background ?? this.background,
    );
  }
}
