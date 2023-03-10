import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Utils/snackbar_utils.dart';
import 'package:task_app/providers/app_providers.dart';
import 'package:task_app/screens/main_screen.dart';
import 'package:task_app/services/auth_services.dart';
import 'package:task_app/services/keys.dart';
import 'package:task_app/styles.dart';

import '../services/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // int signStatus = 0;
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passController;
  late TextEditingController _passConfirmController;
  bool visibility = true;
  bool visibility2 = true;
  int signPage = 0;
  PackageInfo? packageInfo;

  // final signUpFormKey = GlobalKey<FormState>();
  // final signInFormKey = GlobalKey<FormState>();

  Future<void> googleSignIn(BuildContext context) async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    await provider.googleLogin();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    StorageServices.setUID(user.uid);
    StorageServices.setUserName(user.displayName!);
    StorageServices.setUserEmail(user.email!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  void getAppDetails() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _passController = TextEditingController();
    _passConfirmController = TextEditingController();
    getAppDetails();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passConfirmController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
    );
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.backgroundColour,
          secondary: AppColors.backgroundColour.withOpacity(0.5),
        ),
      ),
      home: Scaffold(
        backgroundColor: AppColors.backgroundColour,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                child: Image.asset(
                  "assets/auth-bg-pic.jpg",
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: (signPage == 0) ? size.height * 1.1 : size.height,
                ),
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: (signPage == 0) ? size.height * 1.1 : size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.white,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Consumer<AllAppProviders>(
                  builder: (allAppProvidersContext, allAppProvidersProvider,
                      allAppProvidersChild) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height / 20,
                        ),
                        Lottie.asset(
                          "assets/login-animation.json",
                          width: 200,
                          height: 200,
                        ),
                        GlassmorphicContainer(
                          width: size.width,
                          height: (signPage == 0)
                              ? size.height / 1.35
                              : size.height / 2,
                          borderRadius: 15,
                          linearGradient:
                              AppColors.customGlassIconButtonGradient,
                          border: 2,
                          blur: 4,
                          borderGradient:
                              AppColors.customGlassIconButtonBorderGradient,
                          child: Column(
                            children: [
                              //SIGN UP
                              if (signPage == 0)
                                AuthNameTextField(
                                  icon: Icons.person,
                                  controller: _firstNameController,
                                  hintText: "Your First Name",
                                ),
                              if (signPage == 0)
                                AuthNameTextField(
                                  icon: Icons.badge_outlined,
                                  controller: _lastNameController,
                                  hintText: "Your Last Name",
                                ),
                              if (signPage == 0)
                                AuthTextField(
                                    icon: Icons.email_outlined,
                                    controller: _emailController,
                                    hintText: "Email",
                                    keyboard: TextInputType.emailAddress,
                                    isPassField: false,
                                    isPassConfirmField: false,
                                    isEmailField: true,
                                    pageIndex: signPage),
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.security_outlined,
                                  controller: _passController,
                                  hintText: "Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isPassConfirmField: false,
                                  isEmailField: false,
                                  pageIndex: signPage,
                                ),
                              if (signPage == 0)
                                AuthTextField(
                                  icon: Icons.shield_outlined,
                                  controller: _passConfirmController,
                                  hintText: "Confirm Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: false,
                                  isPassConfirmField: true,
                                  isEmailField: false,
                                  pageIndex: signPage,
                                ),
                              if (signPage == 0)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  child: (allAppProvidersProvider.isLoading)
                                      ? Container(
                                          height: 50,
                                          width: size.width / 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.blackLow
                                                    .withOpacity(0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Lottie.asset(
                                              "assets/loading-animation.json",
                                              width: 100,
                                              height: 50,
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: (() async {
                                            // print(packageInfo!.version);
                                            allAppProvidersProvider
                                                .isLoadingFunc(true);

                                            if (_emailController
                                                    .text.isNotEmpty &&
                                                _passController
                                                    .text.isNotEmpty &&
                                                _passConfirmController
                                                    .text.isNotEmpty &&
                                                _firstNameController
                                                    .text.isNotEmpty &&
                                                _lastNameController
                                                    .text.isNotEmpty &&
                                                _firstNameController.text
                                                        .trim() !=
                                                    _lastNameController.text
                                                        .trim() &&
                                                EmailValidator.validate(
                                                    _emailController.text
                                                        .trim())) {
                                              if (_passController.text ==
                                                  _passConfirmController.text) {
                                                // allAppProvidersProvider
                                                //     .isLoadingFunc(true);
                                                http.Response response =
                                                    await http.post(
                                                  Uri.parse(
                                                      "${Keys.apiUsersBaseUrl}/create"),
                                                  headers: {
                                                    "content-type":
                                                        "application/json",
                                                  },
                                                  body: jsonEncode({
                                                    "usrFirstName":
                                                        _firstNameController
                                                            .text
                                                            .trim(),
                                                    "usrLastName":
                                                        _lastNameController.text
                                                            .trim(),
                                                    "usrPassword":
                                                        _passController.text
                                                            .trim(),
                                                    "usrEmail": _emailController
                                                        .text
                                                        .trim(),
                                                    "uid": _emailController.text
                                                        .trim()
                                                        .split('@')[0],
                                                  }),
                                                );

                                                if (response.statusCode ==
                                                    200) {
                                                  log(response.body.toString());
                                                  StorageServices.setSignInType(
                                                      Keys.email);

                                                  Map<String, dynamic>
                                                      responseJson =
                                                      jsonDecode(response.body);

                                                  if (responseJson["success"]) {
                                                    StorageServices.setUserName(
                                                        "${responseJson[Keys.data][Keys.usrFirstName]}${responseJson[Keys.data][Keys.usrLastName]}");
                                                    StorageServices.setUID(
                                                        responseJson[Keys.data]
                                                            [Keys.uid]);
                                                    StorageServices
                                                        .setUserEmail(
                                                            responseJson[
                                                                    Keys.data][
                                                                Keys.usrEmail]);
                                                    StorageServices.setUsrToken(
                                                        responseJson[
                                                            Keys.token]);

                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            Keys.message],
                                                        context: context,
                                                      ),
                                                    );
                                                    String signInType =
                                                        await StorageServices
                                                            .getUserSignInType();

                                                    if (signInType ==
                                                        Keys.email) {
                                                      _emailController.clear();
                                                      _passController.clear();
                                                      _firstNameController
                                                          .clear();
                                                      _lastNameController
                                                          .clear();
                                                      _passConfirmController
                                                          .clear();
                                                      setState(() {
                                                        signPage = 1;
                                                      });
                                                    }
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            allAppProvidersContext)
                                                        .showSnackBar(
                                                      AppSnackbar()
                                                          .customizedAppSnackbar(
                                                        message: responseJson[
                                                            Keys.message],
                                                        context:
                                                            allAppProvidersContext,
                                                      ),
                                                    );
                                                    allAppProvidersProvider
                                                        .isLoadingFunc(false);
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message:
                                                          "Something went wrong",
                                                      context:
                                                          allAppProvidersContext,
                                                    ),
                                                  );
                                                  allAppProvidersProvider
                                                      .isLoadingFunc(false);
                                                }
                                              } else {
                                                allAppProvidersProvider
                                                    .isLoadingFunc(false);
                                                ScaffoldMessenger.of(
                                                        allAppProvidersContext)
                                                    .showSnackBar(
                                                  AppSnackbar()
                                                      .customizedAppSnackbar(
                                                    message:
                                                        "Please check the password fields",
                                                    context: context,
                                                  ),
                                                );
                                              }
                                            } else {
                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Please fill the fields properly",
                                                  context: context,
                                                ),
                                              );
                                            }
                                          }),
                                          child: Container(
                                            height: 50,
                                            width: size.width / 2,
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.blackLow
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Sign Up",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .backgroundColour,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),

                              //SIGN IN
                              if (signPage == 1)
                                AuthTextField(
                                  icon: Icons.email_outlined,
                                  controller: _emailController,
                                  hintText: "example@gmail.com",
                                  keyboard: TextInputType.emailAddress,
                                  isPassField: false,
                                  isPassConfirmField: false,
                                  isEmailField: true,
                                  pageIndex: signPage,
                                  // formKey: signInFormKey,
                                ),
                              if (signPage == 1)
                                AuthTextField(
                                  icon: Icons.security_outlined,
                                  controller: _passController,
                                  hintText: "Password",
                                  keyboard: TextInputType.visiblePassword,
                                  isPassField: true,
                                  isPassConfirmField: false,
                                  isEmailField: false,
                                  pageIndex: signPage,
                                  // formKey: signInFormKey,
                                ),
                              if (signPage == 1)
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: (() async {
                                        if (_emailController.text.isNotEmpty) {
                                          allAppProvidersProvider
                                              .isLoadingFunc(true);
                                          // EmailPassAuthServices()
                                          //     .forgotPassword(
                                          //   email: _emailController.text.trim(),
                                          //   context: allAppProvidersContext,
                                          // );

                                          http.Response response =
                                              await http.get(
                                            Uri.parse(
                                              "${Keys.apiUsersBaseUrl}/forgotPass/${_emailController.text.trim()}",
                                            ),
                                            headers: {
                                              "content-type":
                                                  "application/json",
                                            },
                                          );

                                          if (response.statusCode == 200) {
                                            Map<String, dynamic> responseJson =
                                                jsonDecode(response.body);
                                            log(responseJson.toString());
                                            // if (responseJson["success"]) {
                                            //   String decryptedPass = "";
                                            //   final key =
                                            //       encrypt_package.Key.fromUtf8(
                                            //           'qwe1234');
                                            //   final iv = encrypt_package.IV
                                            //       .fromLength(10);
                                            //   final encryptor =
                                            //       encrypt_package.Encrypter(
                                            //           encrypt_package.AES(key));
                                            //
                                            //   final encrypted =
                                            //       encryptor.encrypt(
                                            //     responseJson[Keys.data]
                                            //         ["usrPassword"],
                                            //     iv: iv,
                                            //   );
                                            //
                                            //   // Convert the decrypted password from bytes to a string
                                            //   final decrypted = encryptor
                                            //       .decrypt(encrypted, iv: iv);
                                            //   log("Decoded pass : $decrypted");
                                            // }
                                          }

                                          allAppProvidersProvider
                                              .isLoadingFunc(false);
                                        } else {
                                          allAppProvidersProvider
                                              .isLoadingFunc(false);
                                          ScaffoldMessenger.of(
                                                  allAppProvidersContext)
                                              .showSnackBar(
                                            AppSnackbar().customizedAppSnackbar(
                                              message:
                                                  "Please give your registered email",
                                              context: allAppProvidersContext,
                                            ),
                                          );
                                        }
                                      }),
                                      child: const Text(
                                        "Forgot Password",
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (signPage == 1)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  child: (allAppProvidersProvider.isLoading)
                                      ? Container(
                                          height: 50,
                                          width: size.width / 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.blackLow
                                                    .withOpacity(0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Lottie.asset(
                                              "assets/loading-animation.json",
                                              width: 100,
                                              height: 50,
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: (() async {
                                            allAppProvidersProvider
                                                .isLoadingFunc(true);
                                            const CircularProgressIndicator(
                                              backgroundColor:
                                                  AppColors.backgroundColour,
                                            );
                                            if (_emailController
                                                    .text.isNotEmpty &&
                                                _passController
                                                    .text.isNotEmpty) {
                                              // EmailPassAuthServices()
                                              //     .emailPassSignIn(
                                              //   email: _emailController.text
                                              //       .trim(),
                                              //   pass:
                                              //       _passController.text.trim(),
                                              //   context: allAppProvidersContext,
                                              // );

                                              String token =
                                                  await StorageServices
                                                      .getToken();

                                              http.Response response =
                                                  await http.post(
                                                Uri.parse(
                                                    "${Keys.apiUsersBaseUrl}/login"),
                                                headers: {
                                                  "content-type":
                                                      "application/json",
                                                  'Authorization':
                                                      'Bearer $token',
                                                },
                                                body: jsonEncode({
                                                  "usrPassword": _passController
                                                      .text
                                                      .trim(),
                                                  "usrEmail": _emailController
                                                      .text
                                                      .trim(),
                                                }),
                                              );

                                              if (response.statusCode == 200) {
                                                Map<String, dynamic>
                                                    responseJson =
                                                    jsonDecode(response.body);
                                                log(responseJson.toString());

                                                if (responseJson["success"]) {
                                                  StorageServices.setSignStatus(
                                                      true);
                                                  StorageServices.setUserEmail(
                                                      responseJson[Keys.data]
                                                          [Keys.usrEmail]);
                                                  StorageServices.setUserName(
                                                      "${responseJson[Keys.data][Keys.usrFirstName]}${responseJson[Keys.data][Keys.usrLastName]}");
                                                  StorageServices.setUID(
                                                      responseJson[Keys.data]
                                                          [Keys.uid]);
                                                  StorageServices.setSignInType(
                                                      "Email");

                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message: responseJson[
                                                          Keys.message],
                                                      context:
                                                          allAppProvidersContext,
                                                    ),
                                                  );

                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (nextPageContext) =>
                                                              const MainScreen(),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                          allAppProvidersContext)
                                                      .showSnackBar(
                                                    AppSnackbar()
                                                        .customizedAppSnackbar(
                                                      message: responseJson[
                                                          "message"],
                                                      context:
                                                          allAppProvidersContext,
                                                    ),
                                                  );
                                                }
                                              }
                                            } else {
                                              allAppProvidersProvider
                                                  .isLoadingFunc(false);
                                              ScaffoldMessenger.of(
                                                      allAppProvidersContext)
                                                  .showSnackBar(
                                                AppSnackbar()
                                                    .customizedAppSnackbar(
                                                  message:
                                                      "Please fill the fields correctly",
                                                  context:
                                                      allAppProvidersContext,
                                                ),
                                              );
                                            }
                                            allAppProvidersProvider
                                                .isLoadingFunc(false);
                                          }),
                                          child: Container(
                                            height: 50,
                                            width: size.width / 2,
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.blackLow
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Login",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .backgroundColour,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              // const Center(
                              //   child: Text(
                              //     "or",
                              //     style: TextStyle(
                              //       color: AppColors.white,
                              //       fontSize: 15,
                              //     ),
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     top: 10,
                              //     bottom: 10,
                              //     left: 20,
                              //     right: 20,
                              //   ),
                              //   child: Column(
                              //     crossAxisAlignment:
                              //         CrossAxisAlignment.stretch,
                              //     children: [
                              //       Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         children: [
                              //           CompanyAuth(
                              //             logo: "assets/google-logo.png",
                              //             onTap: (() async {
                              //               allAppProvidersProvider
                              //                   .isLoadingFunc(true);
                              //               const CircularProgressIndicator(
                              //                 color: AppColors.backgroundColour,
                              //               );
                              //               await googleSignIn(context);
                              //               allAppProvidersProvider
                              //                   .isLoadingFunc(false);
                              //             }),
                              //           ),
                              //           SizedBox(
                              //             width: size.width / 10,
                              //           ),
                              //           CompanyAuth(
                              //             logo: "assets/apple-logo.png",
                              //             onTap: (() {
                              //               if (!Platform.isIOS ||
                              //                   !Platform.isMacOS) {
                              //                 ScaffoldMessenger.of(
                              //                         allAppProvidersContext)
                              //                     .showSnackBar(
                              //                   AppSnackbar()
                              //                       .customizedAppSnackbar(
                              //                     message:
                              //                         "Your device is not a iOS or macOS device",
                              //                     context:
                              //                         allAppProvidersContext,
                              //                   ),
                              //                 );
                              //               }
                              //             }),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              if (signPage == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        color:
                                            AppColors.blackLow.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() {
                                        setState(() {
                                          signPage = 1;
                                        });
                                        allAppProvidersProvider
                                            .isLoadingFunc(false);
                                        _emailController.clear();
                                        _passController.clear();
                                        _firstNameController.clear();
                                        _lastNameController.clear();
                                        _passConfirmController.clear();
                                      }),
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (signPage == 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have any account?",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() {
                                        setState(() {
                                          signPage = 0;
                                        });
                                        allAppProvidersProvider
                                            .isLoadingFunc(false);
                                        _emailController.clear();
                                        _passController.clear();
                                      }),
                                      child: const Text(
                                        "SignUp",
                                        style: TextStyle(
                                          color: AppColors.backgroundColour,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboard,
    required this.isPassField,
    required this.isEmailField,
    required this.isPassConfirmField,
    required this.icon,
    required this.pageIndex,
    // required this.formKey,
  });
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboard;
  final bool isPassField, isPassConfirmField, isEmailField;
  final IconData icon;
  final int pageIndex;
  // GlobalKey<FormState> formKey;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool passVisibility = true;
  bool passConfirmVisibility = true;

  String? _validate(String? input) {
    if (input != null && input.isNotEmpty) {
      if (widget.isEmailField) {
        if (!EmailValidator.validate(input)) {
          return "Enter a valid email";
        } else {
          return null;
        }
      }
      if (widget.isPassField) {
        if (input.length < 8) {
          return "Password should contain minimum 8 characters";
        }
        if (!RegExp(r'^(?=.*[A-Z])\w+').hasMatch(input)) {
          return "Password should contain minimum 1 Uppercase character";
        }
        if (!RegExp(r'^(?=.*[a-z])\w+').hasMatch(input)) {
          return "Password should contain minimum 1 Lowercase character";
        }
        if (!RegExp(r'^(?=.*[0-9])\w+').hasMatch(input)) {
          return "Password should contain minimum 1 numeric";
        }
        if (!RegExp(r'^(?=.*[@#???_&-+()/*:;!?~`|$^=.,])\w+').hasMatch(input)) {
          return "Password should contain minimum 1 special character";
        }
      }
      return null;
    }
    return "This is a required field";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      child: TextFormField(
        toolbarOptions: (widget.isPassField || widget.isPassConfirmField)
            ? const ToolbarOptions(selectAll: true)
            : const ToolbarOptions(
                selectAll: true,
                copy: true,
                cut: true,
                paste: true,
              ),
        decoration: InputDecoration(
          errorStyle: const TextStyle(
            overflow: TextOverflow.clip,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: AppColors.white,
          ),
          prefixStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.white.withOpacity(0.5),
          ),
          suffixIcon: (widget.isPassField || widget.isPassConfirmField)
              ? IconButton(
                  icon: (widget.isPassField)
                      ? passVisibility
                          ? const Icon(
                              Icons.visibility,
                              color: AppColors.white,
                            )
                          : const Icon(
                              Icons.visibility_off,
                              color: AppColors.white,
                            )
                      : passConfirmVisibility
                          ? const Icon(
                              Icons.visibility,
                              color: AppColors.white,
                            )
                          : const Icon(
                              Icons.visibility_off,
                              color: AppColors.white,
                            ),
                  onPressed: (() {
                    if (widget.isPassField) {
                      setState(() {
                        passVisibility = !passVisibility;
                      });
                    }
                    if (widget.isPassConfirmField) {
                      setState(() {
                        passConfirmVisibility = !passConfirmVisibility;
                      });
                    }
                  }),
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
        ),
        validator: _validate,
        // (widget.isEmailField && widget.controller.text.isNotEmpty)
        //     ? (email) => (email != null && !EmailValidator.validate(email))
        //         ? "Enter a valid email"
        //         : null
        //     : (widget.isPassField && widget.controller.text.isNotEmpty)
        //         ? ((password) {
        //             if (password != null) {
        //               if (password.length < 8) {
        //                 return "Password should contain minimum 8 characters";
        //               }
        //               if (!RegExp(r'^(?=.*[A-Z])\w+').hasMatch(password)) {
        //                 return "Password should contain minimum 1 Uppercase character";
        //               }
        //               if (!RegExp(r'^(?=.*[a-z])\w+').hasMatch(password)) {
        //                 return "Password should contain minimum 1 Lowercase character";
        //               }
        //               if (!RegExp(r'^(?=.*[0-9])\w+').hasMatch(password)) {
        //                 return "Password should contain minimum 1 numeric";
        //               }
        //               if (!RegExp(r'^(?=.*[@#???_&-+()/*:;!?~`|$^=.,])\w+')
        //                   .hasMatch(password)) {
        //                 return "Password should contain minimum 1 special character";
        //               }
        //             }
        //             return null;
        //           })
        //         : null

        autovalidateMode: (widget.isEmailField || widget.isPassField)
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        controller: widget.controller,
        keyboardType: widget.keyboard,
        cursorColor: AppColors.white,
        style: const TextStyle(
          color: AppColors.white,
        ),
        obscureText: (widget.isPassField)
            ? passVisibility
            : (widget.isPassConfirmField)
                ? passConfirmVisibility
                : false,
      ),
    );
  }
}

class AuthNameTextField extends StatefulWidget {
  const AuthNameTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    // required this.formKey,
  });
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  @override
  State<AuthNameTextField> createState() => _AuthNameTextFieldState();
}

class _AuthNameTextFieldState extends State<AuthNameTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            color: AppColors.white,
          ),
          prefixStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.white.withOpacity(0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: AppColors.white,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
        ),
        controller: widget.controller,
        keyboardType: TextInputType.name,
        cursorColor: AppColors.white,
        style: const TextStyle(
          color: AppColors.white,
        ),
      ),
    );
  }
}

class CompanyAuth extends StatelessWidget {
  const CompanyAuth({
    super.key,
    required this.logo,
    required this.onTap,
  });

  final String logo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          image: DecorationImage(
            scale: 1.5,
            image: AssetImage(
              logo,
            ),
          ),
        ),
      ),
    );
  }
}
