/// The result of a single `verify()` call.
///
/// Does not reveal the correct zone for every error on the first attempt.
/// [isComplete] is true when [incorrectIds] is empty.
class ClassificationVerificationResult {
  final Set<int> correctIds;
  final Set<int> incorrectIds;
  final bool isComplete;

  const ClassificationVerificationResult({
    required this.correctIds,
    required this.incorrectIds,
    required this.isComplete,
  });
}
