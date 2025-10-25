import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/component/logo.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/textformfield.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool isLoading = false;
  Crud crud = Crud();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  signIn() async {
    final l10n = AppLocalizations.of(context);

    if (emailController.text.isEmpty || passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            l10n.pleaseFillAllFields,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response = await crud.postRequest(AppLink.login, {
      "userEmail": emailController.text,
      "userPass": passController.text,
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      String userId = response['data']['user_id'].toString();

      // Save user data
      sharedPref.setString("user_id", userId);
      sharedPref.setString("user_email", response['data']['user_email']);
      sharedPref.setString("user_pass", response['data']['user_pass']);

      // Set user-specific preferences
      LanguageManager.setCurrentUser(userId);
      ThemeManager.setCurrentUser(userId);

      // Update app with user's saved preferences
      MyApp.of(context)?.changeLanguage(LanguageManager.getCurrentLanguageCode());
      MyApp.of(context)?.changeTheme(ThemeManager.getThemeMode());

      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.loginFailed,
            style: TextStyle(color: AppColor.warningColor),
          ),
          backgroundColor: AppColor.backgroundcolor2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 50),
            Logo(),
            SizedBox(height: 30),
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              l10n.loginToContinue,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
              l10n.email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: l10n.email,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Text(
              l10n.password,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: l10n.password,
              controller: passController,
              obscureText: true,
              isPassword: true,
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () {
                if (emailController.text == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColor.backgroundcolor2,
                      content: Text(
                        l10n.pleaseFillAllFields,
                        style: TextStyle(color: AppColor.warningColor),
                      ),
                    ),
                  );
                  return;
                }
                // Add forgot password functionality here
              },
              child: Container(
                alignment: TextDirection.ltr == Directionality.of(context)
                    ? Alignment.topRight
                    : Alignment.topLeft,
                child: Text(
                  l10n.forgotPassword,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Button(
              title: l10n.login,
              isLoading: isLoading,
              onpressed: signIn,
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                l10n.orLoginWith,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 20),
            // Row(
            //   children: [
            //     Expanded(
            //       child: InkWell(
            //         onTap: () {},
            //         child: Container(
            //           height: 50,
            //           decoration: BoxDecoration(
            //             color: Colors.blue[50],
            //             borderRadius: BorderRadius.circular(12),
            //             border: Border.all(color: Colors.blue[200]!),
            //           ),
            //           child: Icon(Icons.facebook, color: Colors.blue, size: 30),
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 10),
            //     Expanded(
            //       child: InkWell(
            //         onTap: () {},
            //         child: Container(
            //           height: 50,
            //           decoration: BoxDecoration(
            //             color: Colors.red[50],
            //             borderRadius: BorderRadius.circular(12),
            //             border: Border.all(color: Colors.red[200]!),
            //           ),
            //           child: Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 10),
            //     Expanded(
            //       child: InkWell(
            //         onTap: () {},
            //         child: Container(
            //           height: 50,
            //           decoration: BoxDecoration(
            //             color: Colors.grey[100],
            //             borderRadius: BorderRadius.circular(12),
            //             border: Border.all(color: Colors.grey[300]!),
            //           ),
            //           child: Icon(Icons.apple, color: Colors.black, size: 30),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.dontHaveAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("/register");
                  },
                  child: Text(
                    " ${l10n.register}",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
            Center(child: Text.rich(TextSpan(children:[
              TextSpan(text: "Don't Have an Account?",style: TextStyle(fontSize:14)),
              TextSpan(text: " Register",style: TextStyle(fontSize: 16,color: Colors.blue)),
          ]
            )
        ),
      ),
*/