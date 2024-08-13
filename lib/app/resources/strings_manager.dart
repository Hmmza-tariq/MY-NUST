class StringsManager {
  static const String appName = "Green Eats";
  static const String getStarted = "Get Started";
  static const String email = "Email";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";
  static const String enterEmail = "Enter your email";
  static const String reEnterEmail = "Re-Enter your email";
  static const String enterPassword = "Enter your password";
  static const String login = "Login";
  static const String signIn = "Sign In";
  static const String signOut = "Sign out";
  static const String signUp = "Sign Up";
  static const String signUpTitle = "Sign With Us";
  static const String forgetPassword = "Forgot Password?";
  static const String forgetPassSub =
      "Please enter your email and we will send\n you a link to reset your password";
  static const String resetPassword = "Reset Password";
  static const String createAccount = "Create an account?";
  static const String createAccountSub =
      "Please enter your details or sign up\n with your social media account";
  static const String welcome = "Welcome\nBack";
  static const String otpVerification = "OTP Verification";
  static const String otpVerificationSub =
      "We sent your code to +92 3** *******";
  static const String skip = "Skip";
  static const String show = "Show";
  static const String hide = "Hide";
  static const String address = "Address";
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String phoneNumber = "Phone Number";
  static const String enterAddress = "Enter your Address";
  static const String enterFirstName = "Enter your First Name";
  static const String enterLastName = "Enter your Last Name";
  static const String enterPhoneNumber =
      "Enter your Phone Number as 03xxxxxxxxx";
  static const String completeProfile = "Complete Your Profile";
  static const String completeInfo = "Please complete your information";
  static const String kContinue = "Continue";
  static const String kAcceptTerms =
      "By continue you are confirm that you agree\n with our terms and conditions";
  static const String kEmailNullError = "Please Enter your email";
  static const String kInvalidEmailError = "Please Enter a valid email";
  static const String kPasswordNullError = "Please Enter your password";
  static const String kShortPasswordError = "Password is too short";
  static const String kPasswordMatchError = "Passwords don't match";
  static const String kFirstNameNullError = "Please Enter your first name";
  static const String kLastNameNullError = "Please Enter your last name";
  static const String kPhoneNumberNullError = "Please Enter your phone number";
  static const String kValidPhoneNumberError =
      "Please Enter a valid phone number";
  static const String kValidValueError = "Please Enter a valid value";

  static const String kAddressNullError = "Please Enter your address";
  static const String kEmailAlreadyExits =
      "The email is already existed please try with another one";
  static const String google = "Google";
  static const String facebook = "Facebook";
  static const String apple = "Apple";
  static const String or = "OR";
  static const String noInternet = "No Internet Connection";
  static const String noInternetSub =
      "Your internet connection is currently not available please check it or try again.";
  static const String tryAgain = "Try Again";
  static const String location = "My Location";
  static const String addToCart = "Add to cart";
  static const String cart = "Cart";
  static const String addedToCart = "Added to Cart";
  static const String addedToFavourite = "Added to Favourite";
  static const String allCatagories = "All Catagories";
  static const String touchToGoBack = 'Tap to Go \nBack';
  static const String visible = "visible";
  static const String favourite = "Favourite";
  static const String noItemFound = "No Item Found";
  static const String startShopping = "Start Shopping";
  static const String name = "Hexagone";
  static const String freeDelivery =
      "FREE DELIVERY is available until the end of this month";
  static const String total = "Total";
  static const String checkout = "Check Out";
  static const String quantity = "Quantity";
}

final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z]+\.[a-zA-Z]+");
RegExp phoneNumberValidatorRegExp = RegExp(r"(^(?:[+0]9)?[0-9]{11}$)");
