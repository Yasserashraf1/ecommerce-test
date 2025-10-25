import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/core/constant/linkapi.dart';
import '../component/button.dart';
import '../component/crud.dart';
import '../component/logo.dart';
import '../component/textformfield.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  Crud _crud = Crud();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    confirmController.dispose();
  }

  signUp() async {
    final l10n = AppLocalizations.of(context);

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passController.text.isEmpty ||
        confirmController.text.isEmpty) {
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

    if (passController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            l10n.passwordsDoNotMatch,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response = await _crud.postRequest(AppLink.signUp, {
      "userName": nameController.text,
      "userEmail": emailController.text,
      "userPass": passController.text,
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationSuccessful),
          backgroundColor: AppColor.backgroundcolor,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.registrationFailed,
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
              l10n.createAccount,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              l10n.enterInformation,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
              l10n.userName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: l10n.enterFullName,
              controller: nameController,
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            Text(
              l10n.confirmPassword,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: l10n.confirmPassword,
              controller: confirmController,
              obscureText: true,
              isPassword: true,
            ),
            SizedBox(height: 30),
            Button(
              title: l10n.register,
              isLoading: isLoading,
              onpressed: signUp,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.haveAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(" "),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: Text(
                    l10n.login,
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