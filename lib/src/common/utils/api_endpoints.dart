class ApiEndpoints {
  //! AUTHENTICATION ENDPOINTS
  static const String activate = "/auth/activate";
  static const String getReferralCode = "/auth/referral-code";
  static const String getUserProfile = "/auth/profile";
  static const String login = "/auth/login";
  static const String passwordChange = "/auth/password-change";
  static const String passwordReset = "/auth/password-reset";
  static const String passwordResetRequest = "/auth/password-reset-request";
  static const String refreshToken = "/auth/refresh-token";
  static const String resendActivate = "/auth/resend-activate";
  static const String signup = "/auth/signup";
  static const String update = "/auth/update";
  static const String deleteAccount = "/auth";
  static const String validatePasswordResetToken =
      "/auth/validate-password-reset-token";

  //! PROFILE
  static const String profilePicture = '/upload/profile';
  static const String referralCode = '/auth/referral-code';

  //* YOUNG RANCHERS ENDPOINTS
  static const String course = '/young-ranchers/course';
  static const String courseEnrol = '/young-ranchers/enrollment';
  static const String courseModule = '/young-ranchers/module';
  static const String courseLesson = '/young-ranchers/activity';
  static const String courseReview = '/young-ranchers/review';
  static const String courseProgress = '/young-ranchers/progress';
  static const String courseCategory = '/young-ranchers/category';
  static const String courseLessonAnswer = '/young-ranchers/answer';
  static const String courseResource = '/young-ranchers/resource';

  //? BOATS ENDPOINTS
  static const String boat = "/user/boat";
  static const String boatBvnConfirmation = "/user/boat/bvn/confirm";
  static const String boatBvnUpload = "/user/boat/kyc/update";
  static const String boatPinUpdate = "/user/boat/pin";
  static const String boatAccountDetails = "/transactions/acc/balance";
  static const String addBeneficiary = "/beneficiary";
  //? Transfer
  static const String bankList = '/transactions/banks/list';
  static const String nameEnquiry = '/transactions/banks/name-enquiry';
  static const String interbankTransfer = '/transactions/interbank/transfer';
  static const String singleTransaction = '/transactions/single';
  static const String boatTransfer = '/transactions/transfer';
  static const String transactionHistory = '/transactions/txn-history';
  static const String validateBoatAccount = '/transactions/validate';
  static const String transactionRecheck = '/transactions/interbank-recheck';
  //? Bills
  static const String buyAirtime = '/bills/airtime';
  static const String verifyBillsAccount = '/bills/account/verify';
  static const String buyCabletv = '/bills/cabletv-recharge';
  static const String buyDataBundle = '/bills/data-bundle';
  static const String getDataBundles = '/bills/get/data-bundles';
  static const String buyElectricity = '/bills/electricity-recharge';
  static const String buyCabletvBundles = '/bills/get/cabletv-bundles';
  //? Loans
  static const String loan = '/loan';
  static const String submitInputLoan = '/loan/submitLoanApplication';
  static const String inputLoan = '/loan/input';

  //* DISCOVER ENDPOINTS
  //* Feeds
  static const String postFeeds = "/discover/posts/feed";
  static const String discoverPost = "/discover/posts";
  static const String discoverPostComment = "/discover/comments";
  static const String deleteRepostedFeedPost = "/discover/posts/reposts";

  //* Profile
  static const String discoverProfileConnectionRequest =
      "/discover/profiles/request";
  static const String discoverProfile = "/discover/profiles";
  static const String discoverProfileConnectionReceived =
      "/discover/profiles/connections/received";
  static const String discoverPersonalProfile = "/discover/profiles/personal";
  static const String discoverProfileMedia = "/discover/profiles/media";
  static const String discoverProfileCircle = "/discover/circles/my-circle";

  //* Circles
  static const String discoverCircles = "/discover/circles";

  //* People
  static const String people = "/people";
  static const String peopleFollow = "/people/follow";
  static const String peopleUnfollow = "/people/unfollow";
  //* Posts
  static const String posts = "/posts";
  static const String myPosts = "/posts/me";
  static const String userPosts = "/posts/user";
  //* Circles
  static const String circles = "/circles";
  static const String myCircles = "/circles/me";
  static const String userCircles = "/circles/user";
  //* Discover Search
  static const String discoverSearch = "/discover/search";

  //* TAO AI
  static const String taoAiStartChat = "https://chatbot.taoai.ng/api/v2/chat/";
  static const String taoAiSessions =
      "https://chatbot.taoai.ng/api/v2/chat/sessions/";
  static const String taoAiContinueChat =
      "https://chatbot.taoai.ng/api/v2/chat/sessions/";
  static const String taoAiChatHistory =
      "https://chatbot.taoai.ng/api/v2/chat/sessions/";

  //? TELAGRI ENDPOINTS
  static const String telagri = "/user/telagri";
  //? Onboarding
  static const String farms = "/farms";
  static const String choice = "/choices";
  static const String choiceSearch = "/choices/search";
  //? Warehouse
  static const String warehouseEquipment = "/warehouse/equipment";
  static const String warehouseInputs = "/warehouse/inputs";
  static const String warehouseProduce = "/warehouse/produce";
  //? Finance
  static const String farmsFinance = "/farms/finances";
  //? Monitoring and Evaluation
  static const String farmsWeeksCycle = "/farms/weeks/cycles";
  static const String farmsWeeksDetail = "/farms/weeks";
  static const String farmsSubmitAnswers = "/farms/weeks/submit-answers";

  //? Dashboard

  //? Evaluation and Monitoring

  //! FARM TINDER
  static const String categoryProducts = "/products/category";
  static const String ordersCart = "/orders/cart";
  static const String orderCheckout = "/orders/checkout";
  static const String productCategories = "/orders/get-categories";
  static const String marketCategories = "/marketplace/categories";
  static const String marketProducts = "/marketplace/products";
  static const String featuredProducts = "/marketplace/products/featured";
  static const String bundlesProducts = "/marketplace/products/bundles";
  static const String hotProducts = "/marketplace/products/hot";
  static const String flashProducts = "/marketplace/products/flash";

  //! FARM TINDER TO CART
  static const String addToCart = "/marketplace/cart";
  static const String removeFromCart = "/marketplace/cart/product";

  //!CART ITEM QUANTITY
  static const String cartItemDecrement = "/marketplace/cart/product/decrement";
  static const String cartItemIncrement = "/marketplace/cart/product/increment";

  //! FARM TINDER TO CHECKOUT
  static const String checkout = "/marketplace/cart/checkout";

  //! SEARCH PRODUCT
  static const String searchProduct = "/marketplace/product/search";

  //! UPLOAD
  static const String upload = "/upload";

  //! create paymnet
  static const String createPayment = "/marketplace/orders/pay";

  //! Orders
  static const String customerOrders = "/marketplace/orders/customer";

  //! Search
  static const String searchProducts = "/marketplace/products/search";

  //! JUNCTION ENDPOINTS
  // *Posts
  static const String junctionPosts = "/junction/posts/";
  static const String junctionPostsTags = "/junction/posts/tags/";
  static const String junctionPostsToday = "/junction/posts/today";

  // *Media
  static const String junctionMediaVideo = "/junction/media/videos";

  // *Categories
  static const String junctionPostsCategory = "/junction/categories/";
  static const String junctionCategoryAndPosts = "/junction/categories/posts";
  static const String junctionExplorePosts =
      "/junction/categories/posts/explore";

  // *Comments
  static const String junctionComments = "/junction/posts/";

  // *Saved-Posts
  static const String junctionSavedPosts = "/junction/saved-posts";
}
