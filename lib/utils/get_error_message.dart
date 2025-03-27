String getErrorMessage(String errorCode) {
  switch (errorCode) {
    case "invalid-credential":
      return "Your email or password is incorrect.";
    case "invalid-email":
      return "Please enter a valid email.";
    case "email-already-in-use":
      return "This email is already in use. Please login or use a different email.";
    case "too-many-requests":
      return "Too many requests. Please try again later.";
    case "weak-password":
      return "Please enter a stronger password.";
    default:
      return "An unknown error occurred. Please try again later.";
  }
}
